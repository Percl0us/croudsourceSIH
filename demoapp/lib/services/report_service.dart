// lib/services/report_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;

class ReportService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Backend base (no trailing slash)
  static const String serverBaseUrl = "https://croudsourcesih.onrender.com/api";

  // Cloudinary
  static const String cloudName = "dn0tozwxf";
  static const String uploadPreset = "my_unsigned_preset";

  ReportService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: serverBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          responseType: ResponseType.json,
        ),
      ) {
    // Attach token from secure storage to backend requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Do not attach token for Cloudinary remote URL
          if (options.uri.host.contains("cloudinary.com")) {
            handler.next(options);
            return;
          }
          final token = await _storage.read(key: "jwt");
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
      ),
    );
  }
  Future<List<dynamic>> fetchMyReports() async {
    final resp = await _dio.get("/reports");
    if (resp.statusCode == 200) {
      return resp.data as List<dynamic>;
    } else {
      throw Exception("Failed to fetch reports: ${resp.statusCode}");
    }
  }
Future<Map<String, dynamic>> fetchReportById(String id) async {
  final resp = await _dio.get("/reports/$id");
  if (resp.statusCode == 200) {
    return resp.data as Map<String, dynamic>;
  } else {
    throw Exception("Failed to load report: ${resp.statusCode}");
  }
}

  /// Upload image file to Cloudinary (unsigned). Returns the secure_url.
  Future<String> uploadImageToCloudinary(File file) async {
    final cloudinaryUrl =
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    final fileName = p.basename(file.path);
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
      "upload_preset": uploadPreset,
    });

    final resp = await _dio.post(
      cloudinaryUrl,
      data: formData,
      options: Options(
        headers: {"Accept": "application/json"},
        contentType: "multipart/form-data",
      ),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = resp.data;
      if (data != null && data["secure_url"] != null) {
        return data["secure_url"] as String;
      }
      throw Exception("Cloudinary response missing secure_url");
    } else {
      throw Exception(
        "Cloudinary upload failed: ${resp.statusCode} ${resp.data}",
      );
    }
  }

  /// Create report in backend (expects backend to read `req.user.id` from JWT)
  Future<Response> createReport({
    required String imageUrl,
    required String text,
    required double latitude,
    required double longitude,
    required String priority,
    required String category,
    String? transcription,
    String? summary,
  }) async {
    final body = {
      "image_url": imageUrl,
      "text": text,
      "transcription": transcription,
      "location": {
        "type": "Point",
        "coordinates": [longitude, latitude], // GeoJSON [lng, lat]
      },
      "summary": summary,
      "priority": priority,
      "category": category,
    };

    return await _dio.post("/reports", data: body);
  }
}
