import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Common coming soon widget for unimplemented features
class ComingSoonWidget extends StatelessWidget {
  const ComingSoonWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: InspectorSpacing.lg),
            Text(
              title,
              style: InspectorTypography.title3.copyWith(
                color: InspectorColors.contentSecondary,
              ),
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
}
