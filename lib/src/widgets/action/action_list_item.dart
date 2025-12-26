import 'package:digia_inspector/src/log_managers/action_log_manager.dart';
import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/utils/action_utils.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/material.dart';

/// Individual action flow list item widget
class ActionFlowListItem extends StatelessWidget {
  /// Individual action flow list item widget
  const ActionFlowListItem({
    required this.actionLogManager,
    required this.flow,
    required this.onTap,
    super.key,
  });

  /// Action log manager
  final ActionLogManager actionLogManager;

  /// Action log
  final ActionLog flow;

  /// Callback when item is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.inspectorColors.backgroundSecondary,
        borderRadius: AppBorderRadius.radiusLG,
        border: Border.all(
          color: context.inspectorColors.borderDefault,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.radiusLG,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.sm),
              _buildMetadata(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildTriggerChip(context),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildActionText(context)),
        _buildChevron(context),
      ],
    );
  }

  Widget _buildTriggerChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.inspectorColors.backgroundSecondary,
        borderRadius: AppBorderRadius.radiusSM,
      ),
      child: Text(
        flow.triggerName ?? 'Unknown',
        style: context.inspectorTypography.caption1Bold.copyWith(
          color: context.inspectorColors.contentPrimary,
        ),
      ),
    );
  }

  Widget _buildActionText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          flow.actionType,
          style: context.inspectorTypography.callout.copyWith(
            color: context.inspectorColors.contentPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (flow.sourceChain?.isNotEmpty ?? false)
          Text(
            'Entity: ${flow.sourceChain?.first ?? 'Unknown'}',
            style: context.inspectorTypography.footnote.copyWith(
              color: context.inspectorColors.contentTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildChevron(BuildContext context) {
    return Icon(
      Icons.chevron_right,
      size: AppIconSizes.md,
      color: context.inspectorColors.chevronColor,
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Row(
      children: [
        _buildTimestamp(context),
        const SizedBox(width: AppSpacing.md),
        _buildActionCount(context),
        const Spacer(),
        _buildStatusChip(context),
      ],
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.schedule,
          size: AppIconSizes.sm,
          color: context.inspectorColors.contentTertiary,
        ),
        const SizedBox(width: 2),
        Text(
          flow.timestamp.networkLogFormat,
          style: context.inspectorTypography.footnote.copyWith(
            color: context.inspectorColors.contentSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCount(BuildContext context) {
    final totalActions = actionLogManager.countActionsInFlow(flow.id);
    return Text(
      '$totalActions actions',
      style: context.inspectorTypography.footnote.copyWith(
        color: context.inspectorColors.contentSecondary,
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final statusColor = ActionLogUtils.getStatusColor(
      flow.status.name,
      context.inspectorColors,
    );
    final statusText = ActionLogUtils.getStatusDisplayText(flow.status.name);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: context.inspectorTypography.caption1Bold.copyWith(
          color: context.inspectorColors.backgroundSecondary,
        ),
      ),
    );
  }
}
