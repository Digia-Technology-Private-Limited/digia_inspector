import 'package:digia_inspector/src/models/action_flow_ui_entry.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:digia_inspector/src/utils/action_utils.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector/src/widgets/action/action_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Mobile-first action list view matching the UI design
class ActionListView extends StatefulWidget {
  const ActionListView({
    super.key,
    required this.actionFlows,
    this.searchQuery = '',
    this.statusFilter = ActionStatusFilter.all,
    this.onClearLogs,
    this.onItemTap,
  });

  final List<ActionFlowUIEntry> actionFlows;
  final String searchQuery;
  final ActionStatusFilter statusFilter;
  final VoidCallback? onClearLogs;
  final ValueChanged<ActionFlowUIEntry>? onItemTap;

  @override
  State<ActionListView> createState() => _ActionListViewState();
}

class _ActionListViewState extends State<ActionListView> {
  @override
  Widget build(BuildContext context) {
    final filteredFlows = ActionLogUtils.filterFlowsByStatus(
      widget.actionFlows
          .where(
            (flow) =>
                ActionLogUtils.matchesFlowSearchQuery(flow, widget.searchQuery),
          )
          .toList(),
      widget.statusFilter,
    );

    return Column(
      children: [
        Expanded(
          child: filteredFlows.isEmpty
              ? _buildEmptyState()
              : _buildActionList(filteredFlows),
        ),
        _buildBottomBar(filteredFlows),
      ],
    );
  }

  Widget _buildActionList(List<ActionFlowUIEntry> flows) {
    return ListView.separated(
      padding: InspectorSpacing.paddingMD,
      itemCount: flows.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: InspectorSpacing.sm),
      itemBuilder: (context, index) {
        final flow = flows[index];
        return ActionFlowListItem(
          flow: flow,
          onTap: () {
            if (widget.onItemTap != null) {
              widget.onItemTap!(flow);
            } else {
              _showActionDetail(flow);
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
      message = 'No matching actions';
      subtitle = 'Try adjusting your search query';
      icon = Icons.search_off;
    } else if (widget.statusFilter != ActionStatusFilter.all) {
      message = 'No actions found';
      subtitle = 'Try changing the filter settings';
      icon = Icons.filter_list_off;
    } else {
      message = 'No actions logged';
      subtitle = 'Action logs will appear here when your app performs actions';
      icon = Icons.play_circle_outline;
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

  Widget _buildBottomBar(List<ActionFlowUIEntry> flows) {
    final totalActions = flows.fold<int>(
      0,
      (sum, flow) => sum + flow.actionCount,
    );

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
        flows.length == 1
            ? '1 flow • $totalActions actions'
            : '${flows.length} flows • $totalActions actions',
        style: InspectorTypography.footnote.copyWith(
          color: InspectorColors.contentTertiary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showActionDetail(ActionFlowUIEntry flow) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActionDetailBottomSheet(flow: flow),
    );
  }
}

/// Individual action flow list item widget
class ActionFlowListItem extends StatelessWidget {
  const ActionFlowListItem({
    super.key,
    required this.flow,
    required this.onTap,
  });

  final ActionFlowUIEntry flow;
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
        _buildTriggerChip(),
        const SizedBox(width: InspectorSpacing.sm),
        Expanded(child: _buildActionText()),
        _buildChevron(),
      ],
    );
  }

  Widget _buildTriggerChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: InspectorSpacing.sm,
        vertical: InspectorSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: InspectorColors.accent.withOpacity(0.1),
        borderRadius: InspectorBorderRadius.radiusSM,
      ),
      child: Text(
        flow.triggerName,
        style: InspectorTypography.caption1Bold.copyWith(
          color: InspectorColors.accent,
        ),
      ),
    );
  }

  Widget _buildActionText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          flow.displayName,
          style: InspectorTypography.callout.copyWith(
            color: InspectorColors.contentPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (flow.sourceChain.isNotEmpty)
          Text(
            flow.sourceChainDisplay,
            style: InspectorTypography.footnote.copyWith(
              color: InspectorColors.contentTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
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
        _buildActionCount(),
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
          flow.timestamp.networkLogFormat,
          style: InspectorTypography.footnote.copyWith(
            color: InspectorColors.contentSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCount() {
    return Text(
      '${flow.actionCount} actions',
      style: InspectorTypography.footnote.copyWith(
        color: InspectorColors.contentSecondary,
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusColor = ActionLogUtils.getStatusColor(flow.statusSummary);
    final statusText = ActionLogUtils.getStatusDisplayText(flow.statusSummary);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: InspectorSpacing.sm,
        vertical: InspectorSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: InspectorTypography.caption1Bold.copyWith(
          color: InspectorColors.backgroundSecondary,
        ),
      ),
    );
  }
}
