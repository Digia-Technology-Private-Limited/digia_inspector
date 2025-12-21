import 'package:digia_inspector/src/log_managers/network_log_manager.dart';
import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:flutter/material.dart';

/// Custom overlay for filter dropdown instead of bottom sheet
class FilterOverlay extends StatefulWidget {
  /// Custom overlay for filter dropdown instead of bottom sheet
  const FilterOverlay({
    required this.currentFilter,
    required this.onFilterChanged,
    required this.buttonKey,
    required this.onClose,
    super.key,
  });

  /// Current filter
  final NetworkStatusFilter currentFilter;

  /// Callback when filter is changed
  final ValueChanged<NetworkStatusFilter> onFilterChanged;

  /// Button key
  final GlobalKey buttonKey;

  /// Callback when overlay is closed
  final VoidCallback onClose;

  @override
  State<FilterOverlay> createState() => _FilterOverlayState();
}

class _FilterOverlayState extends State<FilterOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  NetworkStatusFilter _selectedFilter = NetworkStatusFilter.all;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;

    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Transparent overlay to detect taps outside
        GestureDetector(
          onTap: _closeOverlay,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.transparent,
          ),
        ),

        // Positioned filter dropdown
        Positioned(
          top: _getDropdownTop(),
          right: AppSpacing.md,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildFilterDropdown(),
            ),
          ),
        ),
      ],
    );
  }

  double _getDropdownTop() {
    final renderBox =
        widget.buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      return position.dy + renderBox.size.height + 8;
    }
    return 100; // Fallback position
  }

  Widget _buildFilterDropdown() {
    return Material(
      elevation: 8,
      color: context.inspectorColors.backgroundPrimary,
      borderRadius: AppBorderRadius.radiusLG,
      shadowColor: context.inspectorColors.shadow,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.radiusLG,
          border: Border.all(
            color: context.inspectorColors.separator,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildFilterOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: AppSpacing.paddingSM,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.inspectorColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: AppIconSizes.sm,
            color: context.inspectorColors.contentPrimary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Filter',
            style: context.inspectorTypography.subheadBold.copyWith(
              color: context.inspectorColors.contentPrimary,
            ),
          ),
          const Spacer(),
          if (widget.currentFilter != NetworkStatusFilter.all)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = NetworkStatusFilter.all;
                });
                _applyFilter();
              },
              child: Text(
                'Clear',
                style: context.inspectorTypography.caption1.copyWith(
                  color: context.inspectorColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: AppSpacing.paddingXS,
      child: Column(
        children: NetworkStatusFilter.values.map(_buildFilterOption).toList(),
      ),
    );
  }

  Widget _buildFilterOption(NetworkStatusFilter filter) {
    final isSelected = _selectedFilter == filter;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
        _applyFilter();
      },
      borderRadius: AppBorderRadius.radiusSM,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? context.inspectorColors.accent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: AppBorderRadius.radiusSM,
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isSelected ? context.inspectorColors.accent : null,
                border: Border.all(
                  color: isSelected
                      ? context.inspectorColors.accent
                      : context.inspectorColors.contentTertiary,
                  width: 1.5,
                ),
                borderRadius: AppBorderRadius.radiusMD,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: AppIconSizes.xs,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _getFilterTitle(filter),
                style: context.inspectorTypography.subhead.copyWith(
                  color: isSelected
                      ? context.inspectorColors.accent
                      : context.inspectorColors.contentPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilter() {
    widget.onFilterChanged(_selectedFilter);
    _closeOverlay();
  }

  void _closeOverlay() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  String _getFilterTitle(NetworkStatusFilter filter) {
    switch (filter) {
      case NetworkStatusFilter.all:
        return 'All Requests';
      case NetworkStatusFilter.success:
        return 'Success (2xx)';
      case NetworkStatusFilter.error:
        return 'Error (4xx, 5xx)';
      case NetworkStatusFilter.pending:
        return 'Pending';
    }
  }
}

/// Helper widget to show the filter overlay
class FilterOverlayManager {
  /// Overlay entry
  static OverlayEntry? _overlayEntry;

  /// Shows the filter overlay
  static void show({
    required BuildContext context,
    required NetworkStatusFilter currentFilter,
    required ValueChanged<NetworkStatusFilter> onFilterChanged,
    required GlobalKey buttonKey,
  }) {
    hide(); // Hide any existing overlay

    final theme = Theme.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Theme(
        data: theme,
        child: FilterOverlay(
          currentFilter: currentFilter,
          onFilterChanged: onFilterChanged,
          buttonKey: buttonKey,
          onClose: hide,
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hides the filter overlay
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
