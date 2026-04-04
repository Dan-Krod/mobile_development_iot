import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String baseUrl = 'http://10.0.2.2:5000/api';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          debugPrint('API Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response<dynamic>> login(String email, String password) async {
    return await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response<dynamic>> register(Map<String, dynamic> userData) async {
    return await _dio.post('/auth/register', data: userData);
  }

  Future<Response<dynamic>> getTanks(String email) async {
    return await _dio.get('/tanks', queryParameters: {'email': email});
  }

  Future<Response<dynamic>> saveTank(Map<String, dynamic> tankData) async {
    return await _dio.post('/tanks', data: tankData);
  }

  Future<Response<dynamic>> deleteTank(String id) async {
    return await _dio.delete('/tanks', queryParameters: {'id': id});
  }

  Future<Response<dynamic>> getLogs() async {
    return await _dio.get('/logs');
  }

  Future<Response<dynamic>> postLog(String email, String action) async {
    return await _dio.post('/logs', data: {'email': email, 'action': action});
  }

  Future<Response<dynamic>> updateUser(Map<String, dynamic> userData) async {
    return await _dio.put('/auth/update', data: userData);
  }

  Future<Response<dynamic>> deleteUser(String email) async {
    return await _dio.delete('/auth/delete', queryParameters: {'email': email});
  }
}
