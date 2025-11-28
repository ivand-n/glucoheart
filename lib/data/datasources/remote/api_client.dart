// lib/data/datasources/remote/api_client.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class ApiClient {
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://195.88.211.126:3001');
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  ApiClient() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _logger.d('🐛 REQUEST[${options.method}] => PATH: ${options.uri}');
          final token = await _storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          try {
            _logger.d('↪️ body runtimeType: ${options.data?.runtimeType}');
          } catch (_) {}
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('🐛 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (e, handler) {
          _logger.e('⛔ ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
              error: e.response?.data);
          return handler.next(e);
        },
      ),
    );
  }

  // ✅ Public getter biar bisa dipakai: ApiClient().dio
  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final isForm = data is FormData;
      final body = isForm ? data : _normalizeJsonBody(data);
      return await _dio.post(
        path,
        data: body,
        // kalau FormData, biarkan Dio set multipart boundary otomatis
        options: isForm ? null : Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // (nama aslinya "put" di kode kamu tapi panggil PATCH; dibiarkan agar backward compatible)
  Future<Response> patch(String path, {dynamic data}) async {
    try {
      final isForm = data is FormData;
      final body = isForm ? data : _normalizeJsonBody(data);
      return await _dio.patch(
        path,
        data: body,
        options: isForm ? null : Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Opsi helper khusus upload (kalau mau lebih eksplisit)
  Future<Response> postMultipart(String path, {required FormData data}) async {
    try {
      return await _dio.post(path, data: data); // Dio set Content-Type multipart otomatis
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ——— paksa body jadi object JSON jika bukan FormData ———
  dynamic _normalizeJsonBody(dynamic data) {
    if (data == null) return <String, dynamic>{};
    if (data is Map) return data;
    if (data is FormData) return data;

    if (data is String) {
      final s = data.trim();
      if (s.isEmpty) return <String, dynamic>{};
      if (s.startsWith('{') || s.startsWith('[')) {
        try {
          final parsed = json.decode(s);
          return parsed;
        } catch (_) {}
      }
      return <String, dynamic>{'value': data};
    }
    return data;
  }

  void _handleError(DioException e) {
    _logger.e('API Error: ${e.message}', error: e);
  }

  Future<void> saveToken(String token) async => _storage.write(key: 'auth_token', value: token);
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
    _dio.options.headers.remove('Authorization'); // pastikan bersih
  }
  Future<bool> hasToken() async => (await _storage.read(key: 'auth_token')) != null;
  Future<String?> getToken() async => _storage.read(key: 'auth_token');
}
