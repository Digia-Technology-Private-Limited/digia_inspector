import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:flutter/material.dart';

/// Common tab bar for inspector console
class InspectorTabBar extends StatelessWidget {
  /// Common tab bar for inspector console
  const InspectorTabBar({
    required this.tabController,
    super.key,
    this.onTabChanged,
  });

  /// Tab controller
  final TabController tabController;

  /// Callback when tab is changed
  final ValueChanged<int>? onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TabBar(
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        indicator: const BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: AppBorderRadius.radiusXXL,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.contentPrimary,
        unselectedLabelColor: AppColors.contentSecondary,
        labelStyle: InspectorTypography.subheadBold,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        labelPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          // vertical: 6,
        ),
        onTap: onTabChanged,
        tabs: const [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language, size: 16),
                SizedBox(width: 6),
                Text('Network'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.ads_click_sharp, size: 16),
                SizedBox(width: 6),
                Text('Actions'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.storage, size: 16),
                SizedBox(width: 6),
                Text('State'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
