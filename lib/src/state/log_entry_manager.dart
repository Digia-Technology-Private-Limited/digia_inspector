import 'dart:async';

import 'package:digia_inspector/src/models/action_log_entry.dart';
import 'package:digia_inspector/src/models/error_log_entry.dart';
import 'package:digia_inspector/src/models/log_event_type.dart';
import 'package:digia_inspector/src/models/network_log_entry.dart';
import 'package:digia_inspector/src/models/plain_log_entry.dart';
import 'package:digia_inspector/src/models/state_log_entry.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/foundation.dart';

/// Manages the storage, filtering, and searching of log entries.
///
/// This class is responsible for maintaining the list of log entries,
/// applying filters, and providing reactive updates to the UI.
/// It follows the single responsibility principle by focusing only
/// on log entry management.
class LogEntryManager {
  /// Creates a new log entry manager.
  ///
  /// [maxLogs] determines the maximum number of log entries to keep in memory.
  /// Older logs are automatically removed when this limit is exceeded.
  LogEntryManager({this.maxLogs = 1000});

  /// All log entries in chronological order.
  final List<DigiaLogEvent> _allLogs = [];

  /// ValueNotifier for reactive UI updates with filtered entries.
  late final ValueNotifier<List<DigiaLogEvent>> _filteredLogsNotifier =
      ValueNotifier<List<DigiaLogEvent>>([]);

  /// Current search query for filtering entries.
  String _searchQuery = '';

  /// Current log level filter (for plain log entries).
  LogLevel? _levelFilter;

  /// Current entry type filter (All, Network, Errors, etc.).
  LogEventType? _entryTypeFilter;

  /// Maximum number of logs to keep in memory.
  final int maxLogs;

  /// Stream controller for new log entries.
  final StreamController<DigiaLogEvent> _logStreamController =
      StreamController<DigiaLogEvent>.broadcast();

  /// Stream of new log entries.
  Stream<DigiaLogEvent> get logStream => _logStreamController.stream;

  /// All log entries (read-only).
  List<DigiaLogEvent> get allLogs => List.unmodifiable(_allLogs);

  /// Reactive notifier for filtered log entries.
  ValueNotifier<List<DigiaLogEvent>> get filteredLogsNotifier =>
      _filteredLogsNotifier;

  /// Filtered log entries (read-only).
  List<DigiaLogEvent> get filteredLogs => _filteredLogsNotifier.value;

  /// Current search query.
  String get searchQuery => _searchQuery;

  /// Current log level filter.
  LogLevel? get levelFilter => _levelFilter;

  /// Current entry type filter.
  LogEventType? get entryTypeFilter => _entryTypeFilter;

  /// Total number of log entries.
  int get totalCount => _allLogs.length;

  /// Number of filtered log entries.
  int get filteredCount => _filteredLogsNotifier.value.length;

  /// Number of error entries.
  int get errorCount =>
      _allLogs.whereType<ErrorLogEntry>().length +
      _allLogs
          .whereType<PlainLogEntry>()
          .where(
            (log) =>
                log.level == LogLevel.error || log.level == LogLevel.critical,
          )
          .length;

  /// Number of warning entries.
  int get warningCount => _allLogs
      .whereType<PlainLogEntry>()
      .where((l) => l.level == LogLevel.warning)
      .length;

  /// Number of network entries.
  int get networkCount => _allLogs.whereType<NetworkLogEntry>().length;

  /// Number of network error entries.
  int get networkErrorCount => _allLogs
      .whereType<NetworkLogEntry>()
      .where(
        (log) => log.hasNetworkError || log.isServerError || log.isClientError,
      )
      .length;

  /// Number of action entries.
  int get actionCount => _allLogs.whereType<ActionLogEntry>().length;

  /// Number of state entries.
  int get stateCount => _allLogs.whereType<StateLogEntry>().length;

  /// Available entry types from all logs for filtering.
  List<LogEventType> get availableEntryTypes {
    final entryTypes = _allLogs
        .map((log) => LogEventType.fromString(log.eventType))
        .where((t) => t != null)
        .cast<LogEventType>()
        .toSet()
        .toList();
    return entryTypes..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Adds a log entry to the manager.
  ///
  /// This method manages memory limits, applies filters, and notifies listeners.
  void addLogEntry(DigiaLogEvent entry) {
    _allLogs.add(entry);

    // Remove old logs if we exceed the maximum
    if (_allLogs.length > maxLogs) {
      _allLogs.removeAt(0);
    }

    // Apply current filters to update the filtered list
    _applyFilters();

    // Emit the new log entry
    _logStreamController.add(entry);
  }

  /// Updates an existing log entry.
  ///
  /// This is useful for network entries that need to be updated
  /// when responses are received.
  void updateLogEntry(DigiaLogEvent oldEntry, DigiaLogEvent newEntry) {
    final index = _allLogs.indexOf(oldEntry);
    if (index != -1) {
      _allLogs[index] = newEntry;
      _applyFilters();
    }
  }

  /// Finds a log entry by predicate.
  DigiaLogEvent? findLogEntry(bool Function(DigiaLogEvent) predicate) {
    try {
      return _allLogs.firstWhere(predicate);
    } catch (_) {
      return null;
    }
  }

  /// Finds all log entries matching a predicate.
  List<DigiaLogEvent> findLogEntries(bool Function(DigiaLogEvent) predicate) {
    return _allLogs.where(predicate).toList();
  }

  /// Sets the search query and applies filters.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Sets the log level filter and applies filters.
  void setLevelFilter(LogLevel? level) {
    _levelFilter = level;
    _applyFilters();
  }

  /// Sets the entry type filter and applies filters.
  void setEntryTypeFilter(LogEventType? entryType) {
    _entryTypeFilter = entryType;
    _applyFilters();
  }

  /// Filters entries to show only network requests.
  void showNetworkOnly() {
    setEntryTypeFilter(LogEventType.httpRequest);
  }

  /// Filters entries to show only errors.
  void showErrorsOnly() {
    setEntryTypeFilter(LogEventType.error);
  }

  /// Filters entries to show only actions.
  void showActionsOnly() {
    setEntryTypeFilter(LogEventType.action);
  }

  /// Filters entries to show only state changes.
  void showStatesOnly() {
    setEntryTypeFilter(LogEventType.state);
  }

  /// Shows all entry types (clears type filter).
  void showAll() {
    setEntryTypeFilter(null);
  }

  /// Clears all filters.
  void clearFilters() {
    _searchQuery = '';
    _levelFilter = null;
    _entryTypeFilter = null;
    _applyFilters();
  }

  /// Clears all log entries.
  void clearLogs() {
    _allLogs.clear();
    _filteredLogsNotifier.value = [];
  }

  /// Notifies that filters should be reapplied.
  ///
  /// This is useful when entries are updated externally.
  void notifyFiltersChanged() {
    _applyFilters();
  }

  /// Applies current filters to all log entries.
  void _applyFilters() {
    final filtered = _allLogs.where((entry) {
      // Search query filter - search in contents
      if (_searchQuery.isNotEmpty &&
          !entry.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          )) {
        return false;
      }

      // Entry type filter
      if (_entryTypeFilter != null &&
          entry.eventType != _entryTypeFilter!.name) {
        return false;
      }

      // Level filter (only applies to plain log entries)
      if (_levelFilter != null && entry is PlainLogEntry) {
        if (entry.level != _levelFilter) {
          return false;
        }
      }

      return true;
    }).toList();

    _filteredLogsNotifier.value = filtered;
  }

  /// Disposes of resources.
  void dispose() {
    _logStreamController.close();
    _filteredLogsNotifier.dispose();
  }
}
