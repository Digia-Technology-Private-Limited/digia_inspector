import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_monaco/flutter_monaco.dart';

/// Widget for displaying JSON content in a Monaco editor on mobile devices
class MonacoJsonViewer extends StatefulWidget {
  /// Constructor
  const MonacoJsonViewer({
    required this.content,
    super.key,
    this.height,
    this.width,
    this.showCopyButton = true,
  });

  /// The JSON content to display
  final String content;

  /// The height of the widget
  final double? height;

  /// The width of the widget
  final double? width;

  /// Whether to show a copy button
  final bool showCopyButton;

  @override
  State<MonacoJsonViewer> createState() => _MonacoJsonViewerState();
}

class _MonacoJsonViewerState extends State<MonacoJsonViewer> {
  MonacoController? _controller;

  @override
  void initState() {
    super.initState();
    _initEditor();
  }

  Future<void> _initEditor() async {
    var pretty = widget.content;
    final decoded = jsonDecode(widget.content);
    pretty = const JsonEncoder.withIndent('  ').convert(decoded);

    final controller = await MonacoController.create(
      options: const EditorOptions(
          language: MonacoLanguage.json,
          theme: MonacoTheme.vs,
          readOnly: true,
          fontSize: 12,
          lineNumbers: false,
          scrollBeyondLastLine: false,
          wordWrap: false,
          smoothScrolling: true,
          insertSpaces: false,
          lineHeight: 1.3,
          padding: {'top': 8, 'bottom': 8},
          contextMenu: false),
    );

    await controller.setValue(pretty);

    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: widget.height ?? 450,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _controller!.webViewWidget,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
