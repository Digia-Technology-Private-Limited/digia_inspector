import 'dart:async';

import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/foundation.dart';

/// Controller that manages the state of the debugging inspector.
///
/// This class serves as both a [DigiaLogger] and a state manager for the
/// inspector UI. It stores all log events in memory and provides filtering,
/// searching, and real-time updates to the UI.
class InspectorController extends ChangeNotifier implements DigiaLogger {
  /// Creates a new inspector controller.
  ///
  /// [maxLogs] determines the maximum number of log events to keep in memory.
  /// Older logs are automatically removed when this limit is exceeded.
  InspectorController({this.maxLogs = 1000});

  /// All log events in chronological order.
  final List<LogEvent> _allLogs = [];

  /// Filtered log events based on current filters.
  List<LogEvent> _filteredLogs = [];

  /// Current search query.
  String _searchQuery = '';

  /// Current log level filter.
  LogLevel? _levelFilter;

  /// Current category filter.
  String? _categoryFilter;

  /// Current event type filter.
  String? _eventTypeFilter;

  /// Whether the inspector is currently visible.
  bool _isVisible = false;

  /// Maximum number of logs to keep in memory.
  final int maxLogs;

  /// Stream controller for log events.
  final StreamController<LogEvent> _logStreamController =
      StreamController<LogEvent>.broadcast();

  /// Stream of new log events.
  Stream<LogEvent> get logStream => _logStreamController.stream;

  /// All log events (read-only).
  List<LogEvent> get allLogs => List.unmodifiable(_allLogs);

  /// Filtered log events (read-only).
  List<LogEvent> get filteredLogs => List.unmodifiable(_filteredLogs);

  /// Current search query.
  String get searchQuery => _searchQuery;

  /// Current log level filter.
  LogLevel? get levelFilter => _levelFilter;

  /// Current category filter.
  String? get categoryFilter => _categoryFilter;

  /// Current event type filter.
  String? get eventTypeFilter => _eventTypeFilter;

  /// Whether the inspector is currently visible.
  bool get isVisible => _isVisible;

  /// Total number of logs.
  int get totalCount => _allLogs.length;

  /// Number of filtered logs.
  int get filteredCount => _filteredLogs.length;

  /// Number of error logs.
  int get errorCount => _allLogs
      .where(
        (log) => log.level == LogLevel.error || log.level == LogLevel.critical,
      )
      .length;

  /// Number of warning logs.
  int get warningCount =>
      _allLogs.where((log) => log.level == LogLevel.warning).length;

  /// Available categories from all logs.
  List<String> get availableCategories {
    final categories =
        _allLogs
            .where((log) => log.category != null)
            .map((log) => log.category!)
            .toSet()
            .toList()
          ..sort();
    return categories;
  }

  /// Available event types from all logs.
  List<String> get availableEventTypes {
    final eventTypes = _allLogs.map((log) => log.eventType).toSet().toList()
      ..sort();
    return eventTypes;
  }

  @override
  void log(LogEvent event) {
    _allLogs.add(event);

    // Remove old logs if we exceed the maximum
    if (_allLogs.length > maxLogs) {
      _allLogs.removeAt(0);
    }

    // Apply current filters to the new log
    _applyFilters();

    // Emit the new log event
    _logStreamController.add(event);

    // Notify listeners
    notifyListeners();
  }

  /// Shows the inspector overlay.
  void show() {
    _isVisible = true;
    notifyListeners();
  }

  /// Hides the inspector overlay.
  void hide() {
    _isVisible = false;
    notifyListeners();
  }

  /// Toggles the inspector overlay visibility.
  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  /// Sets the search query and applies filters.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Sets the log level filter and applies filters.
  void setLevelFilter(LogLevel? level) {
    _levelFilter = level;
    _applyFilters();
    notifyListeners();
  }

  /// Sets the category filter and applies filters.
  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    _applyFilters();
    notifyListeners();
  }

  /// Sets the event type filter and applies filters.
  void setEventTypeFilter(String? eventType) {
    _eventTypeFilter = eventType;
    _applyFilters();
    notifyListeners();
  }

  /// Clears all filters.
  void clearFilters() {
    _searchQuery = '';
    _levelFilter = null;
    _categoryFilter = null;
    _eventTypeFilter = null;
    _applyFilters();
    notifyListeners();
  }

  /// Clears all log events.
  void clearLogs() {
    _allLogs.clear();
    _filteredLogs.clear();
    notifyListeners();
  }

  /// Exports all logs as JSON.
  Map<String, dynamic> exportLogsAsJson() {
    return {
      'exportTime': TimestampHelper.formatISO(DateTime.now()),
      'totalLogs': _allLogs.length,
      'logs': _allLogs.map((log) => log.toJson()).toList(),
    };
  }

  /// Imports logs from JSON.
  void importLogsFromJson(Map<String, dynamic> json) {
    final logsData = json['logs'] as List<dynamic>?;
    if (logsData == null) return;

    for (final logData in logsData) {
      if (logData is Map<String, dynamic>) {
        try {
          final event = LogEvent.fromJson(logData);
          _allLogs.add(event);
        } catch (e) {
          // Skip invalid log entries
          debugPrint('Failed to import log: $e');
        }
      }
    }

    // Remove old logs if we exceed the maximum
    while (_allLogs.length > maxLogs) {
      _allLogs.removeAt(0);
    }

    _applyFilters();
    notifyListeners();
  }

  /// Applies current filters to all logs.
  void _applyFilters() {
    _filteredLogs = _allLogs.where((log) {
      // Search query filter
      if (_searchQuery.isNotEmpty && !log.matches(_searchQuery)) {
        return false;
      }

      // Level filter
      if (_levelFilter != null && log.level != _levelFilter) {
        return false;
      }

      // Category filter
      if (_categoryFilter != null && log.category != _categoryFilter) {
        return false;
      }

      // Event type filter
      if (_eventTypeFilter != null && log.eventType != _eventTypeFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _logStreamController.close();
    super.dispose();
  }

  // Convenience methods for specific log types

  /// Logs a network request.
  void logRequest(
    String method,
    Uri url, {
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    final request = RequestLog(
      method: method,
      url: url,
      headers: headers,
      body: body,
    );
    log(request);
  }

  /// Logs a network response.
  void logResponse(
    String requestId,
    int statusCode, {
    Map<String, dynamic>? headers,
    dynamic body,
    Duration? duration,
  }) {
    final response = ResponseLog(
      requestId: requestId,
      statusCode: statusCode,
      headers: headers,
      body: body,
      duration: duration,
    );
    log(response);
  }

  /// Logs an application error.
  void logError(
    Object error, {
    StackTrace? stackTrace,
    String? source,
    bool isFatal = false,
  }) {
    final errorLog = ErrorLog(
      error: error,
      stackTrace: stackTrace,
      source: source,
      isFatal: isFatal,
    );
    log(errorLog);
  }

  /// Logs a UI error.
  void logUIError(
    Object error, {
    String? widgetName,
    String? widgetPath,
    StackTrace? stackTrace,
  }) {
    final uiError = UIErrorLog(
      error: error,
      widgetName: widgetName,
      widgetPath: widgetPath,
      stackTrace: stackTrace,
    );
    log(uiError);
  }

  @override
  Future<void> close() async {
    _logStreamController.close();
  }

  @override
  Future<void> flush() async {
    // No async operations needed for in-memory storage
  }

  @override
  bool isLevelEnabled(LogLevel level) {
    return level.priority >= minimumLevel.priority;
  }

  /// Minimum log level that this logger will accept.
  LogLevel _minimumLevel = LogLevel.verbose;

  @override
  LogLevel get minimumLevel => _minimumLevel;

  /// Sets the minimum log level.
  void setMinimumLevel(LogLevel level) {
    _minimumLevel = level;
  }
}
