import 'package:dio/dio.dart';
import 'package:blog_app/services/storage_service.dart';
import 'package:blog_app/utils/constants.dart';

class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._();

  late final Dio dio;
  late StorageService _storage;

  void init(StorageService storage) {
    _storage = storage;
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ));

    // ── Request interceptor: attach JWT ──────────────────────
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },

      onError: (DioException e, handler) {
        // Convert Dio errors to readable messages
        final msg = _parseError(e);
        handler.reject(DioException(
          requestOptions: e.requestOptions,
          error: msg,
          type: e.type,
          response: e.response,
        ));
      },
    ));
  }

  String _parseError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Check your internet.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot reach the server. Check your network or API URL.';
    }
    final data = e.response?.data;
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }
    return e.message ?? 'Unknown error';
  }
}