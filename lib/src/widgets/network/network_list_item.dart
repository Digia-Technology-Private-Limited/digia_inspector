import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector/src/utils/network_utils.dart';
import 'package:flutter/material.dart';

/// Individual network list item widget
class NetworkListItem extends StatelessWidget {
  /// Individual network list item widget
  const NetworkListItem({
    required this.log,
    required this.onTap,
    super.key,
  });

  /// Network log
  final NetworkLogUIEntry log;

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
        _buildMethodChip(context),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildUrlText(context)),
        _buildChevron(context),
      ],
    );
  }

  Widget _buildMethodChip(BuildContext context) {
    final color =
        NetworkLogUtils.getMethodColor(log.method, context.inspectorColors);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppBorderRadius.radiusSM,
      ),
      child: Text(
        log.method,
        style: context.inspectorTypography.caption1Bold.copyWith(color: color),
      ),
    );
  }

  Widget _buildUrlText(BuildContext context) {
    final displayName = NetworkLogUtils.getDisplayName(log);

    return Text(
      displayName,
      style: context.inspectorTypography.callout.copyWith(
        color: context.inspectorColors.contentPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
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
        if (log.duration != null) ...[
          _buildDuration(context),
          const SizedBox(width: AppSpacing.md),
        ],
        _buildSize(context),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.copy,
              size: 18, color: context.inspectorColors.contentSecondary),
          tooltip: 'Copy as cURL',
          onPressed: () async {
            final curl = NetworkLogUtils.toCurl(log);
            await ClipboardUtils.copyToClipboardWithToast(context, curl);
          },
        ),
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
        const SizedBox(width: AppSpacing.xs),
        Text(
          log.timestamp.networkLogFormat,
          style: context.inspectorTypography.footnote.copyWith(
            color: context.inspectorColors.contentSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDuration(BuildContext context) {
    return Text(
      log.duration!.displayString,
      style: context.inspectorTypography.footnote.copyWith(
        color: context.inspectorColors.contentSecondary,
      ),
    );
  }

  Widget _buildSize(BuildContext context) {
    final sizeText = NetworkLogUtils.getSizeDisplay(log);

    return Text(
      sizeText,
      style: context.inspectorTypography.footnote.copyWith(
        color: context.inspectorColors.contentSecondary,
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final statusCode = log.statusCode;
    final text = NetworkLogUtils.getStatusDisplayText(statusCode);
    final color =
        NetworkLogUtils.getStatusCodeColor(statusCode, context.inspectorColors);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppBorderRadius.radiusMD,
      ),
      child: Text(
        text,
        style: context.inspectorTypography.caption1Bold.copyWith(
          color: context.inspectorColors.backgroundSecondary,
        ),
      ),
    );
  }
}
