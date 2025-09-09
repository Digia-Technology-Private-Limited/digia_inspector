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
  final Map<String, dynamic> args = {};

  /// Last updated timestamp for either args or state
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
    if (mounted) setState(() {});
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
                        (e) => _buildPageNamespaceSection(
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
                        (e) => _buildComponentNamespaceSection(
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
                        return StateVariableItem(
                          variableKey: ns,
                          value: e.value,
                          lastUpdated: data.lastUpdated,
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

  /// Page: outer header + inner Parameters and States
  Widget? _buildPageNamespaceSection({
    required String namespace,
    required StateData stateData,
  }) {
    final argsCount = stateData.args.length;
    final stateCount = stateData.currentState.length;
    final totalCount = argsCount + stateCount;
    if (totalCount == 0) return null;

    final outerKey = 'page:$namespace';
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
                            'Page Parameters',
                            style: InspectorTypography.subhead,
                          ),
                          icon: Icons.tune,
                          variableCount: argsCount,
                          isExpanded: isParamsExpanded,
                          onTap: () => setState(
                            () => _expandedStates[paramsKey] =
                                !(_expandedStates[paramsKey] ?? true),
                          ),
                        ),
                        if (isParamsExpanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...stateData.args.entries.map((e) {
                                  final normalized = _normalizeKeyValue(
                                    e.key,
                                    e.value,
                                  );
                                  return StateVariableItem(
                                    variableKey: normalized.key,
                                    value: normalized.value,
                                    lastUpdated: stateData.lastUpdated,
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
                            'Page States',
                            style: InspectorTypography.subhead,
                          ),
                          icon: Icons.data_object,
                          variableCount: stateCount,
                          isExpanded: isStatesExpanded,
                          onTap: () => setState(
                            () => _expandedStates[statesKey] =
                                !(_expandedStates[statesKey] ?? true),
                          ),
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
                                    lastUpdated: stateData.lastUpdated,
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

  /// Component: mirrors Page structure (outer + inner Parameters and States)
  Widget? _buildComponentNamespaceSection({
    required String namespace,
    required StateData stateData,
  }) {
    final argsCount = stateData.args.length;
    final stateCount = stateData.currentState.length;
    final totalCount = argsCount + stateCount;
    if (totalCount == 0) return null;

    final outerKey = 'component:$namespace';
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
            icon: Icons.widgets,
            variableCount: totalCount,
            isExpanded: isExpanded,
            onTap: () =>
                setState(() => _expandedStates[outerKey] = !isExpanded),
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
                            'Component Parameters',
                            style: InspectorTypography.subhead,
                          ),
                          icon: Icons.tune,
                          variableCount: argsCount,
                          isExpanded: isParamsExpanded,
                          onTap: () => setState(
                            () => _expandedStates[paramsKey] =
                                !(_expandedStates[paramsKey] ?? true),
                          ),
                        ),
                        if (isParamsExpanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...stateData.args.entries.map((e) {
                                  final normalized = _normalizeKeyValue(
                                    e.key,
                                    e.value,
                                  );
                                  return StateVariableItem(
                                    variableKey: normalized.key,
                                    value: normalized.value,
                                    lastUpdated: stateData.lastUpdated,
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
                            'Component States',
                            style: InspectorTypography.subhead,
                          ),
                          icon: Icons.data_object,
                          variableCount: stateCount,
                          isExpanded: isStatesExpanded,
                          onTap: () => setState(
                            () => _expandedStates[statesKey] =
                                !(_expandedStates[statesKey] ?? true),
                          ),
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
                                    lastUpdated: stateData.lastUpdated,
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
                      lastUpdated: stateData.lastUpdated,
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
    // Calculate total namespaces across all state types
    var totalNamespaces = 0;
    var totalVariables = 0;

    for (final typeMap in groupedStates.values) {
      totalNamespaces += typeMap.length;
      for (final stateData in typeMap.values) {
        totalVariables += stateData.currentState.length + stateData.args.length;
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

  /// Groups state logs by type and namespace, keeping only the latest state
  /// for each variable
  Map<StateType, Map<String, StateData>> _groupStatesByTypeAndNamespace(
    List<StateLog> logs,
  ) {
    final grouped = <StateType, Map<String, StateData>>{
      StateType.app: {},
      StateType.page: {},
      StateType.component: {},
      StateType.stateContainer: {},
    };

    // Sort logs by timestamp (newest first)
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    for (final log in logs) {
      final namespace = log.namespace ?? 'Unknown';
      final stateType = log.stateType;

      grouped[stateType] ??= {};
      grouped[stateType]![namespace] ??= StateData();

      final stateData = grouped[stateType]![namespace]!;

      // Update args with the latest values (mostly from create event)
      if (log.args != null) {
        for (final entry in log.args!.entries) {
          if (!stateData.args.containsKey(entry.key) ||
              log.timestamp.isAfter(stateData.lastUpdated)) {
            stateData.args[entry.key] = entry.value;
            stateData.lastUpdated = log.timestamp;
          }
        }
      }

      // Update current state with the latest values
      if (log.stateData != null) {
        for (final entry in log.stateData!.entries) {
          if (!stateData.currentState.containsKey(entry.key) ||
              log.timestamp.isAfter(stateData.lastUpdated)) {
            stateData.currentState[entry.key] = entry.value;
            stateData.lastUpdated = log.timestamp;
          }
        }
      }
    }

    return grouped;
  }
}
