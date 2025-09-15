import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Common app bar for inspector console with back button and clear logs action
class InspectorAppBar extends StatelessWidget {
  /// Common app bar for inspector console
  const InspectorAppBar({
    super.key,
    this.onBack,
    this.onClearLogs,
    this.showBackButton = true,
    this.currentTabIndex,
  });

  /// Callback when back button is pressed
  final VoidCallback? onBack;

  /// Callback when clear logs button is pressed
  /// If currentTabIndex is provided, only logs for that tab will be cleared
  final ValueChanged<int?>? onClearLogs;

  /// Whether to show back button
  final bool showBackButton;

  /// Current tab index for tab-specific log clearing
  /// (0=Network, 1=Actions, 2=State)
  /// If null, all logs will be cleared
  final int? currentTabIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingSM,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(
            color: AppColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showBackButton && onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.contentPrimary,
              ),
            )
          else if (showBackButton) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Inspector',
              style: InspectorTypography.headline.copyWith(
                fontSize: 16,
                color: AppColors.contentPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left,
            ),
          ],
          const Spacer(),
          if (onClearLogs != null)
            IconButton(
              onPressed: () => onClearLogs!(currentTabIndex),
              icon: const Icon(
                Icons.clear_all,
                color: AppColors.contentPrimary,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
