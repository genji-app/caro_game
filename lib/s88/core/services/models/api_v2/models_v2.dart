/// API V2 Data Models
///
/// This barrel file exports all data models for the new API V2 format.
library;

/// The V2 API uses numeric keys (0, 1, 2...) instead of named fields.
///
/// Models are built using Freezed for immutability.
/// Custom fromJson methods handle the numeric key format.
///
/// ## Model Hierarchy
/// ```
/// LeagueModelV2
/// └── List<EventModelV2> events
///     └── List<MarketModelV2> markets
///         └── List<OddsModelV2> oddsList
///             ├── OddsStyleModelV2 homeOdds
///             ├── OddsStyleModelV2 awayOdds
///             └── OddsStyleModelV2 drawOdds
///     └── ScoreModelV2? score (polymorphic)
///         ├── SoccerScoreModelV2
///         ├── BasketballScoreModelV2
///         ├── TennisScoreModelV2
///         ├── VolleyballScoreModelV2
///         └── GenericScoreModelV2
/// ```
///
/// ## Usage Example
/// ```dart
/// import 'package:betting_app/core/services/models/api_v2/models_v2.dart';
///
/// // Parse API response
/// final response = await dio.get('/api/v2/events');
/// final leagues = (response.data as List).toLeagueModelsV2();
///
/// // Access data
/// for (final league in leagues) {
///   print('League: ${league.displayName}');
///   for (final event in league.events) {
///     print('  Event: ${event.fullName}');
///     print('  Score: ${event.scoreDisplay}');
///   }
/// }
/// ```

// Core odds models
export 'odds_style_model_v2.dart';
export 'odds_model_v2.dart';

// Market model
export 'market_model_v2.dart';

// Score models (polymorphic based on sport)
export 'score_model_v2.dart';

// Event model
export 'event_model_v2.dart';

// League model
export 'league_model_v2.dart';

// Constants and request model
export 'sport_constants.dart';
export 'events_request_model.dart';

// V2 to Legacy adapter (for gradual migration)
export 'v2_to_legacy_adapter.dart';
