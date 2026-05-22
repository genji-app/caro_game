/// Callback when pending queue exceeds threshold
typedef ThresholdExceededCallback = void Function(
    int currentSize, int threshold);

/// A pending message waiting for its parent to arrive.
class PendingMessage {
  /// Message type
  final String type;

  /// Parsed message data
  final Map<String, dynamic> data;

  /// Parent ID this message is waiting for
  /// - For events waiting for league: leagueId
  /// - For odds/markets waiting for event: eventId
  final int parentId;

  /// When this message was added
  final DateTime timestamp;

  /// Number of retry attempts
  int retryCount;

  PendingMessage({
    required this.type,
    required this.data,
    required this.parentId,
    DateTime? timestamp,
    this.retryCount = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'PendingMessage(type: $type, parentId: $parentId, '
        'retries: $retryCount, age: ${DateTime.now().difference(timestamp).inSeconds}s)';
  }
}

/// Map-based queue for out-of-order messages.
///
/// When a message arrives before its parent (e.g., odds before event),
/// it's stored here until the parent arrives.
///
/// This is NOT a circular buffer - it's a Map for O(1) lookup by parentId.
class PendingQueue {
  /// Map of parentId -> list of pending messages
  final Map<int, List<PendingMessage>> _pendingByParent = {};

  /// Maximum total pending messages
  final int _maxSize;

  /// Time after which pending messages expire
  final Duration _expirationTime;

  /// Current total count
  int _totalCount = 0;

  /// Total dropped due to overflow
  int _droppedCount = 0;

  /// Total expired messages
  int _expiredCount = 0;

  /// Callback when threshold is exceeded
  ThresholdExceededCallback? onThresholdExceeded;

  /// Last threshold that triggered callback (to avoid repeated triggers)
  int? _lastTriggeredThreshold;

  PendingQueue({
    int maxSize = 5000,
    Duration expirationTime = const Duration(seconds: 10),
  })  : _maxSize = maxSize,
        _expirationTime = expirationTime;

  /// Current pending message count
  int get length => _totalCount;

  /// Whether queue is empty
  bool get isEmpty => _totalCount == 0;

  /// Whether queue is full
  bool get isFull => _totalCount >= _maxSize;

  /// Number of dropped messages due to overflow
  int get droppedCount => _droppedCount;

  /// Number of expired messages
  int get expiredCount => _expiredCount;

  /// Number of unique parent IDs waiting
  int get parentCount => _pendingByParent.length;

  /// Add a message waiting for its parent.
  /// Returns true if message was added, false if dropped.
  bool addPending(int parentId, PendingMessage message) {
    // Check if we need to drop oldest
    if (_totalCount >= _maxSize) {
      _dropOldest();
    }

    _pendingByParent.putIfAbsent(parentId, () => []).add(message);
    _totalCount++;
    return true;
  }

  /// Add pending message from parsed data
  bool addPendingParsed({
    required String type,
    required Map<String, dynamic> data,
    required int parentId,
  }) {
    return addPending(
      parentId,
      PendingMessage(type: type, data: data, parentId: parentId),
    );
  }

  /// Check if there are pending messages for a parent
  bool hasPendingFor(int parentId) {
    final list = _pendingByParent[parentId];
    return list != null && list.isNotEmpty;
  }

  /// Get count of pending messages for a parent
  int pendingCountFor(int parentId) {
    return _pendingByParent[parentId]?.length ?? 0;
  }

  /// Get and remove all pending messages for a parent.
  /// Called when the parent arrives.
  List<PendingMessage> flushForParent(int parentId) {
    final pending = _pendingByParent.remove(parentId);
    if (pending != null) {
      _totalCount -= pending.length;
    }
    return pending ?? const [];
  }

  /// Peek at pending messages for a parent without removing
  List<PendingMessage> peekForParent(int parentId) {
    return _pendingByParent[parentId] ?? const [];
  }

  /// Cleanup expired messages.
  /// Returns number of messages removed.
  int cleanupExpired() {
    final now = DateTime.now();
    var removedCount = 0;

    _pendingByParent.removeWhere((parentId, messages) {
      messages.removeWhere((msg) {
        final expired = now.difference(msg.timestamp) > _expirationTime;
        if (expired) {
          removedCount++;
        }
        return expired;
      });
      return messages.isEmpty;
    });

    _totalCount -= removedCount;
    _expiredCount += removedCount;
    return removedCount;
  }

  /// Drop oldest message(s) to make room
  void _dropOldest() {
    if (_pendingByParent.isEmpty) return;

    DateTime? oldestTime;
    int? oldestParent;
    int oldestIndex = 0;

    // Find oldest message across all parents
    for (final entry in _pendingByParent.entries) {
      for (var i = 0; i < entry.value.length; i++) {
        final msg = entry.value[i];
        if (oldestTime == null || msg.timestamp.isBefore(oldestTime)) {
          oldestTime = msg.timestamp;
          oldestParent = entry.key;
          oldestIndex = i;
        }
      }
    }

    // Remove oldest
    if (oldestParent != null) {
      final list = _pendingByParent[oldestParent]!;
      list.removeAt(oldestIndex);
      _totalCount--;
      _droppedCount++;

      if (list.isEmpty) {
        _pendingByParent.remove(oldestParent);
      }
    }
  }

  /// Clear all pending messages
  void clear() {
    _pendingByParent.clear();
    _totalCount = 0;
  }

  /// Reset statistics
  void resetStats() {
    _droppedCount = 0;
    _expiredCount = 0;
  }

  /// Get all parent IDs with pending messages
  Iterable<int> get pendingParentIds => _pendingByParent.keys;

  /// Get all waiting parent IDs as a Set
  Set<int> get waitingParentIds => _pendingByParent.keys.toSet();

  /// Check if queue exceeds the given threshold
  bool exceedsThreshold(int threshold) {
    return _totalCount >= threshold;
  }

  /// Check threshold and notify callback if exceeded.
  /// Only triggers once per threshold level to avoid spam.
  void checkAndNotifyThreshold(int threshold) {
    if (_totalCount >= threshold && _lastTriggeredThreshold != threshold) {
      _lastTriggeredThreshold = threshold;
      onThresholdExceeded?.call(_totalCount, threshold);
    } else if (_totalCount < threshold) {
      // Reset trigger when queue goes below threshold
      _lastTriggeredThreshold = null;
    }
  }

  /// Flush all pending messages and return them.
  /// Use after API refresh to reprocess all pending messages.
  List<PendingMessage> flushAll() {
    final allMessages = <PendingMessage>[];

    for (final messages in _pendingByParent.values) {
      allMessages.addAll(messages);
    }

    _pendingByParent.clear();
    _totalCount = 0;
    _lastTriggeredThreshold = null;

    return allMessages;
  }

  /// Flush pending messages where parent exists in the given set.
  /// Returns flushed messages for reprocessing.
  List<PendingMessage> flushByParents(Set<int> existingParentIds) {
    final flushed = <PendingMessage>[];
    final parentsToFlush = _pendingByParent.keys
        .where((id) => existingParentIds.contains(id))
        .toList();

    for (final parentId in parentsToFlush) {
      final messages = _pendingByParent.remove(parentId);
      if (messages != null) {
        flushed.addAll(messages);
        _totalCount -= messages.length;
      }
    }

    if (flushed.isNotEmpty) {
      _lastTriggeredThreshold = null;
    }

    return flushed;
  }

  /// Remove all pending messages for a specific parent (orphan cleanup).
  /// Returns count of removed messages.
  int removeByParent(int parentId) {
    final messages = _pendingByParent.remove(parentId);
    if (messages != null) {
      _totalCount -= messages.length;
      _expiredCount += messages.length; // Count as expired
      _lastTriggeredThreshold = null;
      return messages.length;
    }
    return 0;
  }

  /// Remove all pending messages for parents NOT in the given set (orphan cleanup).
  /// Returns count of removed messages and list of orphan parent IDs.
  ({int removedCount, List<int> orphanParentIds}) removeOrphans(
      Set<int> existingParentIds) {
    final orphanParentIds = _pendingByParent.keys
        .where((id) => !existingParentIds.contains(id))
        .toList();

    var removedCount = 0;
    for (final parentId in orphanParentIds) {
      removedCount += removeByParent(parentId);
    }

    return (removedCount: removedCount, orphanParentIds: orphanParentIds);
  }

  @override
  String toString() {
    return 'PendingQueue(count: $_totalCount, parents: ${_pendingByParent.length}, '
        'dropped: $_droppedCount, expired: $_expiredCount)';
  }
}
