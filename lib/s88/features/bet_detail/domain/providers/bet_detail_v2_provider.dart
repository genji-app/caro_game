import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/event_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/league_model_v2.dart';

/// Selected event V2 provider - stores the event to show in detail (V2 model)
final selectedEventV2Provider = StateProvider<EventModelV2?>((ref) => null);

/// Selected league V2 provider - stores the league for the selected event (V2 model)
final selectedLeagueV2Provider = StateProvider<LeagueModelV2?>((ref) => null);
