import 'package:digia_inspector/src/models/network_log_entry.dart';
import 'package:digia_inspector/src/state/log_entry_manager.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';

/// Handles correlation between network requests and responses.
///
/// This class is responsible for finding and updating network log entries
/// when responses are received, providing a clean separation of concerns
/// for network request/response correlation logic.
class NetworkLogCorrelator {
  /// Creates a new network log correlator.
  NetworkLogCorrelator({required LogEntryManager logEntryManager})
    : _logEntryManager = logEntryManager;

  /// The log entry manager to search and update entries in.
  final LogEntryManager _logEntryManager;

  /// Finds a network log entry by request ID.
  ///
  /// Used by the interceptor to correlate requests with responses
  /// using unique request IDs instead of method+URL matching.
  NetworkLogEntry? findNetworkEntryByRequestId(String? requestId) {
    if (requestId == null) return null;

    return _logEntryManager.findLogEntry(
          (entry) =>
              entry is NetworkLogEntry &&
              entry.requestId == requestId &&
              entry.isPending,
        )
        as NetworkLogEntry?;
  }

  /// Finds a network log entry by correlation information.
  ///
  /// Used by the interceptor to correlate requests with responses
  /// by matching method, URL, and timing.
  ///
  /// @deprecated Use findNetworkEntryByRequestId for better correlation.
  NetworkLogEntry? findNetworkEntry({
    required String method,
    required String url,
    DateTime? requestTime,
  }) {
    final networkEntries = _logEntryManager
        .findLogEntries((entry) => entry is NetworkLogEntry)
        .cast<NetworkLogEntry>();

    for (final entry in networkEntries.reversed) {
      if (entry.request.method == method &&
          entry.request.url == url &&
          entry.isPending) {
        // If we have request time, check if it's within a reasonable window
        if (requestTime != null) {
          final timeDiff = entry.timestamp.difference(requestTime).abs();
          if (timeDiff.inSeconds > 30) continue; // 30 second window
        }
        return entry;
      }
    }

    return null;
  }

  /// Updates a network entry and notifies the log entry manager.
  ///
  /// This method handles the update process and ensures the UI is notified.
  void updateNetworkEntry(NetworkLogEntry oldEntry, NetworkLogEntry newEntry) {
    _logEntryManager
      ..updateLogEntry(oldEntry, newEntry)
      ..notifyFiltersChanged();
  }

  /// Completes a network request with response data.
  ///
  /// Finds the corresponding pending request and updates it with response information.
  void completeNetworkRequest({
    required String? requestId,
    required int? statusCode,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    final networkEntry = findNetworkEntryByRequestId(requestId);
    if (networkEntry != null) {
      networkEntry.withResponse(
        NetworkResponseLog(
          requestId: requestId ?? '',
          statusCode: statusCode ?? 200,
          headers: headers ?? {},
          body: body,
        ),
      );
      _logEntryManager.notifyFiltersChanged();
    }
  }

  /// Fails a network request with error information.
  ///
  /// Finds the corresponding pending request and updates it with error information.
  void failNetworkRequest({
    required String? requestId,
    required String error,
    int? statusCode,
    Map<String, dynamic>? headers,
    dynamic? body,
  }) {
    final networkEntry = findNetworkEntryByRequestId(requestId);
    if (networkEntry != null) {
      networkEntry.withError(
        NetworkErrorLog(
          error: error,
          requestId: requestId,
        ),
      );
      _logEntryManager.notifyFiltersChanged();
    }
  }
}
