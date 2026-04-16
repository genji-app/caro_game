/// Shared Sport Widgets
///
/// Performance-optimized widgets for displaying sport data.
/// All widgets follow Consumer/Selector pattern for minimal rebuilds.
///
/// See PERFORMANCE_GUIDELINES.md for usage rules.
library sport_widgets;

// Models
export 'models/bet_column.dart';
export 'models/visible_league_data.dart';

// Enums
export 'enums/sport_filter_enums.dart';
export 'enums/odds_direction.dart';
export 'enums/event_status.dart';
export 'enums/game_part.dart';
export 'enums/market_status.dart';

// Selectors
export 'selectors/league_selectors.dart';

// Widgets
export 'league/league_card.dart';
export 'league/league_flat_item.dart';
export 'league/league_header_widget.dart';
export 'league/league_events_sliver.dart';
export 'match/match_row.dart';
export 'match/live_indicator.dart';
export 'match/score_display.dart';
export 'bet/bet_card_sport.dart';
export 'loading/sport_shimmer_loading.dart';
