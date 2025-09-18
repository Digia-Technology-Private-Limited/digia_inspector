# Digia Inspector

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/license-BSL%201.1-green.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/docs-digia.tech-blue.svg)](https://docs.digia.tech)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

**Digia Inspector** is a comprehensive debug console for Flutter applications, providing real-time monitoring of network requests, state changes, and application events with an intuitive Chrome DevTools-like UI.

## 🚀 Overview

Digia Inspector offers powerful debugging capabilities for Flutter apps, featuring:

- **📡 Network Monitoring** - Track HTTP requests, responses, and errors with detailed information
- **🔍 State Inspection** - Monitor state changes across your application in real-time  
- **⚡ Action Logging** - Track user actions and application events with execution timing
- **🖥️ Cross-Platform UI** - Adaptive interface optimized for both web and mobile platforms

Perfect for debugging Digia UI applications or any Flutter app that needs comprehensive observability.

## 📦 Installation

Add Digia Inspector Core to your `pubspec.yaml`:

```yaml
dependencies:
  digia_inspector: ^1.0.0
```

Or use the Flutter CLI:

```bash
flutter pub add digia_inspector
```

Run:

```bash
flutter pub get
```

## 🏁 Quick Start

### 1. Initialize the Inspector Controller

```dart
import 'package:digia_inspector/digia_inspector.dart';

class _MyAppState extends State<MyApp> {
  late final InspectorController _inspectorController;

  @override
  void initState() {
    super.initState();
    _inspectorController = InspectorController();
  }

  @override
  void dispose() {
    _inspectorController.dispose();
    super.dispose();
  }
}
```

### 2. Add Network Monitoring (Dio Integration)

```dart
import 'package:dio/dio.dart';

final dio = Dio();

// Add the Digia Dio interceptor for automatic network logging
dio.interceptors.add(DigiaDioInterceptor(controller: _inspectorController));
```

### 3. Show the Inspector Console

```dart
void _showDigiaInspector() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            InspectorConsole(controller: _inspectorController),
      ),
    );
}
```

## 🎯 Integration with Digia UI

Digia Inspector is designed to work seamlessly with [Digia UI](https://github.com/Digia-Technology-Private-Limited/digia_ui) applications, automatically capturing:

- Server-driven UI state changes
- Network requests to Digia Studio APIs
- State lifecycle events
- Action logs

## 📄 License

This project is licensed under the Business Source License 1.1 (BSL 1.1) - see the [LICENSE](LICENSE) file for details. The BSL 1.1 allows personal and commercial use with certain restrictions around competing platforms. On September 17, 2029, the license will automatically convert to Apache License 2.0.

For commercial licensing inquiries or exceptions, please contact admin@digia.tech.

## 🆘 Support

- 📚 [Documentation](https://docs.digia.tech)
- 💬 [Community](https://discord.gg/szgbr63a)
- 🐛 [Issue Tracker](https://github.com/Digia-Technology-Private-Limited/digia_inspector_core/issues)
- 📧 [Contact Support](mailto:admin@digia.tech)

---

Built with ❤️ by the Digia team
