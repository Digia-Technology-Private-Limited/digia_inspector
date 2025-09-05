import 'package:digia_inspector/src/models/network_log_ui_entry.dart';
import 'package:digia_inspector_core/digia_inspector_core.dart';
import 'package:flutter/foundation.dart';

/// Manages network logs for the UI by correlating requests, responses, and errors
/// using requestId as the unique identifier for each network call
class NetworkLogManager extends ChangeNotifier {
  final Map<String, NetworkLogUIEntry> _networkEntries = {};
  final List<String> _entryOrder = [];

  /// All network log entries in chronological order (latest first)
  List<NetworkLogUIEntry> get allEntries {
    return _entryOrder
        .map((id) => _networkEntries[id])
        .where((entry) => entry != null)
        .cast<NetworkLogUIEntry>()
        .toList();
  }

  /// Notifier for filtered entries
  final ValueNotifier<List<NetworkLogUIEntry>> filteredEntriesNotifier =
      ValueNotifier([]);

  /// Current search query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Current status filter
  NetworkStatusFilter _statusFilter = NetworkStatusFilter.all;
  NetworkStatusFilter get statusFilter => _statusFilter;

  /// Adds a network request log and creates a new UI entry
  void addRequestLog(NetworkRequestLog requestLog) {
    // Use requestId as the unique key since each request gets a unique timestamp-based ID
    final id = requestLog.requestId;

    // Always create a new entry for each request (even for same API)
    final uiEntry = NetworkLogUIEntry.fromRequest(requestLog);
    _networkEntries[id] = uiEntry;
    // Insert at the beginning to keep latest entries at top
    _entryOrder.insert(0, id);

    _applyFilters();
    notifyListeners();
  }

  /// Updates an existing entry with a response log
  void addResponseLog(NetworkResponseLog responseLog) {
    // Find entry by requestId (which is unique for each network call)
    final id = responseLog.requestId;
    final entry = _networkEntries[id];

    if (entry != null) {
      final updatedEntry = entry.withResponse(responseLog);
      _networkEntries[id] = updatedEntry;
      _applyFilters();
      notifyListeners();
    }
  }

  /// Updates an existing entry with an error log
  void addErrorLog(NetworkErrorLog errorLog) {
    // Find entry by requestId (which is unique for each network call)
    final id = errorLog.requestId;
    if (id == null) return; // Skip if no requestId

    final entry = _networkEntries[id];
    if (entry != null) {
      final updatedEntry = entry.withError(errorLog);
      _networkEntries[id] = updatedEntry;
      _applyFilters();
      notifyListeners();
    }
  }

  /// Finds a network entry by request ID
  NetworkLogUIEntry? findEntryByRequestId(String? requestId) {
    if (requestId == null) return null;

    for (final entry in _networkEntries.values) {
      if (entry.requestLog.requestId == requestId) {
        return entry;
      }
    }
    return null;
  }

  /// Sets the search query and applies filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Sets the status filter and applies filters
  void setStatusFilter(NetworkStatusFilter filter) {
    _statusFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  /// Applies current filters to the entries
  void _applyFilters() {
    var filtered = allEntries;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((entry) => _matchesSearch(entry)).toList();
    }

    // Apply status filter
    filtered = _filterByStatus(filtered);

    filteredEntriesNotifier.value = filtered;
  }

  /// Checks if an entry matches the search query
  bool _matchesSearch(NetworkLogUIEntry entry) {
    final query = _searchQuery.toLowerCase();

    return entry.displayName.toLowerCase().contains(query) ||
        entry.method.toLowerCase().contains(query) ||
        entry.url.toString().toLowerCase().contains(query) ||
        (entry.apiId?.toLowerCase().contains(query) ?? false) ||
        (entry.statusCode?.toString().contains(query) ?? false);
  }

  /// Filters entries by status
  List<NetworkLogUIEntry> _filterByStatus(List<NetworkLogUIEntry> entries) {
    switch (_statusFilter) {
      case NetworkStatusFilter.all:
        return entries;
      case NetworkStatusFilter.pending:
        return entries.where((e) => e.isPending).toList();
      case NetworkStatusFilter.success:
        return entries.where((e) => e.isSuccess).toList();
      case NetworkStatusFilter.error:
        return entries.where((e) => e.hasError).toList();
    }
  }

  /// Clears all network logs
  void clear() {
    _networkEntries.clear();
    _entryOrder.clear();
    filteredEntriesNotifier.value = [];
    notifyListeners();
  }

  /// Gets count of entries by status
  int get totalCount => _networkEntries.length;
  int get pendingCount => allEntries.where((e) => e.isPending).length;
  int get successCount => allEntries.where((e) => e.isSuccess).length;
  int get errorCount => allEntries.where((e) => e.hasError).length;

  @override
  void dispose() {
    filteredEntriesNotifier.dispose();
    super.dispose();
  }
}

/// Filter options for network status
enum NetworkStatusFilter {
  all,
  pending,
  success,
  error,
}
