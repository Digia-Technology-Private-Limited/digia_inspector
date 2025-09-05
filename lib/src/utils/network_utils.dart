import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/state/network_log_manager.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:flutter/material.dart';

/// Utilities for working with network logs and HTTP data
class NetworkLogUtils {
  /// Gets the appropriate color for an HTTP method
  static Color getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return InspectorColors.methodGet;
      case 'POST':
        return InspectorColors.methodPost;
      case 'PUT':
        return InspectorColors.methodPut;
      default:
        return InspectorColors.contentSecondary;
    }
  }

  /// Gets the appropriate color for a status code
  static Color getStatusCodeColor(int? statusCode) {
    if (statusCode == null) return InspectorColors.contentSecondary;

    if (statusCode.isSuccess) {
      return InspectorColors.statusSuccess;
    } else if (statusCode.isRedirection) {
      return InspectorColors.statusWarning;
    } else if (statusCode.isClientError || statusCode.isServerError) {
      return InspectorColors.statusError;
    } else {
      return InspectorColors.statusInfo;
    }
  }

  /// Gets display text for status code
  static String getStatusDisplayText(int? statusCode) {
    if (statusCode == null) return 'Pending';
    return '$statusCode';
  }

  /// Gets display text for status with description
  static String getStatusWithDescription(int? statusCode) {
    if (statusCode == null) return 'Pending';
    return '$statusCode ${statusCode.description}';
  }

  /// Extracts display name from network log entry
  static String getDisplayName(NetworkLogUIEntry entry) {
    // Use the API name from the request if available
    if (entry.apiName?.isNotEmpty ?? false) {
      return entry.apiName!;
    }

    // Fall back to URL path
    final path = entry.url.path;
    if (path.isEmpty || path == '/') {
      return entry.url.host;
    }

    return path;
  }

  /// Determines if a request method should show payload tab
  static bool shouldShowPayloadTab(String method) {
    return method.hasRequestBody;
  }

  /// Formats headers map for display
  static Map<String, String> formatHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) => MapEntry(key, value.toString()));
  }

  /// Gets the size display string for a network log entry
  static String getSizeDisplay(NetworkLogUIEntry entry) {
    final requestSize = entry.requestSize;
    final responseSize = entry.responseSize;

    if (requestSize != null && responseSize != null) {
      final total = requestSize + responseSize;
      return total.fileSizeFormat;
    } else if (responseSize != null) {
      return responseSize.fileSizeFormat;
    } else if (requestSize != null) {
      return requestSize.fileSizeFormat;
    }

    return '--';
  }

  /// Checks if a network log entry matches a search query
  static bool matchesSearchQuery(NetworkLogUIEntry entry, String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();

    // Search in display name
    final displayName = getDisplayName(entry).toLowerCase();
    if (displayName.contains(lowerQuery)) return true;

    // Search in HTTP method
    if (entry.method.toLowerCase().contains(lowerQuery)) return true;

    // Search in URL
    if (entry.url.toString().toLowerCase().contains(lowerQuery)) return true;

    // Search in API ID
    if (entry.apiId?.toLowerCase().contains(lowerQuery) ?? false) return true;

    // Search in status code
    final statusCode = entry.statusCode;
    if (statusCode != null && statusCode.toString().contains(lowerQuery)) {
      return true;
    }

    return false;
  }

  /// Filters logs by status type
  static List<NetworkLogUIEntry> filterByStatusType(
    List<NetworkLogUIEntry> entries,
    NetworkStatusFilter filter,
  ) {
    switch (filter) {
      case NetworkStatusFilter.all:
        return entries;
      case NetworkStatusFilter.success:
        return entries.where((entry) => entry.isSuccess).toList();
      case NetworkStatusFilter.error:
        return entries.where((entry) => entry.hasError).toList();
      case NetworkStatusFilter.pending:
        return entries.where((entry) => entry.isPending).toList();
    }
  }

  /// Pretty formats JSON for display
  static String formatJsonForDisplay(dynamic jsonData) {
    if (jsonData == null) return 'null';

    try {
      if (jsonData is String) {
        // Try to parse as JSON first
        try {
          final parsed = parseJson(jsonData);
          return formatJsonString(parsed);
        } catch (_) {
          return jsonData; // Return as-is if not valid JSON
        }
      } else {
        return formatJsonString(jsonData);
      }
    } catch (e) {
      return jsonData.toString();
    }
  }

  /// Parse JSON string
  static dynamic parseJson(String jsonString) {
    // Implementation would depend on your JSON parsing library
    // For now, return the string as-is
    return jsonString;
  }

  /// Format JSON object as indented string
  static String formatJsonString(dynamic json) {
    // Implementation would depend on your JSON formatting library
    // For now, return string representation
    return json.toString();
  }
}
