// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'package:flutter/foundation.dart' show VoidCallback, debugPrint;

const String _markerAttr = 'data-splash-rotated';
const String _skipBtnId = 'splash-skip-btn';

VoidCallback? _activeSkipCallback;
html.ButtonElement? _skipButton;
html.EventListener? _skipListener;

/// Poll DOM (max ~5s) cho `<video>` element xuất hiện rồi:
/// 1. Move element ra `<body>` (thoát khỏi Flutter HtmlElementView container
///    — vốn có transform trên ancestor làm `position: fixed` sai containing
///    block, dẫn tới video lệch vị trí).
/// 2. Apply CSS rotation 90° trực tiếp lên element với `position: fixed` +
///    viewport units, lúc này mới đúng vì containing block = viewport.
/// 3. Nếu [onSkip] cung cấp, tạo HTML skip button cũng ở body với z-index
///    cao hơn video → button hiển thị trên video. Cần thiết vì Flutter widget
///    không thể đè video (video ở z-index 999999, Flutter canvas dưới).
Future<void> rotateWebVideoElement({VoidCallback? onSkip}) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    final videos = html.document.querySelectorAll('video');
    if (videos.isNotEmpty) {
      for (final node in videos) {
        if (node is! html.VideoElement) continue;
        if (node.getAttribute(_markerAttr) == '1') continue;
        node.setAttribute(_markerAttr, '1');
        _applyRotation(node);
      }
      if (onSkip != null) _ensureSkipButton(onSkip);
      debugPrint(
        '[Splash] web rotated ${videos.length} video element(s) '
        'viewport=${html.window.innerWidth}x${html.window.innerHeight}',
      );
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  debugPrint('[Splash] web rotate: no <video> element found after 5s');
}

void _applyRotation(html.VideoElement v) {
  // Move element ra body để position: fixed và vw/vh hoạt động relative
  // tới viewport (Flutter's parent có transform → fixed bị bound theo parent).
  if (v.parent != html.document.body) {
    html.document.body!.append(v);
  }

  final s = v.style;
  s.position = 'fixed';
  s.left = '50%';
  s.top = '50%';
  // Pre-rotation: width=viewportHeight, height=viewportWidth.
  // Sau rotate 90deg quanh center, bounding box swap thành (vw, vh) → fit viewport.
  s.width = '100vh';
  s.height = '100vw';
  s.marginLeft = '-50vh';
  s.marginTop = '-50vw';
  s.setProperty('object-fit', 'cover');
  s.setProperty('max-width', 'none');
  s.setProperty('max-height', 'none');
  s.transformOrigin = 'center center';
  s.transform = 'rotate(90deg)';
  s.zIndex = '999999';
  s.backgroundColor = 'black';
}

void _onSkipClick(html.Event _) {
  final cb = _activeSkipCallback;
  if (cb != null) cb();
}

void _ensureSkipButton(VoidCallback onSkip) {
  _activeSkipCallback = onSkip;

  // Idempotent: nếu đã có button trong DOM thì giữ nguyên (callback đã update
  // qua _activeSkipCallback closure).
  if (_skipButton != null && _skipButton!.isConnected == true) return;

  final btn = html.ButtonElement()
    ..id = _skipBtnId
    ..text = 'Bỏ qua';

  final s = btn.style;
  s.position = 'fixed';
  s.bottom = '24px';
  s.right = '24px';
  s.zIndex = '1000000';
  s.padding = '8px 16px';
  s.backgroundColor = 'rgba(0,0,0,0.5)';
  s.color = 'white';
  s.border = 'none';
  s.borderRadius = '24px';
  s.fontSize = '14px';
  s.fontWeight = '500';
  s.cursor = 'pointer';
  s.fontFamily = 'system-ui, -apple-system, sans-serif';
  // Rotate button 90° CW match video rotation.
  s.transformOrigin = 'center center';
  s.transform = 'rotate(90deg)';
  s.setProperty('-webkit-tap-highlight-color', 'transparent');

  _skipListener = _onSkipClick;
  btn.addEventListener('click', _skipListener);

  html.document.body!.append(btn);
  _skipButton = btn;
}

void resetWebVideoElement() {
  _activeSkipCallback = null;

  if (_skipButton != null) {
    if (_skipListener != null) {
      _skipButton!.removeEventListener('click', _skipListener);
    }
    _skipButton!.remove();
    _skipButton = null;
    _skipListener = null;
  }

  final videos = html.document.querySelectorAll('video');
  for (final node in videos) {
    if (node is! html.VideoElement) continue;
    if (node.getAttribute(_markerAttr) != '1') continue;
    node.removeAttribute(_markerAttr);
    // Remove element khỏi DOM. video_player_web cũng sẽ remove khi
    // controller.dispose() — idempotent.
    node.remove();
  }
}
