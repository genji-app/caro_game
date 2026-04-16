import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Sun247Desktop extends StatefulWidget {
  const Sun247Desktop({super.key});

  @override
  State<Sun247Desktop> createState() => _Sun247DesktopState();
}

class _Sun247DesktopState extends State<Sun247Desktop> {
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
}
