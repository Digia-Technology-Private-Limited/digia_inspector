import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/state/network_log_manager.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector/src/utils/network_utils.dart';
import 'package:digia_inspector/src/widgets/network/network_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Mobile-first network list view matching the UI design
class NetworkListView extends StatefulWidget {
  const NetworkListView({
    super.key,
    required this.networkLogs,
    this.searchQuery = '',
    this.statusFilter = NetworkStatusFilter.all,
    this.onClearLogs,
  });

  final List<NetworkLogUIEntry> networkLogs;
  final String searchQuery;
  final NetworkStatusFilter statusFilter;
  final VoidCallback? onClearLogs;

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
      padding: InspectorSpacing.paddingMD,
      itemCount: logs.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: InspectorSpacing.sm),
      itemBuilder: (context, index) {
        final log = logs[index];
        return NetworkListItem(
          log: log,
          onTap: () => _showNetworkDetail(log),
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
        padding: InspectorSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: InspectorColors.contentTertiary,
            ),
            const SizedBox(height: InspectorSpacing.md),
            Text(
              message,
              style: InspectorTypography.headline.copyWith(
                color: InspectorColors.contentSecondary,
              ),
              textAlign: TextAlign.center,
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

  Widget _buildBottomBar(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: InspectorSpacing.md,
        vertical: InspectorSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: InspectorColors.backgroundSecondary,
        border: Border(
          top: BorderSide(
            color: InspectorColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Text(
        count == 1 ? '1 request' : '$count requests',
        style: InspectorTypography.footnote.copyWith(
          color: InspectorColors.contentTertiary,
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
      builder: (context) => NetworkDetailBottomSheet(log: log),
    );
  }
}

/// Individual network list item widget
class NetworkListItem extends StatelessWidget {
  const NetworkListItem({
    super.key,
    required this.log,
    required this.onTap,
  });

  final NetworkLogUIEntry log;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: InspectorColors.backgroundSecondary,
        borderRadius: InspectorBorderRadius.radiusLG,
        border: Border.all(
          color: InspectorColors.separator,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: InspectorBorderRadius.radiusLG,
        child: InkWell(
          onTap: onTap,
          borderRadius: InspectorBorderRadius.radiusLG,
          child: Padding(
            padding: InspectorSpacing.paddingMD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: InspectorSpacing.sm),
                _buildMetadata(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildMethodChip(),
        const SizedBox(width: InspectorSpacing.sm),
        Expanded(child: _buildUrlText()),
        _buildChevron(),
      ],
    );
  }

  Widget _buildMethodChip() {
    final color = NetworkLogUtils.getMethodColor(log.method);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: InspectorSpacing.sm,
        vertical: InspectorSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: InspectorBorderRadius.radiusSM,
      ),
      child: Text(
        log.method,
        style: InspectorTypography.caption1Bold.copyWith(color: color),
      ),
    );
  }

  Widget _buildUrlText() {
    final displayName = NetworkLogUtils.getDisplayName(log);

    return Text(
      displayName,
      style: InspectorTypography.callout.copyWith(
        color: InspectorColors.contentPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildChevron() {
    return const Icon(
      Icons.chevron_right,
      size: InspectorIconSizes.md,
      color: InspectorColors.chevronColor,
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        _buildTimestamp(),
        const SizedBox(width: InspectorSpacing.md),
        if (log.duration != null) ...[
          _buildDuration(),
          const SizedBox(width: InspectorSpacing.md),
        ],
        _buildSize(),
        const Spacer(),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildTimestamp() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.schedule,
          size: InspectorIconSizes.sm,
          color: InspectorColors.contentTertiary,
        ),
        const SizedBox(width: 2),
        Text(
          log.timestamp.networkLogFormat,
          style: InspectorTypography.footnote.copyWith(
            color: InspectorColors.contentSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDuration() {
    return Text(
      log.duration!.displayString,
      style: InspectorTypography.footnote.copyWith(
        color: InspectorColors.contentSecondary,
      ),
    );
  }

  Widget _buildSize() {
    final sizeText = NetworkLogUtils.getSizeDisplay(log);

    return Text(
      sizeText,
      style: InspectorTypography.footnote.copyWith(
        color: InspectorColors.contentSecondary,
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusCode = log.statusCode;
    final text = NetworkLogUtils.getStatusDisplayText(statusCode);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: InspectorSpacing.sm,
        vertical: InspectorSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: statusCode == 200
            ? InspectorColors.statusSuccess
            : statusCode != null && (statusCode >= 400)
            ? InspectorColors.statusError
            : InspectorColors.contentTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: InspectorTypography.caption1Bold.copyWith(
          color: InspectorColors.backgroundSecondary,
        ),
      ),
    );
  }
}
