import 'package:dio/dio.dart';
import 'package:blog_app/models/user_model.dart';
import 'package:blog_app/services/api_service.dart';

class AuthService {
  final Dio _dio = ApiService.instance.dio;

  /// Sign up a new viewer account. Returns [UserModel] and raw JWT token.
  Future<({UserModel user, String token})> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/signup',
      data: {'name': name, 'email': email, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }

  /// Login for both Author and Viewer. Role comes back in the user payload.
  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }

  /// Login via Google. Returns [UserModel] and raw JWT token.
  Future<({UserModel user, String token})> googleAuth({
    required String idToken,
  }) async {
    final response = await _dio.post(
      '/auth/google',
      data: {'idToken': idToken},
    );
    final data = response.data as Map<String, dynamic>;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }

  /// Fetch the currently authenticated user's profile.
  Future<UserModel> getMe() async {
    final response = await _dio.get('/auth/me');
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? data);
  }
}
