import 'dart:convert';

import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:dio/dio.dart';

/// Dio interceptor that captures network requests and responses for debugging.
///
/// This interceptor logs all network activity passing through Dio to the
/// configured DigiaLogger using RequestLog, ResponseLog, and NetworkErrorLog events.
///
/// Example usage:
/// ```dart
/// final dio = Dio();
/// final controller = InspectorController();
/// dio.interceptors.add(DigiaDioInterceptor(controller));
/// ```
class DigiaDioInterceptor extends Interceptor {
  /// Creates a new Dio interceptor with the specified logger.
  DigiaDioInterceptor(this._logger);

  /// The logger to send network events to.
  final DigiaLogger _logger;

  /// Map to track request/response correlation.
  final Map<RequestOptions, String> _requestIds = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Set start time for duration calculation
    options.extra['start_time'] = DateTime.now();

    final request = _createRequestLog(options);
    _requestIds[options] = request.id;
    _logger.log(request);

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final requestId = _requestIds.remove(response.requestOptions);
    if (requestId != null) {
      final responseLog = _createResponseLog(response, requestId);
      _logger.log(responseLog);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = _requestIds.remove(err.requestOptions);
    final errorLog = _createNetworkErrorLog(err, requestId);
    _logger.log(errorLog);

    handler.next(err);
  }

  /// Creates a RequestLog from Dio RequestOptions.
  RequestLog _createRequestLog(RequestOptions options) {
    return RequestLog(
      method: options.method,
      url: options.uri,
      headers: _sanitizeHeaders(options.headers),
      body: _sanitizeBody(options.data),
      requestSize: _calculateSize(options.data),
      tags: {'dio'},
    );
  }

  /// Creates a ResponseLog from Dio Response.
  ResponseLog _createResponseLog(Response<dynamic> response, String requestId) {
    final requestTime =
        response.requestOptions.extra['start_time'] as DateTime?;
    final duration = requestTime != null
        ? DateTime.now().difference(requestTime)
        : null;

    return ResponseLog(
      requestId: requestId,
      statusCode: response.statusCode ?? 0,
      headers: _sanitizeHeaders(response.headers.map),
      body: _sanitizeBody(response.data),
      responseSize: _calculateSize(response.data),
      duration: duration,
      tags: {'dio'},
    );
  }

  /// Creates a NetworkErrorLog from DioException.
  NetworkErrorLog _createNetworkErrorLog(
    DioException error,
    String? requestId,
  ) {
    return NetworkErrorLog(
      requestId: requestId,
      error: error,
      stackTrace: error.stackTrace,
      errorContext: {
        'type': error.type.toString(),
        'message': error.message,
        'response': error.response?.data,
        'statusCode': error.response?.statusCode,
      },
      tags: {'dio', 'error'},
    );
  }

  /// Sanitizes headers by removing sensitive information.
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};

    for (final entry in headers.entries) {
      final key = entry.key.toLowerCase();

      // Hide sensitive headers
      if (_isSensitiveHeader(key)) {
        sanitized[entry.key] = '***';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }

  /// Sanitizes request/response body by limiting size and hiding sensitive data.
  dynamic _sanitizeBody(dynamic body) {
    if (body == null) return null;

    try {
      String bodyString;

      if (body is String) {
        bodyString = body;
      } else if (body is Map || body is List) {
        bodyString = jsonEncode(body);
      } else {
        bodyString = body.toString();
      }

      // Limit body size for display (max 10KB)
      if (bodyString.length > 10240) {
        return '${bodyString.substring(0, 10240)}... [truncated]';
      }

      // Try to parse as JSON to pretty-print
      try {
        final jsonBody = jsonDecode(bodyString);
        return jsonBody;
      } catch (_) {
        return bodyString;
      }
    } catch (_) {
      return body?.toString() ?? 'Unable to serialize body';
    }
  }

  /// Checks if a header contains sensitive information.
  bool _isSensitiveHeader(String headerName) {
    final sensitive = [
      'authorization',
      'cookie',
      'set-cookie',
      'x-api-key',
      'x-auth-token',
      'access-token',
      'refresh-token',
    ];

    return sensitive.any((s) => headerName.contains(s));
  }

  /// Calculates the approximate size of data in bytes.
  int? _calculateSize(dynamic data) {
    if (data == null) return null;

    try {
      if (data is String) {
        return data.length;
      } else if (data is Map || data is List) {
        return jsonEncode(data).length;
      } else {
        return data.toString().length;
      }
    } catch (_) {
      return null;
    }
  }
}
