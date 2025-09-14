import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:flutter/material.dart';

/// Generic search bar for inspector console
class InspectorSearchBar extends StatefulWidget {
  /// Generic search bar for inspector console
  const InspectorSearchBar({
    required this.hintText,
    required this.onSearchChanged,
    super.key,
    this.initialQuery = '',
    this.onFilterPressed,
    this.hasActiveFilter = false,
  });

  /// Initial query
  final String initialQuery;

  /// Hint text
  final String hintText;

  /// Callback when search is changed
  final ValueChanged<String> onSearchChanged;

  /// Callback when filter button is pressed
  final VoidCallback? onFilterPressed;

  /// Whether to show filter button
  final bool hasActiveFilter;

  @override
  State<InspectorSearchBar> createState() => _InspectorSearchBarState();
}

class _InspectorSearchBarState extends State<InspectorSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMD,
      color: AppColors.backgroundSecondary,
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.searchBackground,
        borderRadius: AppBorderRadius.radiusMD,
      ),
      child: TextField(
        controller: _controller,
        style: InspectorTypography.subhead.copyWith(
          color: AppColors.contentPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: InspectorTypography.subhead.copyWith(
            color: AppColors.contentPlaceholder,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.contentTertiary,
            size: AppIconSizes.md,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
          ),
          isDense: true,
        ),
        onChanged: widget.onSearchChanged,
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: widget.hasActiveFilter
            ? AppColors.accent.withValues(alpha: 0.1)
            : AppColors.searchBackground,
        borderRadius: AppBorderRadius.radiusMD,
      ),
      child: InkWell(
        onTap: widget.onFilterPressed,
        borderRadius: AppBorderRadius.radiusMD,
        splashFactory: NoSplash.splashFactory,
        child: Stack(
          children: [
            Icon(
              Icons.tune,
              color: widget.hasActiveFilter
                  ? AppColors.accent
                  : AppColors.contentTertiary,
              size: AppIconSizes.md,
            ),
            if (widget.hasActiveFilter)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
