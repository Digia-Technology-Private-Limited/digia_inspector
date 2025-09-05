import 'dart:convert';

import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:dio/dio.dart';

/// Dio interceptor that captures network requests and responses for debugging.
///
/// This interceptor creates [NetworkRequestLog], [NetworkResponseLog] and
/// [NetworkErrorLog] instances that integrate directly with the
/// [InspectorController].
///
/// The interceptor correlates requests and responses using URL and method
/// matching, eliminating the need for separate request ID tracking.
///
/// Example usage:
/// ```dart
/// final dio = Dio();
/// final controller = InspectorController();
/// dio.interceptors.add(DigiaDioInterceptor(controller: controller));
/// ```
class DigiaDioInterceptorImpl extends Interceptor
    implements DigiaDioInterceptor {
  /// Creates a new Dio interceptor with the specified inspector controller.
  DigiaDioInterceptorImpl({required InspectorController controller})
    : _controller = controller;

  /// The inspector controller to log network entries to.
  final InspectorController _controller;

  /// Map to track request timing information.
  final Map<RequestOptions, DateTime> _requestTimes = {};

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

  /// Formats a DioException into a readable error message.
  String _formatDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Bad response: ${error.response?.statusCode ?? 'Unknown'}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error: ${error.message ?? 'Unknown'}';
      case DioExceptionType.badCertificate:
        return 'Bad certificate';
      case DioExceptionType.unknown:
        return 'Unknown error: ${error.message ?? 'No message'}';
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Extract API name and ID from request options extra field
    final apiName = options.extra['apiName'] as String?;
    final apiId = options.extra['apiId'] as String?;

    // Create network request log
    final requestLog = NetworkRequestLog(
      requestId: DateTime.now().microsecondsSinceEpoch.toString(),
      method: options.method,
      url: options.uri,
      headers: _sanitizeHeaders(options.headers),
      body: _sanitizeBody(options.data),
      queryParameters: options.queryParameters.isNotEmpty
          ? Map<String, dynamic>.from(options.queryParameters)
          : null,
      apiName: apiName,
      apiId: apiId,
      timestamp: DateTime.now(),
    );

    // Log to network manager
    _controller.networkLogManager.addRequestLog(requestLog);

    // Store request ID for correlation
    options.extra['digiaRequestId'] = requestLog.requestId;

    // Track request timing
    _requestTimes[options] = DateTime.now();

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final requestTime = _requestTimes.remove(response.requestOptions);
    final requestId =
        response.requestOptions.extra['digiaRequestId'] as String?;

    if (requestId != null) {
      // Create response log
      final responseLog = NetworkResponseLog(
        requestId: requestId,
        statusCode: response.statusCode ?? 200,
        headers: _sanitizeHeaders(response.headers.map),
        body: _sanitizeBody(response.data),
        duration: requestTime != null
            ? DateTime.now().difference(requestTime)
            : null,
        timestamp: DateTime.now(),
      );

      // Log to network manager
      _controller.networkLogManager.addResponseLog(responseLog);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _requestTimes.remove(err.requestOptions);
    final requestId = err.requestOptions.extra['digiaRequestId'] as String?;

    if (requestId != null) {
      // Create error log
      final errorLog = NetworkErrorLog(
        requestId: requestId,
        error: _formatDioError(err),
        failedUrl: err.requestOptions.uri.toString(),
        failedMethod: err.requestOptions.method,
        stackTrace: err.stackTrace,
        timestamp: DateTime.now(),
        errorContext: {
          'type': err.type.toString(),
          if (err.response?.statusCode != null)
            'statusCode': err.response!.statusCode,
          if (err.response?.headers.map != null)
            'responseHeaders': _sanitizeHeaders(err.response!.headers.map),
          if (err.response?.data != null)
            'responseBody': _sanitizeBody(err.response!.data),
        },
      );

      // Log to network manager
      _controller.networkLogManager.addErrorLog(errorLog);
    }

    handler.next(err);
  }

  @override
  Interceptor get interceptor => this;
}
