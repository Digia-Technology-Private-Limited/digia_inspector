import 'dart:async';

import 'package:digia_inspector/src/log_managers/state_log_manager.dart';
import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/widgets/state/state_section_header.dart';
import 'package:digia_inspector/src/widgets/state/state_variable_item.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/material.dart';

/// Data class to hold current state information for a namespace
class StateData {
  /// Current state key-value pairs
  final Map<String, dynamic> currentState = {};

  /// Arguments/parameters captured at creation time (e.g., pageArgs, componentArgs)
  final Map<String, dynamic> argData = {};

  /// Last updated timestamp per variable (key = variable name, value = timestamp)
  final Map<String, DateTime> variableTimestamps = {};

  /// Last updated timestamp for args
  final Map<String, DateTime> argTimestamps = {};

  /// Last updated timestamp for either args or state (for UI display)
  DateTime lastUpdated = DateTime.fromMillisecondsSinceEpoch(0);
}

/// Widget that displays all state logs organized hierarchically by state type.
///
/// Shows expandable sections for:
/// - Global/App States (with outer section)
/// - Page and Component: outer section + inner Parameters and States
/// - State Container: outer section (states only)
class StateLogListView extends StatefulWidget {
  /// State log list view
  const StateLogListView({
    required this.stateLogManager,
    super.key,
  });

  /// State log manager
  final StateLogManager stateLogManager;

  @override
  State<StateLogListView> createState() => _StateLogListViewState();
}

class _StateLogListViewState extends State<StateLogListView> {
  Timer? _refreshTimer;
  final Map<String, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    widget.stateLogManager.addListener(_onStateLogsChanged);
    // Refresh every second to update relative timestamps
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    widget.stateLogManager.removeListener(_onStateLogsChanged);
    super.dispose();
  }

  void _onStateLogsChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allLogs = widget.stateLogManager.allLogs;
    final groupedStates = _groupStatesByTypeAndNamespace(allLogs);

    if (allLogs.isEmpty) {
      return Column(
        children: [
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.layers_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No state logs available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Navigate through your app to see state changes',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          _buildBottomBar(groupedStates),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              // Global/App State - states only, no parameters
              if (_hasAnyNonEmptyCurrentState(groupedStates[StateType.app]))
                _buildGlobalStateSection(groupedStates[StateType.app]!),

              // Pages
              ...groupedStates[StateType.page]
                      ?.entries
                      .map(
                        (e) => _buildEntityNamespaceSection(
                          namespace: e.key,
                          stateData: e.value,
                        ),
                      )
                      .whereType<Widget>()
                      .toList() ??
                  [],

              // Components
              ...groupedStates[StateType.component]
                      ?.entries
                      .map(
                        (e) => _buildEntityNamespaceSection(
                          namespace: e.key,
                          stateData: e.value,
                        ),
                      )
                      .whereType<Widget>()
                      .toList() ??
                  [],

              // State Containers
              ...groupedStates[StateType.stateContainer]
                      ?.entries
                      .map(
                        (e) => _buildStateContainerNamespaceSection(
                          namespace: e.key,
                          stateData: e.value,
                        ),
                      )
                      .whereType<Widget>()
                      .toList() ??
                  [],
            ],
          ),
        ),
        _buildBottomBar(groupedStates),
      ],
    );
  }

  // =============== Sections ===============

  /// Global/App State section with expandable header (states only)
  Widget _buildGlobalStateSection(Map<String, StateData> namespaces) {
    const sectionKey = 'app';
    final isExpanded = _expandedStates[sectionKey] ?? false;

    final variableCount = namespaces.values
        .map((d) => d.currentState.length)
        .fold<int>(0, (a, b) => a + b);

    // Determine most recent update across all app namespaces
    DateTime? latest;
    for (final data in namespaces.values) {
      if (latest == null || data.lastUpdated.isAfter(latest)) {
        latest = data.lastUpdated;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: AppElevation.cardShadow,
      ),
      child: Column(
        children: [
          StateSectionHeader(
            title: const Text(
              'Global State',
              style: InspectorTypography.headline,
            ),
            icon: Icons.public,
            variableCount: variableCount,
            isExpanded: isExpanded,
            onTap: () {
              setState(() {
                _expandedStates[sectionKey] = !isExpanded;
              });
            },
            lastUpdated: latest,
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...namespaces.entries.expand((entry) {
                    final ns = entry.key;
                    final data = entry.value;
                    if (data.currentState.isEmpty) return <Widget>[];
                    return [
                      ...data.currentState.entries.map((e) {
                        final normalized = _normalizeKeyValue(e.key, e.value);
                        return StateVariableItem(
                          variableKey: ns,
                          value: normalized.value,
                          lastUpdated: data.variableTimestamps[e.key] ??
                              data.lastUpdated,
                        );
                      }),
                    ];
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Entity: outer header + inner Parameters and States
  Widget? _buildEntityNamespaceSection({
    required String namespace,
    required StateData stateData,
  }) {
    final argsCount = stateData.argData.length;
    final stateCount = stateData.currentState.length;
    final totalCount = argsCount + stateCount;
    if (totalCount == 0) return null;

    final outerKey = 'entity:$namespace';
    final paramsKey = '$outerKey:params';
    final statesKey = '$outerKey:states';

    final isExpanded = _expandedStates[outerKey] ?? false;
    final isParamsExpanded = _expandedStates.putIfAbsent(paramsKey, () => true);
    final isStatesExpanded = _expandedStates.putIfAbsent(statesKey, () => true);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: AppElevation.cardShadow,
      ),
      child: Column(
        children: [
          StateSectionHeader(
            title: Text(namespace, style: InspectorTypography.headline),
            icon: Icons.web,
            variableCount: totalCount,
            isExpanded: isExpanded,
            onTap: () =>
                setState(() => _expandedStates[outerKey] = !isExpanded),
            lastUpdated: stateData.lastUpdated,
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
              child: Column(
                children: [
                  if (argsCount > 0)
                    Column(
                      children: [
                        StateSectionHeader(
                          title: const Text(
                            'Parameters',
                            style: InspectorTypography.subhead,
                          ),
                          icon: Icons.tune,
                          variableCount: argsCount,
                          isExpanded: isParamsExpanded,
                          onTap: () => setState(
                            () => _expandedStates[paramsKey] =
                                !(_expandedStates[paramsKey] ?? true),
                          ),
                          lastUpdated: stateData.lastUpdated,
                        ),
                        if (isParamsExpanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...stateData.argData.entries.map((e) {
                                  final normalized = _normalizeKeyValue(
                                    e.key,
                                    e.value,
                                  );
                                  return StateVariableItem(
                                    variableKey: normalized.key,
                                    value: normalized.value,
                                    lastUpdated:
                                        stateData.argTimestamps[e.key] ??
                                            stateData.lastUpdated,
                                  );
                                }),
                              ],
                            ),
                          ),
                      ],
                    ),
                  if (stateCount > 0)
                    Column(
                      children: [
                        StateSectionHeader(
                          title: const Text(
                            'States',
                            style: InspectorTypography.subhead,
                          ),
                          icon: Icons.data_object,
                          variableCount: stateCount,
                          isExpanded: isStatesExpanded,
                          onTap: () => setState(
                            () => _expandedStates[statesKey] =
                                !(_expandedStates[statesKey] ?? true),
                          ),
                          lastUpdated: stateData.lastUpdated,
                        ),
                        if (isStatesExpanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...stateData.currentState.entries.map((e) {
                                  final normalized = _normalizeKeyValue(
                                    e.key,
                                    e.value,
                                  );
                                  return StateVariableItem(
                                    variableKey: normalized.key,
                                    value: normalized.value,
                                    lastUpdated:
                                        stateData.variableTimestamps[e.key] ??
                                            stateData.lastUpdated,
                                  );
                                }),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// State Container: outer-only, states only
  Widget? _buildStateContainerNamespaceSection({
    required String namespace,
    required StateData stateData,
  }) {
    final stateCount = stateData.currentState.length;
    if (stateCount == 0) return null;

    final outerKey = 'container:$namespace';
    final isExpanded = _expandedStates[outerKey] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: AppElevation.cardShadow,
      ),
      child: Column(
        children: [
          StateSectionHeader(
            title: Text(namespace, style: InspectorTypography.headline),
            icon: Icons.inventory_2,
            variableCount: stateCount,
            isExpanded: isExpanded,
            onTap: () =>
                setState(() => _expandedStates[outerKey] = !isExpanded),
            lastUpdated: stateData.lastUpdated,
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...stateData.currentState.entries.map((e) {
                    final normalized = _normalizeKeyValue(e.key, e.value);
                    return StateVariableItem(
                      variableKey: normalized.key,
                      value: normalized.value,
                      lastUpdated: stateData.variableTimestamps[e.key] ??
                          stateData.lastUpdated,
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =============== Helpers ===============

  Widget _buildBottomBar(Map<StateType, Map<String, StateData>> groupedStates) {
    var totalVariables = 0;
    final totalNamespaces =
        groupedStates.values.fold<int>(0, (a, b) => a + b.length);

    for (final typeMap in groupedStates.values) {
      for (final stateData in typeMap.values) {
        totalVariables +=
            stateData.currentState.length + stateData.argData.length;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(
          top: BorderSide(
            color: AppColors.borderDefault,
          ),
        ),
      ),
      child: Text(
        totalNamespaces == 1
            ? '1 entity • $totalVariables variables'
            : '$totalNamespaces entities • $totalVariables variables',
        style: InspectorTypography.footnote.copyWith(
          color: AppColors.contentPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  bool _hasAnyNonEmptyCurrentState(Map<String, StateData>? map) {
    if (map == null || map.isEmpty) return false;
    for (final data in map.values) {
      if (data.currentState.isNotEmpty) return true;
    }
    return false;
  }

  /// Normalize state entries when values are wrapped, ensuring the displayed
  /// variable name is correct (avoids showing 'value' as the key).
  MapEntry<String, dynamic> _normalizeKeyValue(String key, dynamic value) {
    if (value is Map) {
      // Case 1: {'name': 'varA', 'value': 123}
      final hasName = value.containsKey('name');
      final hasValue = value.containsKey('value');
      if (hasName && hasValue) {
        final name = value['name']?.toString() ?? key;
        return MapEntry(name, value['value']);
      }
      // Case 2: {'value': 123} only -> keep parent key, unwrap value
      if (value.length == 1 && hasValue) {
        return MapEntry(key, value['value']);
      }
    }
    return MapEntry(key, value);
  }

  /// Groups state logs by type and namespace, tracking lifecycle properly
  /// to show current active state while preserving navigation history
  Map<StateType, Map<String, StateData>> _groupStatesByTypeAndNamespace(
    List<StateLog> logs,
  ) {
    final grouped = <StateType, Map<String, StateData>>{
      StateType.app: {},
      StateType.page: {},
      StateType.component: {},
      StateType.stateContainer: {},
    };

    // Sort logs by timestamp (chronological order - oldest first)
    logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Track namespace lifecycle: key = "stateType:namespace",
    // value = last event timestamp and status
    final namespaceStatus = <String, (DateTime, bool)>{};

    // First pass: determine final status of each namespace
    for (final log in logs) {
      final namespace = log.namespace ?? 'Unknown';
      final key = '${log.stateType.value}:$namespace';

      if (log.stateEventType == StateEventType.create) {
        // Mark as active - latest create event wins
        final existing = namespaceStatus[key];
        if (existing == null || log.timestamp.isAfter(existing.$1)) {
          namespaceStatus[key] = (log.timestamp, true);
        }
      } else if (log.stateEventType == StateEventType.dispose) {
        // Mark as disposed - latest dispose event wins
        final existing = namespaceStatus[key];
        if (existing == null || log.timestamp.isAfter(existing.$1)) {
          namespaceStatus[key] = (log.timestamp, false);
        }
      } else if (log.stateEventType == StateEventType.change) {
        // Change events don't affect lifecycle status, but ensure namespace exists
        if (!namespaceStatus.containsKey(key)) {
          namespaceStatus[key] =
              (log.timestamp, true); // Assume active if not seen before
        }
      }
    }

    // Second pass: process logs for currently active namespaces
    for (final log in logs.reversed) {
      // Skip dispose events (they don't contribute to current state)
      if (log.stateEventType == StateEventType.dispose) {
        continue;
      }

      final namespace = log.namespace ?? 'Unknown';
      final stateType = log.stateType;
      final key = '${stateType.value}:$namespace';

      // Only show namespaces that are currently active (not disposed)
      final status = namespaceStatus[key];
      if (status == null || !status.$2) {
        continue;
      }

      grouped[stateType] ??= {};
      grouped[stateType]![namespace] ??= StateData();

      final stateData = grouped[stateType]![namespace]!;

      // Update args with the latest values (from page/component create events)
      if (log.argData != null) {
        for (final entry in log.argData!.entries) {
          final existingTimestamp = stateData.argTimestamps[entry.key];
          if (existingTimestamp == null ||
              log.timestamp.isAfter(existingTimestamp)) {
            stateData.argData[entry.key] = entry.value;
            stateData.argTimestamps[entry.key] = log.timestamp;
            if (log.timestamp.isAfter(stateData.lastUpdated)) {
              stateData.lastUpdated = log.timestamp;
            }
          }
        }
      }

      // Update current state with the latest values (from state context events)
      if (log.stateData != null) {
        for (final entry in log.stateData!.entries) {
          final existingTimestamp = stateData.variableTimestamps[entry.key];
          if (existingTimestamp == null ||
              log.timestamp.isAfter(existingTimestamp)) {
            stateData.currentState[entry.key] = entry.value;
            stateData.variableTimestamps[entry.key] = log.timestamp;
            if (log.timestamp.isAfter(stateData.lastUpdated)) {
              stateData.lastUpdated = log.timestamp;
            }
          }
        }
      }
    }

    return grouped;
  }
}
