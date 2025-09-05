import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_dimensions.dart';
import '../../state/network_log_manager.dart';

/// Custom overlay for filter dropdown instead of bottom sheet
class FilterOverlay extends StatefulWidget {
  final NetworkStatusFilter currentFilter;
  final ValueChanged<NetworkStatusFilter> onFilterChanged;
  final GlobalKey buttonKey;
  final VoidCallback onClose;

  const FilterOverlay({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.buttonKey,
    required this.onClose,
  });

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
      duration: InspectorAnimations.fast,
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        );

    _slideAnimation =
        Tween<Offset>(
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
          right: InspectorSpacing.md,
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
    final RenderBox? renderBox =
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
      borderRadius: InspectorBorderRadius.radiusLG,
      shadowColor: InspectorColors.shadow,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: InspectorColors.surfaceElevated,
          borderRadius: InspectorBorderRadius.radiusLG,
          border: Border.all(
            color: InspectorColors.separator,
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
      padding: InspectorSpacing.paddingSM,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: InspectorColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: InspectorIconSizes.sm,
            color: InspectorColors.contentPrimary,
          ),
          const SizedBox(width: InspectorSpacing.xs),
          Text(
            'Filter',
            style: InspectorTypography.subheadBold.copyWith(
              color: InspectorColors.contentPrimary,
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
                style: InspectorTypography.caption1.copyWith(
                  color: InspectorColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: InspectorSpacing.paddingXS,
      child: Column(
        children: NetworkStatusFilter.values
            .map((filter) => _buildFilterOption(filter))
            .toList(),
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
      borderRadius: InspectorBorderRadius.radiusSM,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: InspectorSpacing.sm,
          vertical: InspectorSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? InspectorColors.accent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: InspectorBorderRadius.radiusSM,
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isSelected ? InspectorColors.accent : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? InspectorColors.accent
                      : InspectorColors.contentTertiary,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: InspectorColors.backgroundSecondary,
                      size: 10,
                    )
                  : null,
            ),
            const SizedBox(width: InspectorSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFilterTitle(filter),
                    style: InspectorTypography.subhead.copyWith(
                      color: isSelected
                          ? InspectorColors.accent
                          : InspectorColors.contentPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  Text(
                    _getFilterDescription(filter),
                    style: InspectorTypography.caption1.copyWith(
                      color: InspectorColors.contentSecondary,
                    ),
                  ),
                ],
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

  String _getFilterDescription(NetworkStatusFilter filter) {
    switch (filter) {
      case NetworkStatusFilter.all:
        return 'Show all requests';
      case NetworkStatusFilter.success:
        return 'Show successful only';
      case NetworkStatusFilter.error:
        return 'Show failed requests';
      case NetworkStatusFilter.pending:
        return 'Show pending requests';
    }
  }
}

/// Helper widget to show the filter overlay
class FilterOverlayManager {
  static OverlayEntry? _overlayEntry;

  static void show({
    required BuildContext context,
    required NetworkStatusFilter currentFilter,
    required ValueChanged<NetworkStatusFilter> onFilterChanged,
    required GlobalKey buttonKey,
  }) {
    hide(); // Hide any existing overlay

    _overlayEntry = OverlayEntry(
      builder: (context) => FilterOverlay(
        currentFilter: currentFilter,
        onFilterChanged: onFilterChanged,
        buttonKey: buttonKey,
        onClose: hide,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
