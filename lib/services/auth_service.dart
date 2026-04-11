import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class AuthService {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  AuthService() {
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("AuthService: Firebase not initialized. Using Mock Auth.");
    }
  }

  /// Streams the current user's authentication state.
  Stream<User?> get user => _auth?.authStateChanges() ?? const Stream.empty();

  /// Signs up a new user using Firebase Auth and creates a profile in Firestore.
  Future<UserCredential?> signUp(String email, String password, String name) async {
    if (_auth == null || _firestore == null) return null;
    try {
      UserCredential credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore for storing metadata like watchlist
      UserProfile userProfile = UserProfile(
        uid: credential.user!.uid,
        email: email,
        name: name,
      );

      await _firestore!
          .collection('users')
          .doc(credential.user!.uid)
          .set(userProfile.toMap());

      return credential;
    } catch (e) {
      rethrow;
    }
  }

  /// Logs in an existing user with email and password.
  Future<UserCredential?> login(String email, String password) async {
    if (_auth == null) return null;
    try {
      return await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Signs the user out of Firebase.
  Future<void> logout() async {
    await _auth?.signOut();
  }

  /// Verifies a phone number and triggers the OTP code to be sent.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(FirebaseAuthException e) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    if (_auth == null) return;
    await _auth!.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  /// Signs in the user using the verification ID and the SMS code.
  Future<UserCredential?> signInWithPhoneNumber(String verificationId, String smsCode) async {
    if (_auth == null) return null;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth!.signInWithCredential(credential);
  }

  /// Retrieves a user's profile from Firestore by their UID.
  Future<UserProfile?> getUserProfile(String uid) async {
    if (_firestore == null) return null;
    try {
      DocumentSnapshot doc = await _firestore!.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
