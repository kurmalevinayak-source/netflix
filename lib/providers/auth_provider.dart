import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

/// Firebase errors where we should show the message (real credential / validation issues).
bool _isUserFacingAuthError(FirebaseAuthException e) {
  const codes = {
    'wrong-password',
    'user-not-found',
    'invalid-email',
    'invalid-credential',
    'email-already-in-use',
    'weak-password',
    'invalid-verification-code',
    'invalid-verification-id',
    'credential-already-in-use',
    'provider-already-linked',
    'account-exists-with-different-credential',
  };
  return codes.contains(e.code);
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isDemoMode = false;

  String? _verificationId;
  bool _isOtpSent = false;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null || _isDemoMode;
  bool get isDemoMode => _isDemoMode;
  bool get isOtpSent => _isOtpSent;

  AuthProvider() {
    _authService.user.listen((User? user) {
      if (!_isDemoMode) {
        _user = user;
        if (user != null) {
          _fetchUserProfile(user.uid);
        } else {
          _userProfile = null;
          notifyListeners();
        }
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    _userProfile = await _authService.getUserProfile(uid);
    notifyListeners();
  }

  Future<String?> signUp(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.signUp(email, password, name);
      if (result == null) {
        _isDemoMode = true;
        _userProfile = UserProfile(uid: 'demo_uid', email: email, name: name);
      } else {
        _isDemoMode = false;
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (_isUserFacingAuthError(e)) {
        notifyListeners();
        return e.message ?? e.code;
      }
      _isDemoMode = true;
      _userProfile = UserProfile(uid: 'demo_uid', email: email, name: name);
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _isDemoMode = true;
      _userProfile = UserProfile(uid: 'demo_uid', email: email, name: name);
      notifyListeners();
      return null;
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.login(email, password);
      if (result == null) {
        _isDemoMode = true;
        _userProfile = UserProfile(uid: 'demo_uid', email: email, name: 'Demo User');
      } else {
        _isDemoMode = false;
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (_isUserFacingAuthError(e)) {
        notifyListeners();
        return e.message ?? e.code;
      }
      _isDemoMode = true;
      _userProfile = UserProfile(uid: 'demo_uid', email: email, name: 'Demo User');
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _isDemoMode = true;
      _userProfile = UserProfile(uid: 'demo_uid', email: email, name: 'Demo User');
      notifyListeners();
      return null;
    }
  }

  /// Skip Firebase entirely — browse the app without an account.
  void enterGuestMode() {
    _isDemoMode = true;
    _user = null;
    _userProfile = UserProfile(
      uid: 'guest',
      email: 'guest@demo.local',
      name: 'Guest',
    );
    _isOtpSent = false;
    _verificationId = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _isDemoMode = false;
    _user = null;
    _userProfile = null;
    notifyListeners();
  }

  Future<void> sendOTP(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _isOtpSent = true;
          _isLoading = false;
          notifyListeners();
        },
        verificationFailed: (e) {
          _isLoading = false;
          _isOtpSent = false;
          notifyListeners();
          debugPrint('Phone verification failed: ${e.message}');
        },
        verificationCompleted: (credential) async {
          // Auto-sign-in on some Android devices
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error sending OTP: $e');
    }
  }

  Future<String?> verifyOTP(String smsCode) async {
    if (_verificationId == null) return 'Verification ID is null';
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.signInWithPhoneNumber(_verificationId!, smsCode);
      if (result == null) {
        _isDemoMode = true;
        _userProfile = UserProfile(uid: 'demo_uid_otp', email: 'otp@demo.com', name: 'OTP User');
      } else {
        _isDemoMode = false;
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (_isUserFacingAuthError(e)) {
        notifyListeners();
        return e.message ?? e.code;
      }
      _isDemoMode = true;
      _userProfile = UserProfile(uid: 'demo_uid_otp', email: 'otp@demo.com', name: 'OTP User');
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _isDemoMode = true;
      _userProfile = UserProfile(uid: 'demo_uid_otp', email: 'otp@demo.com', name: 'OTP User');
      notifyListeners();
      return null;
    }
  }
  
  // Update local watchlist to avoid redundant fetching
  void toggleWatchlistLocal(String movieId) {
    if (_userProfile == null) return;
    
    final List<String> currentWatchlist = List.from(_userProfile!.watchlist);
    if (currentWatchlist.contains(movieId)) {
      currentWatchlist.remove(movieId);
    } else {
      currentWatchlist.add(movieId);
    }
    
    _userProfile = UserProfile(
      uid: _userProfile!.uid,
      email: _userProfile!.email,
      name: _userProfile!.name,
      watchlist: currentWatchlist,
    );
    notifyListeners();
  }
}
