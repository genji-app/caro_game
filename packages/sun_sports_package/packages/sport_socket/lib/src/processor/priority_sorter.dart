import 'message_key.dart';
import '../utils/constants.dart';

/// Priority sorter for WebSocket messages.
///
/// This is Layer 2 of the processing pipeline.
/// Sorts messages by type priority so that parent entities
/// are processed before their children.
///
/// Priority order (lower = higher priority):
/// 1. league_ins - Must exist before events
/// 2. event_ins - Must exist before markets/odds
/// 3. event_up / score_up - Update existing events
/// 4. market_up - Market status changes
/// 5. odds_up / odds_ins - Most frequent, lowest priority
/// 6. event_rm - Cleanup last
class PrioritySorter {
  /// Sort messages by priority (lower priority number = process first)
  List<ExtractedKey> sort(List<ExtractedKey> keys) {
    if (keys.length <= 1) return keys;

    // Create a copy and sort
    final sorted = List<ExtractedKey>.from(keys);
    sorted.sort(_compareByPriority);
    return sorted;
  }

  /// Sort in place
  void sortInPlace(List<ExtractedKey> keys) {
    if (keys.length <= 1) return;
    keys.sort(_compareByPriority);
  }

  /// Compare two keys by priority
  int _compareByPriority(ExtractedKey a, ExtractedKey b) {
    final priorityA = MessagePriority.getPriority(a.type);
    final priorityB = MessagePriority.getPriority(b.type);
    return priorityA.compareTo(priorityB);
  }

  /// Get priority for a message type
  int getPriority(String type) => MessagePriority.getPriority(type);

  /// Check if type A should be processed before type B
  bool shouldProcessFirst(String typeA, String typeB) {
    return getPriority(typeA) < getPriority(typeB);
  }

  /// Group messages by priority level
  Map<int, List<ExtractedKey>> groupByPriority(List<ExtractedKey> keys) {
    final groups = <int, List<ExtractedKey>>{};

    for (final key in keys) {
      final priority = getPriority(key.type);
      groups.putIfAbsent(priority, () => []).add(key);
    }

    return groups;
  }

  /// Get sorted priority levels present in keys
  List<int> getSortedPriorityLevels(List<ExtractedKey> keys) {
    final levels = <int>{};
    for (final key in keys) {
      levels.add(getPriority(key.type));
    }
    final sorted = levels.toList()..sort();
    return sorted;
  }
}
