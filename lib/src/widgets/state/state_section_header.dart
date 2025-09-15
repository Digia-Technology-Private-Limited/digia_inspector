import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:flutter/material.dart';

/// Widget for the header of a state section that can be expanded/collapsed
class StateSectionHeader extends StatelessWidget {
  /// State section header
  const StateSectionHeader({
    required this.title,
    required this.icon,
    required this.variableCount,
    required this.isExpanded,
    required this.onTap,
    this.lastUpdated,
    this.freshnessDuration = const Duration(seconds: 2),
    super.key,
  });

  /// State section header
  final Widget title;

  /// Icon
  final IconData icon;

  /// Variable count
  final int variableCount;

  /// Is expanded
  final bool isExpanded;

  /// On tap
  final VoidCallback onTap;

  /// Optional last updated timestamp used to show a transient
  /// "Updated just now" badge. If null, no badge is shown.
  final DateTime? lastUpdated;

  /// Duration within which the update badge is considered fresh.
  final Duration freshnessDuration;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final showUpdatedBadge = lastUpdated != null &&
        now.difference(lastUpdated!) <= freshnessDuration;
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.radiusMD,
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Row(
          children: [
            Icon(
              icon,
              size: AppIconSizes.md,
              color: AppColors.contentPrimary,
            ),
            const SizedBox(width: AppSpacing.sm),
            title,
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$variableCount variable${variableCount != 1 ? 's' : ''}',
              style: InspectorTypography.subhead.copyWith(
                color: AppColors.contentSecondary,
              ),
            ),
            if (showUpdatedBadge) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  // Use withValues instead of deprecated withOpacity
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: AppBorderRadius.radiusSM,
                ),
                child: Text(
                  'Updated just now',
                  style: InspectorTypography.caption1.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: AppIconSizes.sm,
              color: AppColors.contentPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
