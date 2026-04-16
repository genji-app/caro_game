import 'dart:async';

/// Giới hạn số lượng [Future] chạy đồng thời.
///
/// Khi [acquire] được gọi và số lượng Future đang chạy đã đạt [maxCount],
/// Future mới sẽ suspend cho đến khi một Future hiện tại gọi [release].
///
/// Dùng khi cần fan-out nhiều tác vụ async song song nhưng cần kiểm soát
/// concurrency để tránh quá tải server hoặc resource (vd. HTTP connections).
///
/// Cách dùng:
/// ```dart
/// final semaphore = Semaphore(10);
///
/// await Future.wait(
///   items.map((item) async {
///     await semaphore.acquire();
///     try {
///       await doWork(item);
///     } finally {
///       semaphore.release();
///     }
///   }),
///   eagerError: false,
/// );
/// ```
class Semaphore {
  final int _maxCount;
  int _current = 0;
  final _queue = <Completer<void>>[];

  Semaphore(this._maxCount) : assert(_maxCount > 0);

  /// Số slot đang được sử dụng.
  int get currentCount => _current;

  /// Chờ đến khi có slot trống, rồi chiếm 1 slot.
  Future<void> acquire() async {
    if (_current < _maxCount) {
      _current++;
      return;
    }
    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
    _current++;
  }

  /// Giải phóng 1 slot; nếu có Future đang chờ trong queue, unblock ngay.
  void release() {
    _current--;
    if (_queue.isNotEmpty) {
      _queue.removeAt(0).complete();
    }
  }
}
