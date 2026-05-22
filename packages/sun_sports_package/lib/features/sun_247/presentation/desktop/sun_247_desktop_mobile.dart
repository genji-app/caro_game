import 'package:flutter/material.dart';
<<<<<<<< HEAD:packages/sun_sports_package/lib/features/sun_247/presentation/desktop/sun_247_desktop_mobile.dart
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Mobile/Desktop-native (Android, iOS, macOS) implementation
/// dùng `webview_flutter`.
class Sun247DesktopImpl extends StatefulWidget {
  const Sun247DesktopImpl({super.key});

  @override
  State<Sun247DesktopImpl> createState() => _Sun247DesktopImplState();
}

class _Sun247DesktopImplState extends State<Sun247DesktopImpl> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(SbConfig.livechatUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WebViewWidget(controller: _controller),
    );
  }
========

// Conditional imports — chọn implementation theo platform.
// - Web: dùng `dart:html` IFrameElement (sun_247_desktop_web.dart)
// - Mobile / Desktop-native (Android, iOS, macOS): dùng `webview_flutter`
//   (sun_247_desktop_mobile.dart)
import 'package:co_caro_flame/s88/features/sun_247/presentation/desktop/sun_247_desktop_mobile.dart'
    if (dart.library.html)
        'package:co_caro_flame/s88/features/sun_247/presentation/desktop/sun_247_desktop_web.dart';

class Sun247Desktop extends StatelessWidget {
  const Sun247Desktop({super.key});

  @override
  Widget build(BuildContext context) => const Sun247DesktopImpl();
>>>>>>>> 78c820f596120d9fe32e3c53d06f14cf496d9745:lib/s88/features/sun_247/presentation/desktop/sun_247_desktop.dart
}
