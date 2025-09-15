import 'package:digia_inspector/src/log_managers/network_log_manager.dart';
import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/utils/network_utils.dart';
import 'package:digia_inspector/src/widgets/network/network_detail_view.dart';
import 'package:digia_inspector/src/widgets/network/network_list_item.dart';
import 'package:flutter/material.dart';

/// Mobile-first network list view matching the UI design
class NetworkListView extends StatefulWidget {
  /// Constructor
  const NetworkListView({
    required this.networkLogs,
    this.networkLogManager,
    super.key,
    this.searchQuery = '',
    this.statusFilter = NetworkStatusFilter.all,
    this.onClearLogs,
    this.onItemTap,
  });

  /// Network logs
  final List<NetworkLogUIEntry> networkLogs;

  /// Search query
  final String searchQuery;

  /// Status filter
  final NetworkStatusFilter statusFilter;

  /// Callback when logs are cleared
  final VoidCallback? onClearLogs;

  /// Callback when an item is tapped
  final ValueChanged<NetworkLogUIEntry>? onItemTap;

  /// Network log manager
  final NetworkLogManager? networkLogManager;

  @override
  State<NetworkListView> createState() => _NetworkListViewState();
}

class _NetworkListViewState extends State<NetworkListView> {
  @override
  Widget build(BuildContext context) {
    final filteredLogs = NetworkLogUtils.filterByStatusType(
      widget.networkLogs
          .where(
            (entry) =>
                NetworkLogUtils.matchesSearchQuery(entry, widget.searchQuery),
          )
          .toList(),
      widget.statusFilter,
    );

    return Column(
      children: [
        Expanded(
          child: filteredLogs.isEmpty
              ? _buildEmptyState()
              : _buildNetworkList(filteredLogs),
        ),
        _buildBottomBar(filteredLogs.length),
      ],
    );
  }

  Widget _buildNetworkList(List<NetworkLogUIEntry> logs) {
    return ListView.separated(
      padding: AppSpacing.paddingMD,
      itemCount: logs.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final log = logs[index];
        return NetworkListItem(
          log: log,
          onTap: () {
            if (widget.onItemTap != null) {
              widget.onItemTap!(log);
            } else {
              _showNetworkDetail(log);
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    IconData icon;

    if (widget.searchQuery.isNotEmpty) {
      message = 'No matching requests';
      subtitle = 'Try adjusting your search query';
      icon = Icons.search_off;
    } else if (widget.statusFilter != NetworkStatusFilter.all) {
      message = 'No requests found';
      subtitle = 'Try changing the filter settings';
      icon = Icons.filter_list_off;
    } else {
      message = 'No network requests';
      subtitle =
          'Network requests will appear here when your app makes API calls';
      icon = Icons.language;
    }

    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.contentTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(int count) {
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
        count == 1 ? '1 request' : '$count requests',
        style: InspectorTypography.footnote.copyWith(
          color: AppColors.contentPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showNetworkDetail(NetworkLogUIEntry log) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NetworkDetailView(
        networkLogManager: widget.networkLogManager,
        logId: log.id,
      ),
    );
  }
}
