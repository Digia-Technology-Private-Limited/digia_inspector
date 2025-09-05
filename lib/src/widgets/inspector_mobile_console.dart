import 'package:digia_inspector/src/models/action_flow_ui_entry.dart';
import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector/src/state/network_log_manager.dart';
import 'package:digia_inspector/src/theme_system.dart';
import 'package:digia_inspector/src/widgets/action/action_list_view.dart';
import 'package:digia_inspector/src/widgets/action/action_search_filter.dart';
import 'package:digia_inspector/src/widgets/common/coming_soon_widget.dart';
import 'package:digia_inspector/src/widgets/common/inspector_app_bar.dart';
import 'package:digia_inspector/src/widgets/common/inspector_tab_bar.dart';
import 'package:digia_inspector/src/widgets/network/network_list_view.dart';
import 'package:digia_inspector/src/widgets/network/network_search_filter.dart';
import 'package:flutter/material.dart';

/// Mobile-optimized inspector console with existing mobile structure
class InspectorMobileConsole extends StatefulWidget {
  const InspectorMobileConsole({
    super.key,
    required this.controller,
    this.onClose,
    this.initialTabIndex = 0,
  });

  final InspectorController controller;
  final VoidCallback? onClose;
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
  ActionStatusFilter _actionStatusFilter = ActionStatusFilter.all;

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
      backgroundColor: InspectorColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
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
    });
  }
}
