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
        color: AppColors.backgroundSecondary,
        borderRadius: AppBorderRadius.radiusLG,
        border: Border.all(
          color: AppColors.borderDefault,
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
              _buildHeader(),
              const SizedBox(height: AppSpacing.sm),
              _buildMetadata(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildTriggerChip(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildActionText()),
        _buildChevron(),
      ],
    );
  }

  Widget _buildTriggerChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: AppBorderRadius.radiusSM,
      ),
      child: Text(
        flow.triggerName ?? 'Unknown',
        style: InspectorTypography.caption1Bold.copyWith(
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildActionText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          flow.actionType,
          style: InspectorTypography.callout.copyWith(
            color: AppColors.contentPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (flow.sourceChain?.isNotEmpty ?? false)
          Text(
            'Entity: ${flow.sourceChain?.first ?? 'Unknown'}',
            style: InspectorTypography.footnote.copyWith(
              color: AppColors.contentTertiary,
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
      size: AppIconSizes.md,
      color: AppColors.chevronColor,
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        _buildTimestamp(),
        const SizedBox(width: AppSpacing.md),
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
          size: AppIconSizes.sm,
          color: AppColors.contentTertiary,
        ),
        const SizedBox(width: 2),
        Text(
          flow.timestamp.networkLogFormat,
          style: InspectorTypography.footnote.copyWith(
            color: AppColors.contentSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCount() {
    final totalActions = actionLogManager.countActionsInFlow(flow.id);
    return Text(
      '$totalActions actions',
      style: InspectorTypography.footnote.copyWith(
        color: AppColors.contentSecondary,
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusColor = ActionLogUtils.getStatusColor(flow.status.name);
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
        style: InspectorTypography.caption1Bold.copyWith(
          color: AppColors.backgroundSecondary,
        ),
      ),
    );
  }
}
