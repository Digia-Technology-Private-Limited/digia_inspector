import 'dart:convert';

import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/inspector_controller.dart';

/// Mobile-optimized inspector panel for preview apps.
///
/// Designed for touch interaction with larger tap targets and mobile-friendly navigation.
/// Can be shown as a bottom sheet or full-screen modal.
class InspectorPanelMobile extends StatefulWidget {
  final InspectorController controller;
  final double maxHeight;
  final bool showAsFullScreen;

  const InspectorPanelMobile({
    super.key,
    required this.controller,
    this.maxHeight = 600,
    this.showAsFullScreen = false,
  });

  @override
  State<InspectorPanelMobile> createState() => _InspectorPanelMobileState();
}

class _InspectorPanelMobileState extends State<InspectorPanelMobile>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.text = widget.controller.searchQuery;
    _searchController.addListener(() {
      widget.controller.setSearchQuery(_searchController.text);
    });
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAsFullScreen) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildContent(),
      );
    } else {
      return Container(
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      );
    }
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Digia Inspector'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: [
        _buildLogCounts(),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 8),
                  Text('Clear All'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Export Logs'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bug_report,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'Digia Inspector',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _buildLogCounts(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Logs'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogCounts() {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCountChip(
              icon: Icons.info_outline,
              count: widget.controller.totalCount,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _buildCountChip(
              icon: Icons.warning_outlined,
              count: widget.controller.warningCount,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            _buildCountChip(
              icon: Icons.error_outline,
              count: widget.controller.errorCount,
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCountChip({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildTabBar(),
        Expanded(child: _buildTabContent()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search logs...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    widget.controller.setSearchQuery('');
                  },
                )
              : null,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: Theme.of(context).textTheme.labelMedium,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Network'),
          Tab(text: 'Logs'),
          Tab(text: 'Errors'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildLogList(),
        _buildNetworkList(),
        _buildMessageList(),
        _buildErrorList(),
      ],
    );
  }

  Widget _buildLogList() {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final logs = widget.controller.filteredLogs;
        return _buildList(logs);
      },
    );
  }

  Widget _buildNetworkList() {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final logs = widget.controller.filteredLogs
            .where(
              (log) =>
                  log is RequestLog ||
                  log is ResponseLog ||
                  log is NetworkErrorLog,
            )
            .toList();
        return _buildList(logs);
      },
    );
  }

  Widget _buildMessageList() {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final logs = widget.controller.filteredLogs
            .where((log) => log.eventType == 'message')
            .toList();
        return _buildList(logs);
      },
    );
  }

  Widget _buildErrorList() {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final logs = widget.controller.filteredLogs
            .where(
              (log) =>
                  log is ErrorLog ||
                  log.level == LogLevel.error ||
                  log.level == LogLevel.critical,
            )
            .toList();
        return _buildList(logs);
      },
    );
  }

  Widget _buildList(List<LogEvent> logs) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No logs found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: logs.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
      ),
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogTile(log);
      },
    );
  }

  Widget _buildLogTile(LogEvent log) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildLogIcon(log),
      title: Text(
        log.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            log.description,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${TimestampHelper.format(log.timestamp)} • ${log.eventType}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
      onTap: () => _showLogDetails(log),
    );
  }

  Widget _buildLogIcon(LogEvent log) {
    IconData icon;
    Color color;

    switch (log.level) {
      case LogLevel.critical:
      case LogLevel.error:
        icon = Icons.error;
        color = Colors.red;
        break;
      case LogLevel.warning:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case LogLevel.debug:
        icon = Icons.bug_report;
        color = Colors.purple;
        break;
      default:
        if (log is RequestLog) {
          icon = Icons.arrow_upward;
          color = Colors.blue;
        } else if (log is ResponseLog) {
          icon = Icons.arrow_downward;
          color = Colors.green;
        } else if (log is NetworkErrorLog) {
          icon = Icons.network_check;
          color = Colors.red;
        } else {
          icon = Icons.info;
          color = Colors.grey;
        }
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, size: 20, color: color),
    );
  }

  void _showLogDetails(LogEvent log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LogDetailsBottomSheet(log: log),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear':
        widget.controller.clearLogs();
        break;
      case 'export':
        _exportLogs();
        break;
    }
  }

  void _exportLogs() {
    final json = widget.controller.exportLogsAsJson();
    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(json);

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: jsonString));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copied to clipboard')),
    );
  }
}

/// Bottom sheet for showing detailed log information on mobile.
class _LogDetailsBottomSheet extends StatelessWidget {
  final LogEvent log;

  const _LogDetailsBottomSheet({required this.log});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Log Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailCard('Basic Info', [
                        _buildDetailRow('ID', log.id),
                        _buildDetailRow('Type', log.eventType),
                        _buildDetailRow('Level', log.level.name),
                        _buildDetailRow(
                          'Timestamp',
                          TimestampHelper.format(log.timestamp),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildDetailCard('Content', [
                        _buildDetailRow('Title', log.title),
                        _buildDetailRow('Description', log.description),
                        if (log.category != null)
                          _buildDetailRow('Category', log.category!),
                        if (log.tags.isNotEmpty)
                          _buildDetailRow('Tags', log.tags.join(', ')),
                      ]),
                      if (log.metadata.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailCard('Metadata', [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (() {
                                const encoder = JsonEncoder.withIndent('  ');
                                return encoder.convert(log.metadata);
                              })(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                            ),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
