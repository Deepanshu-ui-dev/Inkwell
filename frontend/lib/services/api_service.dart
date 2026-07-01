import 'package:dio/dio.dart';
import 'package:blog_app/utils/constants.dart';
import 'package:blog_app/services/storage_service.dart';

/// Singleton Dio client. Automatically attaches the Bearer token to every
/// request via an interceptor — screens and services don't need to think about it.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  late final Dio _dio;
  late final StorageService _storage;

  void init(StorageService storage) {
    _storage = storage;
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Auth interceptor — injects token before every request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) {
          // Pass errors through — let callers handle them
          handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
