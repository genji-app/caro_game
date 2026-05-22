import 'package:web/web.dart' as web;

import 'ncc_tab_opener.dart';

/// Web: mở sẵn tab trắng để điều hướng sau khi có launch URL.
NccPendingTab? openPendingTabImpl() {
  final win = web.window.open('about:blank', '_blank');
  if (win == null) return null;
  return _WebPendingTab(win);
}

class _WebPendingTab implements NccPendingTab {
  _WebPendingTab(this._win);

  final web.Window _win;

  @override
  void navigate(String url) => _win.location.href = url;

  @override
  void close() => _win.close();
}
