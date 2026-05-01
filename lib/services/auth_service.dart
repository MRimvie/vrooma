import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  final GetStorage _storage = GetStorage();

  AuthService() {
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      print('Firebase not initialized: $e');
    }
  }

  User? get currentUser => _auth?.currentUser;
  String? get currentUserId => _auth?.currentUser?.uid;
  bool get isAuthenticated => _auth?.currentUser != null;

  Future<void> sendOTP(String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    if (_auth == null) {
      onError('Firebase not configured. Please add google-services.json');
      return;
    }
    try {
      await _auth!.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth?.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Erreur de vérification');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<UserCredential?> verifyOTP(String verificationId, String smsCode) async {
    if (_auth == null) {
      throw Exception('Firebase not configured');
    }
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth!.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Code OTP invalide');
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (_auth == null) throw Exception('Firebase not configured');
    try {
      return await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Email ou mot de passe incorrect');
    }
  }

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    if (_auth == null) throw Exception('Firebase not configured');
    try {
      return await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erreur lors de la création du compte');
    }
  }

  Future<void> signOut() async {
    await _auth?.signOut();
    _storage.erase();
  }

  Future<void> resetPassword(String email) async {
    if (_auth == null) throw Exception('Firebase not configured');
    try {
      await _auth!.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation du mot de passe');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    if (_firestore == null) return null;
    try {
      final doc = await _firestore!.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    if (_firestore == null) throw Exception('Firebase not configured');
    await _firestore!.collection('users').doc(userId).update(data);
  }

  Future<void> createUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String role,
  }) async {
    if (_firestore == null) throw Exception('Firebase not configured');
    await _firestore!.collection('users').doc(userId).set({
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  void saveUserLocally(Map<String, dynamic> userData) {
    _storage.write('user_id', userData['userId']);
    _storage.write('user_role', userData['role']);
    _storage.write('user_name', '${userData['firstName']} ${userData['lastName']}');
    _storage.write('user_email', userData['email']);
    _storage.write('user_phone', userData['phone']);
  }

  String? getLocalUserId() => _storage.read('user_id');
  String? getLocalUserRole() => _storage.read('user_role');
  String? getLocalUserName() => _storage.read('user_name');
}
