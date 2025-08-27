import 'package:digia_inspector/src/state/inspector_controller.dart';
import 'package:digia_inspector/src/widgets/network_request_viewer.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A comprehensive debug console that displays all logged events.
///
/// This widget provides filtering, searching, and detailed views of
/// network requests, errors, and other log events.
class LogConsole extends StatefulWidget {
  /// Creates a new log console.
  const LogConsole({
    required this.controller,
    super.key,
  });

  /// The inspector controller to use.
  final InspectorController controller;

  @override
  State<LogConsole> createState() => _LogConsoleState();
}

class _LogConsoleState extends State<LogConsole> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.text = widget.controller.searchQuery;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.8),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchAndFilters(),
              _buildTabs(),
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.bug_report, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            'Debug Console',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: widget.controller,
            builder: (context, child) {
              return Text(
                '${widget.controller.filteredCount}/${widget.controller.totalCount}',
                style: TextStyle(color: Colors.grey.shade600),
              );
            },
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _showClearDialog,
            tooltip: 'Clear logs',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => widget.controller.hide(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search logs...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) => widget.controller.setSearchQuery(value),
          ),
          const SizedBox(height: 8),
          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLevelFilter(),
                const SizedBox(width: 8),
                _buildCategoryFilter(),
                const SizedBox(width: 8),
                _buildEventTypeFilter(),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => widget.controller.clearFilters(),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelFilter() {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return DropdownButton<LogLevel?>(
          value: widget.controller.levelFilter,
          hint: const Text('Level'),
          items: [
            const DropdownMenuItem<LogLevel?>(
              child: Text('All Levels'),
            ),
            ...LogLevel.values.map(
              (level) => DropdownMenuItem<LogLevel?>(
                value: level,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForLevel(level),
                      size: 16,
                      color: _getColorForLevel(level),
                    ),
                    const SizedBox(width: 4),
                    Text(level.displayName),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (level) => widget.controller.setLevelFilter(level),
        );
      },
    );
  }

  Widget _buildCategoryFilter() {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final categories = widget.controller.availableCategories;
        if (categories.isEmpty) return const SizedBox.shrink();

        return DropdownButton<String?>(
          value: widget.controller.categoryFilter,
          hint: const Text('Category'),
          items: [
            const DropdownMenuItem<String?>(
              child: Text('All Categories'),
            ),
            ...categories.map(
              (category) => DropdownMenuItem<String?>(
                value: category,
                child: Text(category),
              ),
            ),
          ],
          onChanged: (category) =>
              widget.controller.setCategoryFilter(category),
        );
      },
    );
  }

  Widget _buildEventTypeFilter() {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final eventTypes = widget.controller.availableEventTypes;
        if (eventTypes.isEmpty) return const SizedBox.shrink();

        return DropdownButton<String?>(
          value: widget.controller.eventTypeFilter,
          hint: const Text('Type'),
          items: [
            const DropdownMenuItem<String?>(
              child: Text('All Types'),
            ),
            ...eventTypes.map(
              (type) => DropdownMenuItem<String?>(
                value: type,
                child: Text(type),
              ),
            ),
          ],
          onChanged: (type) => widget.controller.setEventTypeFilter(type),
        );
      },
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'All', icon: Icon(Icons.list, size: 16)),
        Tab(text: 'Network', icon: Icon(Icons.network_check, size: 16)),
        Tab(text: 'Errors', icon: Icon(Icons.error, size: 16)),
        Tab(text: 'Custom', icon: Icon(Icons.code, size: 16)),
      ],
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue,
    );
  }

  Widget _buildTabContent() {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return TabBarView(
          controller: _tabController,
          children: [
            _buildLogsList(widget.controller.filteredLogs),
            _buildLogsList(_getNetworkLogs()),
            _buildLogsList(_getErrorLogs()),
            _buildLogsList(_getCustomLogs()),
          ],
        );
      },
    );
  }

  Widget _buildLogsList(List<LogEvent> logs) {
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          'No logs to display',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log =
            logs[logs.length - 1 - index]; // Reverse order (newest first)
        return _buildLogItem(log);
      },
    );
  }

  Widget _buildLogItem(LogEvent log) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: () => _showLogDetails(log),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getIconForLevel(log.level),
                    size: 16,
                    color: _getColorForLevel(log.level),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    log.eventType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    TimestampHelper.formatTime(log.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                log.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (log.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    log.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (log.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 4,
                    children: log.tags
                        .take(3)
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            labelStyle: const TextStyle(fontSize: 10),
                            backgroundColor: Colors.grey.shade200,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<LogEvent> _getNetworkLogs() {
    return widget.controller.filteredLogs
        .where(
          (log) =>
              log is RequestLog || log is ResponseLog || log is NetworkErrorLog,
        )
        .toList();
  }

  List<LogEvent> _getErrorLogs() {
    return widget.controller.filteredLogs
        .where(
          (log) =>
              log.level == LogLevel.error || log.level == LogLevel.critical,
        )
        .toList();
  }

  List<LogEvent> _getCustomLogs() {
    return widget.controller.filteredLogs
        .where((log) => log.eventType == 'message' || log.eventType == 'custom')
        .toList();
  }

  Future<void> _showLogDetails(LogEvent log) async {
    if (log is RequestLog || log is ResponseLog || log is NetworkErrorLog) {
      await _showNetworkRequestDetails(log);
    } else {
      await _showGenericLogDetails(log);
    }
  }

  Future<void> _showNetworkRequestDetails(LogEvent log) async {
    await showDialog<void>(
      context: context,
      builder: (context) => NetworkRequestViewer(log: log),
    );
  }

  Future<void> _showGenericLogDetails(LogEvent log) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', log.eventType),
              _buildDetailRow('Level', log.level.displayName),
              _buildDetailRow('Time', TimestampHelper.format(log.timestamp)),
              if (log.category != null)
                _buildDetailRow('Category', log.category!),
              if (log.tags.isNotEmpty)
                _buildDetailRow('Tags', log.tags.join(', ')),
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(log.description),
              if (log.metadata.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Metadata:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(log.metadata.toString()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: log.toJson().toString()));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
        ],
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
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showClearDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.controller.clearLogs();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return Icons.chat_bubble_outline;
      case LogLevel.debug:
        return Icons.bug_report;
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.warning:
        return Icons.warning_outlined;
      case LogLevel.error:
        return Icons.error_outline;
      case LogLevel.critical:
        return Icons.dangerous;
    }
  }

  Color _getColorForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return Colors.grey;
      case LogLevel.debug:
        return Colors.blue;
      case LogLevel.info:
        return Colors.green;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.critical:
        return Colors.red.shade800;
    }
  }
}
