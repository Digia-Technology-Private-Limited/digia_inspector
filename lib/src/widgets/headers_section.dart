import 'package:flutter/material.dart';

import '../extensions/string_extensions.dart';

/// Widget for displaying header sections with optional collapsing.
///
/// This widget provides a consistent way to display grouped key-value pairs
/// such as HTTP headers, query parameters, and general request information.
/// It supports collapsible sections to save space and individual item copying.
class HeadersSection extends StatefulWidget {
  /// Creates a new headers section.
  ///
  /// The [title] is displayed as the section header, and [headers] contains
  /// the key-value pairs to display. The optional [icon] is shown next to
  /// the title for visual categorization.
  const HeadersSection({
    super.key,
    required this.title,
    required this.headers,
    this.icon,
    this.isCollapsible = false,
    this.isInitiallyExpanded = true,
    this.showCopyButtons = true,
    this.headerKeyStyle,
    this.headerValueStyle,
  });

  /// The title to display for this section.
  final String title;

  /// Map of headers/key-value pairs to display.
  final Map<String, String> headers;

  /// Optional icon to display next to the title.
  final IconData? icon;

  /// Whether this section can be collapsed.
  final bool isCollapsible;

  /// Whether the section starts expanded (only applies if collapsible).
  final bool isInitiallyExpanded;

  /// Whether to show copy buttons for individual headers.
  final bool showCopyButtons;

  /// Custom text style for header keys.
  final TextStyle? headerKeyStyle;

  /// Custom text style for header values.
  final TextStyle? headerValueStyle;

  @override
  State<HeadersSection> createState() => _HeadersSectionState();
}

class _HeadersSectionState extends State<HeadersSection> {
  /// Whether the section is currently expanded.
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.headers.isEmpty) {
      return _buildEmptySection();
    }

    return Card(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          if (_isExpanded) _buildHeadersList(),
        ],
      ),
    );
  }

  /// Builds the section header with title and optional collapse button.
  Widget _buildSectionHeader() {
    return InkWell(
      onTap: widget.isCollapsible ? _toggleExpansion : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            if (widget.isCollapsible)
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of headers.
  Widget _buildHeadersList() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: widget.headers.entries
            .map((entry) => _buildHeaderItem(entry.key, entry.value))
            .toList(),
      ),
    );
  }

  /// Builds an individual header item with key and value.
  Widget _buildHeaderItem(String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header key
          Expanded(
            flex: 2,
            child: SelectableText(
              key,
              style:
                  widget.headerKeyStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          // Header value
          Expanded(
            flex: 3,
            child: SelectableText(
              value,
              style:
                  widget.headerValueStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ),
          // Copy button
          if (widget.showCopyButtons) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.content_copy, size: 16),
              onPressed: () => _copyHeaderValue(key, value),
              tooltip: 'Copy $key',
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the empty section display.
  Widget _buildEmptySection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 20,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(empty)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).disabledColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggles the section expansion state.
  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  /// Copies a header value to the clipboard.
  Future<void> _copyHeaderValue(String key, String value) async {
    await value.copyToClipboard(
      context,
      label: key,
    );
  }
}

/// Specialized widget for displaying request/response headers.
///
/// This widget extends the basic [HeadersSection] with specific formatting
/// and behavior for HTTP headers, including sensitive header handling and
/// special formatting for common header types.
class HttpHeadersSection extends StatelessWidget {
  /// Creates an HTTP headers section.
  const HttpHeadersSection({
    super.key,
    required this.title,
    required this.headers,
    this.icon,
    this.isCollapsible = false,
    this.isInitiallyExpanded = true,
    this.highlightSensitive = true,
  });

  /// The title to display for this section.
  final String title;

  /// Map of HTTP headers to display.
  final Map<String, String> headers;

  /// Optional icon to display next to the title.
  final IconData? icon;

  /// Whether this section can be collapsed.
  final bool isCollapsible;

  /// Whether the section starts expanded.
  final bool isInitiallyExpanded;

  /// Whether to highlight sensitive headers.
  final bool highlightSensitive;

  @override
  Widget build(BuildContext context) {
    return HeadersSectionExtension.withCustomStyling(
      title: title,
      headers: headers,
      icon: icon,
      isCollapsible: isCollapsible,
      isInitiallyExpanded: isInitiallyExpanded,
      headerKeyStyle: _getHeaderKeyStyle(context),
      headerValueStyle: (k, v) => _getHeaderValueStyle(context, k, v),
    );
  }

  /// Gets the text style for header keys.
  TextStyle? _getHeaderKeyStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
      color: Theme.of(context).primaryColor.withOpacity(0.8),
    );
  }

  /// Gets the text style for header values based on the header type.
  TextStyle? _getHeaderValueStyle(
    BuildContext context,
    String key,
    String value,
  ) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
    );

    // Highlight sensitive headers
    if (highlightSensitive && _isSensitiveHeader(key)) {
      return baseStyle?.copyWith(
        color: Colors.red[700],
        fontWeight: FontWeight.w500,
      );
    }

    // Special formatting for common headers
    if (_isJsonContentType(value) || _isXmlContentType(value)) {
      return baseStyle?.copyWith(
        color: Colors.blue[700],
        fontWeight: FontWeight.w500,
      );
    }

    return baseStyle;
  }

  /// Checks if a header is sensitive and should be highlighted.
  bool _isSensitiveHeader(String headerName) {
    final sensitive = [
      'authorization',
      'cookie',
      'set-cookie',
      'x-api-key',
      'x-auth-token',
      'access-token',
      'refresh-token',
    ];

    return sensitive.any((s) => headerName.toLowerCase().contains(s));
  }

  /// Checks if a value is a JSON content type.
  bool _isJsonContentType(String value) {
    return value.toLowerCase().contains('application/json') ||
        value.toLowerCase().contains('text/json') ||
        value.toLowerCase().contains('+json');
  }

  /// Checks if a value is an XML content type.
  bool _isXmlContentType(String value) {
    return value.toLowerCase().contains('application/xml') ||
        value.toLowerCase().contains('text/xml') ||
        value.toLowerCase().contains('+xml');
  }
}

/// Extension to allow custom styling function in HeadersSection.
extension HeadersSectionExtension on HeadersSection {
  /// Creates a headers section with custom value styling.
  static Widget withCustomStyling({
    required String title,
    required Map<String, String> headers,
    IconData? icon,
    bool isCollapsible = false,
    bool isInitiallyExpanded = true,
    bool showCopyButtons = true,
    TextStyle? headerKeyStyle,
    TextStyle? Function(String key, String value)? headerValueStyle,
  }) {
    return _CustomStyledHeadersSection(
      title: title,
      headers: headers,
      icon: icon,
      isCollapsible: isCollapsible,
      isInitiallyExpanded: isInitiallyExpanded,
      showCopyButtons: showCopyButtons,
      headerKeyStyle: headerKeyStyle,
      headerValueStyleFunction: headerValueStyle,
    );
  }
}

/// Internal widget for custom styled headers section.
class _CustomStyledHeadersSection extends HeadersSection {
  const _CustomStyledHeadersSection({
    required super.title,
    required super.headers,
    super.icon,
    super.isCollapsible,
    super.isInitiallyExpanded,
    super.showCopyButtons,
    super.headerKeyStyle,
    this.headerValueStyleFunction,
  });

  /// Function to determine header value style based on key and value.
  final TextStyle? Function(String key, String value)? headerValueStyleFunction;

  @override
  State<HeadersSection> createState() => _CustomStyledHeadersSectionState();
}

/// State for the custom styled headers section.
class _CustomStyledHeadersSectionState extends _HeadersSectionState {
  @override
  Widget _buildHeaderItem(String key, String value) {
    final customSection = widget as _CustomStyledHeadersSection;
    final valueStyle =
        customSection.headerValueStyleFunction?.call(key, value) ??
        widget.headerValueStyle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header key
          Expanded(
            flex: 2,
            child: SelectableText(
              key,
              style:
                  widget.headerKeyStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          // Header value
          Expanded(
            flex: 3,
            child: SelectableText(
              value,
              style:
                  valueStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ),
          // Copy button
          if (widget.showCopyButtons) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.content_copy, size: 16),
              onPressed: () => _copyHeaderValue(key, value),
              tooltip: 'Copy $key',
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Copies a header value to the clipboard.
  Future<void> _copyHeaderValue(String key, String value) async {
    await value.copyToClipboard(
      context,
      label: key,
    );
  }
}
