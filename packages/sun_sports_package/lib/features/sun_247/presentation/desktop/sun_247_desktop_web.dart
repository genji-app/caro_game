import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:sun_sports/core/services/config/sb_config.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';

/// Web implementation dùng IFrameElement + HtmlElementView.
///
/// ### Vì sao có padding bottom (mobile / tablet)
///
/// Trên Flutter Web, `HtmlElementView` (iframe) là DOM element thật. Bottom
/// nav trong shell layout là một Flutter widget được `Positioned` overlay
/// lên trên cùng tab content area. Trên mobile browser (đặc biệt là iOS
/// Safari), khi iframe overlap về mặt visual với một Flutter widget khác,
/// browser thường route touch event vào iframe trước — kết quả là click
/// vào bottom nav không phản hồi khi đang ở tab này.
///
/// Workaround: chỉ render iframe trong vùng phía trên bottom nav, để Flutter
/// tự nhận pointer events ở vùng nav (không có DOM overlap nữa).
///
/// Trên desktop (web) bottom nav không tồn tại theo cách overlay này nên
/// không cần padding.
class Sun247DesktopImpl extends StatefulWidget {
  const Sun247DesktopImpl({super.key});

  @override
  State<Sun247DesktopImpl> createState() => _Sun247DesktopImplState();
}

class _Sun247DesktopImplState extends State<Sun247DesktopImpl> {
  /// Chiều cao bottom nav (mobile / tablet shell). Match với
  /// `ShellBottomNavigation` (~56 nav + padding xung quanh ≈ 80).
  static const double _bottomNavHeight = 80.0;

  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType =
        'sun247-iframe-${DateTime.now().millisecondsSinceEpoch}';
    _registerIFrame();
  }

  void _registerIFrame() {
    final url = SbConfig.livechatUrl;

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      // Wrap iframe trong div để DOM containment rõ ràng (overflow: hidden
      // tránh iframe bleed ra ngoài khi browser tính sai size trong vài frame
      // đầu).
      final container = html.DivElement()
        ..style.position = 'relative'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.overflow = 'hidden'
        ..style.backgroundColor = 'black';

      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.left = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'black'
        ..allowFullscreen = true
        ..allow = 'autoplay; encrypted-media';

      container.append(iframe);
      return container;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBuilder.isDesktop(context);
    final mq = MediaQuery.of(context);

    // Mobile / tablet: chừa khoảng cho bottom nav + safe area inset (Android
    // gesture bar, iOS home indicator). Desktop web: full bleed.
    final bottomPadding = isDesktop
        ? 0.0
        : _bottomNavHeight + mq.padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        // ClipRect đảm bảo iframe DOM không vẽ ra ngoài bounds của widget,
        // tránh edge case browser render iframe lệch 1-2px sang vùng nav.
        child: ClipRect(
          child: SizedBox.expand(
            child: HtmlElementView(viewType: _viewType),
          ),
        ),
      ),
    );
  }
}
