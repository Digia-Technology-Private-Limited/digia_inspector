import 'package:digia_inspector/src/models/action_flow_ui_entry.dart';
import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector/src/state/network_log_manager.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:digia_inspector/src/widgets/action/action_list_view.dart';
import 'package:digia_inspector/src/widgets/action/action_search_filter.dart';
import 'package:digia_inspector/src/widgets/network/network_list_view.dart';
import 'package:digia_inspector/src/widgets/network/network_search_filter.dart';
import 'package:flutter/material.dart';

/// Main inspector dashboard with pixel-perfect mobile-first design
class InspectorMobileView extends StatefulWidget {
  const InspectorMobileView({
    required this.controller,
    super.key,
    this.onClose,
    this.initialTabIndex = 0,
  });

  final InspectorController controller;
  final VoidCallback? onClose;
  final int initialTabIndex;

  @override
  State<InspectorMobileView> createState() => _InspectorMobileViewState();
}

class _InspectorMobileViewState extends State<InspectorMobileView>
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
            _buildAppBar(),
            _buildTabBar(),
            _buildSearchBar(),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: InspectorSpacing.paddingMD,
      decoration: const BoxDecoration(
        color: InspectorColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(
            color: InspectorColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.onClose != null)
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(
                Icons.arrow_back_ios,
                color: InspectorColors.contentPrimary,
              ),
            )
          else
            const SizedBox(width: 48), // Spacer for centering
          Expanded(
            child: Text(
              'Inspect',
              style: InspectorTypography.headline.copyWith(
                color: InspectorColors.contentPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _clearLogs,
            icon: const Icon(
              Icons.refresh,
              color: InspectorColors.contentPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: InspectorColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(
            color: InspectorColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: InspectorColors.accent,
        labelColor: InspectorColors.contentPrimary,
        unselectedLabelColor: InspectorColors.contentSecondary,
        labelStyle: InspectorTypography.subheadBold,
        unselectedLabelStyle: InspectorTypography.subhead,
        tabs: const [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: InspectorIconSizes.sm,
                ),
                SizedBox(width: InspectorSpacing.xs),
                Text('Network'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt,
                  size: InspectorIconSizes.sm,
                ),
                SizedBox(width: InspectorSpacing.xs),
                Text('Actions'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storage,
                  size: InspectorIconSizes.sm,
                ),
                SizedBox(width: InspectorSpacing.xs),
                Text('State'),
              ],
            ),
          ),
        ],
        onTap: (index) {
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
        },
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
    return _buildComingSoonTab(
      icon: Icons.storage,
      title: 'State',
      subtitle: 'State inspection coming soon...',
    );
  }

  Widget _buildComingSoonTab({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: InspectorSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: InspectorColors.contentTertiary,
            ),
            const SizedBox(height: InspectorSpacing.lg),
            Text(
              title,
              style: InspectorTypography.title3.copyWith(
                color: InspectorColors.contentSecondary,
              ),
            ),
            const SizedBox(height: InspectorSpacing.sm),
            Text(
              subtitle,
              style: InspectorTypography.subhead.copyWith(
                color: InspectorColors.contentTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
