import 'package:digia_inspector/src/models/action_flow_ui_entry.dart';
import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector/src/state/network_log_manager.dart';
import 'package:digia_inspector/src/theme_system.dart';
import 'package:digia_inspector/src/widgets/action/action_detail_bottom_sheet.dart';
import 'package:digia_inspector/src/widgets/action/action_list_view.dart';
import 'package:digia_inspector/src/widgets/action/action_search_filter.dart';
import 'package:digia_inspector/src/widgets/common/coming_soon_widget.dart';
import 'package:digia_inspector/src/widgets/common/inspector_app_bar.dart';
import 'package:digia_inspector/src/widgets/common/inspector_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

/// Web-optimized inspector console with nested navigation
class InspectorWebConsole extends StatefulWidget {
  const InspectorWebConsole({
    super.key,
    required this.controller,
    this.onClose,
    this.initialTabIndex = 0,
    this.height = 400,
    this.width,
  });

  final InspectorController controller;
  final VoidCallback? onClose;
  final int initialTabIndex;
  final double height;
  final double? width;

  @override
  State<InspectorWebConsole> createState() => _InspectorWebConsoleState();
}

class _InspectorWebConsoleState extends State<InspectorWebConsole>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search and filter state
  String _searchQuery = '';
  NetworkStatusFilter _networkStatusFilter = NetworkStatusFilter.all;
  ActionStatusFilter _actionStatusFilter = ActionStatusFilter.all;

  // Navigation state for web
  String? _selectedNetworkLogId;
  String? _selectedActionFlowId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        color: InspectorColors.backgroundPrimary,
        border: Border.all(
          color: InspectorColors.separator,
        ),
        borderRadius: InspectorBorderRadius.radiusLG,
        boxShadow: InspectorElevation.cardShadow,
      ),
      child: _buildMainView(),
    );
  }

  Widget _buildMainView() {
    return Column(
      children: [
        InspectorAppBar(
          onBack: widget.onClose,
          onClearLogs: _clearLogs,
        ),
        InspectorTabBar(
          tabController: _tabController,
          onTabChanged: _onTabChanged,
        ),
        _buildSearchBar(),
        Expanded(
          child: _buildSplitView(),
        ),
      ],
    );
  }

  Widget _buildSplitView() {
    final hasDetail =
        _selectedNetworkLogId != null || _selectedActionFlowId != null;
    if (!hasDetail) {
      return _buildTabContent();
    }

    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerThickness: 8,
        dividerPainter: DividerPainters.background(
          highlightedColor: Colors.transparent,
          color: Colors.transparent,
        ),
      ),
      child: MultiSplitView(
        initialAreas: [
          Area(flex: 1),
          Area(flex: 2, min: 1, max: 1.4),
        ],
        builder: (context, area) {
          if (area.index == 0) {
            return _buildTabContent();
          }
          return _buildDetailView();
        },
      ),
    );
  }

  Widget _buildDetailView() {
    if (_selectedNetworkLogId != null) {
      return _buildNetworkDetail();
    } else if (_selectedActionFlowId != null) {
      return _buildActionDetail();
    }
    return const SizedBox.shrink();
  }

  Widget _buildSearchBar() {
    final currentTab = _tabController.index;

    if (currentTab == 0) {
      // Network tab
      return NetworkSearchBar(
        initialQuery: _searchQuery,
        currentFilter: _networkStatusFilter,
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
          widget.controller.networkLogManager.setSearchQuery(query);
        },
        onFilterChanged: (filter) {
          setState(() {
            _networkStatusFilter = filter;
          });
          widget.controller.networkLogManager.setStatusFilter(filter);
        },
      );
    } else if (currentTab == 1) {
      // Actions tab
      return ActionSearchBar(
        initialQuery: _searchQuery,
        currentFilter: _actionStatusFilter,
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
          widget.controller.actionLogManager.setSearchQuery(query);
        },
        onFilterChanged: (filter) {
          setState(() {
            _actionStatusFilter = filter;
          });
          widget.controller.actionLogManager.setStatusFilter(filter);
        },
      );
    }

    // No search bar for State tab
    return const SizedBox.shrink();
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildNetworkTab(),
        _buildActionsTab(),
        _buildStateTab(),
      ],
    );
  }

  Widget _buildNetworkTab() {
    return ValueListenableBuilder<List<NetworkLogUIEntry>>(
      valueListenable:
          widget.controller.networkLogManager.filteredEntriesNotifier,
      builder: (context, networkEntries, __) {
        return NetworkListView(
          networkLogs: networkEntries,
          searchQuery: _searchQuery,
          statusFilter: _networkStatusFilter,
          onClearLogs: _clearLogs,
          onItemTap: (log) {
            setState(() {
              _selectedNetworkLogId = log.id;
              _selectedActionFlowId = null;
            });
          },
        );
      },
    );
  }

  Widget _buildActionsTab() {
    return ValueListenableBuilder<List<ActionFlowUIEntry>>(
      valueListenable:
          widget.controller.actionLogManager.filteredFlowEntriesNotifier,
      builder: (context, actionFlows, __) {
        return ActionListView(
          actionFlows: actionFlows,
          searchQuery: _searchQuery,
          statusFilter: _actionStatusFilter,
          onClearLogs: _clearLogs,
          onItemTap: (flow) {
            setState(() {
              _selectedActionFlowId = flow.flowId;
              _selectedNetworkLogId = null;
            });
          },
        );
      },
    );
  }

  Widget _buildStateTab() {
    return const ComingSoonWidget(
      icon: Icons.storage,
      title: 'State',
      subtitle: 'State inspection coming soon...',
    );
  }

  Widget _buildNetworkDetail() {
    // Find the selected network log
    final networkLogs = widget.controller.networkLogManager.allEntries;
    final selectedLog = networkLogs.firstWhere(
      (log) => log.id == _selectedNetworkLogId,
      orElse: () => networkLogs.first,
    );

    return NetworkDetailBottomSheet(
      log: selectedLog,
      isWebView: true,
      onClose: () {
        setState(() {
          _selectedNetworkLogId = null;
        });
      },
    );
  }

  Widget _buildActionDetail() {
    // Find the selected action flow
    final actionFlows = widget.controller.actionLogManager.allFlowEntries;
    final selectedFlow = actionFlows.firstWhere(
      (flow) => flow.flowId == _selectedActionFlowId,
      orElse: () => actionFlows.first,
    );

    return ActionDetailBottomSheet(
      flow: selectedFlow,
      isWebView: true,
      onClose: () {
        setState(() {
          _selectedActionFlowId = null;
        });
      },
    );
  }

  void _onTabChanged(int index) {
    setState(() {
      // Clear search when switching tabs
      _searchQuery = '';
      _networkStatusFilter = NetworkStatusFilter.all;
      _actionStatusFilter = ActionStatusFilter.all;
      widget.controller.networkLogManager.setSearchQuery('');
      widget.controller.networkLogManager.setStatusFilter(
        NetworkStatusFilter.all,
      );
      widget.controller.actionLogManager.setSearchQuery('');
      widget.controller.actionLogManager.setStatusFilter(
        ActionStatusFilter.all,
      );
      // Clear selected items when switching tabs
      _selectedNetworkLogId = null;
      _selectedActionFlowId = null;
    });
  }

  void _clearLogs() {
    widget.controller.clearLogs();
    widget.controller.networkLogManager.clear();
    widget.controller.actionLogManager.clear();
    setState(() {
      _searchQuery = '';
      _networkStatusFilter = NetworkStatusFilter.all;
      _actionStatusFilter = ActionStatusFilter.all;
      _selectedNetworkLogId = null;
      _selectedActionFlowId = null;
    });
  }
}
