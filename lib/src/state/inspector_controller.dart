import 'dart:async';

import 'package:digia_inspector/src/interceptors/digia_dio_interceptor.dart';
import 'package:digia_inspector/src/models/error_log_entry.dart';
import 'package:digia_inspector/src/models/log_event_type.dart';
import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/models/plain_log_entry.dart';
import 'package:digia_inspector/src/models/state_log_entry.dart';
import 'package:digia_inspector/src/state/action_log_manager.dart';
import 'package:digia_inspector/src/state/network_log_manager.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/foundation.dart';

/// Simplified controller that manages debugging inspector state and coordination.
///
/// This controller focuses on coordination between specialized managers:
/// - [NetworkLogManager] for network request/response/error correlation
/// - [ActionLogManager] for action execution tracking and correlation
/// - [LogExporter] for exporting logs
///
/// The controller maintains the [DigiaLogger] and [ActionObserver] contracts
/// while providing a clean, maintainable architecture.
class InspectorController extends ChangeNotifier
    implements DigiaLogger, ActionObserver {
  /// Creates a new inspector controller.
  InspectorController()
    : _networkLogManager = NetworkLogManager(),
      _actionLogManager = ActionLogManager();

  /// Manages network logs with request/response/error correlation.
  final NetworkLogManager _networkLogManager;

  /// Manages action logs with execution tracking and correlation.
  final ActionLogManager _actionLogManager;

  /// Whether the inspector is currently visible.
  bool _isVisible = false;

  /// Cached Dio interceptor instance.
  DigiaDioInterceptor? _dioInterceptor;

  /// Other log entries that aren't network logs (errors, plain logs, etc.)
  final List<DigiaLogEvent> _otherLogs = [];

  /// Stream controller for new log entries.
  final StreamController<DigiaLogEvent> _logStreamController =
      StreamController<DigiaLogEvent>.broadcast();

  /// Stream of new log entries.
  Stream<DigiaLogEvent> get logStream => _logStreamController.stream;

  // Network log management - delegate to NetworkLogManager

  /// Network log manager for direct access from UI
  NetworkLogManager get networkLogManager => _networkLogManager;

  // Action log management - delegate to ActionLogManager

  /// Action log manager for direct access from UI
  ActionLogManager get actionLogManager => _actionLogManager;

  // General log properties

  /// All log entries (network + other logs).
  List<DigiaLogEvent> get allLogs {
    final networkLogs = <DigiaLogEvent>[
      ..._networkLogManager.allEntries.map((e) => e.requestLog),
      ..._networkLogManager.allEntries
          .where((e) => e.responseLog != null)
          .map((e) => e.responseLog!),
      ..._networkLogManager.allEntries
          .where((e) => e.errorLog != null)
          .map((e) => e.errorLog!),
    ];
    return [...networkLogs, ..._otherLogs];
  }

  /// Filtered log entries (for backward compatibility).
  List<DigiaLogEvent> get filteredLogs => allLogs;

  /// Reactive notifier for filtered log entries (for backward compatibility).
  ValueNotifier<List<DigiaLogEvent>> get filteredLogsNotifier =>
      ValueNotifier(filteredLogs);

  /// Current search query (delegated to network manager for now).
  String get searchQuery => _networkLogManager.searchQuery;

  /// Current log level filter (not used in new system).
  LogLevel? get levelFilter => null;

  /// Current entry type filter (not used in new system).
  LogEventType? get entryTypeFilter => null;

  /// Whether the inspector is currently visible.
  bool get isVisible => _isVisible;

  /// Total number of log entries.
  int get totalCount => allLogs.length;

  /// Number of filtered log entries.
  int get filteredCount => allLogs.length;

  /// Number of error entries.
  int get errorCount =>
      _otherLogs.whereType<ErrorLogEntry>().length +
      _networkLogManager.errorCount;

  /// Number of warning entries.
  int get warningCount => _otherLogs
      .whereType<PlainLogEntry>()
      .where((l) => l.level == LogLevel.warning)
      .length;

  /// Number of network entries.
  int get networkCount => _networkLogManager.totalCount;

  /// Number of network error entries.
  int get networkErrorCount => _networkLogManager.errorCount;

  /// Number of action entries.
  int get actionCount => _actionLogManager.totalCount;

  /// Number of action flow entries.
  int get actionFlowCount => _actionLogManager.flowCount;

  /// Number of state entries.
  int get stateCount => _otherLogs.whereType<StateLogEntry>().length;

  /// Available entry types from all logs for filtering.
  List<LogEventType> get availableEntryTypes {
    // For now, return basic types
    return [
      LogEventType.httpRequest,
      LogEventType.error,
      LogEventType.action,
      LogEventType.state,
    ];
  }

  @override
  DigiaDioInterceptor? get dioInterceptor {
    return _dioInterceptor ??= DigiaDioInterceptorImpl(controller: this);
  }

  @override
  ActionObserver? get actionObserver => this;

  /// Logs a unified log entry to the inspector.
  void logEntry(DigiaLogEvent entry) {
    // Handle network logs
    if (entry is NetworkRequestLog) {
      _networkLogManager.addRequestLog(entry);
    } else if (entry is NetworkResponseLog) {
      _networkLogManager.addResponseLog(entry);
    } else if (entry is NetworkErrorLog) {
      _networkLogManager.addErrorLog(entry);
    }
    // Handle action logs
    else if (entry is ActionLog) {
      _actionLogManager.addActionLog(entry);
    }
    // Handle other log types
    else {
      _otherLogs.add(entry);
    }

    _logStreamController.add(entry);
  }

  /// Updates an existing log entry (for backward compatibility).
  void updateLogEntry(DigiaLogEvent oldEntry, DigiaLogEvent newEntry) {
    // This method is kept for backward compatibility but is not needed
    // in the new system since NetworkLogManager handles updates internally
    logEntry(newEntry);
  }

  @override
  void log(DigiaLogEvent event) {
    logEntry(event);
  }

  // UI State Management

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

  // Filtering Methods - For backward compatibility

  /// Sets the search query (delegated to network manager).
  void setSearchQuery(String query) => _networkLogManager.setSearchQuery(query);

  /// Sets the log level filter (not used in new system).
  void setLevelFilter(LogLevel? level) {
    // Not implemented in new system
    notifyListeners();
  }

  /// Sets the entry type filter (not used in new system).
  void setEntryTypeFilter(LogEventType? entryType) {
    // Not implemented in new system
    notifyListeners();
  }

  /// Filters entries to show only network requests.
  void showNetworkOnly() {
    // Not needed in new system - UI handles this directly
    notifyListeners();
  }

  /// Filters entries to show only errors.
  void showErrorsOnly() {
    // Not needed in new system - UI handles this directly
    notifyListeners();
  }

  /// Filters entries to show only actions.
  void showActionsOnly() {
    // Not needed in new system - UI handles this directly
    notifyListeners();
  }

  /// Filters entries to show only state changes.
  void showStatesOnly() {
    // Not needed in new system - UI handles this directly
    notifyListeners();
  }

  /// Shows all entry types (clears type filter).
  void showAll() {
    // Not needed in new system
    notifyListeners();
  }

  /// Clears all filters.
  void clearFilters() {
    _networkLogManager.setSearchQuery('');
    _networkLogManager.setStatusFilter(NetworkStatusFilter.all);
    notifyListeners();
  }

  /// Clears all log entries.
  void clearLogs() {
    _networkLogManager.clear();
    _actionLogManager.clear();
    _otherLogs.clear();
    notifyListeners();
  }

  // Export Methods - Simplified for now

  /// Exports all log entries as JSON.
  Map<String, dynamic> exportLogsAsJson() {
    return {
      'exportTime': DateTime.now().toIso8601String(),
      'totalLogs': allLogs.length,
      'logs': allLogs
          .map(
            (log) => {
              'timestamp': log.timestamp.toIso8601String(),
              'type': log.eventType,
              'description': log.description,
            },
          )
          .toList(),
    };
  }

  /// Exports log entries as CSV string.
  String exportLogsAsCsv() {
    final buffer = StringBuffer();
    buffer.writeln('timestamp,type,description');
    for (final log in allLogs) {
      buffer.writeln(
        '"${log.timestamp.toIso8601String()}","${log.eventType}","${log.description.replaceAll('"', '""')}"',
      );
    }
    return buffer.toString();
  }

  /// Exports log entries as plain text.
  String exportLogsAsText() {
    final buffer = StringBuffer();
    for (final log in allLogs) {
      buffer.writeln(
        '[${log.timestamp.toIso8601String()}] ${log.eventType}: ${log.description}',
      );
    }
    return buffer.toString();
  }

  /// Exports only network logs with enhanced formatting.
  Map<String, dynamic> exportNetworkLogsAsJson() {
    final networkLogs = allLogs
        .where(
          (log) =>
              log is NetworkRequestLog ||
              log is NetworkResponseLog ||
              log is NetworkErrorLog,
        )
        .toList();
    return {
      'exportTime': DateTime.now().toIso8601String(),
      'totalLogs': networkLogs.length,
      'logs': networkLogs
          .map(
            (log) => {
              'timestamp': log.timestamp.toIso8601String(),
              'type': log.eventType,
              'description': log.description,
            },
          )
          .toList(),
    };
  }

  /// Exports only action logs with enhanced formatting.
  Map<String, dynamic> exportActionLogsAsJson() {
    // For now, return empty since actions are simplified
    return {
      'exportTime': DateTime.now().toIso8601String(),
      'totalLogs': 0,
      'logs': <Map<String, dynamic>>[],
    };
  }

  // Network-specific methods for interceptor

  /// Finds a network entry by request ID (for interceptor).
  NetworkLogUIEntry? findNetworkEntryByRequestId(String? requestId) {
    return _networkLogManager.findEntryByRequestId(requestId);
  }

  @override
  void dispose() {
    _logStreamController.close();
    _networkLogManager.dispose();
    super.dispose();
  }

  // Convenience methods for creating specific log entry types

  /// Logs a plain message.
  void logMessage(
    String message, {
    LogLevel level = LogLevel.info,
    String? category,
  }) {
    logEntry(
      PlainLogEntry(
        message: message,
        level: level,
        category: category,
      ),
    );
  }

  /// Logs an application error.
  void logError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    logEntry(
      ErrorLogEntry(
        error: error,
        stackTrace: stackTrace,
        context: context,
        severity: severity,
      ),
    );
  }

  /// Logs a user action.
  void logAction(
    String action,
    String target, {
    Map<String, dynamic>? parameters,
    String? userId,
  }) {
    // Simplified for now - just log as plain entry
    logMessage('Action: $action on $target', level: LogLevel.info);
  }

  /// Logs a state change.
  void logState(
    String stateName,
    String changeType, {
    dynamic oldValue,
    dynamic newValue,
    String? context,
  }) {
    logEntry(
      StateLogEntry(
        stateName: stateName,
        changeType: changeType,
        oldValue: oldValue,
        newValue: newValue,
        context: context,
      ),
    );
  }

  // DigiaLogger interface implementation

  @override
  Future<void> close() async {
    dispose();
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
    notifyListeners();
  }

  // ActionObserver implementation - Integrated with ActionLogManager

  @override
  void onActionStart(ActionLog event) {
    // Add action to the action log manager for UI display
    _actionLogManager.addActionLog(event);

    // Also add to general log stream for backwards compatibility
    logEntry(event);

    // Log a simple message for debugging
    logMessage('Action Started: ${event.actionType}', level: LogLevel.info);
  }

  @override
  void onActionProgress(ActionLog event) {
    // Update existing action with progress information
    _actionLogManager.updateActionLog(event);

    // Log progress message
    final progressInfo = event.progressData != null
        ? ' (${event.progressData})'
        : '';
    logMessage(
      'Action Progress: ${event.actionType}$progressInfo',
      level: LogLevel.debug,
    );
  }

  @override
  void onActionComplete(ActionLog event) {
    // Update existing action with completion status
    _actionLogManager.updateActionLog(event);

    // Also add to general log stream
    logEntry(event);

    // Log completion with timing if available
    final timing = event.executionTime != null
        ? ' in ${event.executionTime!.inMilliseconds}ms'
        : '';
    final status = event.isFailed ? 'Failed' : 'Completed';
    logMessage(
      'Action $status: ${event.actionType}$timing',
      level: event.isFailed ? LogLevel.error : LogLevel.info,
    );
  }

  @override
  void onActionDisabled(ActionLog event) {
    // Add disabled action to the action log manager
    _actionLogManager.addActionLog(event);

    // Also add to general log stream
    logEntry(event);

    // Log disabled message
    logMessage('Action Disabled: ${event.actionType}', level: LogLevel.warning);
  }
}
