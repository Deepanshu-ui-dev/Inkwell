import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/services/auth_service.dart';
import 'package:blog_app/services/storage_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;

  UserModel? _currentUser;
  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    required AuthService authService,
    required StorageService storageService,
  })  : _authService = authService,
        _storageService = storageService;

  // ── Getters ────────────────────────────────────────────────
  UserModel? get currentUser => _currentUser;
  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _status == AuthStatus.authenticated && _currentUser != null;
  bool get isAuthor => isLoggedIn && (_currentUser?.isAuthor ?? false);
  bool get isViewer => isLoggedIn && (_currentUser?.isViewer ?? false);

  // ── Auto-login (called on app start) ──────────────────────
  Future<void> tryAutoLogin() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    // Try loading cached user first for fast startup
    final cached = await _storageService.getUser();
    if (cached != null) {
      _currentUser = cached;
      _status = AuthStatus.authenticated;
      notifyListeners();
    }

    // Validate token with server in the background
    try {
      final freshUser = await _authService.getMe();
      _currentUser = freshUser;
      await _storageService.saveUser(freshUser);
      _status = AuthStatus.authenticated;
    } catch (_) {
      // Token expired or server unreachable — clear if no cached user
      if (cached == null) {
        await _storageService.clearAll();
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }
    }
    notifyListeners();
  }

  // ── Login ──────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await _authService.login(email: email, password: password);
      await _storageService.saveToken(result.token);
      await _storageService.saveUser(result.user);
      _currentUser = result.user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _errorMessage = _extractError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ── Signup ─────────────────────────────────────────────────
  Future<bool> signup(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await _authService.signup(
        name: name,
        email: email,
        password: password,
      );
      await _storageService.saveToken(result.token);
      await _storageService.saveUser(result.user);
      _currentUser = result.user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _errorMessage = _extractError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ── Google Sign-In ─────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount? account = await GoogleSignIn.instance.authenticate();
      
      if (account == null) {
        // User canceled the sign-in flow
        _setLoading(false);
        return false;
      }
      
      final GoogleSignInAuthentication auth = await account.authentication;
      final idToken = auth.idToken;
      
      if (idToken == null) {
        _errorMessage = 'Failed to get authentication token from Google.';
        _setLoading(false);
        return false;
      }

      final result = await _authService.googleAuth(idToken: idToken);
      await _storageService.saveToken(result.token);
      await _storageService.saveUser(result.user);
      _currentUser = result.user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _errorMessage = _extractError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Google Sign-In failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────
  Future<void> logout() async {
    await _storageService.clearAll();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return (data['message'] ?? data['error'] ?? 'Request failed').toString();
    }
    return e.message ?? 'Network error. Check your connection.';
  }
}
