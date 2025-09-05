import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Common app bar for inspector console with back button and clear logs action
class InspectorAppBar extends StatelessWidget {
  const InspectorAppBar({
    super.key,
    this.onBack,
    this.onClearLogs,
    this.title = 'Inspect',
    this.showBackButton = true,
    this.showClearButton = true,
  });

  final VoidCallback? onBack;
  final VoidCallback? onClearLogs;
  final String title;
  final bool showBackButton;
  final bool showClearButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: InspectorSpacing.paddingMD,
      decoration: const BoxDecoration(
        color: InspectorColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(
            color: InspectorColors.separator,
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
                color: InspectorColors.contentPrimary,
              ),
            )
          else if (showBackButton)
            const SizedBox(width: 48), // Spacer for centering
          Expanded(
            child: Text(
              title,
              style: InspectorTypography.headline.copyWith(
                color: InspectorColors.contentPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (showClearButton && onClearLogs != null)
            IconButton(
              onPressed: onClearLogs,
              icon: const Icon(
                Icons.clear_all,
                color: InspectorColors.contentPrimary,
              ),
            )
          else if (showClearButton)
            const SizedBox(width: 48), // Spacer for centering
        ],
      ),
    );
  }
}
