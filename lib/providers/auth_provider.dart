import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

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
        // Fallback to demo mode if Firebase is not configured
        _isDemoMode = true;
        _userProfile = UserProfile(uid: 'demo_uid', email: email, name: name);
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.login(email, password);
      if (result == null) {
        // Fallback to demo mode if Firebase is not configured
        _isDemoMode = true;
        _userProfile = UserProfile(uid: 'demo_uid', email: email, name: 'Demo User');
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
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
        // Mock demo mode for testing OTP without real Firebase
        _isDemoMode = true;
        _userProfile = UserProfile(uid: 'demo_uid_otp', email: 'otp@demo.com', name: 'OTP User');
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
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
