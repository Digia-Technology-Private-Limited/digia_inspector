import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector/src/utils/network_utils.dart';
import 'package:digia_inspector/src/widgets/common/inspector_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        color: AppColors.backgroundSecondary,
        borderRadius: AppBorderRadius.radiusLG,
        border: Border.all(
          color: AppColors.borderDefault,
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
              _buildHeader(),
              const SizedBox(height: AppSpacing.sm),
              _buildMetadata(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildMethodChip(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildUrlText()),
        _buildChevron(),
      ],
    );
  }

  Widget _buildMethodChip() {
    final color = NetworkLogUtils.getMethodColor(log.method);

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
        style: InspectorTypography.caption1Bold.copyWith(color: color),
      ),
    );
  }

  Widget _buildUrlText() {
    final displayName = NetworkLogUtils.getDisplayName(log);

    return Text(
      displayName,
      style: InspectorTypography.callout.copyWith(
        color: AppColors.contentPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildChevron() {
    return const Icon(
      Icons.chevron_right,
      size: AppIconSizes.md,
      color: AppColors.chevronColor,
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Row(
      children: [
        _buildTimestamp(),
        const SizedBox(width: AppSpacing.md),
        if (log.duration != null) ...[
          _buildDuration(),
          const SizedBox(width: AppSpacing.md),
        ],
        _buildSize(),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.copy,
              size: 18, color: AppColors.contentSecondary),
          tooltip: 'Copy as cURL',
          onPressed: () async {
            final curl = NetworkLogUtils.toCurl(log);
            if (curl.isEmpty) {
              showInspectorToast(context, 'Nothing to copy!');
              return;
            }
            try {
              await Clipboard.setData(ClipboardData(text: curl));
              showInspectorToast(context, 'Copied to clipboard!');
            }catch (e) {
              showInspectorToast(context, 'Copy failed:');
            }
          },
        ),
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
        const SizedBox(width: AppSpacing.xs),
        Text(
          log.timestamp.networkLogFormat,
          style: InspectorTypography.footnote.copyWith(
            color: AppColors.contentSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDuration() {
    return Text(
      log.duration!.displayString,
      style: InspectorTypography.footnote.copyWith(
        color: AppColors.contentSecondary,
      ),
    );
  }

  Widget _buildSize() {
    final sizeText = NetworkLogUtils.getSizeDisplay(log);

    return Text(
      sizeText,
      style: InspectorTypography.footnote.copyWith(
        color: AppColors.contentSecondary,
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusCode = log.statusCode;
    final text = NetworkLogUtils.getStatusDisplayText(statusCode);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: statusCode == 200
            ? AppColors.statusSuccess
            : statusCode != null && (statusCode >= 400)
                ? AppColors.statusError
                : AppColors.contentTertiary,
        borderRadius: AppBorderRadius.radiusMD,
      ),
      child: Text(
        text,
        style: InspectorTypography.caption1Bold.copyWith(
          color: AppColors.backgroundSecondary,
        ),
      ),
    );
  }
}
