import 'package:flutter/services.dart';

/// Extension methods for common operations
extension StringExtensionsForInspector on String? {
  /// Returns true if string is not null and not empty
  bool get isNotEmpty => this != null && this!.trim().isNotEmpty;

  /// Returns the string or a fallback if null/empty
  String orDefault(String fallback) => isNotEmpty ? this! : fallback;
}

extension HttpMethodExtensions on String {
  /// Returns true if the HTTP method typically has a request body
  bool get hasRequestBody {
    final method = toUpperCase();
    return method == 'POST' ||
        method == 'PUT' ||
        method == 'PATCH' ||
        method == 'DELETE';
  }

  /// Returns true if the HTTP method is considered safe (read-only)
  bool get isSafeMethod {
    final method = toUpperCase();
    return method == 'GET' || method == 'HEAD' || method == 'OPTIONS';
  }
}

extension StatusCodeExtensions on int {
  /// Returns true if status code indicates success (2xx)
  bool get isSuccess => this >= 200 && this < 300;

  /// Returns true if status code indicates client error (4xx)
  bool get isClientError => this >= 400 && this < 500;

  /// Returns true if status code indicates server error (5xx)
  bool get isServerError => this >= 500 && this < 600;

  /// Returns true if status code indicates redirection (3xx)
  bool get isRedirection => this >= 300 && this < 400;

  /// Returns human-readable description of the status code
  String get description {
    switch (this) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 202:
        return 'Accepted';
      case 204:
        return 'No Content';
      case 301:
        return 'Moved Permanently';
      case 302:
        return 'Found';
      case 304:
        return 'Not Modified';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 405:
        return 'Method Not Allowed';
      case 409:
        return 'Conflict';
      case 422:
        return 'Unprocessable Entity';
      case 429:
        return 'Too Many Requests';
      case 500:
        return 'Internal Server Error';
      case 501:
        return 'Not Implemented';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      case 504:
        return 'Gateway Timeout';
      default:
        return 'Unknown';
    }
  }
}

extension DurationExtensions on Duration {
  /// Formats duration for display in network logs
  String get displayString {
    if (inMilliseconds < 1000) {
      return '${inMilliseconds}ms';
    } else if (inMilliseconds < 60000) {
      final seconds = inMilliseconds / 1000;
      return '${seconds.toStringAsFixed(1)}s';
    } else {
      final minutes = inMinutes;
      final remainingSeconds = (inMilliseconds % 60000) / 1000;
      return '${minutes}m ${remainingSeconds.toStringAsFixed(0)}s';
    }
  }
}

extension DateTimeExtensions on DateTime {
  /// Formats timestamp for network log display
  String get networkLogFormat {
    final now = DateTime.now();
    final isToday = year == now.year && month == now.month && day == now.day;

    if (isToday) {
      // Show time only for today
      return '${hour.toString().padLeft(2, '0')}:'
          '${minute.toString().padLeft(2, '0')}:'
          '${second.toString().padLeft(2, '0')}';
    } else {
      // Show date and time for other days
      return '${month}/${day} '
          '${hour.toString().padLeft(2, '0')}:'
          '${minute.toString().padLeft(2, '0')}';
    }
  }

  /// Returns relative time string (e.g., "2 minutes ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }
}

extension FileSizeExtensions on int {
  /// Formats file size for display
  String get fileSizeFormat {
    if (this < 1024) {
      return '${this}B';
    } else if (this < 1024 * 1024) {
      return '${(this / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}

/// Clipboard utilities
class ClipboardUtils {
  /// Copies text to clipboard and returns success status
  static Future<bool> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (e) {
      return false;
    }
  }
}
