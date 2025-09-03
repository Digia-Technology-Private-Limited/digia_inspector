import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector/src/widgets/network_logs_panel.dart';
import 'package:flutter/material.dart';

/// Main debug inspector dashboard with Chrome DevTools-like interface.
///
/// This widget provides a tabbed interface for debugging different aspects
/// of the app including network requests, actions, and state management.
class InspectorDashboard extends StatefulWidget {
  const InspectorDashboard({
    required this.controller,
    super.key,
    this.onClose,
    this.initialTab = 0,
    this.isFullScreen = true,
  });

  /// The inspector controller managing log data.
  final InspectorController controller;

  /// Callback when the dashboard should be closed.
  final VoidCallback? onClose;

  /// Initial tab to display (0=Network, 1=Actions, 2=State).
  final int initialTab;

  /// Whether to show as full screen or overlay.
  final bool isFullScreen;

  @override
  State<InspectorDashboard> createState() => _InspectorDashboardState();
}

class _InspectorDashboardState extends State<InspectorDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
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
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                NetworkLogsPanel(
                  controller: widget.controller,
                  searchQuery: _searchQuery,
                ),
                _buildActionsPanel(),
                _buildStatePanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2D2D2D),
      elevation: 0,
      title: const Text(
        'Inspect',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: widget.onClose,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            widget.controller.clearLogs();
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E1E1E),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search logs...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                // TODO: Implement filter functionality
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF333333),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF007ACC),
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 18),
                const SizedBox(width: 8),
                const Text('Network'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 18),
                const SizedBox(width: 8),
                const Text('Actions'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage, size: 18),
                const SizedBox(width: 8),
                const Text('State'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsPanel() {
    return const Center(
      child: Text(
        'Actions panel coming soon...',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildStatePanel() {
    return const Center(
      child: Text(
        'State panel coming soon...',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
