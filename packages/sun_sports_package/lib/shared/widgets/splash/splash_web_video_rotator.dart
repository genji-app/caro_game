import 'package:flutter/foundation.dart' show VoidCallback;

import 'splash_web_video_rotator_stub.dart'
    if (dart.library.html) 'splash_web_video_rotator_web.dart'
    as impl;

/// Apply CSS rotation directly to `<video>` element on web. No-op on native.
///
/// Workaround cho iOS Safari: khi `<video>` nằm trong container có CSS
/// transform (như [RotatedBox] của Flutter), Safari render không đúng (frame
/// không hiện) nhưng audio/timer vẫn chạy. Apply transform trực tiếp lên
/// chính `<video>` element để bỏ qua bug stacking context.
///
/// Optional [onSkip]: nếu cung cấp, tạo thêm HTML skip button ở body (z-index
/// trên video) — Flutter widget không thể đè video ở web mobile rotated.
Future<void> rotateWebVideoElement({VoidCallback? onSkip}) =>
    impl.rotateWebVideoElement(onSkip: onSkip);

/// Restore original styling so the element is removed cleanly when the splash
/// dismisses (or when we no longer want rotation). Also removes skip button.
void resetWebVideoElement() => impl.resetWebVideoElement();
