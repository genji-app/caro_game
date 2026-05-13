import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
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
      ..loadRequest(Uri.parse('https://secure.livechatinc.com/licence/14834214/v2/open_chat.cgi'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WebViewWidget(controller: _controller),
    );
  }
}
