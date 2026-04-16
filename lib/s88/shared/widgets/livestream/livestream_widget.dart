import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';

// Conditional imports based on platform
import 'package:co_caro_flame/s88/shared/widgets/livestream/livestream_widget_mobile.dart'
    if (dart.library.html) 'package:co_caro_flame/s88/shared/widgets/livestream/livestream_widget_web.dart';

/// Livestream Widget for displaying live match video stream
///
/// Uses platform-specific implementation:
/// - Web: IFrame (dart:html)
/// - Mobile: WebView (webview_flutter)
///
/// Only shows for live matches with livestream available (isLive && isLivestream).
/// Video player will display in 16:9 aspect ratio based on device width.
class LivestreamWidget extends StatelessWidget {
  /// The livestream URL (h5Link from API)
  final String url;

  /// Event data for displaying statistics overlay
  final LeagueEventData? eventData;

  /// Callback khi PiP được activate (click icon PiP)
  final VoidCallback? onPiPActivated;

  const LivestreamWidget({
    super.key,
    required this.url,
    this.eventData,
    this.onPiPActivated,
  });

  @override
  Widget build(BuildContext context) => LivestreamWidgetImpl(
    url: url,
    eventData: eventData,
    onPiPActivated: onPiPActivated,
  );
}
