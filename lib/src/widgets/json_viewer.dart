import 'dart:convert';
import 'package:flutter/material.dart';

import '../extensions/object_extensions.dart';
import '../extensions/string_extensions.dart';

/// Widget for displaying JSON and other structured data with syntax highlighting.
///
/// This widget automatically detects the data type and formats it appropriately.
/// It supports JSON syntax highlighting, collapsible sections for large data,
/// and copy-to-clipboard functionality.
class JsonViewer extends StatefulWidget {
  /// Creates a new JSON viewer.
  ///
  /// The [data] can be any object that will be formatted for display.
  /// The optional [title] is shown as a header above the data.
  const JsonViewer({
    super.key,
    required this.data,
    this.title,
    this.isCollapsible = true,
    this.isInitiallyExpanded = true,
    this.maxHeight,
    this.showCopyButton = true,
    this.syntaxHighlighting = true,
  });

  /// The data to display in the viewer.
  final dynamic data;

  /// Optional title to display above the data.
  final String? title;

  /// Whether the viewer can be collapsed.
  final bool isCollapsible;

  /// Whether the viewer starts expanded.
  final bool isInitiallyExpanded;

  /// Maximum height for the viewer (with scrolling).
  final double? maxHeight;

  /// Whether to show the copy button.
  final bool showCopyButton;

  /// Whether to apply JSON syntax highlighting.
  final bool syntaxHighlighting;

  @override
  State<JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  /// Whether the viewer is currently expanded.
  bool _isExpanded = true;

  /// The formatted string representation of the data.
  String? _formattedData;

  /// Whether the data is valid JSON.
  bool _isValidJson = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
    _processData();
  }

  @override
  void didUpdateWidget(JsonViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _processData();
    }
  }

  /// Processes the input data for display.
  void _processData() {
    if (widget.data == null) {
      _formattedData = 'null';
      _isValidJson = false;
      return;
    }

    try {
      // Try to format as JSON
      if (widget.data is String) {
        // Try to parse and reformat
        try {
          final parsed = jsonDecode(widget.data as String);
          _formattedData = const JsonEncoder.withIndent('  ').convert(parsed);
          _isValidJson = true;
        } catch (e) {
          // Not valid JSON, treat as plain string
          _formattedData = widget.data as String;
          _isValidJson = false;
        }
      } else {
        // Try to encode as JSON
        _formattedData = const JsonEncoder.withIndent(
          '  ',
        ).convert(widget.data);
        _isValidJson = true;
      }
    } catch (e) {
      // Fall back to string representation
      _formattedData = widget.data.toString();
      _isValidJson = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_formattedData == null || _formattedData!.isEmpty) {
      return _buildEmptyState();
    }

    return Card(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null ||
              widget.isCollapsible ||
              widget.showCopyButton)
            _buildHeader(),
          if (_isExpanded) _buildContent(),
        ],
      ),
    );
  }

  /// Builds the viewer header with title and controls.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: _isExpanded
              ? BorderSide(color: Theme.of(context).dividerColor)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          if (widget.title != null) ...[
            Icon(
              _getDataTypeIcon(),
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
          if (_isValidJson) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'JSON',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
          ],
          const Spacer(),
          if (widget.showCopyButton)
            IconButton(
              icon: const Icon(Icons.content_copy, size: 16),
              onPressed: _copyData,
              tooltip: 'Copy ${widget.title ?? 'Data'}',
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          if (widget.isCollapsible)
            IconButton(
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
              ),
              onPressed: _toggleExpansion,
              tooltip: _isExpanded ? 'Collapse' : 'Expand',
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the main content area.
  Widget _buildContent() {
    Widget content;

    if (widget.syntaxHighlighting && _isValidJson) {
      content = _buildSyntaxHighlightedJson();
    } else {
      content = _buildPlainText();
    }

    // Wrap with height constraint if specified
    if (widget.maxHeight != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight!),
        child: SingleChildScrollView(
          child: content,
        ),
      );
    }

    return content;
  }

  /// Builds syntax-highlighted JSON content.
  Widget _buildSyntaxHighlightedJson() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildJsonTextSpans(),
      ),
    );
  }

  /// Builds the JSON with syntax highlighting using TextSpans.
  Widget _buildJsonTextSpans() {
    final spans = <TextSpan>[];
    final lines = _formattedData!.split('\n');

    for (int i = 0; i < lines.length; i++) {
      spans.addAll(_parseJsonLine(lines[i]));
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        height: 1.4,
      ),
    );
  }

  /// Parses a JSON line and returns styled TextSpans.
  List<TextSpan> _parseJsonLine(String line) {
    final spans = <TextSpan>[];
    final colorScheme = Theme.of(context).colorScheme;

    // Simple regex-based syntax highlighting
    final regexPatterns = [
      // String values
      RegExp(r'"([^"\\]|\\.)*"(?=\s*:)'), // Keys
      RegExp(r':\s*"([^"\\]|\\.)*"'), // String values
      // Numbers
      RegExp(r':\s*-?\d+\.?\d*'),
      // Booleans and null
      RegExp(r':\s*(true|false|null)'),
      // Structural characters
      RegExp(r'[{}[\],]'),
    ];

    int lastEnd = 0;
    final matches = <Match>[];

    // Collect all matches
    for (final pattern in regexPatterns) {
      matches.addAll(pattern.allMatches(line));
    }

    // Sort matches by start position
    matches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in matches) {
      // Add unmatched text
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: line.substring(lastEnd, match.start),
            style: TextStyle(color: colorScheme.onSurface),
          ),
        );
      }

      // Add styled matched text
      final matchText = match.group(0)!;
      TextStyle style;

      if (matchText.contains('"') && matchText.endsWith(':')) {
        // JSON key
        style = TextStyle(
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
        );
      } else if (matchText.startsWith(': "')) {
        // String value
        style = TextStyle(color: Colors.green[700]);
      } else if (RegExp(r':\s*-?\d+\.?\d*').hasMatch(matchText)) {
        // Number
        style = TextStyle(color: Colors.orange[700]);
      } else if (matchText.contains(RegExp(r'(true|false|null)'))) {
        // Boolean or null
        style = TextStyle(
          color: Colors.purple[700],
          fontWeight: FontWeight.w500,
        );
      } else {
        // Structural characters
        style = TextStyle(
          color: colorScheme.onSurface.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        );
      }

      spans.add(TextSpan(text: matchText, style: style));
      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < line.length) {
      spans.add(
        TextSpan(
          text: line.substring(lastEnd),
          style: TextStyle(color: colorScheme.onSurface),
        ),
      );
    }

    return spans;
  }

  /// Builds plain text content without syntax highlighting.
  Widget _buildPlainText() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: SelectableText(
        _formattedData!,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.4,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  /// Builds the empty state when no data is available.
  Widget _buildEmptyState() {
    return Card(
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 48,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 12),
            Text(
              widget.title != null
                  ? 'No ${widget.title}'
                  : 'No data to display',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets the appropriate icon for the data type.
  IconData _getDataTypeIcon() {
    if (_isValidJson) {
      return Icons.code;
    } else if (widget.data is String) {
      return Icons.text_snippet;
    } else {
      return Icons.data_object;
    }
  }

  /// Toggles the expansion state of the viewer.
  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  /// Copies the data to clipboard.
  Future<void> _copyData() async {
    if (_formattedData != null) {
      await _formattedData!.copyToClipboard(
        context,
        label: widget.title ?? 'Data',
      );
    }
  }
}

/// Specialized JSON viewer for request/response payloads.
///
/// This widget extends the basic JSON viewer with specific features for
/// network request inspection, including payload size indicators and
/// request/response specific formatting.
class PayloadJsonViewer extends StatelessWidget {
  /// Creates a payload-specific JSON viewer.
  const PayloadJsonViewer({
    super.key,
    required this.payload,
    required this.isRequest,
    this.maxHeight = 300,
    this.showMetadata = true,
  });

  /// The payload data to display.
  final dynamic payload;

  /// Whether this is a request payload (vs response).
  final bool isRequest;

  /// Maximum height for the viewer.
  final double maxHeight;

  /// Whether to show metadata like size and type.
  final bool showMetadata;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showMetadata) _buildMetadata(context),
        JsonViewer(
          data: payload,
          title: isRequest ? 'Request Payload' : 'Response Data',
          maxHeight: maxHeight,
          isCollapsible: true,
          isInitiallyExpanded: true,
        ),
      ],
    );
  }

  /// Builds metadata information about the payload.
  Widget _buildMetadata(BuildContext context) {
    final sizeText = _getPayloadSize();
    final typeText = _getPayloadType();

    if (sizeText == null && typeText == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (sizeText != null) ...[
            Icon(
              Icons.data_usage,
              size: 16,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Size: $sizeText',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
          if (sizeText != null && typeText != null) ...[
            const SizedBox(width: 16),
            Container(
              width: 1,
              height: 16,
              color: Theme.of(context).dividerColor,
            ),
            const SizedBox(width: 16),
          ],
          if (typeText != null) ...[
            Icon(
              Icons.info_outline,
              size: 16,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Type: $typeText',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Gets the formatted payload size.
  String? _getPayloadSize() {
    if (payload == null) return null;

    try {
      String payloadString;
      if (payload is String) {
        payloadString = payload as String;
      } else {
        payloadString = jsonEncode(payload);
      }

      return payloadString.length.toString().asReadableSize;
    } catch (e) {
      return null;
    }
  }

  /// Gets the payload content type.
  String? _getPayloadType() {
    if (payload == null) return 'null';

    if (payload is String) {
      try {
        jsonDecode(payload as String);
        return 'JSON';
      } catch (e) {
        return 'Text';
      }
    } else if (payload is Map) {
      return 'JSON Object';
    } else if (payload is List) {
      return 'JSON Array';
    } else {
      return payload.runtimeType.toString();
    }
  }
}
