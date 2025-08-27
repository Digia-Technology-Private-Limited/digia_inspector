import 'dart:convert';

import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/inspector_controller.dart';

/// Web-optimized console widget for the dashboard.
///
/// Provides a Chrome DevTools-like experience with tabs for Network, Logs, Errors, etc.
/// Designed for desktop/web platforms with mouse and keyboard interaction.
class InspectorConsoleWeb extends StatefulWidget {
  final InspectorController controller;
  final double height;
  final double? width;
  final bool isDockable;

  const InspectorConsoleWeb({
    super.key,
    required this.controller,
    this.height = 400,
    this.width,
    this.isDockable = true,
  });

  @override
  State<InspectorConsoleWeb> createState() => _InspectorConsoleWebState();
}

class _InspectorConsoleWebState extends State<InspectorConsoleWeb>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.text = widget.controller.searchQuery;
    _searchController.addListener(() {
      widget.controller.setSearchQuery(_searchController.text);
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
    return Container(
      height: _isExpanded ? widget.height : 32,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_isExpanded) ...[
            _buildTabBar(),
            Expanded(child: _buildTabContent()),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(
            Icons.bug_report,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Digia Inspector',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _buildLogCounts(),
          const SizedBox(width: 8),
          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildLogCounts() {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Row(
          children: [
            _buildCountChip(
              icon: Icons.info_outline,
              count: widget.controller.totalCount,
              color: Colors.blue,
            ),
            const SizedBox(width: 4),
            _buildCountChip(
              icon: Icons.warning_outlined,
              count: widget.controller.warningCount,
              color: Colors.orange,
            ),
            const SizedBox(width: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.clear_all, size: 16),
          onPressed: widget.controller.clearLogs,
          tooltip: 'Clear All Logs',
          constraints: const BoxConstraints.tightFor(width: 24, height: 24),
          padding: EdgeInsets.zero,
        ),
        IconButton(
          icon: const Icon(Icons.download, size: 16),
          onPressed: _exportLogs,
          tooltip: 'Export Logs',
          constraints: const BoxConstraints.tightFor(width: 24, height: 24),
          padding: EdgeInsets.zero,
        ),
        IconButton(
          icon: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 16,
          ),
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          tooltip: _isExpanded ? 'Collapse' : 'Expand',
          constraints: const BoxConstraints.tightFor(width: 24, height: 24),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: Theme.of(context).textTheme.labelSmall,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Network'),
                Tab(text: 'Logs'),
                Tab(text: 'Errors'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 200,
              height: 24,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search logs...',
                  prefixIcon: Icon(Icons.search, size: 16),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 8,
                  ),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
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
        child: Text(
          'No logs found',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return ListView.separated(
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
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: _buildLogIcon(log),
      title: Text(
        log.title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${TimestampHelper.format(log.timestamp)} - ${log.eventType}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
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

    return Icon(icon, size: 16, color: color);
  }

  void _showLogDetails(LogEvent log) {
    showDialog(
      context: context,
      builder: (context) => _LogDetailsDialog(log: log),
    );
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

/// Dialog for showing detailed log information.
class _LogDetailsDialog extends StatelessWidget {
  final LogEvent log;

  const _LogDetailsDialog({required this.log});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Log Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('ID', log.id),
                    _buildDetailRow('Type', log.eventType),
                    _buildDetailRow('Level', log.level.name),
                    _buildDetailRow(
                      'Timestamp',
                      TimestampHelper.format(log.timestamp),
                    ),
                    _buildDetailRow('Title', log.title),
                    _buildDetailRow('Description', log.description),
                    if (log.category != null)
                      _buildDetailRow('Category', log.category!),
                    if (log.tags.isNotEmpty)
                      _buildDetailRow('Tags', log.tags.join(', ')),
                    if (log.metadata.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Metadata',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
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
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
