import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/widgets.dart';

/// Manages all ActionLogs and provides tree reconstruction
class ActionLogManager extends ChangeNotifier {
  /// Flat store of all logs by id
  final Map<String, ActionLog> _logs = {};

  /// Notifier for top-level actions (for real-time updates)
  final ValueNotifier<List<ActionLog>> _topLevelActionsNotifier =
      ValueNotifier<List<ActionLog>>([]);

  /// Notifier for all logs (for real-time updates)
  final ValueNotifier<List<ActionLog>> _allLogsNotifier =
      ValueNotifier<List<ActionLog>>([]);

  /// Get notifier for top-level actions
  ValueNotifier<List<ActionLog>> get topLevelActionsNotifier =>
      _topLevelActionsNotifier;

  /// Get notifier for all logs
  ValueNotifier<List<ActionLog>> get allLogsNotifier => _allLogsNotifier;

  /// Insert or update a log
  void upsert(ActionLog log) {
    _logs[log.id] = log;
    _updateNotifiers();
    notifyListeners();
  }

  /// Update the notifiers with current data
  void _updateNotifiers() {
    _allLogsNotifier.value = allLogs;
    _topLevelActionsNotifier.value = topLevelActions;
  }

  /// Returns a log by ID
  ActionLog? getById(String id) => _logs[id];

  /// All logs in reverse chronological order (newest first)
  List<ActionLog> get allLogs {
    final logs = _logs.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  /// Root flows = logs with no parent (top-level actions/flows)
  List<ActionLog> get rootFlows {
    return allLogs.where((log) => log.parentActionId == null).toList();
  }

  /// Get all root flows (actions that are not children of other actions)
  List<ActionLog> get topLevelActions {
    // Get all logs that have no parent (parentEventId is null)
    final rootLogs =
        allLogs.where((log) => log.parentActionId == null).toList();

    // Also get logs that are children but their parent doesn't exist
    // This handles the case where a child action is created before its parent
    final orphanedChildLogs = <ActionLog>[];
    for (final log in allLogs) {
      if (log.parentActionId != null &&
          !_logs.containsKey(log.parentActionId)) {
        // This is a child whose parent doesn't exist - treat as top-level
        orphanedChildLogs.add(log);
      }
    }

    // Combine root logs and orphaned child logs
    final result = <ActionLog>[
      ...rootLogs,
      ...orphanedChildLogs,
    ];

    return result;
  }

  /// Get children of a given log (newest first)
  List<ActionLog> getChildren(String parentId) {
    final children = _logs.values
        .where((log) => log.parentActionId == parentId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return children;
  }

  /// Count all actions that belong to the same action flow
  int countActions(String actionId) {
    // Count all logs that belong to the same action flow
    final actionLogs = _logs.values.where((log) => log.id == actionId);

    // Also include logs where this actionId is their parent's actionId
    final childLogs = _logs.values.where((log) {
      if (log.parentActionId == null) return false;
      final parent = _logs[log.parentActionId];
      return parent?.id == actionId;
    });

    final allRelatedLogs = <ActionLog>{...actionLogs, ...childLogs};
    return allRelatedLogs.length;
  }

  /// Recursively count all actions in a flow starting from [rootEventId].
  ///
  /// This includes the root action itself and all of its descendants at any
  /// depth level. Use this for accurate counts in the UI.
  int countActionsInFlow(String rootEventId) {
    int total = 1; // include root
    final children = getChildren(rootEventId);
    for (final child in children) {
      total += countActionsInFlow(child.id);
    }
    return total;
  }

  /// Count all child actions that belong to the same action flow
  int countChildActions(String parentId) {
    final children = getChildren(parentId);
    if (children.isEmpty) return 0;

    var total = children.length;
    for (final child in children) {
      total += countChildActions(child.id);
    }
    return total;
  }

  /// Get all logs in hierarchical order (parent-child structure)
  List<ActionLog> get allLogsHierarchical {
    final result = <ActionLog>[];
    final processed = <String>{};

    // First, add all top-level actions
    for (final root in topLevelActions) {
      _addLogHierarchically(result, root, processed, 0);
    }

    return result;
  }

  /// Recursively add logs in hierarchical order
  void _addLogHierarchically(
    List<ActionLog> result,
    ActionLog log,
    Set<String> processed,
    int depth,
  ) {
    if (processed.contains(log.id)) return;

    processed.add(log.id);
    result.add(log);

    // Add children
    final children = getChildren(log.id);
    for (final child in children) {
      _addLogHierarchically(result, child, processed, depth + 1);
    }
  }

  /// Clear all logs
  void clear() {
    _logs.clear();
    _updateNotifiers();
    notifyListeners();
  }

  @override
  void dispose() {
    _topLevelActionsNotifier.dispose();
    _allLogsNotifier.dispose();
    super.dispose();
  }
}
