import 'package:digia_inspector/src/log_managers/network_log_manager.dart';
import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/widgets/action/action_log_list_view.dart';
import 'package:digia_inspector/src/widgets/common/inspector_app_bar.dart';
import 'package:digia_inspector/src/widgets/common/inspector_tab_bar.dart';
import 'package:digia_inspector/src/widgets/network/network_list_view.dart';
import 'package:digia_inspector/src/widgets/network/network_search_filter.dart';
import 'package:digia_inspector/src/widgets/state/state_log_list_view.dart';
import 'package:flutter/material.dart';

/// Mobile-optimized inspector console with existing mobile structure
class InspectorMobileConsole extends StatefulWidget {
  /// Mobile-optimized inspector console with existing mobile structure
  const InspectorMobileConsole({
    required this.controller,
    super.key,
    this.onClose,
    this.initialTabIndex = 0,
  });

  /// The inspector controller managing log data
  final InspectorController controller;

  /// Callback when the console should be closed
  final VoidCallback? onClose;

  /// Initial tab to display (0=Network, 1=Actions, 2=State)
  final int initialTabIndex;

  @override
  State<InspectorMobileConsole> createState() => _InspectorMobileConsoleState();
}

class _InspectorMobileConsoleState extends State<InspectorMobileConsole>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search and filter state
  String _searchQuery = '';
  NetworkStatusFilter _networkStatusFilter = NetworkStatusFilter.all;

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
    return Scaffold(
      backgroundColor: context.inspectorColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
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
            _buildSearchBar(),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
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
          networkLogManager: widget.controller.networkLogManager,
        );
      },
    );
  }

  Widget _buildActionsTab() {
    return ActionLogListView(
      actionLogManager: widget.controller.actionLogManager,
      onClearLogs: _clearLogs,
    );
  }

  Widget _buildStateTab() {
    return StateLogListView(
      stateLogManager: widget.controller.stateLogManager,
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
    });
  }
}
