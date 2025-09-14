import 'dart:async';

import 'package:digia_inspector/src/implementations/action_observer_impl.dart';
import 'package:digia_inspector/src/implementations/network_observer_impl.dart';
import 'package:digia_inspector/src/implementations/state_observer_impl.dart';
import 'package:digia_inspector/src/log_managers/action_log_manager.dart';
import 'package:digia_inspector/src/log_managers/network_log_manager.dart';
import 'package:digia_inspector/src/log_managers/state_log_manager.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/foundation.dart';

/// Simplified controller that manages debugging inspector state
/// and coordination.
///
/// This controller focuses on coordination between specialized managers:
/// - [NetworkLogManager] for network request/response/error correlation
/// - [ActionLogManager] for action execution tracking and correlation
/// - [StateLogManager] for state lifecycle and change tracking
class InspectorController extends ChangeNotifier implements DigiaInspector {
  /// Creates a new inspector controller.
  InspectorController()
      : _networkLogManager = NetworkLogManager(),
        _actionLogManager = ActionLogManager(),
        _stateLogManager = StateLogManager(),
        _networkObserver = null,
        _actionObserver = null,
        _stateObserver = null;

  /// Manages network logs with request/response/error correlation.
  final NetworkLogManager _networkLogManager;

  /// Manages action logs with execution tracking and correlation.
  final ActionLogManager _actionLogManager;

  /// Manages state logs with lifecycle and change tracking.
  final StateLogManager _stateLogManager;

  /// Action observer implementation for handling action lifecycle events.
  ActionObserverImpl? _actionObserver;

  /// State observer implementation for handling state lifecycle events.
  StateObserverImpl? _stateObserver;

  /// Whether the inspector is currently visible.
  final bool _isVisible = false;

  /// Cached Network observer instance.
  NetworkObserver? _networkObserver;

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

  // State log management - delegate to StateLogManager

  /// State log manager for direct access from UI
  StateLogManager get stateLogManager => _stateLogManager;

  // General log properties

  /// All log entries (network + action + state + other logs).
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

    final actionLogs = <DigiaLogEvent>[
      ..._actionLogManager.allLogs,
    ];

    final stateLogs = <DigiaLogEvent>[
      ..._stateLogManager.allLogs,
    ];

    return [...networkLogs, ...actionLogs, ...stateLogs, ..._otherLogs];
  }

  /// Filtered log entries (for backward compatibility).
  List<DigiaLogEvent> get filteredLogs => allLogs;

  /// Reactive notifier for filtered log entries (for backward compatibility).
  ValueNotifier<List<DigiaLogEvent>> get filteredLogsNotifier =>
      ValueNotifier(filteredLogs);

  /// Current search query (delegated to network manager for now).
  String get searchQuery => _networkLogManager.searchQuery;

  /// Current log level filter (not used in new system).
  String? get levelFilter => null;

  /// Whether the inspector is currently visible.
  bool get isVisible => _isVisible;

  /// Total number of log entries.
  int get totalCount => allLogs.length;

  /// Number of filtered log entries.
  int get filteredCount => allLogs.length;

  /// Number of network entries.
  int get networkCount => _networkLogManager.totalCount;

  /// Number of network error entries.
  int get networkErrorCount => _networkLogManager.errorCount;

  /// Number of action entries.
  int get actionCount => _actionLogManager.allLogs.length;

  /// Number of action flow entries.
  int get actionFlowCount => _actionLogManager.topLevelActions.length;

  @override
  NetworkObserver? get networkObserver {
    return _networkObserver ??= NetworkObserverImpl(controller: this);
  }

  @override
  ActionObserver? get actionObserver =>
      _actionObserver ??= ActionObserverImpl(controller: this);

  @override
  StateObserver? get stateObserver =>
      _stateObserver ??= StateObserverImpl(controller: this);

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
      _actionLogManager.upsert(entry);
    }
    // Handle state logs
    else if (entry is StateLog) {
      _stateLogManager.addStateLog(entry);
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

  /// Clears all log entries.
  void clearLogs() {
    _networkLogManager.clear();
    _actionLogManager.clear();
    _stateLogManager.clear();
    _otherLogs.clear();
    notifyListeners();
  }

  /// Clears logs for a specific tab.
  /// [tabIndex] - 0: Network, 1: Actions, 2: State
  void clearTabLogs(int tabIndex) {
    switch (tabIndex) {
      case 0: // Network tab
        _networkLogManager.clear();
      case 1: // Actions tab
        _actionLogManager.clear();
      case 2: // State tab
        _stateLogManager.clear();
      default:
        clearLogs(); // Fallback to clearing all logs
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _logStreamController.close();
    _networkLogManager.dispose();
    _actionLogManager.dispose();
    _stateLogManager.dispose();
    super.dispose();
  }
}
