import 'package:demoapp/services/navigation_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );
    _setupInterceptors();
  }
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = "https://croudsourcesih.onrender.com/api/auth";

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: "jwt");
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          //if token expires/unauthorized, remove token(or implement refresh)
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: "jwt");
            navigatorkey.currentState?.pushReplacementNamed('/');
          }
          handler.next(error);
        },
      ),
    );
  }

  //Auth methods
  Future<void> signup(String name, String mobile, String email, String password) async {
  try {
    await _dio.post(
      "/signup",
      data: {
        "name": name,
        "mobile_number": mobile,
        "email": email,
        "password": password,
      },
    );
  } on DioException catch (e) {
    throw _handleDioError(e);
  }
}

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {"email": email, "password": password},
      );
      final token = response.data?["token"] as String?;
      if (token == null) throw Exception("No token received from server");
      await _storage.write(key: "jwt", value: token);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: "jwt");
  }

  Future<String?> getToken() async {
    return await _storage.read(key: "jwt");
  }

  Future<bool> isLoggedIn() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get("/profile");
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<String> ping() async {
    try {
      final response = await _dio.get("https://croudsourcesih.onrender.com/ping");
      return response.data.toString();
    } on DioException catch (e) {
      return "Ping failed: ${e.message}";
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data["message"] != null) {
        return Exception(data["message"]);
      }
      return Exception("Request failed: ${e.response!.statusCode}");
    }
    return Exception(e.message ?? "Network error");
  }
}
