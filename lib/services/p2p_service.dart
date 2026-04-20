import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user_model.dart';
import '../models/peer_profile.dart';

typedef OnPeerDiscovered = void Function(PeerProfile peer);
typedef OnPeerLost = void Function(String endpointId);
typedef OnMessageReceived = void Function(String fromPrn, String message);
typedef OnMatchConfirmed = void Function(String endpointId);

class P2PService {
  static final P2PService _instance = P2PService._();
  factory P2PService() => _instance;
  P2PService._();

  static const _serviceId = 'vitality_node';

  final _nearby = Nearby();

  final Map<String, String> _endpointToPrn = {};
  final Set<String> _connectedEndpoints = {};

  final StreamController<PeerProfile> _discoveredCtrl = StreamController.broadcast();
  final StreamController<String> _lostCtrl = StreamController.broadcast();
  final StreamController<MapEntry<String, String>> _msgCtrl = StreamController.broadcast();

  Stream<PeerProfile> get discoveredPeers$ => _discoveredCtrl.stream;
  Stream<String> get lostPeers$ => _lostCtrl.stream;
  Stream<MapEntry<String, String>> get incomingMessages$ => _msgCtrl.stream;

  UserModel? _localUser;

  bool _active = false;

  static List<String> computeIntersection(List<String> a, List<String> b) {
    final setB = b.map((e) => e.toLowerCase()).toSet();
    return a.where((e) => setB.contains(e.toLowerCase())).toList();
  }

  bool _psiMatch(UserModel local, PeerProfile peer) {
    final tagOverlap = computeIntersection(local.tags, peer.tags);
    if (tagOverlap.isNotEmpty) return true;
    final genderMatch = local.prefGender == 'Any' || local.prefGender == peer.gender;
    final reverseGenderMatch = peer.prefGender == 'Any' || peer.prefGender == local.gender;
    final yearMatch = local.prefYear == 'Any' || local.prefYear == peer.year;
    final reverseYearMatch = peer.prefYear == 'Any' || peer.prefYear == local.year;
    return genderMatch && reverseGenderMatch && yearMatch && reverseYearMatch;
  }

  Future<bool> _hasPermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final loc = await Permission.locationWhenInUse.status;
      final bt = await Permission.bluetooth.status;
      return loc.isGranted && bt != PermissionStatus.permanentlyDenied;
    } catch (_) {
      return false;
    }
  }

  Future<void> start(UserModel user) async {
    _localUser = user;
    if (_active) return;
    _active = true;
    if (!await _hasPermissions()) {
      debugPrint('[P2P] Permissions not granted — P2P disabled.');
      _active = false;
      return;
    }
    await _startAdvertising();
    await _startDiscovery();
  }

  Future<void> _startAdvertising() async {
    try {
      await _nearby.startAdvertising(
        _localUser!.prn,
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: _serviceId,
      );
    } catch (e) {
      debugPrint('[P2P] Advertise error: $e');
    }
  }

  Future<void> _startDiscovery() async {
    try {
      await _nearby.startDiscovery(
        _localUser!.prn,
        Strategy.P2P_CLUSTER,
        onEndpointFound: (id, name, serviceId) async {
          try {
            await _nearby.requestConnection(
              _localUser!.prn,
              id,
              onConnectionInitiated: _onConnectionInitiated,
              onConnectionResult: _onConnectionResult,
              onDisconnected: _onDisconnected,
            );
          } catch (e) {
            debugPrint('[P2P] Request conn error: $e');
          }
        },
        onEndpointLost: (id) {
          if (id != null) {
            _connectedEndpoints.remove(id);
            _lostCtrl.add(id);
          }
        },
        serviceId: _serviceId,
      );
    } catch (e) {
      debugPrint('[P2P] Discovery error: $e');
    }
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    _nearby.acceptConnection(
      id,
      onPayLoadRecieved: _onPayloadReceived,
      onPayloadTransferUpdate: (_, __) {},
    );
  }

  void _onConnectionResult(String id, Status status) {
    if (status == Status.CONNECTED) {
      _connectedEndpoints.add(id);
      _sendProfile(id);
    }
  }

  void _onDisconnected(String id) {
    _connectedEndpoints.remove(id);
    _endpointToPrn.remove(id);
    _lostCtrl.add(id);
  }

  void _onPayloadReceived(String endpointId, Payload payload) {
    if (payload.type != PayloadType.BYTES) return;
    final bytes = payload.bytes;
    if (bytes == null) return;
    final raw = utf8.decode(bytes);
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final type = json['type'] as String?;
      if (type == 'profile') {
        _handleProfilePayload(endpointId, json['data'] as Map<String, dynamic>);
      } else if (type == 'message') {
        final prn = _endpointToPrn[endpointId] ?? endpointId;
        _msgCtrl.add(MapEntry(prn, json['data'] as String? ?? ''));
      } else if (type == 'like') {
        _handleLikePayload(endpointId);
      }
    } catch (e) {
      debugPrint('[P2P] Payload parse error: $e');
    }
  }

  void _handleProfilePayload(String endpointId, Map<String, dynamic> data) {
    final local = _localUser;
    if (local == null) return;
    final overlap = computeIntersection(local.tags, List<String>.from(data['tags'] as List? ?? []));
    final peer = PeerProfile.fromJson(data, endpointId, overlap);
    if (!_psiMatch(local, peer)) return;
    _endpointToPrn[endpointId] = peer.prn;
    _discoveredCtrl.add(peer);
  }

  void _handleLikePayload(String endpointId) {
  }

  void _sendProfile(String endpointId) {
    final local = _localUser;
    if (local == null) return;
    final payload = jsonEncode({'type': 'profile', 'data': _buildLocalProfileJson()});
    _nearby.sendBytesPayload(endpointId, Uint8List.fromList(utf8.encode(payload)));
  }

  Map<String, dynamic> _buildLocalProfileJson() {
    final u = _localUser!;
    return {
      'prn': u.prn,
      'name': u.name,
      'gender': u.gender,
      'year': u.year,
      'branch': u.branch,
      'tags': u.tags,
      'goals': u.goals,
      'prefGender': u.prefGender,
      'prefYear': u.prefYear,
    };
  }

  Future<void> sendMessage(String endpointId, String message) async {
    final payload = jsonEncode({'type': 'message', 'data': message});
    await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(utf8.encode(payload)));
  }

  Future<void> sendLike(String endpointId) async {
    final payload = jsonEncode({'type': 'like', 'data': _localUser?.prn ?? ''});
    await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(utf8.encode(payload)));
  }

  Future<void> stop() async {
    _active = false;
    _connectedEndpoints.clear();
    _endpointToPrn.clear();
    try {
      await _nearby.stopAllEndpoints();
      await _nearby.stopAdvertising();
      await _nearby.stopDiscovery();
    } catch (_) {}
  }

  void dispose() {
    stop();
    _discoveredCtrl.close();
    _lostCtrl.close();
    _msgCtrl.close();
  }
}
