import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/foundation.dart';

/// Manages state logs for the UI by organizing them into buckets by state type
/// and providing views of state changes across the application
class StateLogManager extends ChangeNotifier {
  final Map<String, StateLog> _stateLogs = {};
  final List<String> _logOrder = [];

  /// All state logs in chronological order (latest first)
  List<StateLog> get allLogs {
    return _logOrder
        .map((id) => _stateLogs[id])
        .where((log) => log != null)
        .cast<StateLog>()
        .toList();
  }

  /// State logs grouped by state type for bucketized display
  Map<StateType, List<StateLog>> get logsByType {
    final grouped = <StateType, List<StateLog>>{};

    for (final type in StateType.values) {
      grouped[type] = allLogs.where((log) => log.stateType == type).toList();
    }

    return grouped;
  }

  /// State logs grouped by current page context
  Map<String, List<StateLog>> get logsByPageContext {
    final grouped = <String, List<StateLog>>{};

    for (final log in allLogs) {
      final pageId = log.metadata['currentPageId'] as String? ??
          log.metadata['pageId'] as String? ??
          'Unknown';

      grouped.putIfAbsent(pageId, () => <StateLog>[]).add(log);
    }

    return grouped;
  }

  /// Get current state snapshot by state type
  Map<StateType, Map<String, StateLog>> get currentStateSnapshot {
    final snapshot = <StateType, Map<String, StateLog>>{};

    for (final type in StateType.values) {
      snapshot[type] = <String, StateLog>{};
    }

    // Get the latest state for each state ID
    final latestStates = <String, StateLog>{};

    for (final log in allLogs.reversed) {
      // Process in chronological order
      if (log.stateEventType == StateEventType.create ||
          log.stateEventType == StateEventType.change) {
        latestStates[log.stateId] = log;
      } else if (log.stateEventType == StateEventType.dispose) {
        latestStates.remove(log.stateId);
      }
    }

    // Group by state type
    for (final log in latestStates.values) {
      snapshot[log.stateType]![log.stateId] = log;
    }

    return snapshot;
  }

  /// Total count of all state logs
  int get totalCount => allLogs.length;

  /// Count of logs by state type
  Map<StateType, int> get countsByType {
    final counts = <StateType, int>{};
    for (final type in StateType.values) {
      counts[type] = allLogs.where((log) => log.stateType == type).length;
    }
    return counts;
  }

  /// Count of currently active states (created but not disposed)
  Map<StateType, int> get activeStateCount {
    final counts = <StateType, int>{};
    final snapshot = currentStateSnapshot;

    for (final type in StateType.values) {
      counts[type] = snapshot[type]?.length ?? 0;
    }

    return counts;
  }

  /// Adds a state log entry
  void addStateLog(StateLog log) {
    _stateLogs[log.id] = log;
    _logOrder.insert(0, log.id); // Latest first

    notifyListeners();
  }

  /// Clears all state logs
  void clear() {
    _stateLogs.clear();
    _logOrder.clear();
    notifyListeners();
  }

  /// Gets the state log by ID
  StateLog? getById(String id) => _stateLogs[id];

  /// Gets all logs for a specific state ID (across its lifecycle)
  List<StateLog> getLogsForStateId(String stateId) {
    return allLogs.where((log) => log.stateId == stateId).toList();
  }

  /// Gets all logs for a specific namespace
  List<StateLog> getLogsForNamespace(String namespace) {
    return allLogs.where((log) => log.namespace == namespace).toList();
  }

  /// Gets current state data for a specific state ID
  Map<String, Object?>? getCurrentStateData(String stateId) {
    final logs = getLogsForStateId(stateId);
    if (logs.isEmpty) return null;

    // Find the latest change or create event
    for (final log in logs) {
      if (log.stateEventType == StateEventType.create ||
          log.stateEventType == StateEventType.change) {
        return log.stateData;
      }
    }

    return null;
  }
}
