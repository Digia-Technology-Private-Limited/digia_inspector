import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:digia_inspector/src/theme/theme_system.dart';
import 'package:digia_inspector/src/utils/extensions.dart';
import 'package:digia_inspector/src/widgets/common/json_view.dart';
import 'package:digia_inspector/src/widgets/json_viewer/json_view_html.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Widget for displaying JSON content in a Monaco editor on web devices
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
  late final String _instanceId;
  web.HTMLIFrameElement? _iframe;
  StreamSubscription<web.MessageEvent>? _sub;

  @override
  void initState() {
    super.initState();
    _instanceId =
        'monaco-json-${DateTime.now().microsecondsSinceEpoch}-$hashCode';
    if (kIsWeb) {
      _setupIframe();
      _listenMessages();
    }
  }

  void _setupIframe() {
    final iframe = web.HTMLIFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..setAttribute('data-instance-id', _instanceId)
      ..srcdoc = inlineHtml().toJS;

    iframe.onLoad.listen((_) {
      _postToIframe({
        'action': 'set_value',
        'value': widget.content,
        'instanceId': _instanceId,
      });
      _postToIframe({
        'action': 'set_theme',
        'instanceId': _instanceId,
      });
    });

    ui_web.platformViewRegistry.registerViewFactory(
      _instanceId,
      (int viewId) => iframe,
    );

    _iframe = iframe;
  }

  void _listenMessages() {
    _sub = web.window.onMessage.listen((event) {
      if (!mounted) return;
      final sourceElement = event.source as web.Window?;
      if (sourceElement?.frameElement?.getAttribute('data-instance-id') !=
          _instanceId) {
        return;
      }
      try {
        final data = jsonDecode(event.data.toString());
        if (data is Map && data['type'] == 'init') {
          _postToIframe({
            'action': 'set_value',
            'value': widget.content,
            'instanceId': _instanceId,
          });
          _postToIframe({
            'action': 'set_theme',
            'theme': _isDark(context) ? 'vs-dark' : 'vs',
            'instanceId': _instanceId,
          });
        }
      } on Exception catch (_) {
        // ignore non-JSON messages
      }
    });
  }

  void _postToIframe(Map<String, dynamic> message) {
    _iframe?.contentWindow?.postMessage(message.jsify(), '*'.toJS);
  }

  bool _isDark(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark;
  }

  @override
  void didUpdateWidget(covariant MonacoJsonViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!kIsWeb) return;
    if (oldWidget.content != widget.content) {
      _postToIframe({
        'action': 'set_value',
        'value': widget.content,
        'instanceId': _instanceId,
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _iframe?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = BoxDecoration(
      border: Border.all(color: context.inspectorColors.separator),
      borderRadius: AppBorderRadius.radiusMD,
    );

    if (!kIsWeb) {
      // Fallback to existing JsonView on non-web
      dynamic parsed = widget.content;
      try {
        parsed = jsonDecode(widget.content);
      } on Exception catch (_) {}
      return Container(
        decoration: box,
        child: Padding(
          padding: AppSpacing.paddingSM,
          child: JsonView(value: parsed, showCopyButton: widget.showCopyButton),
        ),
      );
    }

    final effectiveHeight = widget.height ?? 440;

    return Container(
      height: effectiveHeight,
      width: widget.width ?? double.infinity,
      decoration: box,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: AppSpacing.paddingSM,
            decoration: BoxDecoration(
              color: context.inspectorColors.backgroundPrimary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppBorderRadius.md),
                topRight: Radius.circular(AppBorderRadius.md),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.data_object,
                  size: AppIconSizes.sm,
                  color: context.inspectorColors.contentSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'JSON',
                  style: context.inspectorTypography.footnoteBold.copyWith(
                    color: context.inspectorColors.contentPrimary,
                  ),
                ),
                const Spacer(),
                if (widget.showCopyButton)
                  IconButton(
                    onPressed: () async {
                      await ClipboardUtils.copyToClipboardWithToast(
                        context,
                        widget.content,
                        customMessage: 'JSON copied',
                      );
                    },
                    icon: Icon(
                      Icons.copy,
                      size: AppIconSizes.sm,
                      color: context.inspectorColors.contentSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Copy JSON',
                  ),
              ],
            ),
          ),
          Expanded(
            child: HtmlElementView(viewType: _instanceId),
          ),
        ],
      ),
    );
  }
}
