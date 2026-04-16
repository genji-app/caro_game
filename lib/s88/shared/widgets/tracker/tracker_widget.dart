import 'package:flutter/material.dart';

// Conditional imports based on platform
import 'package:co_caro_flame/s88/shared/widgets/tracker/tracker_widget_mobile.dart'
    if (dart.library.html) 'package:co_caro_flame/s88/shared/widgets/tracker/tracker_widget_web.dart';

/// Tracker Widget for displaying live match simulation
///
/// Uses platform-specific implementation:
/// - Web: IFrame (dart:html)
/// - Mobile: WebView (webview_flutter)
///
/// Only shows for live matches without livestream (isLive && !isLivestream).
class TrackerWidget extends StatelessWidget {
  /// Event Stats ID from API field 'esi'
  final int eventStatsId;

  /// Sport ID (1=Football, 5=Tennis, 6=Volleyball)
  final int sportId;

  /// Widget height
  final double height;

  const TrackerWidget({
    super.key,
    required this.eventStatsId,
    required this.sportId,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) => TrackerWidgetImpl(
    eventStatsId: eventStatsId,
    sportId: sportId,
    height: height,
  );
}
