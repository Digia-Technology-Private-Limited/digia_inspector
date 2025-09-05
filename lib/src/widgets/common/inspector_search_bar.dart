import 'package:digia_inspector/src/theme/app_colors.dart';
import 'package:digia_inspector/src/theme/app_dimensions.dart';
import 'package:digia_inspector/src/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Generic search bar for inspector console
class InspectorSearchBar extends StatefulWidget {
  const InspectorSearchBar({
    super.key,
    this.initialQuery = '',
    required this.hintText,
    required this.onSearchChanged,
    this.onFilterPressed,
    this.showFilterButton = false,
    this.hasActiveFilter = false,
  });

  final String initialQuery;
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onFilterPressed;
  final bool showFilterButton;
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
      padding: InspectorSpacing.paddingMD,
      color: InspectorColors.backgroundSecondary,
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          if (widget.showFilterButton) ...[
            const SizedBox(width: InspectorSpacing.sm),
            _buildFilterButton(),
          ],
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
          hintText: widget.hintText,
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
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: widget.hasActiveFilter
            ? InspectorColors.accent.withOpacity(0.1)
            : InspectorColors.searchBackground,
        borderRadius: InspectorBorderRadius.radiusMD,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: InspectorBorderRadius.radiusMD,
        child: InkWell(
          onTap: widget.onFilterPressed,
          borderRadius: InspectorBorderRadius.radiusMD,
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.tune,
                  color: widget.hasActiveFilter
                      ? InspectorColors.accent
                      : InspectorColors.contentTertiary,
                  size: InspectorIconSizes.md,
                ),
              ),
              if (widget.hasActiveFilter)
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
}
