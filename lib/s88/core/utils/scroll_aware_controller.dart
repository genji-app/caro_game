import 'dart:async';
import 'package:flutter/foundation.dart';

/// Singleton controller để track scroll state
/// Dùng để disable animation khi đang scroll
///
/// Usage:
/// ```dart
/// // Trong widget chứa CustomScrollView:
/// NotificationListener<ScrollNotification>(
///   onNotification: (notification) {
///     if (notification is ScrollStartNotification ||
///         notification is ScrollUpdateNotification) {
///       ScrollAwareController.instance.onScrollStart();
///     } else if (notification is ScrollEndNotification) {
///       ScrollAwareController.instance.onScrollEnd();
///     }
///     return false;
///   },
///   child: CustomScrollView(...),
/// )
///
/// // Trong widget con:
/// ScrollAwareController.instance.addListener(_onScrollStateChanged);
/// ```
class ScrollAwareController extends ChangeNotifier {
  static final instance = ScrollAwareController._();
  ScrollAwareController._();

  bool _isScrolling = false;
  Timer? _scrollEndTimer;

  /// Returns true if user is currently scrolling
  bool get isScrolling => _isScrolling;

  /// Call when scroll starts or updates
  void onScrollStart() {
    _scrollEndTimer?.cancel();
    if (!_isScrolling) {
      _isScrolling = true;
      notifyListeners();
    }
  }

  /// Call when scroll ends
  /// Uses debounce to avoid rapid state changes
  void onScrollEnd() {
    _scrollEndTimer?.cancel();
    _scrollEndTimer = Timer(const Duration(milliseconds: 150), () {
      if (_isScrolling) {
        _isScrolling = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _scrollEndTimer?.cancel();
    super.dispose();
  }
}
