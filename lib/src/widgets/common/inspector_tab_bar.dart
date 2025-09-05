import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Common tab bar for inspector console
class InspectorTabBar extends StatelessWidget {
  const InspectorTabBar({
    super.key,
    required this.tabController,
    this.onTabChanged,
  });

  final TabController tabController;
  final ValueChanged<int>? onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: InspectorColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(
            color: InspectorColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: InspectorColors.contentPrimary,
        unselectedLabelColor: InspectorColors.contentSecondary,
        labelStyle: InspectorTypography.subheadBold,
        unselectedLabelStyle: InspectorTypography.subhead,
        onTap: onTabChanged,
        tabs: const [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: InspectorIconSizes.sm,
                ),
                SizedBox(width: InspectorSpacing.xs),
                Text('Network'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt,
                  size: InspectorIconSizes.sm,
                ),
                SizedBox(width: InspectorSpacing.xs),
                Text('Actions'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storage,
                  size: InspectorIconSizes.sm,
                ),
                SizedBox(width: InspectorSpacing.xs),
                Text('State'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
