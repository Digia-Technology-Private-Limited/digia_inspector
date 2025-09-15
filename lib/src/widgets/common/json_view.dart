import 'dart:convert';

import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:flutter/material.dart';

/// A reusable JSON (Map/List) viewer widget with expand/collapse and copy support.
///
/// Features:
/// - Lazy recursive rendering of nested Maps and Lists
/// - Collapsed preview up to an initial [collapsedDepth]
/// - Stable ordering of Map keys (alphabetical) for deterministic UI and copy
/// - Copy button copies the full canonical JSON (NOT the truncated preview)
/// - Handles primitives, nulls, long strings (with expansion), and circular refs defensively
/// - Adheres to digia design system (colors, spacing, typography)
class JsonView extends StatefulWidget {
  /// Create a JSON view for a dynamic value (Map/List/primitives)
  const JsonView({
    required this.value,
    super.key,
    this.collapsedDepth = 1,
    this.maxStringPreview = 160,
    this.showCopyButton = true,
    this.inline = false,
    this.onCopied,
  });

  /// The value to render. Typically Map / List / primitives.
  final dynamic value;

  /// Depth at which nested collections start collapsed. 0 = fully expanded.
  final int collapsedDepth;

  /// Max characters for inline string preview before truncation.
  final int maxStringPreview;

  /// Whether to show a copy button in the header (only when not inline).
  final bool showCopyButton;

  /// Inline variant (no container chrome, useful for embedding in rows)
  final bool inline;

  /// Callback when copy is triggered successfully.
  final VoidCallback? onCopied;

  @override
  State<JsonView> createState() => _JsonViewState();
}

class _JsonViewState extends State<JsonView> {
  late final String _fullJsonString;
  final Set<_IdentityWrapper> _visited = {};

  @override
  void initState() {
    super.initState();
    _fullJsonString = _stringify(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildValue(widget.value, 0, isRoot: true);

    if (widget.inline) return content;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.separator),
        borderRadius: AppBorderRadius.radiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingSM,
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingSM,
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.md),
          topRight: Radius.circular(AppBorderRadius.md),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.data_object,
            size: AppIconSizes.sm,
            color: AppColors.contentSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'JSON',
            style: InspectorTypography.footnoteBold.copyWith(
              color: AppColors.contentPrimary,
            ),
          ),
          const Spacer(),
          if (widget.showCopyButton)
            IconButton(
              onPressed: () async {
                await ClipboardUtils.copyToClipboardWithToast(
                  context,
                  _fullJsonString,
                  customMessage: 'JSON copied',
                );
                widget.onCopied?.call();
              },
              icon: const Icon(
                Icons.copy,
                size: AppIconSizes.sm,
                color: AppColors.contentSecondary,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Copy JSON',
            ),
        ],
      ),
    );
  }

  Widget _buildValue(dynamic value, int depth, {bool isRoot = false}) {
    if (value == null || value is num || value is bool) {
      return SelectableText(
        value == null ? 'null' : value.toString(),
        style: InspectorTypography.monospace.copyWith(
          color: value == null
              ? AppColors.contentTertiary
              : AppColors.contentPrimary,
        ),
      );
    }
    if (value is String) {
      final truncated = value.length > widget.maxStringPreview
          ? '${value.substring(0, widget.maxStringPreview)}…'
          : value;
      final needsExpand = truncated.endsWith('…');
      return _ExpandablePrimitive(
        preview: '"$truncated"',
        full: '"$value"',
        needsExpand: needsExpand,
      );
    }

    if (value is Map) {
      return _buildMap(value.cast<dynamic, dynamic>(), depth, isRoot: isRoot);
    }
    if (value is List) {
      return _buildList(value, depth, isRoot: isRoot);
    }
    // Fallback
    return SelectableText(
      value.toString(),
      style: InspectorTypography.monospace.copyWith(
        color: AppColors.contentPrimary,
      ),
    );
  }

  Widget _buildMap(Map<dynamic, dynamic> map, int depth,
      {bool isRoot = false}) {
    final idWrap = _IdentityWrapper(map);
    if (_visited.contains(idWrap)) {
      return _circularRefTag('Map');
    }
    _visited.add(idWrap);

    final sortedKeys = map.keys.map((e) => e.toString()).toList()..sort();
    final length = sortedKeys.length;
    final collapsed = depth >= widget.collapsedDepth && !isRoot;

    if (length == 0) {
      return SelectableText(
        '{}',
        style: InspectorTypography.monospace.copyWith(
          color: AppColors.contentSecondary,
        ),
      );
    }

    return _CollapsibleNode(
      headerBuilder: (context, isExpanded) => _collectionHeader(
        '{',
        '}',
        'object',
        length,
        isExpanded,
      ),
      initiallyExpanded: !collapsed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final key in sortedKeys)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      key,
                      style: InspectorTypography.monospace.copyWith(
                        color: AppColors.contentSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    flex: 3,
                    child: _buildValue(map[key], depth + 1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic> list, int depth, {bool isRoot = false}) {
    final idWrap = _IdentityWrapper(list);
    if (_visited.contains(idWrap)) {
      return _circularRefTag('List');
    }
    _visited.add(idWrap);

    final length = list.length;
    final collapsed = depth >= widget.collapsedDepth && !isRoot;
    if (length == 0) {
      return SelectableText(
        '[]',
        style: InspectorTypography.monospace.copyWith(
          color: AppColors.contentSecondary,
        ),
      );
    }
    return _CollapsibleNode(
      headerBuilder: (context, isExpanded) => _collectionHeader(
        '[',
        ']',
        'array',
        length,
        isExpanded,
      ),
      initiallyExpanded: !collapsed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < length; i++)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '[$i]',
                    style: InspectorTypography.monospace.copyWith(
                      color: AppColors.contentSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: _buildValue(list[i], depth + 1)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _collectionHeader(
    String open,
    String close,
    String kind,
    int length,
    bool isExpanded,
  ) {
    return Row(
      children: [
        Icon(
          isExpanded ? Icons.expand_more : Icons.chevron_right,
          size: AppIconSizes.sm,
          color: AppColors.contentSecondary,
        ),
        Text(
          '$kind ($length)',
          style: InspectorTypography.footnoteBold.copyWith(
            color: AppColors.contentPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          isExpanded ? open : '$open…$close',
          style: InspectorTypography.monospace.copyWith(
            color: AppColors.contentTertiary,
          ),
        ),
      ],
    );
  }

  Widget _circularRefTag(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.statusWarning.withValues(alpha: 0.15),
        borderRadius: AppBorderRadius.radiusSM,
      ),
      child: Text(
        '<circular $type>',
        style: InspectorTypography.monospace.copyWith(
          color: AppColors.statusWarning,
          fontSize: 11,
        ),
      ),
    );
  }

  String _stringify(dynamic value) {
    try {
      final normalized = _normalize(value, {});
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(normalized);
    } catch (_) {
      return value.toString();
    }
  }

  dynamic _normalize(dynamic value, Map<int, bool> seen) {
    final identity =
        value is Map || value is List ? identityHashCode(value) : null;
    if (identity != null) {
      if (seen.containsKey(identity)) return '<circular>';
      seen[identity] = true;
    }
    if (value is Map) {
      final map = <String, dynamic>{};
      final keys = value.keys.map((e) => e.toString()).toList()..sort();
      for (final k in keys) {
        map[k] = _normalize(value[k], seen);
      }
      return map;
    } else if (value is List) {
      return value.map((e) => _normalize(e, seen)).toList();
    }
    return value;
  }
}

/// Collapsible node widget for Map/List sections.
class _CollapsibleNode extends StatefulWidget {
  const _CollapsibleNode({
    required this.headerBuilder,
    required this.child,
    required this.initiallyExpanded,
  });

  final Widget Function(BuildContext, bool isExpanded) headerBuilder;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<_CollapsibleNode> createState() => _CollapsibleNodeState();
}

class _CollapsibleNodeState extends State<_CollapsibleNode> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: widget.headerBuilder(context, _expanded),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: widget.child,
          ),
      ],
    );
  }
}

/// Expandable primitive used for long strings.
class _ExpandablePrimitive extends StatefulWidget {
  const _ExpandablePrimitive({
    required this.preview,
    required this.full,
    required this.needsExpand,
  });

  final String preview;
  final String full;
  final bool needsExpand;

  @override
  State<_ExpandablePrimitive> createState() => _ExpandablePrimitiveState();
}

class _ExpandablePrimitiveState extends State<_ExpandablePrimitive> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text =
        _expanded || !widget.needsExpand ? widget.full : widget.preview;
    return GestureDetector(
      onTap: widget.needsExpand
          ? () => setState(() => _expanded = !_expanded)
          : null,
      child: SelectableText(
        text,
        style: InspectorTypography.monospace.copyWith(
          color: AppColors.contentPrimary,
        ),
      ),
    );
  }
}

/// Wrapper to track identity (for circular detection) using referential equality.
class _IdentityWrapper {
  const _IdentityWrapper(this.value);
  final Object value;
  @override
  bool operator ==(Object other) =>
      other is _IdentityWrapper && identical(other.value, value);
  @override
  int get hashCode => identityHashCode(value);
}
