import 'package:digia_inspector/src/log_managers/network_log_manager.dart';
import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/widgets/action/action_detail_view.dart';
import 'package:digia_inspector/src/widgets/action/action_log_list_view.dart';
import 'package:digia_inspector/src/widgets/common/inspector_app_bar.dart';
import 'package:digia_inspector/src/widgets/common/inspector_tab_bar.dart';
import 'package:digia_inspector/src/widgets/network/network_detail_view.dart';
import 'package:digia_inspector/src/widgets/network/network_list_view.dart';
import 'package:digia_inspector/src/widgets/network/network_search_filter.dart';
import 'package:digia_inspector/src/widgets/state/state_log_list_view.dart';
import 'package:flutter/material.dart';

/// Web-optimized inspector console with nested navigation
class InspectorWebConsole extends StatefulWidget {
  /// Web-optimized inspector console with nested navigation
  const InspectorWebConsole({
    required this.controller,
    super.key,
    this.onClose,
    this.initialTabIndex = 0,
    this.height = 400,
    this.width,
  });

  /// The inspector controller managing log data
  final InspectorController controller;

  /// Callback when the console should be closed
  final VoidCallback? onClose;

  /// Initial tab to display (0=Network, 1=Actions, 2=State)
  final int initialTabIndex;

  /// Height of the console (web only)
  final double height;

  /// Width of the console (web only)
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
        color: context.inspectorColors.backgroundSecondary,
        border: Border.all(
          color: context.inspectorColors.separator,
        ),
        borderRadius: AppBorderRadius.radiusLG,
        boxShadow: AppElevation.cardShadow,
      ),
      child: _buildMainView(),
    );
  }

  Widget _buildMainView() {
    final hasDetail =
        _selectedNetworkLogId != null || _selectedActionFlowId != null;

    return Column(
      children: [
        InspectorAppBar(
          onBack: widget.onClose,
          onClearLogs: _clearTabLogs,
          currentTabIndex: _tabController.index,
        ),
        InspectorTabBar(
          tabController: _tabController,
          onTabChanged: _onTabChanged,
        ),
        if (hasDetail)
          Expanded(child: _buildDetailView())
        else ...[
          _buildSearchBar(),
          Expanded(child: _buildTabContent()),
        ],
      ],
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
    }

    // No search bar for Actions and State tabs
    return const SizedBox.shrink();
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
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
      builder: (context, networkEntries, _) {
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
    return ActionLogListView(
      actionLogManager: widget.controller.actionLogManager,
      onClearLogs: _clearLogs,
      onItemTap: (flow) {
        setState(() {
          _selectedActionFlowId = flow.id;
          _selectedNetworkLogId = null;
        });
      },
    );
  }

  Widget _buildStateTab() {
    return StateLogListView(
      stateLogManager: widget.controller.stateLogManager,
    );
  }

  Widget _buildNetworkDetail() {
    // Use the network log manager and log ID for reactive updates
    return NetworkDetailView(
      networkLogManager: widget.controller.networkLogManager,
      logId: _selectedNetworkLogId,
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
    final selectedFlow = widget.controller.actionLogManager.getById(
      _selectedActionFlowId!,
    );
    if (selectedFlow == null) {
      return const SizedBox.shrink();
    }

    return ActionDetailView(
      flow: selectedFlow,
      actionLogManager: widget.controller.actionLogManager,
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
      widget.controller.networkLogManager.setSearchQuery('');
      widget.controller.networkLogManager.setStatusFilter(
        NetworkStatusFilter.all,
      );
      // Clear selected items when switching tabs
      _selectedNetworkLogId = null;
      _selectedActionFlowId = null;
    });
  }

  void _clearTabLogs(int? tabIndex) {
    if (tabIndex != null) {
      widget.controller.clearTabLogs(tabIndex);
      // Only clear search state if we're clearing the network tab
      if (tabIndex == 0) {
        setState(() {
          _searchQuery = '';
          _networkStatusFilter = NetworkStatusFilter.all;
          _selectedNetworkLogId = null;
        });
      } else if (tabIndex == 1) {
        // Clear action selection if clearing actions tab
        setState(() {
          _selectedActionFlowId = null;
        });
      }
    } else {
      _clearLogs();
    }
  }

  void _clearLogs() {
    widget.controller.clearLogs();
    widget.controller.networkLogManager.clear();
    widget.controller.actionLogManager.clear();
    setState(() {
      _searchQuery = '';
      _networkStatusFilter = NetworkStatusFilter.all;
      _selectedNetworkLogId = null;
      _selectedActionFlowId = null;
    });
  }
}
