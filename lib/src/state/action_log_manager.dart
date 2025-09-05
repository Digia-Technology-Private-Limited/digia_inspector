import 'package:digia_inspector/src/models/action_flow_ui_entry.dart';
import 'package:digia_inspector/src/models/action_log_ui_entry.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/foundation.dart';

/// Manages action logs for the UI by correlating actions and flows
/// using eventId as the unique identifier for each action
class ActionLogManager extends ChangeNotifier {
  final Map<String, ActionLogUIEntry> _actionEntries = {};
  final Map<String, ActionFlowUIEntry> _flowEntries = {};
  final List<String> _entryOrder = [];

  /// All action log entries in chronological order (latest first)
  List<ActionLogUIEntry> get allEntries {
    return _entryOrder
        .map((id) => _actionEntries[id])
        .where((entry) => entry != null)
        .cast<ActionLogUIEntry>()
        .toList();
  }

  /// All flow entries (top-level actions that represent flows)
  List<ActionFlowUIEntry> get allFlowEntries {
    return _flowEntries.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Notifier for filtered entries
  final ValueNotifier<List<ActionLogUIEntry>> filteredEntriesNotifier =
      ValueNotifier([]);

  /// Notifier for filtered flow entries
  final ValueNotifier<List<ActionFlowUIEntry>> filteredFlowEntriesNotifier =
      ValueNotifier([]);

  /// Current search query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Current status filter
  ActionStatusFilter _statusFilter = ActionStatusFilter.all;
  ActionStatusFilter get statusFilter => _statusFilter;

  /// Adds an action log and creates or updates UI entries
  void addActionLog(ActionLog actionLog) {
    final id = actionLog.eventId;

    // Create UI entry for this action
    final uiEntry = ActionLogUIEntry.fromActionLog(actionLog);
    _actionEntries[id] = uiEntry;
    // Insert at the beginning to keep latest entries at top
    _entryOrder.insert(0, id);

    // Handle flow management
    _handleFlowManagement(actionLog);

    _applyFilters();
    notifyListeners();
  }

  /// Updates an existing action with new status/information
  void updateActionLog(ActionLog updatedActionLog) {
    final id = updatedActionLog.eventId;
    final existingEntry = _actionEntries[id];

    if (existingEntry != null) {
      final updatedEntry = ActionLogUIEntry.fromActionLog(updatedActionLog);
      _actionEntries[id] = updatedEntry;

      // Update flow entries if this action is part of a flow
      _updateFlowEntries(updatedActionLog);

      _applyFilters();
      notifyListeners();
    }
  }

  /// Handles flow creation and management
  void _handleFlowManagement(ActionLog actionLog) {
    if (actionLog.isTopLevel) {
      // This is a top-level action - create or update flow
      final flowId = actionLog.eventId;
      final existingFlow = _flowEntries[flowId];

      if (existingFlow == null) {
        // Create new flow
        final newFlow = ActionFlowUIEntry(
          flowId: flowId,
          rootAction: actionLog,
          actions: [actionLog],
          timestamp: actionLog.timestamp,
          triggerName: actionLog.triggerName,
          sourceChain: actionLog.sourceChain,
        );
        _flowEntries[flowId] = newFlow;
      } else {
        // Update existing flow
        final updatedActions = List<ActionLog>.from(existingFlow.actions);
        final actionIndex = updatedActions.indexWhere(
          (a) => a.eventId == actionLog.eventId,
        );
        if (actionIndex >= 0) {
          updatedActions[actionIndex] = actionLog;
        } else {
          updatedActions.add(actionLog);
        }

        _flowEntries[flowId] = existingFlow.copyWith(
          rootAction: actionLog,
          actions: updatedActions,
        );
      }
    } else if (actionLog.parentEventId != null) {
      // This is a child action - add to parent flow
      final parentFlow = _findFlowByRootOrChild(actionLog.parentEventId!);
      if (parentFlow != null) {
        final updatedActions = List<ActionLog>.from(parentFlow.actions);
        final actionIndex = updatedActions.indexWhere(
          (a) => a.eventId == actionLog.eventId,
        );

        if (actionIndex >= 0) {
          updatedActions[actionIndex] = actionLog;
        } else {
          updatedActions.add(actionLog);
        }

        _flowEntries[parentFlow.flowId] = parentFlow.copyWith(
          actions: updatedActions,
        );
      }
    }
  }

  /// Updates flow entries when an action is updated
  void _updateFlowEntries(ActionLog updatedActionLog) {
    // Find flows that contain this action
    for (final flowEntry in _flowEntries.values) {
      final actionIndex = flowEntry.actions.indexWhere(
        (a) => a.eventId == updatedActionLog.eventId,
      );
      if (actionIndex >= 0) {
        final updatedActions = List<ActionLog>.from(flowEntry.actions);
        updatedActions[actionIndex] = updatedActionLog;

        _flowEntries[flowEntry.flowId] = flowEntry.copyWith(
          actions: updatedActions,
          rootAction: flowEntry.rootAction.eventId == updatedActionLog.eventId
              ? updatedActionLog
              : flowEntry.rootAction,
        );
      }
    }
  }

  /// Finds a flow by root action ID or child action ID
  ActionFlowUIEntry? _findFlowByRootOrChild(String actionId) {
    for (final flow in _flowEntries.values) {
      if (flow.rootAction.eventId == actionId ||
          flow.actions.any((a) => a.eventId == actionId)) {
        return flow;
      }
    }
    return null;
  }

  /// Finds an action entry by event ID
  ActionLogUIEntry? findEntryByEventId(String? eventId) {
    if (eventId == null) return null;
    return _actionEntries[eventId];
  }

  /// Finds a flow entry by flow ID
  ActionFlowUIEntry? findFlowByFlowId(String? flowId) {
    if (flowId == null) return null;
    return _flowEntries[flowId];
  }

  /// Gets all child actions for a specific parent action
  List<ActionLogUIEntry> getChildActions(String parentEventId) {
    return _actionEntries.values
        .where((entry) => entry.parentEventId == parentEventId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Sets the search query and applies filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Sets the status filter and applies filters
  void setStatusFilter(ActionStatusFilter filter) {
    _statusFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  /// Applies current filters to the entries
  void _applyFilters() {
    var filtered = allEntries;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((entry) => _matchesSearch(entry)).toList();
    }

    // Apply status filter
    filtered = _filterByStatus(filtered);

    filteredEntriesNotifier.value = filtered;

    // Filter flow entries
    var filteredFlows = allFlowEntries;

    // Apply search filter to flows
    if (_searchQuery.isNotEmpty) {
      filteredFlows = filteredFlows
          .where((flow) => _matchesFlowSearch(flow))
          .toList();
    }

    // Apply status filter to flows
    filteredFlows = _filterFlowsByStatus(filteredFlows);

    filteredFlowEntriesNotifier.value = filteredFlows;
  }

  /// Checks if an entry matches the search query
  bool _matchesSearch(ActionLogUIEntry entry) {
    final query = _searchQuery.toLowerCase();

    return entry.actionType.toLowerCase().contains(query) ||
        entry.triggerName.toLowerCase().contains(query) ||
        entry.target.toLowerCase().contains(query) ||
        entry.sourceChain.any((source) => source.toLowerCase().contains(query));
  }

  /// Checks if a flow matches the search query
  bool _matchesFlowSearch(ActionFlowUIEntry flow) {
    final query = _searchQuery.toLowerCase();

    return flow.rootAction.actionType.toLowerCase().contains(query) ||
        flow.triggerName.toLowerCase().contains(query) ||
        flow.sourceChain.any(
          (source) => source.toLowerCase().contains(query),
        ) ||
        flow.actions.any(
          (action) => action.actionType.toLowerCase().contains(query),
        );
  }

  /// Filters entries by status
  List<ActionLogUIEntry> _filterByStatus(List<ActionLogUIEntry> entries) {
    switch (_statusFilter) {
      case ActionStatusFilter.all:
        return entries;
      case ActionStatusFilter.pending:
        return entries.where((e) => e.isPending).toList();
      case ActionStatusFilter.running:
        return entries.where((e) => e.isRunning).toList();
      case ActionStatusFilter.completed:
        return entries.where((e) => e.isCompleted).toList();
      case ActionStatusFilter.error:
        return entries.where((e) => e.hasFailed).toList();
    }
  }

  /// Filters flow entries by status
  List<ActionFlowUIEntry> _filterFlowsByStatus(List<ActionFlowUIEntry> flows) {
    switch (_statusFilter) {
      case ActionStatusFilter.all:
        return flows;
      case ActionStatusFilter.pending:
        return flows.where((f) => f.isPending).toList();
      case ActionStatusFilter.running:
        return flows.where((f) => f.isRunning).toList();
      case ActionStatusFilter.completed:
        return flows.where((f) => f.isCompleted).toList();
      case ActionStatusFilter.error:
        return flows.where((f) => f.hasFailed).toList();
    }
  }

  /// Clears all action logs
  void clear() {
    _actionEntries.clear();
    _flowEntries.clear();
    _entryOrder.clear();
    filteredEntriesNotifier.value = [];
    filteredFlowEntriesNotifier.value = [];
    notifyListeners();
  }

  /// Gets count of entries by status
  int get totalCount => _actionEntries.length;
  int get flowCount => _flowEntries.length;
  int get pendingCount => allEntries.where((e) => e.isPending).length;
  int get runningCount => allEntries.where((e) => e.isRunning).length;
  int get completedCount => allEntries.where((e) => e.isCompleted).length;
  int get failedCount => allEntries.where((e) => e.hasFailed).length;

  @override
  void dispose() {
    filteredEntriesNotifier.dispose();
    filteredFlowEntriesNotifier.dispose();
    super.dispose();
  }
}
