import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // الـ API غالباً يرجع 4xx مع { success, message } — نقرأ الرسالة بدل رمي Dio الافتراضي
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConfig.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _logRequest(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          handler.next(response);
        },
        onError: (error, handler) {
          _logDioError(error);
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;

  T unwrap<T>(Response response, T Function(dynamic data) map) {
    final status = response.statusCode ?? 0;
    final body = response.data;

    if (body is Map) {
      final json = Map<String, dynamic>.from(body);
      final success = json['success'] == true;
      final message = (json['message'] as String?)?.trim();
      if (!success || status >= 400) {
        final ex = ApiException(
          (message != null && message.isNotEmpty)
              ? message
              : _fallbackMessage(status),
          statusCode: status,
        );
        _logApiError(
          method: response.requestOptions.method,
          url: response.requestOptions.uri.toString(),
          statusCode: status,
          message: ex.message,
          body: json,
        );
        throw ex;
      }
      final data = json['data'];
      if (data is Map) {
        return map(Map<String, dynamic>.from(data));
      }
      if (data is List) {
        return map(data);
      }
      return map(data);
    }

    if (status >= 400) {
      final ex = ApiException(_fallbackMessage(status), statusCode: status);
      _logApiError(
        method: response.requestOptions.method,
        url: response.requestOptions.uri.toString(),
        statusCode: status,
        message: ex.message,
        body: body,
      );
      throw ex;
    }
    throw ApiException('استجابة غير متوقعة من الخادم', statusCode: status);
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    bool attachComplexId = true,
    required T Function(dynamic data) map,
  }) async {
    try {
      final res = await _dio.get(
        path,
        queryParameters: attachComplexId ? _withComplex(query) : query,
      );
      return unwrap(res, map);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    required T Function(dynamic data) map,
  }) async {
    try {
      final res = await _dio.post(path, data: data, queryParameters: query);
      return unwrap(res, map);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    required T Function(dynamic data) map,
  }) async {
    try {
      final res = await _dio.put(path, data: data, queryParameters: query);
      return unwrap(res, map);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic data) map,
  }) async {
    try {
      final res = await _dio.delete(path, queryParameters: query);
      return unwrap(res, map);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<T> postMultipart<T>(
    String path, {
    required FormData data,
    required T Function(dynamic data) map,
  }) async {
    try {
      final res = await _dio.post(
        path,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      return unwrap(res, map);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Map<String, dynamic> _withComplex(Map<String, dynamic>? query) {
    final q = <String, dynamic>{...?query};
    q.putIfAbsent('ComplexId', () => AppConfig.complexId);
    return q;
  }

  String _fallbackMessage(int status) {
    switch (status) {
      case 400:
        return 'طلب غير صالح';
      case 401:
        return 'بيانات الدخول غير صحيحة أو انتهت الجلسة';
      case 403:
        return 'غير مصرح بهذا الإجراء';
      case 404:
        return 'المسار أو العنصر غير موجود على الخادم';
      default:
        return 'حدث خطأ غير متوقع ($status)';
    }
  }

  ApiException _fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map && data['message'] is String && (data['message'] as String).trim().isNotEmpty) {
      return ApiException((data['message'] as String).trim(), statusCode: status);
    }
    if (status != null) return ApiException(_fallbackMessage(status), statusCode: status);
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException('انتهت مهلة الاتصال بالخادم');
    }
    if (e.type == DioExceptionType.connectionError) {
      return ApiException('تعذر الاتصال بالخادم (${AppConfig.apiBaseUrl})');
    }
    return ApiException('حدث خطأ في الاتصال بالخادم');
  }

  void _logRequest(RequestOptions options) {
    final buffer = StringBuffer()
      ..writeln('━━━━━━━━ REQUEST ━━━━━━━━')
      ..writeln('${options.method} ${options.uri}')
      ..writeln('Headers: ${_safeHeaders(options.headers)}');
    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('Query: ${_pretty(options.queryParameters)}');
    }
    if (options.data != null) {
      buffer.writeln('Body: ${_pretty(options.data)}');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    _print(buffer.toString());
  }

  void _logResponse(Response response) {
    final buffer = StringBuffer()
      ..writeln('━━━━━━━━ RESPONSE ━━━━━━━')
      ..writeln('${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}')
      ..writeln('Body: ${_pretty(response.data)}')
      ..writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    _print(buffer.toString());
  }

  void _logDioError(DioException error) {
    final buffer = StringBuffer()
      ..writeln('━━━━━━━━ DIO ERROR ━━━━━━')
      ..writeln('${error.requestOptions.method} ${error.requestOptions.uri}')
      ..writeln('Type: ${error.type}')
      ..writeln('Status: ${error.response?.statusCode}')
      ..writeln('Message: ${error.message}')
      ..writeln('Body: ${_pretty(error.response?.data)}')
      ..writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    _print(buffer.toString(), isError: true);
  }

  void _logApiError({
    required String method,
    required String url,
    required int statusCode,
    required String message,
    Object? body,
  }) {
    final buffer = StringBuffer()
      ..writeln('━━━━━━━━ API ERROR ━━━━━━━')
      ..writeln('$method $url')
      ..writeln('Status: $statusCode')
      ..writeln('Message: $message')
      ..writeln('Body: ${_pretty(body)}')
      ..writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    _print(buffer.toString(), isError: true);
  }

  Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    final auth = copy['Authorization'] ?? copy['authorization'];
    if (auth is String && auth.isNotEmpty) {
      copy['Authorization'] = auth.length > 20 ? '${auth.substring(0, 20)}…' : '***';
    }
    return copy;
  }

  String _pretty(Object? value) {
    try {
      if (value == null) return 'null';
      if (value is FormData) return '[FormData]';
      if (value is Map || value is List) {
        return const JsonEncoder.withIndent('  ').convert(value);
      }
      if (value is String) return value;
      return value.toString();
    } catch (_) {
      return value.toString();
    }
  }

  void _print(String message, {bool isError = false}) {
    if (kDebugMode) {
      debugPrint(message);
      developer.log(message, name: 'API', level: isError ? 1000 : 800);
    } else {
      // حتى في release أثناء التجربة على الجهاز
      debugPrint(message);
    }
  }
}
