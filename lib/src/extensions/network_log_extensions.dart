import 'dart:convert';
import 'package:digia_inspector_core/digia_inspector_core.dart';

/// Extension methods for [UnifiedNetworkLog] providing network debugging
///  and debugging utilities.
extension NetworkLogExtensions on UnifiedNetworkLog {
  /// Gets the URL from the request.
  String get url => request.url.toString();

  /// Gets the HTTP method from the request.
  String get method => request.method;

  /// Gets the status code from the response if available.
  int? get statusCode => response?.statusCode;

  /// Gets the response headers if available.
  Map<String, dynamic>? get responseHeaders => response?.headers;

  /// Gets the response body if available.
  dynamic get responseBody => response?.body;

  /// Gets whether the request is completed.
  bool get isCompleted => !isPending && error == null;

  /// Gets whether the request has an error.
  bool get isError => hasNetworkError || isServerError || isClientError;

  /// Gets the API name from the request.
  String? get apiName => request.apiName;

  /// Gets the display name (using existing implementation).
  String get displayName => request.apiName ?? request.url.path;

  /// Converts the network request to a cURL command string.
  ///
  /// Generates a properly formatted cURL command that can be executed
  /// in a terminal to reproduce the same HTTP request. Includes proper
  /// escaping for shell execution and handles headers, body, and query
  /// parameters.
  ///
  /// Returns a complete cURL command string, or null if the request
  /// data is insufficient to generate a valid command.
  ///
  /// Example output:
  /// ```bash
  /// $ curl -X POST "https://api.example.com/users" \
  ///   -H "Content-Type: application/json" \
  ///   -H "Authorization: Bearer token123" \
  ///   --data '{"name":"John Doe","email":"john@example.com"}'
  /// ```
  String? toCurlCommand() {
    try {
      final buffer = StringBuffer('curl');

      // Only add method if not GET
      if (request.method.toUpperCase() != 'GET') {
        buffer.write(' -X ${request.method.toUpperCase()}');
      }

      // Add URL with single quotes and proper escaping
      final escapedUrl = _escapeShellString(url);
      buffer.write(" '$escapedUrl'");

      // Add headers with single quotes
      if (request.headers.isNotEmpty) {
        request.headers.forEach((key, value) {
          final escapedKey = _escapeShellString(key);
          final escapedValue = _escapeShellString(value.toString());
          buffer.write(" \\\n  -H '$escapedKey: $escapedValue'");
        });
      }

      // Add request body for methods that support it
      if (_methodSupportsBody() && request.body != null) {
        var body = request.body;

        // Handle FormData by converting to Map
        if (body.runtimeType.toString().contains('FormData')) {
          // If requestBody is FormData, try to convert to Map
          try {
            // For now, convert to string representation as we can't directly
            // access FormData fields
            body = {'form_data': body.toString()};
          } on Exception catch (_) {
            body = {'form_data': 'Unable to serialize FormData'};
          }
        }

        final String bodyString;
        if (body is String) {
          bodyString = body;
        } else if (body is Map || body is List) {
          bodyString = jsonEncode(body);
        } else {
          bodyString = body.toString();
        }

        if (bodyString.isNotEmpty) {
          final escapedBody = _escapeShellString(bodyString);
          buffer.write(" \\\n  -d '$escapedBody'");
        }
      }

      return buffer.toString();
    } on Exception catch (_) {
      return null;
    }
  }

  /// Formats the request duration as a human-readable string.
  ///
  /// Returns a formatted duration string appropriate for display in
  /// debugging interfaces. Shows milliseconds for short durations
  /// and seconds for longer ones.
  ///
  /// Returns:
  /// - "Pending..." if the request is still in progress
  /// - "Failed" if the request failed without timing data
  /// - Formatted duration string (e.g., "234ms", "2.3s") if available
  /// - "Unknown" if duration cannot be determined
  String asReadableDuration() {
    if (isPending) {
      return 'Pending...';
    }

    if (duration == null) {
      return hasNetworkError ? 'Failed' : 'Unknown';
    }

    final milliseconds = duration!.inMilliseconds;

    if (milliseconds < 1000) {
      return '${milliseconds}ms';
    } else if (milliseconds < 10000) {
      final seconds = milliseconds / 1000.0;
      return '${seconds.toStringAsFixed(1)}s';
    } else {
      final seconds = (milliseconds / 1000).round();
      return '${seconds}s';
    }
  }

  /// Checks if the network request completed with a successful status code.
  ///
  /// Returns `true` if the request completed (not pending or failed) and
  /// the status code indicates success (200-299 range).
  bool get isSuccessful {
    return isCompleted &&
        statusCode != null &&
        statusCode! >= 200 &&
        statusCode! < 300;
  }

  /// Checks if the network request resulted in a client error (4xx).
  ///
  /// Returns `true` if the status code is in the 400-499 range,
  /// indicating a client-side error (bad request, unauthorized, etc.).
  bool get isClientError {
    return statusCode != null && statusCode! >= 400 && statusCode! < 500;
  }

  /// Checks if the network request resulted in a server error (5xx).
  ///
  /// Returns `true` if the status code is in the 500-599 range,
  /// indicating a server-side error (internal server error, bad gateway, etc.).
  bool get isServerError {
    return statusCode != null && statusCode! >= 500 && statusCode! < 600;
  }

  /// Gets a human-readable status description.
  ///
  /// Returns a descriptive string based on the current request status
  /// and status code, suitable for display in debugging interfaces.
  String get statusDescription {
    if (isPending) {
      return 'Pending';
    }

    if (error != null) {
      return 'Failed: $error';
    }

    if (statusCode == null) {
      return 'Unknown';
    }

    final code = statusCode!;

    // Common status codes with descriptions
    switch (code) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 204:
        return 'No Content';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 500:
        return 'Internal Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      default:
        if (code >= 200 && code < 300) return 'Success';
        if (code >= 300 && code < 400) return 'Redirect';
        if (code >= 400 && code < 500) return 'Client Error';
        if (code >= 500 && code < 600) return 'Server Error';
        return 'Unknown';
    }
  }

  /// Gets the content type from request or response headers.
  ///
  /// Searches both request and response headers for Content-Type,
  /// returning the MIME type portion (without parameters like charset).
  String? get contentType {
    // Check response headers first
    if (responseHeaders != null) {
      final responseContentType = _extractContentType(responseHeaders!);
      if (responseContentType != null) return responseContentType;
    }

    // Fall back to request headers
    return _extractContentType(request.headers);
  }

  /// Checks if the response content is JSON.
  ///
  /// Returns `true` if the Content-Type indicates JSON data.
  bool get isJsonResponse {
    final ct = contentType?.toLowerCase();
    return ct != null &&
        (ct.contains('application/json') ||
            ct.contains('text/json') ||
            ct.contains('+json'));
  }

  /// Gets the response size in bytes if available.
  ///
  /// Attempts to determine the response size from Content-Length header
  /// or by measuring the response body size.
  int? get responseSize {
    // Try Content-Length header first
    if (responseHeaders != null) {
      final contentLength = _getHeaderValue(responseHeaders!, 'content-length');
      if (contentLength != null) {
        return int.tryParse(contentLength);
      }
    }

    // Fall back to measuring response body
    if (responseBody != null) {
      if (responseBody is String) {
        return (responseBody as String).length;
      } else {
        try {
          return jsonEncode(responseBody).length;
        } on Exception catch (_) {
          return responseBody.toString().length;
        }
      }
    }

    return null;
  }

  /// Formats the response size as a human-readable string.
  ///
  /// Returns a formatted size string (e.g., "1.2KB", "345B") suitable
  /// for display in debugging interfaces.
  String get formattedResponseSize {
    final size = responseSize;
    if (size == null) return 'Unknown';

    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      final kb = size / 1024.0;
      return '${kb.toStringAsFixed(1)}KB';
    } else {
      final mb = size / (1024.0 * 1024.0);
      return '${mb.toStringAsFixed(1)}MB';
    }
  }

  /// Extracts the host portion from the URL.
  ///
  /// Returns the hostname/domain from the request URL,
  /// useful for grouping requests by host in debugging interfaces.
  String? get host {
    try {
      return Uri.parse(url).host;
    } on Exception catch (_) {
      return null;
    }
  }

  /// Extracts the path portion from the URL.
  ///
  /// Returns the path component of the URL without query parameters,
  /// useful for identifying API endpoints.
  String? get path {
    try {
      return Uri.parse(url).path;
    } on Exception catch (_) {
      return null;
    }
  }

  /// Checks if the HTTP method supports a request body.
  bool _methodSupportsBody() {
    final upperMethod = method.toUpperCase();
    return ['POST', 'PUT', 'PATCH', 'DELETE'].contains(upperMethod);
  }

  /// Escapes a string for safe use in shell commands.
  ///
  /// Handles special characters that could break shell command parsing.
  String _escapeShellString(String input) {
    // Escape single quotes via input.replaceAll("'", "'\''")
    return input.replaceAll("'", r"'\''");
  }

  /// Extracts Content-Type from headers map.
  ///
  /// Searches for Content-Type header (case-insensitive) and returns
  /// the MIME type portion without parameters.
  String? _extractContentType(Map<String, dynamic> headers) {
    final contentType = _getHeaderValue(headers, 'content-type');
    if (contentType == null) return null;

    // Extract MIME type (everything before first semicolon)
    final semicolonIndex = contentType.indexOf(';');
    if (semicolonIndex >= 0) {
      return contentType.substring(0, semicolonIndex).trim();
    }

    return contentType.trim();
  }

  /// Gets a header value by name (case-insensitive).
  String? _getHeaderValue(Map<String, dynamic> headers, String name) {
    final lowerName = name.toLowerCase();

    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == lowerName) {
        return entry.value?.toString();
      }
    }

    return null;
  }
}
