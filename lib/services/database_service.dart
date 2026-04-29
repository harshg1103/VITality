import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/match_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is Iterable) return value.map((e) => e.toString()).toList();
    return [value.toString()];
  }

  Future<void> saveUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.prn).set({
        'prn': user.prn,
        'name': user.name,
        'gender': user.gender,
        'year': user.year,
        'branch': user.branch,
        'bio': user.bio,
        'tags': user.tags,
        'goals': user.goals,
        'hobbies': user.hobbies,
        'technicalSkills': user.technicalSkills,
        'prefGender': user.prefGender,
        'prefYear': user.prefYear,
        'photoPath': user.photoPath,
        'isAdmin': user.prn == '12413129', // Admin Privileges
      }, SetOptions(merge: true)).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Resolve the future locally. Firestore will sync this in the background!
          return;
        },
      );
    } catch (e) {
      throw Exception('DatabaseService.saveUser failed: $e');
    }
  }

  Future<UserModel?> getUser(String prn) async {
    try {
      final doc = await _db.collection('users').doc(prn).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      final user = UserModel(
        prn: data['prn']?.toString() ?? prn,
        name: data['name']?.toString() ?? '',
        password: '', // Kept secure via FirebaseAuth
        gender: data['gender']?.toString() ?? '',
        year: data['year']?.toString() ?? '',
        branch: data['branch']?.toString() ?? '',
      );
      user.bio = data['bio']?.toString() ?? '';
      user.tags = _parseList(data['tags']);
      user.goals = _parseList(data['goals']);
      user.hobbies = _parseList(data['hobbies']);
      user.technicalSkills = _parseList(data['technicalSkills']);
      user.prefGender = data['prefGender']?.toString() ?? 'Any';
      user.prefYear = data['prefYear']?.toString() ?? 'Any';
      user.photoPath = data['photoPath']?.toString() ?? '';
      return user;
    } catch (e) {
      throw Exception('DatabaseService.getUser failed: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _db.collection('users').get();
      final users = <UserModel>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final user = UserModel(
          prn: data['prn'] ?? '',
          name: data['name'] ?? '',
          password: '',
          gender: data['gender'] ?? '',
          year: data['year'] ?? '',
          branch: data['branch'] ?? '',
        );
        users.add(user);
      }
      return users;
    } catch (e) {
      throw Exception('DatabaseService.getAllUsers failed: $e');
    }
  }

  Future<void> saveMatch(MatchModel match) async {
    try {
      await _db.collection('matches').doc(match.matchId).set({
        'matchId': match.matchId,
        'peerPrn': match.peerPrn,
        'peerName': match.peerName,
        'timestamp': match.timestamp,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('DatabaseService.saveMatch failed: $e');
    }
  }

  Future<void> addMessage(String matchId, String message) async {
    try {
      await _db
          .collection('matches')
          .doc(matchId)
          .collection('messages')
          .add({
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('DatabaseService.addMessage failed: $e');
    }
  }

  Stream<QuerySnapshot> getAllMatches() {
    return _db.collection('matches').snapshots();
  }

  Stream<QuerySnapshot> getMatchMessages(String matchId) {
    return _db.collection('matches').doc(matchId).collection('messages').orderBy('timestamp').snapshots();
  }
}
