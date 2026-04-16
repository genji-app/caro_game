import 'package:flutter/material.dart';

// Conditional imports based on platform
import 'package:co_caro_flame/s88/shared/widgets/stats/stats_widget_mobile.dart'
    if (dart.library.html) 'package:co_caro_flame/s88/shared/widgets/stats/stats_widget_web.dart';

/// Stats Widget for displaying match statistics page
///
/// Uses platform-specific implementation:
/// - Web: IFrame (dart:html)
/// - Mobile: WebView (webview_flutter)
///
/// URL format: {urlStatistics}/?token={token}&agentId={agentId}&lng=vi&sportId={sportId}&route=6&m={eventStatsId}
class StatsWidget extends StatelessWidget {
  /// Event Stats ID from API field 'esi'
  final int eventStatsId;

  /// Sport ID (1=Football, 5=Tennis, 6=Volleyball)
  final int sportId;

  /// Widget height
  final double? height;

  final double? width;

  const StatsWidget({
    super.key,
    required this.eventStatsId,
    required this.sportId,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) => StatsWidgetImpl(
    eventStatsId: eventStatsId,
    sportId: sportId,
    height: height,
    width: width,
  );
}
