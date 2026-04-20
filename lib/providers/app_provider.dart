import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/match_model.dart';
import '../models/peer_profile.dart';
import '../services/auth_service.dart';
import '../services/p2p_service.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  final _auth = AuthService();
  final _p2p = P2PService();
  final _db = DatabaseService();
  final _uuid = const Uuid();

  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  final List<PeerProfile> _peerStack = [];
  final Map<String, bool> _likedEndpoints = {};
  final List<MatchModel> _matches = [];

  final Map<String, String> _endpointIdByPrn = {};

  StreamSubscription? _discoverySub;
  StreamSubscription? _lostSub;
  StreamSubscription? _messageSub;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PeerProfile> get peerStack => List.unmodifiable(_peerStack);
  List<MatchModel> get matches => List.unmodifiable(_matches);

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  void clearError() => _setError(null);

  Future<void> tryAutoLogin() async {
    final user = await _auth.getSessionUser();
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
      _startP2P();
      _loadMatches();
    }
  }

  Future<bool> register({
    required String prn,
    required String name,
    required String password,
    required String gender,
    required String year,
    required String branch,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _auth.register(
        prn: prn,
        name: name,
        password: password,
        gender: gender,
        year: year,
        branch: branch,
      );
      _currentUser = user;
      _isLoggedIn = true;
      await _auth.saveSession(prn);
      _loadMatches();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String prn, required String password}) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _auth.login(prn: prn, password: password);
      _currentUser = user;
      _isLoggedIn = true;
      await _auth.saveSession(prn);
      _startP2P();
      _loadMatches();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _auth.clearSession();
    await _p2p.stop();
    _discoverySub?.cancel();
    _lostSub?.cancel();
    _messageSub?.cancel();
    _currentUser = null;
    _isLoggedIn = false;
    _peerStack.clear();
    _matches.clear();
    _likedEndpoints.clear();
    _endpointIdByPrn.clear();
    notifyListeners();
  }

  Future<void> saveProfile(UserModel updated) async {
    await updated.save();
    await _db.saveUser(updated);
    _currentUser = updated;
    notifyListeners();
    _startP2P();
  }

  void _startP2P() {
    final user = _currentUser;
    if (user == null) return;
    _discoverySub?.cancel();
    _lostSub?.cancel();
    _messageSub?.cancel();
    _p2p.start(user);
    _discoverySub = _p2p.discoveredPeers$.listen(_onPeerDiscovered);
    _lostSub = _p2p.lostPeers$.listen(_onPeerLost);
    _messageSub = _p2p.incomingMessages$.listen(_onMessageReceived);
    _injectDemoPeers();
  }

  void _injectDemoPeers() {
    if (_peerStack.isNotEmpty) return;
    final demos = [
      const PeerProfile(
        endpointId: 'demo_1',
        prn: '22100001',
        name: 'Aarav Mehta',
        gender: 'Male',
        year: 'TY',
        branch: 'Computer Engineering',
        tags: ['Flutter', 'Firebase', 'UI/UX'],
        goals: ['Looking for Hackathon Teammates'],
        prefGender: 'Any',
        prefYear: 'Any',
        overlappingTags: ['Flutter', 'UI/UX'],
      ),
      const PeerProfile(
        endpointId: 'demo_2',
        prn: '22100002',
        name: 'Priya Sharma',
        gender: 'Female',
        year: 'SY',
        branch: 'Information Technology',
        tags: ['React Native', 'Web3', 'Blockchain'],
        goals: ['Study Group', 'Social/Collaboration'],
        prefGender: 'Any',
        prefYear: 'Any',
        overlappingTags: ['Web3', 'Blockchain'],
      ),
      const PeerProfile(
        endpointId: 'demo_3',
        prn: '22100003',
        name: 'Rohan Kulkarni',
        gender: 'Male',
        year: 'FY',
        branch: 'Electronics & Telecom',
        tags: ['Machine Learning', 'Python', 'IoT'],
        goals: ['Looking for Hackathon Teammates'],
        prefGender: 'Any',
        prefYear: 'Any',
        overlappingTags: ['Machine Learning'],
      ),
    ];
    _peerStack.addAll(demos);
    notifyListeners();
  }

  void _onPeerDiscovered(PeerProfile peer) {
    _endpointIdByPrn[peer.prn] = peer.endpointId;
    if (!_peerStack.any((p) => p.prn == peer.prn)) {
      _peerStack.add(peer);
      notifyListeners();
    }
  }

  void _onPeerLost(String endpointId) {
    _peerStack.removeWhere((p) => p.endpointId == endpointId);
    notifyListeners();
  }

  void _onMessageReceived(MapEntry<String, String> entry) {
    final prn = entry.key;
    final message = entry.value;
    final box = Hive.box<MatchModel>('matches');
    for (final match in box.values) {
      if (match.peerPrn == prn) {
        match.messages.add('them:$message');
        match.save();
        _db.saveMatch(match);
        final idx = _matches.indexWhere((m) => m.peerPrn == prn);
        if (idx != -1) _matches[idx] = match;
        notifyListeners();
        break;
      }
    }
  }

  Future<MatchModel?> likePeer(PeerProfile peer) async {
    _likedEndpoints[peer.endpointId] = true;
    if (peer.endpointId.startsWith('demo_')) {
      return await _createMatch(peer);
    }
    await _p2p.sendLike(peer.endpointId);
    return null;
  }

  void passPeer(PeerProfile peer) {
    _peerStack.removeWhere((p) => p.endpointId == peer.endpointId);
    notifyListeners();
  }

  Future<MatchModel> _createMatch(PeerProfile peer) async {
    final box = Hive.box<MatchModel>('matches');
    final existing = box.values.where((m) => m.peerPrn == peer.prn);
    if (existing.isNotEmpty) return existing.first;
    final match = MatchModel(
      matchId: _uuid.v4(),
      peerPrn: peer.prn,
      peerName: peer.name,
      peerPhotoPath: peer.photoPath,
      peerTags: peer.tags,
      peerYear: peer.year,
      peerBranch: peer.branch,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await box.put(match.matchId, match);
    await _db.saveMatch(match);
    _matches.insert(0, match);
    notifyListeners();
    return match;
  }

  void _loadMatches() {
    final box = Hive.box<MatchModel>('matches');
    _matches.clear();
    _matches.addAll(box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)));
    notifyListeners();
  }

  Future<void> sendMessage(MatchModel match, String text) async {
    match.messages.add('me:$text');
    await match.save();
    await _db.saveMatch(match);
    final idx = _matches.indexWhere((m) => m.matchId == match.matchId);
    if (idx != -1) _matches[idx] = match;
    notifyListeners();
    final endpointId = _endpointIdByPrn[match.peerPrn];
    if (endpointId != null && !match.matchId.startsWith('demo_')) {
      await _p2p.sendMessage(endpointId, text);
    }
  }

  @override
  void dispose() {
    _discoverySub?.cancel();
    _lostSub?.cancel();
    _messageSub?.cancel();
    _p2p.dispose();
    super.dispose();
  }
}
