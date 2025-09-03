import 'dart:async';

import 'package:digia_inspector/src/interceptors/digia_dio_interceptor.dart';
import 'package:digia_inspector/src/state/action_log_handler.dart';
import 'package:digia_inspector/src/state/log_entry_manager.dart';
import 'package:digia_inspector/src/state/log_exporter.dart';
import 'package:digia_inspector/src/state/network_log_correlator.dart';
import 'package:digia_inspector/src/models/log_event_type.dart';
import 'package:digia_inspector/src/models/error_log_entry.dart';
import 'package:digia_inspector/src/models/plain_log_entry.dart';
import 'package:digia_inspector/src/models/network_log_entry.dart';
import 'package:digia_inspector/src/models/state_log_entry.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/foundation.dart';

/// Unified controller that manages debugging inspector state and coordination.
///
/// This refactored controller focuses on coordination between specialized
/// components and UI state management, following the single responsibility
/// principle. The heavy lifting is delegated to focused classes:
/// - [LogEntryManager] for log storage and filtering
/// - [NetworkLogCorrelator] for network request/response correlation
/// - [ActionLogHandler] for action observability
/// - [LogExporter] for exporting logs
///
/// The controller maintains the [DigiaLogger] and [ActionObserver] contracts
/// while providing a clean, maintainable architecture.
class InspectorController extends ChangeNotifier
    implements DigiaLogger, ActionObserver {
  /// Creates a new inspector controller.
  ///
  /// [maxLogs] determines the maximum number of log entries to keep in memory.
  /// Older logs are automatically removed when this limit is exceeded.
  InspectorController({int maxLogs = 1000})
    : _logEntryManager = LogEntryManager(maxLogs: maxLogs),
      _logExporter = LogExporter() {
    // Initialize components that depend on the log entry manager
    _actionLogHandler = ActionLogHandler(logEntryManager: _logEntryManager);
    _networkLogCorrelator = NetworkLogCorrelator(
      logEntryManager: _logEntryManager,
    );

    // Listen to log entry changes for UI updates
    _logEntryManager.filteredLogsNotifier.addListener(notifyListeners);
  }

  /// Manages log entry storage, filtering, and searching.
  final LogEntryManager _logEntryManager;

  /// Handles network request/response correlation.
  late final NetworkLogCorrelator _networkLogCorrelator;

  /// Handles action observability and logging.
  late final ActionLogHandler _actionLogHandler;

  /// Handles exporting logs to various formats.
  final LogExporter _logExporter;

  /// Whether the inspector is currently visible.
  bool _isVisible = false;

  /// Cached Dio interceptor instance.
  DigiaDioInterceptor? _dioInterceptor;

  /// Stream of new log entries.
  Stream<DigiaLogEvent> get logStream => _logEntryManager.logStream;

  // Delegates to LogEntryManager for all log-related properties

  /// All log entries (read-only).
  List<DigiaLogEvent> get allLogs => _logEntryManager.allLogs;

  /// Reactive notifier for filtered log entries.
  ValueNotifier<List<DigiaLogEvent>> get filteredLogsNotifier =>
      _logEntryManager.filteredLogsNotifier;

  /// Filtered log entries (read-only).
  List<DigiaLogEvent> get filteredLogs => _logEntryManager.filteredLogs;

  /// Current search query.
  String get searchQuery => _logEntryManager.searchQuery;

  /// Current log level filter.
  LogLevel? get levelFilter => _logEntryManager.levelFilter;

  /// Current entry type filter.
  LogEventType? get entryTypeFilter => _logEntryManager.entryTypeFilter;

  /// Whether the inspector is currently visible.
  bool get isVisible => _isVisible;

  /// Total number of log entries.
  int get totalCount => _logEntryManager.totalCount;

  /// Number of filtered log entries.
  int get filteredCount => _logEntryManager.filteredCount;

  /// Number of error entries.
  int get errorCount => _logEntryManager.errorCount;

  /// Number of warning entries.
  int get warningCount => _logEntryManager.warningCount;

  /// Number of network entries.
  int get networkCount => _logEntryManager.networkCount;

  /// Number of network error entries.
  int get networkErrorCount => _logEntryManager.networkErrorCount;

  /// Number of action entries.
  int get actionCount => _logEntryManager.actionCount;

  /// Number of state entries.
  int get stateCount => _logEntryManager.stateCount;

  /// Available entry types from all logs for filtering.
  List<LogEventType> get availableEntryTypes =>
      _logEntryManager.availableEntryTypes;

  @override
  DigiaDioInterceptor? get dioInterceptor {
    return _dioInterceptor ??= DigiaDioInterceptorImpl(controller: this);
  }

  @override
  ActionObserver? get actionObserver => _actionLogHandler;

  /// Logs a unified log entry to the inspector.
  ///
  /// This method delegates to the [LogEntryManager] which handles all types of
  /// [DigiaLogEvent] instances and maintains the unified logging system.
  void logEntry(DigiaLogEvent entry) {
    _logEntryManager.addLogEntry(entry);
    // The LogEntryManager will handle filtering and notifications
  }

  /// Updates an existing log entry.
  ///
  /// This is useful for network entries that need to be updated
  /// when responses are received.
  void updateLogEntry(DigiaLogEvent oldEntry, DigiaLogEvent newEntry) {
    _logEntryManager.updateLogEntry(oldEntry, newEntry);
  }

  @override
  void log(DigiaLogEvent event) {
    // For now, we'll log all events directly since they are already DigiaLogEvent instances
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

  // Filtering Methods - Delegate to LogEntryManager

  /// Sets the search query and applies filters.
  void setSearchQuery(String query) => _logEntryManager.setSearchQuery(query);

  /// Sets the log level filter and applies filters.
  void setLevelFilter(LogLevel? level) =>
      _logEntryManager.setLevelFilter(level);

  /// Sets the entry type filter and applies filters.
  void setEntryTypeFilter(LogEventType? entryType) =>
      _logEntryManager.setEntryTypeFilter(entryType);

  /// Filters entries to show only network requests.
  void showNetworkOnly() => _logEntryManager.showNetworkOnly();

  /// Filters entries to show only errors.
  void showErrorsOnly() => _logEntryManager.showErrorsOnly();

  /// Filters entries to show only actions.
  void showActionsOnly() => _logEntryManager.showActionsOnly();

  /// Filters entries to show only state changes.
  void showStatesOnly() => _logEntryManager.showStatesOnly();

  /// Shows all entry types (clears type filter).
  void showAll() => _logEntryManager.showAll();

  /// Clears all filters.
  void clearFilters() => _logEntryManager.clearFilters();

  /// Clears all log entries.
  void clearLogs() {
    _logEntryManager.clearLogs();
    notifyListeners();
  }

  // Export Methods - Delegate to LogExporter

  /// Exports all log entries as JSON.
  Map<String, dynamic> exportLogsAsJson() => _logExporter.exportAsJson(allLogs);

  /// Exports log entries as CSV string.
  String exportLogsAsCsv() => _logExporter.exportAsCsv(allLogs);

  /// Exports log entries as plain text.
  String exportLogsAsText() => _logExporter.exportAsText(allLogs);

  /// Exports only network logs with enhanced formatting.
  Map<String, dynamic> exportNetworkLogsAsJson() =>
      _logExporter.exportNetworkLogsAsJson(allLogs);

  /// Exports only action logs with enhanced formatting.
  Map<String, dynamic> exportActionLogsAsJson() =>
      _logExporter.exportActionLogsAsJson(allLogs);

  // Network Correlation Methods - Delegate to NetworkLogCorrelator

  /// Notifies that an entry has been updated (e.g., network state change).
  void notifyEntryUpdated() {
    _logEntryManager.notifyFiltersChanged();
    notifyListeners();
  }

  /// Finds a network log entry by request ID.
  ///
  /// Used by the interceptor to correlate requests with responses
  /// using unique request IDs instead of method+URL matching.
  NetworkLogEntry? findNetworkEntryByRequestId(String? requestId) =>
      _networkLogCorrelator.findNetworkEntryByRequestId(requestId);

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
  }) => _networkLogCorrelator.findNetworkEntry(
    method: method,
    url: url,
    requestTime: requestTime,
  );

  @override
  void dispose() {
    _logEntryManager.dispose();
    _logEntryManager.filteredLogsNotifier.removeListener(notifyListeners);
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
  }) => _actionLogHandler.logAction(
    action,
    target,
    parameters: parameters,
    userId: userId,
  );

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
    _logEntryManager.dispose();
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

  // ActionObserver implementation - Delegate to ActionLogHandler

  @override
  void onActionStart(ActionLog event) => _actionLogHandler.onActionStart(event);

  @override
  void onActionProgress(ActionLog event) =>
      _actionLogHandler.onActionProgress(event);

  @override
  void onActionComplete(ActionLog event) =>
      _actionLogHandler.onActionComplete(event);

  @override
  void onActionDisabled(ActionLog event) =>
      _actionLogHandler.onActionDisabled(event);
}
