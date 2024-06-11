// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:mobile/app/core/logger/logger.dart';

enum Level {
  BASIC,
  HEADERS,
  BODY,
}

class DioRequestLogger extends Interceptor {
  final Level level;

  DioRequestLogger({required this.level});

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    if (level == Level.BASIC) {
      Log.info("${request.method} ${request.uri} [${response.statusCode}]\n");
    } else {
      final buffer = StringBuffer();

      buffer.write("${request.method} ${request.uri}\n");

      if (level == Level.HEADERS) {
        buffer.write("${stringifyHeaders(request.headers)}\n\n\n");
      } else {
        buffer.write("${stringifyHeaders(request.headers)}\n\n");
        try {
          buffer.write("${jsonEncode(request.data)}\n\n\n");
        } catch (e) {
          buffer.write(request.data.toString());
        }
      }

      buffer.write("Response Status: ${response.statusCode}\n");

      if (level == Level.HEADERS) {
        buffer.write("${stringifyHeaders(response.headers.map)}\n");
      } else {
        buffer.write("${stringifyHeaders(response.headers.map)}\n\n");
        buffer.write("${jsonEncode(response.data)}\n");
      }

      Log.info(buffer.toString());
    }
    return handler.next(response);
  }

  String stringifyHeaders(Map<String, dynamic> headers) {
    return headers.keys
        .map((key) => key != "Authorization"
            ? "$key: ${headers[key]}"
            : "$key: ${headers[key]}")
        // : "$key: [Filtered]")
        .join("\n");
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final request = err.requestOptions;
    if (level == Level.BASIC) {
      Log.info(
          "${request.method} ${request.uri} [${err.response?.statusCode}]\n");
    } else {
      final buffer = StringBuffer();

      buffer.write("${request.method} ${request.uri}\n");

      if (level == Level.HEADERS) {
        buffer.write("${stringifyHeaders(request.headers)}\n\n\n");
      } else {
        buffer.write("${stringifyHeaders(request.headers)}\n\n");
        try {
          buffer.write("${jsonEncode(request.data)}\n\n\n");
        } catch (e) {
          buffer.write(request.data.toString());
        }
      }

      buffer.write("Response Status: ${err.response?.statusCode}\n");

      if (level == Level.HEADERS && err.response?.headers.map != null) {
        buffer.write("${stringifyHeaders(err.response!.headers.map)}\n");
      } else {
        if (err.response?.headers.map != null) {
          buffer.write("${stringifyHeaders(err.response!.headers.map)}\n\n");
        }
        buffer.write("${jsonEncode(err.response?.data)}\n");
      }
      Log.info(buffer.toString());
    }

    FirebaseCrashlytics.instance.recordError(
      err,
      err.stackTrace,
      information: [
        'METHOD: ${request.method}',
        'URI: ${request.uri}',
        'STATUS: ${err.response?.statusCode}',
        'HEADERS: ${stringifyHeaders(request.headers)}',
        'DATA: ${request.data}',
      ],
    );

    return handler.next(err);
  }
}
