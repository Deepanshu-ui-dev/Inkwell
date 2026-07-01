import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:blog_app/utils/constants.dart';
import 'package:blog_app/models/user_model.dart';

/// Wraps FlutterSecureStorage for token + user persistence.
class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  // ── Token ──────────────────────────────────────────────────
  Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.tokenKey, value: token);

  Future<String?> getToken() =>
      _storage.read(key: AppConstants.tokenKey);

  Future<void> deleteToken() =>
      _storage.delete(key: AppConstants.tokenKey);

  // ── User ───────────────────────────────────────────────────
  Future<void> saveUser(UserModel user) =>
      _storage.write(key: AppConstants.userKey, value: jsonEncode(user.toJson()));

  Future<UserModel?> getUser() async {
    final raw = await _storage.read(key: AppConstants.userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUser() =>
      _storage.delete(key: AppConstants.userKey);

  // ── Clear all ──────────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();
}
