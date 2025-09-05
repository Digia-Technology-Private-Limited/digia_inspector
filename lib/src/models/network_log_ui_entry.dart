import 'package:digia_inspector_core/digia_inspector_core.dart';

/// UI representation of a network log entry that can be in different states
class NetworkLogUIEntry {
  /// Unique identifier for this UI entry (typically the API ID or request ID)
  final String id;

  /// The initial network request log
  final NetworkRequestLog requestLog;

  /// The network response log (if available)
  final NetworkResponseLog? responseLog;

  /// The network error log (if available)
  final NetworkErrorLog? errorLog;

  /// Timestamp when this entry was created
  final DateTime timestamp;

  const NetworkLogUIEntry({
    required this.id,
    required this.requestLog,
    this.responseLog,
    this.errorLog,
    required this.timestamp,
  });

  /// Creates a new UI entry from a request log
  factory NetworkLogUIEntry.fromRequest(NetworkRequestLog requestLog) {
    return NetworkLogUIEntry(
      id: requestLog.apiId ?? requestLog.requestId,
      requestLog: requestLog,
      timestamp: requestLog.timestamp,
    );
  }

  /// Creates a copy with updated response log
  NetworkLogUIEntry withResponse(NetworkResponseLog responseLog) {
    return NetworkLogUIEntry(
      id: id,
      requestLog: requestLog,
      responseLog: responseLog,
      errorLog: errorLog,
      timestamp: timestamp,
    );
  }

  /// Creates a copy with updated error log
  NetworkLogUIEntry withError(NetworkErrorLog errorLog) {
    return NetworkLogUIEntry(
      id: id,
      requestLog: requestLog,
      responseLog: responseLog,
      errorLog: errorLog,
      timestamp: timestamp,
    );
  }

  /// Whether this entry has completed (either success or error)
  bool get isCompleted => responseLog != null || errorLog != null;

  /// Whether this entry is still pending
  bool get isPending => !isCompleted;

  /// Whether this entry has an error
  bool get hasError => errorLog != null;

  /// Whether this entry was successful
  bool get isSuccess => responseLog != null && !hasError;

  /// Gets the status code (from response or error context)
  int? get statusCode {
    if (responseLog != null) {
      return responseLog!.statusCode;
    }
    if (errorLog?.errorContext['statusCode'] != null) {
      return errorLog!.errorContext['statusCode'] as int;
    }
    return null;
  }

  /// Gets the HTTP method
  String get method => requestLog.method;

  /// Gets the URL
  Uri get url => requestLog.url;

  /// Gets the API name
  String? get apiName => requestLog.apiName;

  /// Gets the API ID
  String? get apiId => requestLog.apiId;

  /// Gets the display name (API name or URL path)
  String get displayName => apiName ?? url.path;

  /// Gets the duration (from response log)
  Duration? get duration => responseLog?.duration;

  /// Gets the request headers
  Map<String, dynamic> get requestHeaders => requestLog.headers;

  /// Gets the request body
  dynamic get requestBody => requestLog.body;

  /// Gets the response headers
  Map<String, dynamic>? get responseHeaders => responseLog?.headers;

  /// Gets the response body
  dynamic get responseBody => responseLog?.body;

  /// Gets the error information
  Object? get error => errorLog?.error;

  /// Gets the error stack trace
  StackTrace? get stackTrace => errorLog?.stackTrace;

  /// Gets the request size
  int? get requestSize => requestLog.requestSize;

  /// Gets the response size
  int? get responseSize => responseLog?.responseSize;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkLogUIEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NetworkLogUIEntry($method $displayName)';
}
