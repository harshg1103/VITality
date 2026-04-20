import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  bool validatePrn(String prn) {
    return RegExp(r'^\d{8}$').hasMatch(prn);
  }

  Future<UserModel?> register({
    required String prn,
    required String name,
    required String password,
    required String gender,
    required String year,
    required String branch,
  }) async {
    if (!validatePrn(prn)) throw Exception('Invalid PRN format. Must be 8 digits.');
    if (password.length < 6) throw Exception('Password must be at least 6 characters.');
    
    // Create User in Firebase Auth
    try {
      await _auth.createUserWithEmailAndPassword(
        email: '$prn@vitality.app', 
        password: password
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration Failed');
    }

    final user = UserModel(
      prn: prn,
      name: name,
      password: '', // Firebase handles password security
      gender: gender,
      year: year,
      branch: branch,
    );
    
    // Save User Profile to Firestore
    await _db.saveUser(user);
    
    return user;
  }

  Future<UserModel?> login({required String prn, required String password}) async {
    if (!validatePrn(prn)) throw Exception('Invalid PRN format.');
    
    try {
      await _auth.signInWithEmailAndPassword(
        email: '$prn@vitality.app', 
        password: password
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Invalid credentials.');
    }

    // Fetch User Profile from Firestore
    final user = await _db.getUser(prn);
    if (user == null) throw Exception('Node profile not found in database.');
    return user;
  }

  Future<void> saveSession(String prn) async {
    final session = Hive.box('session');
    await session.put('activePrn', prn);
  }

  Future<void> clearSession() async {
    await _auth.signOut();
    final session = Hive.box('session');
    await session.delete('activePrn');
  }

  Future<UserModel?> getSessionUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;
    
    final prn = currentUser.email?.split('@').first;
    if (prn == null) return null;
    
    return await _db.getUser(prn);
  }
}
