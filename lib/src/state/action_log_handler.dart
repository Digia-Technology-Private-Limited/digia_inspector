import 'package:digia_inspector/src/models/action_log_entry.dart';
import 'package:digia_inspector/src/models/error_log_entry.dart';
import 'package:digia_inspector/src/state/log_entry_manager.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';

/// Handles action observer implementation and action log management.
///
/// This class is responsible for processing action events and converting them
/// into appropriate log entries, providing a clean separation of concerns
/// for action observability logic.
class ActionLogHandler implements ActionObserver {
  /// Creates a new action log handler.
  ActionLogHandler({required LogEntryManager logEntryManager})
    : _logEntryManager = logEntryManager;

  /// The log entry manager to add entries to.
  final LogEntryManager _logEntryManager;

  /// Map of active actions for tracking state updates.
  final Map<String, ActionLogEntry> _activeActions = <String, ActionLogEntry>{};

  @override
  void onActionStart(ActionLog event) {
    // Check if this is a pending -> running transition
    final existingAction = _activeActions[event.eventId];
    if (existingAction != null && event.status == ActionStatus.running) {
      // Update existing pending action to running status
      final updatedAction = ActionLogEntry(
        action: existingAction.action,
        target: existingAction.target,
        status: event.status,
        parameters: {
          ...?existingAction.parameters,
          'status': event.status.name,
        },
        userId: existingAction.userId,
        id: event.eventId,
        timestamp: event.timestamp,
      );

      // Replace in active actions map
      _activeActions[event.eventId] = updatedAction;

      // Update in logs list
      _logEntryManager.updateLogEntry(existingAction, updatedAction);
      return;
    }

    // Create new action entry (for pending status or first time)
    final entry = ActionLogEntry(
      action: event.actionType,
      target: event.sourceChain.join(' → '),
      status: event.status,
      parameters: {
        'eventId': event.eventId,
        'status': event.status.name,
        if (event.parentEventId != null) 'parentEventId': event.parentEventId!,
        'actionDefinition': event.actionDefinition,
        'resolvedParameters': event.resolvedParameters,
      },
      id: event.eventId,
      timestamp: event.timestamp,
    );

    // Store action for potential updates
    _activeActions[event.eventId] = entry;

    _logEntryManager.addLogEntry(entry);
  }

  @override
  void onActionProgress(ActionLog event) {
    // Update existing action entry with progress data instead of creating new one
    final existingAction = _activeActions[event.eventId];
    if (existingAction != null) {
      final updatedAction = ActionLogEntry(
        action: existingAction.action,
        target: existingAction.target,
        status: event.status,
        parameters: {
          ...existingAction.parameters!,
          'status': event.status.name,
          if (event.progressData != null) 'progressData': event.progressData,
        },
        userId: existingAction.userId,
        // eventId: event.eventId,
        // status: event.status.name,
      );

      // Replace in active actions map
      _activeActions[event.eventId] = updatedAction;

      // Update in logs list
      _logEntryManager.updateLogEntry(existingAction, updatedAction);
    } else {
      // Fallback: create new entry if existing not found
      final entry = ActionLogEntry(
        action: '${event.actionType} (Progress)',
        target: event.sourceChain.join(' → '),
        status: event.status,
        parameters: {
          'eventId': event.eventId,
          'status': event.status.name,
          if (event.progressData != null) 'progressData': event.progressData,
          if (event.parentEventId != null)
            'parentEventId': event.parentEventId!,
        },
        // eventId: event.eventId,
        // status: event.status.name,
      );
      _logEntryManager.addLogEntry(entry);
    }
  }

  @override
  void onActionComplete(ActionLog event) {
    // Update existing action or create new one
    final existingAction = _activeActions[event.eventId];
    ActionLogEntry entry;

    if (existingAction != null) {
      // Update existing action with completion data
      entry = ActionLogEntry(
        action: existingAction.action,
        target: existingAction.target,
        status: event.status,
        parameters: {
          ...existingAction.parameters!,
          'status': event.status.name,
          if (event.executionTime != null)
            'executionTime': '${event.executionTime!.inMilliseconds}ms',
          if (event.error != null) 'error': event.error.toString(),
          if (event.errorMessage != null) 'errorMessage': event.errorMessage!,
        },
        userId: existingAction.userId,
        // eventId: event.eventId,
        // status: event.status.name,
      );

      // Update in logs list
      _logEntryManager.updateLogEntry(existingAction, entry);

      // Remove from active actions since it's complete
      _activeActions.remove(event.eventId);
    } else {
      // Create new entry if existing not found
      entry = ActionLogEntry(
        action: event.actionType,
        target: event.sourceChain.join(' → '),
        status: event.status,
        parameters: {
          'eventId': event.eventId,
          'status': event.status.name,
          if (event.executionTime != null)
            'executionTime': '${event.executionTime!.inMilliseconds}ms',
          if (event.error != null) 'error': event.error.toString(),
          if (event.errorMessage != null) 'errorMessage': event.errorMessage!,
          if (event.parentEventId != null)
            'parentEventId': event.parentEventId!,
          'actionDefinition': event.actionDefinition,
          'resolvedParameters': event.resolvedParameters,
        },
        // eventId: event.eventId,
        // status: event.status.name,
      );
      _logEntryManager.addLogEntry(entry);
    }

    // If there's an error, also log it as an error entry
    if (event.error != null) {
      final errorEntry = ErrorLogEntry(
        error: event.error!,
        stackTrace: event.stackTrace,
        context: 'Action execution: ${event.actionType}',
      );
      _logEntryManager.addLogEntry(errorEntry);
    }
  }

  @override
  void onActionDisabled(ActionLog event) {
    final entry = ActionLogEntry(
      action: '${event.actionType} (Disabled)',
      target: event.sourceChain.join(' → '),
      status: event.status,
      parameters: {
        'eventId': event.eventId,
        'status': event.status.name,
        'reason': event.metadata['reason'] ?? 'Action was disabled',
        if (event.parentEventId != null) 'parentEventId': event.parentEventId!,
      },
      // eventId: event.eventId,
      // status: event.status.name,
    );
    _logEntryManager.addLogEntry(entry);
  }

  /// Logs a user action manually.
  void logAction(
    String action,
    String target, {
    Map<String, dynamic>? parameters,
    String? userId,
  }) {
    final entry = ActionLogEntry(
      action: action,
      target: target,
      status: ActionStatus.running,
      parameters: parameters,
      userId: userId,
    );
    _logEntryManager.addLogEntry(entry);
  }

  /// Gets the current active actions.
  Map<String, ActionLogEntry> get activeActions =>
      Map.unmodifiable(_activeActions);

  /// Clears all active actions (useful for testing or reset scenarios).
  void clearActiveActions() {
    _activeActions.clear();
  }
}
