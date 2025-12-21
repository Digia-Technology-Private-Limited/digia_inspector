import 'package:digia_inspector/src/log_managers/network_log_manager.dart';
import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/widgets/common/filter_overlay.dart';
import 'package:flutter/material.dart';

/// Search bar for network logs with filter button using overlay
class NetworkSearchBar extends StatefulWidget {
  /// Search bar for network logs with filter button using overlay
  const NetworkSearchBar({
    required this.onSearchChanged,
    required this.onFilterChanged,
    super.key,
    this.initialQuery = '',
    this.currentFilter = NetworkStatusFilter.all,
  });

  /// Initial query
  final String initialQuery;

  /// Current filter
  final NetworkStatusFilter currentFilter;

  /// Callback when search is changed
  final ValueChanged<String> onSearchChanged;

  /// Callback when filter is changed
  final ValueChanged<NetworkStatusFilter> onFilterChanged;

  @override
  State<NetworkSearchBar> createState() => _NetworkSearchBarState();
}

class _NetworkSearchBarState extends State<NetworkSearchBar> {
  late TextEditingController _controller;
  final GlobalKey _filterButtonKey = GlobalKey();

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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: context.inspectorColors.backgroundSecondary,
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
      decoration: BoxDecoration(
        color: context.inspectorColors.backgroundSecondary,
        borderRadius: AppBorderRadius.radiusXL,
        border: Border.all(
          color: context.inspectorColors.borderDefault,
        ),
      ),
      child: TextField(
        controller: _controller,
        style: context.inspectorTypography.subhead.copyWith(
          color: context.inspectorColors.contentPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search requests...',
          hintStyle: context.inspectorTypography.subhead.copyWith(
            color: context.inspectorColors.contentPlaceholder,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: context.inspectorColors.contentTertiary,
            size: AppIconSizes.md,
          ),
          border: const OutlineInputBorder(
            borderRadius: AppBorderRadius.radiusXL,
            borderSide: BorderSide.none,
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
    final hasActiveFilter = widget.currentFilter != NetworkStatusFilter.all;

    return Container(
      key: _filterButtonKey,
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: hasActiveFilter
            ? context.inspectorColors.accent.withValues(alpha: 0.1)
            : context.inspectorColors.backgroundSecondary,
        borderRadius: AppBorderRadius.radiusMD,
        border: Border.all(
          color: context.inspectorColors.borderDefault,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppBorderRadius.radiusMD,
        child: InkWell(
          onTap: _showFilterOverlay,
          borderRadius: AppBorderRadius.radiusMD,
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.tune,
                  color: hasActiveFilter
                      ? context.inspectorColors.accent
                      : context.inspectorColors.contentTertiary,
                  size: AppIconSizes.md,
                ),
              ),
              if (hasActiveFilter)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.inspectorColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterOverlay() {
    FilterOverlayManager.show(
      context: context,
      currentFilter: widget.currentFilter,
      onFilterChanged: widget.onFilterChanged,
      buttonKey: _filterButtonKey,
    );
  }
}
