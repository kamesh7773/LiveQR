import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env.dart';
import '../constants/api_endpoints.dart';

part 'api_client.g.dart';

/// Dio for the LiveQR API. Sends the signed-in user's Firebase ID token,
/// which the backend verifies on every `/v1` request.
@Riverpod(keepAlive: true)
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl(ApiEndpoints.baseUrl),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // getIdToken() refreshes the token itself when it has expired.
        final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      // Surface the backend's {"error": "..."} text as the exception message.
      onError: (error, handler) {
        final data = error.response?.data;
        final serverMessage = data is Map
            ? (data['error'] ?? data['message'])?.toString()
            : null;
        final message = switch (error.type) {
          DioExceptionType.connectionTimeout ||
          DioExceptionType.receiveTimeout ||
          DioExceptionType.sendTimeout ||
          DioExceptionType.connectionError =>
            'No internet connection, please check your connection',
          _ => serverMessage ?? 'Something went wrong',
        };
        handler.next(error.copyWith(message: message));
      },
    ),
  );

  if (Env.enableLogs && kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  return dio;
}

/// The Android emulator reaches the host machine's localhost at 10.0.2.2.
String _baseUrl(String url) =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android
    ? url.replaceFirst('//localhost', '//10.0.2.2')
    : url;
