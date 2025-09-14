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

  @override
  Widget build(BuildContext context) {
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
