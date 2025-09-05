import 'package:digia_inspector/src/state/network_log_manager.dart';
import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:digia_inspector/src/widgets/common/filter_overlay.dart';
import 'package:flutter/material.dart';

/// Search bar for network logs with filter button using overlay
class NetworkSearchBar extends StatefulWidget {
  const NetworkSearchBar({
    super.key,
    this.initialQuery = '',
    this.currentFilter = NetworkStatusFilter.all,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final String initialQuery;
  final NetworkStatusFilter currentFilter;
  final ValueChanged<String> onSearchChanged;
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
      padding: InspectorSpacing.paddingMD,
      color: InspectorColors.backgroundSecondary,
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: InspectorSpacing.sm),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: InspectorColors.searchBackground,
        borderRadius: InspectorBorderRadius.radiusMD,
      ),
      child: TextField(
        controller: _controller,
        style: InspectorTypography.subhead.copyWith(
          color: InspectorColors.contentPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search requests...',
          hintStyle: InspectorTypography.subhead.copyWith(
            color: InspectorColors.contentPlaceholder,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: InspectorColors.contentTertiary,
            size: InspectorIconSizes.md,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: InspectorSpacing.sm,
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
            ? InspectorColors.accent.withOpacity(0.1)
            : InspectorColors.searchBackground,
        borderRadius: InspectorBorderRadius.radiusMD,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: InspectorBorderRadius.radiusMD,
        child: InkWell(
          onTap: _showFilterOverlay,
          borderRadius: InspectorBorderRadius.radiusMD,
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.tune,
                  color: hasActiveFilter
                      ? InspectorColors.accent
                      : InspectorColors.contentTertiary,
                  size: InspectorIconSizes.md,
                ),
              ),
              if (hasActiveFilter)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: InspectorColors.accent,
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

/// Filter bottom sheet for status codes
class NetworkFilterBottomSheet extends StatefulWidget {
  const NetworkFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  final NetworkStatusFilter currentFilter;
  final ValueChanged<NetworkStatusFilter> onFilterChanged;

  @override
  State<NetworkFilterBottomSheet> createState() =>
      _NetworkFilterBottomSheetState();
}

class _NetworkFilterBottomSheetState extends State<NetworkFilterBottomSheet> {
  late NetworkStatusFilter _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: InspectorColors.surfaceElevated,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(InspectorBorderRadius.xl),
          topRight: Radius.circular(InspectorBorderRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildFilterOptions(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: InspectorSpacing.paddingMD,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: InspectorColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: InspectorColors.contentTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: InspectorSpacing.md),
          // Title
          Row(
            children: [
              const Icon(
                Icons.filter_list,
                size: InspectorIconSizes.md,
                color: InspectorColors.contentPrimary,
              ),
              const SizedBox(width: InspectorSpacing.sm),
              Expanded(
                child: Text(
                  'Filter Requests',
                  style: InspectorTypography.headline.copyWith(
                    color: InspectorColors.contentPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = NetworkStatusFilter.all;
                  });
                },
                child: Text(
                  'Clear',
                  style: InspectorTypography.subhead.copyWith(
                    color: InspectorColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: InspectorSpacing.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Code',
            style: InspectorTypography.subheadBold.copyWith(
              color: InspectorColors.contentPrimary,
            ),
          ),
          const SizedBox(height: InspectorSpacing.sm),
          ...NetworkStatusFilter.values.map(
            _buildFilterOption,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(NetworkStatusFilter filter) {
    final isSelected = _selectedFilter == filter;

    return Container(
      margin: const EdgeInsets.only(bottom: InspectorSpacing.xs),
      decoration: BoxDecoration(
        color: isSelected
            ? InspectorColors.accent.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: InspectorBorderRadius.radiusMD,
        border: isSelected
            ? Border.all(color: InspectorColors.accent, width: 1)
            : null,
      ),
      child: RadioListTile<NetworkStatusFilter>(
        value: filter,
        groupValue: _selectedFilter,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedFilter = value;
            });
          }
        },
        title: Text(
          _getFilterTitle(filter),
          style: InspectorTypography.subhead.copyWith(
            color: isSelected
                ? InspectorColors.accent
                : InspectorColors.contentPrimary,
          ),
        ),
        subtitle: Text(
          _getFilterDescription(filter),
          style: InspectorTypography.footnote.copyWith(
            color: InspectorColors.contentSecondary,
          ),
        ),
        activeColor: InspectorColors.accent,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: InspectorSpacing.paddingMD,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: InspectorColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: InspectorColors.separator),
                shape: const RoundedRectangleBorder(
                  borderRadius: InspectorBorderRadius.radiusMD,
                ),
              ),
              child: Text(
                'Cancel',
                style: InspectorTypography.subheadBold.copyWith(
                  color: InspectorColors.contentPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: InspectorSpacing.sm),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onFilterChanged(_selectedFilter);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: InspectorColors.accent,
                shape: const RoundedRectangleBorder(
                  borderRadius: InspectorBorderRadius.radiusMD,
                ),
              ),
              child: Text(
                'Apply',
                style: InspectorTypography.subheadBold.copyWith(
                  color: InspectorColors.backgroundSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
        return 'Show all network requests';
      case NetworkStatusFilter.success:
        return 'Show only successful requests';
      case NetworkStatusFilter.error:
        return 'Show only failed requests';
      case NetworkStatusFilter.pending:
        return 'Show only pending requests';
    }
  }
}
