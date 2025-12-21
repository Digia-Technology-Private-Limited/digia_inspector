import 'package:digia_inspector/digia_inspector.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// MyApp
class MyApp extends StatelessWidget {
  /// MyApp
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DigiaInspector Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'DigiaInspector Demo'),
    );
  }
}

/// MyHomePage
class MyHomePage extends StatefulWidget {
  /// MyHomePage
  const MyHomePage({required this.title, super.key});

  /// Title
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // Create the DigiaInspector controller
  late final InspectorController _inspectorController;

  @override
  void initState() {
    super.initState();
    _inspectorController = InspectorController();

    // Demonstrate state logging
    _logStateCreate();
  }

  @override
  void dispose() {
    _inspectorController.dispose();
    super.dispose();
  }

  void _logStateCreate() {
    // Log state creation using the state observer
    _inspectorController.stateObserver?.onCreate(
      id: 'counter_state',
      stateType: StateType.component,
      namespace: 'MyHomePage',
      argData: {'title': widget.title},
      stateData: {'counter': _counter},
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      // Log the state change using the state observer
      _inspectorController.stateObserver?.onChange(
        id: 'counter_state',
        stateType: StateType.component,
        namespace: 'MyHomePage',
        stateData: {'counter': _counter},
      );
    });
  }

  void _simulateAction() {
    final actionLog = ActionLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      actionType: 'CounterIncrement',
      status: ActionStatus.pending,
      timestamp: DateTime.now(),
      category: 'user_action',
      sourceChain: ['MyHomePage', 'FloatingActionButton'],
      triggerName: 'onPressed',
      actionDefinition: {
        'type': 'increment',
        'target': 'counter',
        'description': 'Increments the counter value by 1',
      },
      resolvedParameters: {'current_value': _counter, 'increment_by': 1},
    );

    // Log action start
    _inspectorController.actionObserver?.onActionPending(actionLog);
    _inspectorController.actionObserver?.onActionStart(
      actionLog.copyWith(
        status: ActionStatus.running,
        timestamp: DateTime.now(),
      ),
    );

    // Simulate some work and then complete
    Future.delayed(const Duration(milliseconds: 100), () {
      _inspectorController.actionObserver?.onActionComplete(
        actionLog.copyWith(
          status: ActionStatus.completed,
          timestamp: DateTime.now(),
          executionTime: const Duration(milliseconds: 100),
        ),
      );
    });
  }

  void _showInspector() {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: InspectorConsole(
            controller: _inspectorController,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _showInspector,
            tooltip: 'Open DigiaInspector',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _simulateAction();
                _incrementCounter();
              },
              child: const Text('Increment with Action Logging'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showInspector,
              child: const Text('Open DigiaInspector Console'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Features demonstrated:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• State change logging'),
                Text('• Action execution tracking'),
                Text('• Inspector console UI'),
                Text('• Cross-platform support'),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _simulateAction();
          _incrementCounter();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
