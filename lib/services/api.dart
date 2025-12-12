// lib/services/api.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => "ApiException($statusCode): $message";
}

class Api {
  Api._internal();

  static final Api _instance = Api._internal();
  factory Api() => _instance;

  late Dio _dio;
  String _baseUrl = "";
  Duration _timeout = const Duration(seconds: 15);

  static const String _jwtKey = "jwt_token";

  Future<void> init({required String baseUrl, Duration? timeout}) async {
    _baseUrl = baseUrl;

    if (timeout != null) {
      _timeout = timeout;
    }

    BaseOptions options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      responseType: ResponseType.json,
      validateStatus: (code) => code != null && code < 500,
    );

    _dio = Dio(options);

    // Attach JWT automatically
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_jwtKey);

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },
      ),
    );
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jwtKey, token);

    // Immediately apply token to Dio headers
    _dio.options.headers["Authorization"] = "Bearer $token";

    print("TOKEN SET IN DIO: $token");
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jwtKey);

    // Remove token from Dio headers
    _dio.options.headers.remove("Authorization");

    print("TOKEN CLEARED FROM DIO");
  }
  // -------------------------
  // API METHODS
  // -------------------------

  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? query}) async {
    return _request("GET", path, queryParameters: query);
  }

  Future<Map<String, dynamic>> postJson(String path,
      {Map<String, dynamic>? body}) async {
    return _request("POST", path,
        data: body, contentType: "application/json");
  }

  Future<Map<String, dynamic>> postForm(String path,
      {Map<String, dynamic>? fields}) async {
    return _request("POST", path,
        data: FormData.fromMap(fields ?? {}),
        contentType: "multipart/form-data");
  }

  // add imports at top if not present:
// import 'dart:typed_data';
// import 'package:dio/dio.dart';

  Future<Map<String, dynamic>> postMultipart(
      String path, {
        FormData? formData,
        Map<String, dynamic>? fields,
        Map<String, List<dynamic>>? files,
      }) async {
    // Use provided FormData directly if passed
    FormData form = formData ?? FormData();

    // Add fields (text)
    if (formData == null && fields != null) {
      fields.forEach((k, v) {
        form.fields.add(MapEntry(k, v.toString()));
      });
    }

    // Add files (only if we built the form here)
    if (formData == null && files != null) {
      for (final entry in files.entries) {
        final field = entry.key;
        final items = entry.value;
        for (final item in items) {
          // If item already a MultipartFile (e.g. created with MultipartFile.fromBytes/fromFile)
          if (item is MultipartFile) {
            form.files.add(MapEntry(field, item));
            continue;
          }

          // bytes (Uint8List / List<int>) — common on web via file_picker.withData
          if (item is List<int> || item is Uint8List) {
            final filename = "file_${DateTime.now().millisecondsSinceEpoch}.pdf";
            form.files.add(
              MapEntry(
                field,
                MultipartFile.fromBytes(item as List<int>, filename: filename),
              ),
            );
            continue;
          }

          // Map form for explicit bytes + filename + contentType
          if (item is Map) {
            final bytes = item['bytes'] as List<int>?;
            final filename = (item['filename'] ?? "file_${DateTime.now().millisecondsSinceEpoch}.pdf") as String;
            final contentType = item['contentType'] as String?;
            if (bytes != null) {
              if (contentType != null) {
                form.files.add(MapEntry(
                  field,
                  MultipartFile.fromBytes(bytes, filename: filename, contentType: MediaType.parse(contentType)),
                ));
              } else {
                form.files.add(MapEntry(field, MultipartFile.fromBytes(bytes, filename: filename)));
              }
              continue;
            }
          }

          // String path (mobile)
          if (item is String) {
            final fileName = item.split('/').last;
            form.files.add(
              MapEntry(
                field,
                await MultipartFile.fromFile(item, filename: fileName),
              ),
            );
            continue;
          }

          throw Exception("Unsupported file type for multipart: ${item.runtimeType}");
        }
      }
    }

    return _request("POST", path, data: form, contentType: "multipart/form-data");
  }



  Future<Map<String, dynamic>> putJson(String path,
      {Map<String, dynamic>? body}) async {
    return _request("PUT", path,
        data: body, contentType: "application/json");
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _request("DELETE", path);
  }

  // -------------------------
  // INTERNAL REQUEST HANDLER
  // -------------------------

  Future<Map<String, dynamic>> _request(
      String method,
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        String? contentType,
      }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers:
          contentType != null ? {"Content-Type": contentType} : null,
        ),
      );

      if (response.data is Map<String, dynamic>) {
        if (response.statusCode != null && response.statusCode! >= 400) {
          throw ApiException(
            response.data["error"] ??
                response.data["message"] ??
                "Request failed",
            statusCode: response.statusCode,
          );
        }
        return response.data;
      }

      return {"data": response.data};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw ApiException("Connection timed out");
      }

      if (e.type == DioExceptionType.badResponse &&
          e.response != null &&
          e.response!.data is Map) {
        throw ApiException(
          e.response!.data["error"] ??
              e.response!.data["message"] ??
              "Request failed",
          statusCode: e.response!.statusCode,
        );
      }

      throw ApiException(e.message ?? "Network error");
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
  // ===============================================
// GET HOME FEED (returns a List instead of a Map)
// ===============================================
  static Future<List<dynamic>?> getHomeFeed() async {
    final api = Api();
    final res = await api.get("/feed/home");

    if (res.containsKey("data")) {
      return res["data"] as List?;
    }
    return null;
  }
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await _dio.post(path, data: body);
      return res.data;
    } catch (e) {
      throw Exception("POST error: $e");
    }
  }
// ===============================================
// DOWNLOAD BYTES (used for PDFs + images)
// ===============================================
  static Future<Uint8List?> downloadBytes(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      return response.data;
    } catch (e) {
      return null;
    }
  }

// ===============================================
// BASIC GET FOR LIST ENDPOINTS (optional helper)
// ===============================================
  static Future<List<dynamic>> getList(String path) async {
    final api = Api();
    final res = await api.get(path);

    if (res["data"] is List) {
      return List<dynamic>.from(res["data"]);
    }

    return [];
  }

}
