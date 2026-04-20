// This is a generated file - do not edit.
//
// Generated from app_schema_20260115.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use payloadDescriptor instead')
const Payload$json = {
  '1': 'Payload',
  '2': [
    {'1': 'channel', '3': 1, '4': 1, '5': 9, '10': 'channel'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'time_range', '3': 3, '4': 1, '5': 5, '10': 'timeRange'},
    {
      '1': 'league',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.app.proto.LeagueResponse',
      '9': 0,
      '10': 'league'
    },
    {
      '1': 'event',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.app.proto.EventResponse',
      '9': 0,
      '10': 'event'
    },
    {
      '1': 'hot_event',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.app.proto.HotEventsResponse',
      '9': 0,
      '10': 'hotEvent'
    },
    {
      '1': 'outright',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.app.proto.OutrightEventResponse',
      '9': 0,
      '10': 'outright'
    },
    {
      '1': 'bet_slip_status',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.app.proto.BetSlipStatusResponse',
      '9': 0,
      '10': 'betSlipStatus'
    },
  ],
  '8': [
    {'1': 'data'},
  ],
};

/// Descriptor for `Payload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List payloadDescriptor = $convert.base64Decode(
    'CgdQYXlsb2FkEhgKB2NoYW5uZWwYASABKAlSB2NoYW5uZWwSEgoEdHlwZRgCIAEoCVIEdHlwZR'
    'IdCgp0aW1lX3JhbmdlGAMgASgFUgl0aW1lUmFuZ2USMwoGbGVhZ3VlGAQgASgLMhkuYXBwLnBy'
    'b3RvLkxlYWd1ZVJlc3BvbnNlSABSBmxlYWd1ZRIwCgVldmVudBgFIAEoCzIYLmFwcC5wcm90by'
    '5FdmVudFJlc3BvbnNlSABSBWV2ZW50EjsKCWhvdF9ldmVudBgGIAEoCzIcLmFwcC5wcm90by5I'
    'b3RFdmVudHNSZXNwb25zZUgAUghob3RFdmVudBI+CghvdXRyaWdodBgHIAEoCzIgLmFwcC5wcm'
    '90by5PdXRyaWdodEV2ZW50UmVzcG9uc2VIAFIIb3V0cmlnaHQSSgoPYmV0X3NsaXBfc3RhdHVz'
    'GAggASgLMiAuYXBwLnByb3RvLkJldFNsaXBTdGF0dXNSZXNwb25zZUgAUg1iZXRTbGlwU3RhdH'
    'VzQgYKBGRhdGE=');

@$core.Deprecated('Use leagueResponseDescriptor instead')
const LeagueResponse$json = {
  '1': 'LeagueResponse',
  '2': [
    {
      '1': 'events',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.EventResponse',
      '10': 'events'
    },
    {'1': 'sport_id', '3': 2, '4': 1, '5': 5, '10': 'sportId'},
    {'1': 'sport_name', '3': 3, '4': 1, '5': 9, '10': 'sportName'},
    {'1': 'league_id', '3': 4, '4': 1, '5': 5, '10': 'leagueId'},
    {'1': 'league_name', '3': 5, '4': 1, '5': 9, '10': 'leagueName'},
    {'1': 'league_name_en', '3': 6, '4': 1, '5': 9, '10': 'leagueNameEn'},
    {'1': 'league_logo', '3': 7, '4': 1, '5': 9, '10': 'leagueLogo'},
    {'1': 'league_order', '3': 8, '4': 1, '5': 5, '10': 'leagueOrder'},
    {
      '1': 'league_priority_order',
      '3': 9,
      '4': 1,
      '5': 5,
      '10': 'leaguePriorityOrder'
    },
    {'1': 'type', '3': 10, '4': 1, '5': 5, '10': 'type'},
    {'1': 'is_parlay', '3': 11, '4': 1, '5': 8, '10': 'isParlay'},
    {'1': 'is_cash_out', '3': 12, '4': 1, '5': 8, '10': 'isCashOut'},
    {'1': 'is_pin', '3': 13, '4': 1, '5': 8, '10': 'isPin'},
    {'1': 'sport_type', '3': 14, '4': 1, '5': 9, '10': 'sportType'},
    {'1': 'sport_type_id', '3': 15, '4': 1, '5': 5, '10': 'sportTypeId'},
  ],
};

/// Descriptor for `LeagueResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leagueResponseDescriptor = $convert.base64Decode(
    'Cg5MZWFndWVSZXNwb25zZRIwCgZldmVudHMYASADKAsyGC5hcHAucHJvdG8uRXZlbnRSZXNwb2'
    '5zZVIGZXZlbnRzEhkKCHNwb3J0X2lkGAIgASgFUgdzcG9ydElkEh0KCnNwb3J0X25hbWUYAyAB'
    'KAlSCXNwb3J0TmFtZRIbCglsZWFndWVfaWQYBCABKAVSCGxlYWd1ZUlkEh8KC2xlYWd1ZV9uYW'
    '1lGAUgASgJUgpsZWFndWVOYW1lEiQKDmxlYWd1ZV9uYW1lX2VuGAYgASgJUgxsZWFndWVOYW1l'
    'RW4SHwoLbGVhZ3VlX2xvZ28YByABKAlSCmxlYWd1ZUxvZ28SIQoMbGVhZ3VlX29yZGVyGAggAS'
    'gFUgtsZWFndWVPcmRlchIyChVsZWFndWVfcHJpb3JpdHlfb3JkZXIYCSABKAVSE2xlYWd1ZVBy'
    'aW9yaXR5T3JkZXISEgoEdHlwZRgKIAEoBVIEdHlwZRIbCglpc19wYXJsYXkYCyABKAhSCGlzUG'
    'FybGF5Eh4KC2lzX2Nhc2hfb3V0GAwgASgIUglpc0Nhc2hPdXQSFQoGaXNfcGluGA0gASgIUgVp'
    'c1BpbhIdCgpzcG9ydF90eXBlGA4gASgJUglzcG9ydFR5cGUSIgoNc3BvcnRfdHlwZV9pZBgPIA'
    'EoBVILc3BvcnRUeXBlSWQ=');

@$core.Deprecated('Use eventResponseDescriptor instead')
const EventResponse$json = {
  '1': 'EventResponse',
  '2': [
    {
      '1': 'children',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.EventResponse',
      '10': 'children'
    },
    {
      '1': 'markets',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.app.proto.MarketResponse',
      '10': 'markets'
    },
    {'1': 'sport_id', '3': 3, '4': 1, '5': 5, '10': 'sportId'},
    {'1': 'league_id', '3': 4, '4': 1, '5': 5, '10': 'leagueId'},
    {'1': 'event_id', '3': 5, '4': 1, '5': 3, '10': 'eventId'},
    {'1': 'start_date', '3': 6, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'start_time', '3': 7, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'is_suspended', '3': 8, '4': 1, '5': 8, '10': 'isSuspended'},
    {'1': 'is_hidden', '3': 9, '4': 1, '5': 8, '10': 'isHidden'},
    {'1': 'is_parlay', '3': 10, '4': 1, '5': 8, '10': 'isParlay'},
    {'1': 'is_cash_out', '3': 11, '4': 1, '5': 8, '10': 'isCashOut'},
    {'1': 'type', '3': 12, '4': 1, '5': 5, '10': 'type'},
    {'1': 'pin_type', '3': 13, '4': 1, '5': 5, '10': 'pinType'},
    {
      '1': 'special_situation',
      '3': 14,
      '4': 1,
      '5': 9,
      '10': 'specialSituation'
    },
    {'1': 'event_stats_id', '3': 15, '4': 1, '5': 3, '10': 'eventStatsId'},
    {'1': 'sport_type_id', '3': 16, '4': 1, '5': 5, '10': 'sportTypeId'},
    {'1': 'sport_type_name', '3': 17, '4': 1, '5': 9, '10': 'sportTypeName'},
    {'1': 'home_id', '3': 18, '4': 1, '5': 5, '10': 'homeId'},
    {'1': 'away_id', '3': 19, '4': 1, '5': 5, '10': 'awayId'},
    {'1': 'home_name', '3': 20, '4': 1, '5': 9, '10': 'homeName'},
    {'1': 'away_name', '3': 21, '4': 1, '5': 9, '10': 'awayName'},
    {'1': 'home_logo', '3': 22, '4': 1, '5': 9, '10': 'homeLogo'},
    {'1': 'away_logo', '3': 23, '4': 1, '5': 9, '10': 'awayLogo'},
    {'1': 'market_count', '3': 24, '4': 1, '5': 5, '10': 'marketCount'},
    {'1': 'market_groups', '3': 25, '4': 3, '5': 5, '10': 'marketGroups'},
    {
      '1': 'time_market_groups',
      '3': 26,
      '4': 3,
      '5': 5,
      '10': 'timeMarketGroups'
    },
    {'1': 'is_hot', '3': 27, '4': 1, '5': 8, '10': 'isHot'},
    {'1': 'is_going_live', '3': 28, '4': 1, '5': 8, '10': 'isGoingLive'},
    {'1': 'is_live', '3': 29, '4': 1, '5': 8, '10': 'isLive'},
    {'1': 'is_live_stream', '3': 30, '4': 1, '5': 8, '10': 'isLiveStream'},
    {'1': 'game_part', '3': 31, '4': 1, '5': 5, '10': 'gamePart'},
    {'1': 'game_time', '3': 32, '4': 1, '5': 5, '10': 'gameTime'},
    {'1': 'stoppage_time', '3': 33, '4': 1, '5': 5, '10': 'stoppageTime'},
    {
      '1': 'live_score',
      '3': 34,
      '4': 1,
      '5': 11,
      '6': '.app.proto.ScoreResponse',
      '10': 'liveScore'
    },
    {'1': 'child_type', '3': 35, '4': 1, '5': 5, '10': 'childType'},
  ],
};

/// Descriptor for `EventResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventResponseDescriptor = $convert.base64Decode(
    'Cg1FdmVudFJlc3BvbnNlEjQKCGNoaWxkcmVuGAEgAygLMhguYXBwLnByb3RvLkV2ZW50UmVzcG'
    '9uc2VSCGNoaWxkcmVuEjMKB21hcmtldHMYAiADKAsyGS5hcHAucHJvdG8uTWFya2V0UmVzcG9u'
    'c2VSB21hcmtldHMSGQoIc3BvcnRfaWQYAyABKAVSB3Nwb3J0SWQSGwoJbGVhZ3VlX2lkGAQgAS'
    'gFUghsZWFndWVJZBIZCghldmVudF9pZBgFIAEoA1IHZXZlbnRJZBIdCgpzdGFydF9kYXRlGAYg'
    'ASgJUglzdGFydERhdGUSHQoKc3RhcnRfdGltZRgHIAEoA1IJc3RhcnRUaW1lEiEKDGlzX3N1c3'
    'BlbmRlZBgIIAEoCFILaXNTdXNwZW5kZWQSGwoJaXNfaGlkZGVuGAkgASgIUghpc0hpZGRlbhIb'
    'Cglpc19wYXJsYXkYCiABKAhSCGlzUGFybGF5Eh4KC2lzX2Nhc2hfb3V0GAsgASgIUglpc0Nhc2'
    'hPdXQSEgoEdHlwZRgMIAEoBVIEdHlwZRIZCghwaW5fdHlwZRgNIAEoBVIHcGluVHlwZRIrChFz'
    'cGVjaWFsX3NpdHVhdGlvbhgOIAEoCVIQc3BlY2lhbFNpdHVhdGlvbhIkCg5ldmVudF9zdGF0c1'
    '9pZBgPIAEoA1IMZXZlbnRTdGF0c0lkEiIKDXNwb3J0X3R5cGVfaWQYECABKAVSC3Nwb3J0VHlw'
    'ZUlkEiYKD3Nwb3J0X3R5cGVfbmFtZRgRIAEoCVINc3BvcnRUeXBlTmFtZRIXCgdob21lX2lkGB'
    'IgASgFUgZob21lSWQSFwoHYXdheV9pZBgTIAEoBVIGYXdheUlkEhsKCWhvbWVfbmFtZRgUIAEo'
    'CVIIaG9tZU5hbWUSGwoJYXdheV9uYW1lGBUgASgJUghhd2F5TmFtZRIbCglob21lX2xvZ28YFi'
    'ABKAlSCGhvbWVMb2dvEhsKCWF3YXlfbG9nbxgXIAEoCVIIYXdheUxvZ28SIQoMbWFya2V0X2Nv'
    'dW50GBggASgFUgttYXJrZXRDb3VudBIjCg1tYXJrZXRfZ3JvdXBzGBkgAygFUgxtYXJrZXRHcm'
    '91cHMSLAoSdGltZV9tYXJrZXRfZ3JvdXBzGBogAygFUhB0aW1lTWFya2V0R3JvdXBzEhUKBmlz'
    'X2hvdBgbIAEoCFIFaXNIb3QSIgoNaXNfZ29pbmdfbGl2ZRgcIAEoCFILaXNHb2luZ0xpdmUSFw'
    'oHaXNfbGl2ZRgdIAEoCFIGaXNMaXZlEiQKDmlzX2xpdmVfc3RyZWFtGB4gASgIUgxpc0xpdmVT'
    'dHJlYW0SGwoJZ2FtZV9wYXJ0GB8gASgFUghnYW1lUGFydBIbCglnYW1lX3RpbWUYICABKAVSCG'
    'dhbWVUaW1lEiMKDXN0b3BwYWdlX3RpbWUYISABKAVSDHN0b3BwYWdlVGltZRI3CgpsaXZlX3Nj'
    'b3JlGCIgASgLMhguYXBwLnByb3RvLlNjb3JlUmVzcG9uc2VSCWxpdmVTY29yZRIdCgpjaGlsZF'
    '90eXBlGCMgASgFUgljaGlsZFR5cGU=');

@$core.Deprecated('Use scoreResponseDescriptor instead')
const ScoreResponse$json = {
  '1': 'ScoreResponse',
  '2': [
    {
      '1': 'soccer',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.app.proto.SoccerScoreResponse',
      '9': 0,
      '10': 'soccer'
    },
    {
      '1': 'basketball',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.app.proto.BasketballScoreResponse',
      '9': 0,
      '10': 'basketball'
    },
    {
      '1': 'volleyball',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.app.proto.VolleyballScoreResponse',
      '9': 0,
      '10': 'volleyball'
    },
    {
      '1': 'tennis',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.app.proto.TennisScoreResponse',
      '9': 0,
      '10': 'tennis'
    },
    {
      '1': 'table_tennis',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.app.proto.TableTennisScoreResponse',
      '9': 0,
      '10': 'tableTennis'
    },
    {
      '1': 'badminton',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.app.proto.BadmintonScoreResponse',
      '9': 0,
      '10': 'badminton'
    },
  ],
  '8': [
    {'1': 'data'},
  ],
};

/// Descriptor for `ScoreResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scoreResponseDescriptor = $convert.base64Decode(
    'Cg1TY29yZVJlc3BvbnNlEjgKBnNvY2NlchgBIAEoCzIeLmFwcC5wcm90by5Tb2NjZXJTY29yZV'
    'Jlc3BvbnNlSABSBnNvY2NlchJECgpiYXNrZXRiYWxsGAIgASgLMiIuYXBwLnByb3RvLkJhc2tl'
    'dGJhbGxTY29yZVJlc3BvbnNlSABSCmJhc2tldGJhbGwSRAoKdm9sbGV5YmFsbBgDIAEoCzIiLm'
    'FwcC5wcm90by5Wb2xsZXliYWxsU2NvcmVSZXNwb25zZUgAUgp2b2xsZXliYWxsEjgKBnRlbm5p'
    'cxgEIAEoCzIeLmFwcC5wcm90by5UZW5uaXNTY29yZVJlc3BvbnNlSABSBnRlbm5pcxJICgx0YW'
    'JsZV90ZW5uaXMYBSABKAsyIy5hcHAucHJvdG8uVGFibGVUZW5uaXNTY29yZVJlc3BvbnNlSABS'
    'C3RhYmxlVGVubmlzEkEKCWJhZG1pbnRvbhgGIAEoCzIhLmFwcC5wcm90by5CYWRtaW50b25TY2'
    '9yZVJlc3BvbnNlSABSCWJhZG1pbnRvbkIGCgRkYXRh');

@$core.Deprecated('Use soccerScoreResponseDescriptor instead')
const SoccerScoreResponse$json = {
  '1': 'SoccerScoreResponse',
  '2': [
    {'1': 'home_score', '3': 1, '4': 1, '5': 5, '10': 'homeScore'},
    {'1': 'away_score', '3': 2, '4': 1, '5': 5, '10': 'awayScore'},
    {'1': 'home_score_h2', '3': 3, '4': 1, '5': 5, '10': 'homeScoreH2'},
    {'1': 'away_score_h2', '3': 4, '4': 1, '5': 5, '10': 'awayScoreH2'},
    {'1': 'home_corner', '3': 5, '4': 1, '5': 5, '10': 'homeCorner'},
    {'1': 'away_corner', '3': 6, '4': 1, '5': 5, '10': 'awayCorner'},
    {'1': 'home_score_o_t', '3': 7, '4': 1, '5': 5, '10': 'homeScoreOT'},
    {'1': 'away_score_o_t', '3': 8, '4': 1, '5': 5, '10': 'awayScoreOT'},
    {'1': 'home_score_pen', '3': 9, '4': 1, '5': 5, '10': 'homeScorePen'},
    {'1': 'away_score_pen', '3': 10, '4': 1, '5': 5, '10': 'awayScorePen'},
    {
      '1': 'yellow_cards_home',
      '3': 11,
      '4': 1,
      '5': 5,
      '10': 'yellowCardsHome'
    },
    {
      '1': 'yellow_cards_away',
      '3': 12,
      '4': 1,
      '5': 5,
      '10': 'yellowCardsAway'
    },
    {'1': 'red_cards_home', '3': 13, '4': 1, '5': 5, '10': 'redCardsHome'},
    {'1': 'red_cards_away', '3': 14, '4': 1, '5': 5, '10': 'redCardsAway'},
  ],
};

/// Descriptor for `SoccerScoreResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List soccerScoreResponseDescriptor = $convert.base64Decode(
    'ChNTb2NjZXJTY29yZVJlc3BvbnNlEh0KCmhvbWVfc2NvcmUYASABKAVSCWhvbWVTY29yZRIdCg'
    'phd2F5X3Njb3JlGAIgASgFUglhd2F5U2NvcmUSIgoNaG9tZV9zY29yZV9oMhgDIAEoBVILaG9t'
    'ZVNjb3JlSDISIgoNYXdheV9zY29yZV9oMhgEIAEoBVILYXdheVNjb3JlSDISHwoLaG9tZV9jb3'
    'JuZXIYBSABKAVSCmhvbWVDb3JuZXISHwoLYXdheV9jb3JuZXIYBiABKAVSCmF3YXlDb3JuZXIS'
    'IwoOaG9tZV9zY29yZV9vX3QYByABKAVSC2hvbWVTY29yZU9UEiMKDmF3YXlfc2NvcmVfb190GA'
    'ggASgFUgthd2F5U2NvcmVPVBIkCg5ob21lX3Njb3JlX3BlbhgJIAEoBVIMaG9tZVNjb3JlUGVu'
    'EiQKDmF3YXlfc2NvcmVfcGVuGAogASgFUgxhd2F5U2NvcmVQZW4SKgoReWVsbG93X2NhcmRzX2'
    'hvbWUYCyABKAVSD3llbGxvd0NhcmRzSG9tZRIqChF5ZWxsb3dfY2FyZHNfYXdheRgMIAEoBVIP'
    'eWVsbG93Q2FyZHNBd2F5EiQKDnJlZF9jYXJkc19ob21lGA0gASgFUgxyZWRDYXJkc0hvbWUSJA'
    'oOcmVkX2NhcmRzX2F3YXkYDiABKAVSDHJlZENhcmRzQXdheQ==');

@$core.Deprecated('Use liveScoreDescriptor instead')
const LiveScore$json = {
  '1': 'LiveScore',
  '2': [
    {'1': 'home_score', '3': 1, '4': 1, '5': 9, '10': 'homeScore'},
    {'1': 'away_score', '3': 2, '4': 1, '5': 9, '10': 'awayScore'},
  ],
};

/// Descriptor for `LiveScore`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List liveScoreDescriptor = $convert.base64Decode(
    'CglMaXZlU2NvcmUSHQoKaG9tZV9zY29yZRgBIAEoCVIJaG9tZVNjb3JlEh0KCmF3YXlfc2Nvcm'
    'UYAiABKAlSCWF3YXlTY29yZQ==');

@$core.Deprecated('Use basketballScoreResponseDescriptor instead')
const BasketballScoreResponse$json = {
  '1': 'BasketballScoreResponse',
  '2': [
    {
      '1': 'live_scores',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.LiveScore',
      '10': 'liveScores'
    },
    {'1': 'home_score_f_t', '3': 2, '4': 1, '5': 5, '10': 'homeScoreFT'},
    {'1': 'away_score_f_t', '3': 3, '4': 1, '5': 5, '10': 'awayScoreFT'},
    {'1': 'home_score_o_t', '3': 4, '4': 1, '5': 5, '10': 'homeScoreOT'},
    {'1': 'away_score_o_t', '3': 5, '4': 1, '5': 5, '10': 'awayScoreOT'},
  ],
};

/// Descriptor for `BasketballScoreResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List basketballScoreResponseDescriptor = $convert.base64Decode(
    'ChdCYXNrZXRiYWxsU2NvcmVSZXNwb25zZRI1CgtsaXZlX3Njb3JlcxgBIAMoCzIULmFwcC5wcm'
    '90by5MaXZlU2NvcmVSCmxpdmVTY29yZXMSIwoOaG9tZV9zY29yZV9mX3QYAiABKAVSC2hvbWVT'
    'Y29yZUZUEiMKDmF3YXlfc2NvcmVfZl90GAMgASgFUgthd2F5U2NvcmVGVBIjCg5ob21lX3Njb3'
    'JlX29fdBgEIAEoBVILaG9tZVNjb3JlT1QSIwoOYXdheV9zY29yZV9vX3QYBSABKAVSC2F3YXlT'
    'Y29yZU9U');

@$core.Deprecated('Use volleyballScoreResponseDescriptor instead')
const VolleyballScoreResponse$json = {
  '1': 'VolleyballScoreResponse',
  '2': [
    {
      '1': 'live_scores',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.LiveScore',
      '10': 'liveScores'
    },
    {'1': 'home_set_score', '3': 2, '4': 1, '5': 5, '10': 'homeSetScore'},
    {'1': 'away_set_score', '3': 3, '4': 1, '5': 5, '10': 'awaySetScore'},
    {'1': 'home_total_point', '3': 4, '4': 1, '5': 5, '10': 'homeTotalPoint'},
    {'1': 'away_total_point', '3': 5, '4': 1, '5': 5, '10': 'awayTotalPoint'},
    {'1': 'serving_side', '3': 6, '4': 1, '5': 9, '10': 'servingSide'},
    {'1': 'current_set', '3': 7, '4': 1, '5': 5, '10': 'currentSet'},
    {'1': 'num_of_sets', '3': 8, '4': 1, '5': 9, '10': 'numOfSets'},
  ],
};

/// Descriptor for `VolleyballScoreResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List volleyballScoreResponseDescriptor = $convert.base64Decode(
    'ChdWb2xsZXliYWxsU2NvcmVSZXNwb25zZRI1CgtsaXZlX3Njb3JlcxgBIAMoCzIULmFwcC5wcm'
    '90by5MaXZlU2NvcmVSCmxpdmVTY29yZXMSJAoOaG9tZV9zZXRfc2NvcmUYAiABKAVSDGhvbWVT'
    'ZXRTY29yZRIkCg5hd2F5X3NldF9zY29yZRgDIAEoBVIMYXdheVNldFNjb3JlEigKEGhvbWVfdG'
    '90YWxfcG9pbnQYBCABKAVSDmhvbWVUb3RhbFBvaW50EigKEGF3YXlfdG90YWxfcG9pbnQYBSAB'
    'KAVSDmF3YXlUb3RhbFBvaW50EiEKDHNlcnZpbmdfc2lkZRgGIAEoCVILc2VydmluZ1NpZGUSHw'
    'oLY3VycmVudF9zZXQYByABKAVSCmN1cnJlbnRTZXQSHgoLbnVtX29mX3NldHMYCCABKAlSCW51'
    'bU9mU2V0cw==');

@$core.Deprecated('Use tennisScoreResponseDescriptor instead')
const TennisScoreResponse$json = {
  '1': 'TennisScoreResponse',
  '2': [
    {
      '1': 'live_scores',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.LiveScore',
      '10': 'liveScores'
    },
    {'1': 'home_set_score', '3': 2, '4': 1, '5': 5, '10': 'homeSetScore'},
    {'1': 'away_set_score', '3': 3, '4': 1, '5': 5, '10': 'awaySetScore'},
    {'1': 'home_game_score', '3': 4, '4': 1, '5': 5, '10': 'homeGameScore'},
    {'1': 'away_game_score', '3': 5, '4': 1, '5': 5, '10': 'awayGameScore'},
    {
      '1': 'home_current_point',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'homeCurrentPoint'
    },
    {
      '1': 'away_current_point',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'awayCurrentPoint'
    },
    {'1': 'serving_side', '3': 8, '4': 1, '5': 9, '10': 'servingSide'},
    {'1': 'current_set', '3': 9, '4': 1, '5': 5, '10': 'currentSet'},
    {'1': 'num_of_sets', '3': 10, '4': 1, '5': 9, '10': 'numOfSets'},
  ],
};

/// Descriptor for `TennisScoreResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tennisScoreResponseDescriptor = $convert.base64Decode(
    'ChNUZW5uaXNTY29yZVJlc3BvbnNlEjUKC2xpdmVfc2NvcmVzGAEgAygLMhQuYXBwLnByb3RvLk'
    'xpdmVTY29yZVIKbGl2ZVNjb3JlcxIkCg5ob21lX3NldF9zY29yZRgCIAEoBVIMaG9tZVNldFNj'
    'b3JlEiQKDmF3YXlfc2V0X3Njb3JlGAMgASgFUgxhd2F5U2V0U2NvcmUSJgoPaG9tZV9nYW1lX3'
    'Njb3JlGAQgASgFUg1ob21lR2FtZVNjb3JlEiYKD2F3YXlfZ2FtZV9zY29yZRgFIAEoBVINYXdh'
    'eUdhbWVTY29yZRIsChJob21lX2N1cnJlbnRfcG9pbnQYBiABKAlSEGhvbWVDdXJyZW50UG9pbn'
    'QSLAoSYXdheV9jdXJyZW50X3BvaW50GAcgASgJUhBhd2F5Q3VycmVudFBvaW50EiEKDHNlcnZp'
    'bmdfc2lkZRgIIAEoCVILc2VydmluZ1NpZGUSHwoLY3VycmVudF9zZXQYCSABKAVSCmN1cnJlbn'
    'RTZXQSHgoLbnVtX29mX3NldHMYCiABKAlSCW51bU9mU2V0cw==');

@$core.Deprecated('Use tableTennisScoreResponseDescriptor instead')
const TableTennisScoreResponse$json = {
  '1': 'TableTennisScoreResponse',
  '2': [
    {
      '1': 'live_scores',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.LiveScore',
      '10': 'liveScores'
    },
    {'1': 'home_set_score', '3': 2, '4': 1, '5': 5, '10': 'homeSetScore'},
    {'1': 'away_set_score', '3': 3, '4': 1, '5': 5, '10': 'awaySetScore'},
    {'1': 'home_total_point', '3': 4, '4': 1, '5': 5, '10': 'homeTotalPoint'},
    {'1': 'away_total_point', '3': 5, '4': 1, '5': 5, '10': 'awayTotalPoint'},
    {'1': 'serving_side', '3': 6, '4': 1, '5': 9, '10': 'servingSide'},
    {'1': 'current_set', '3': 7, '4': 1, '5': 5, '10': 'currentSet'},
    {'1': 'num_of_sets', '3': 8, '4': 1, '5': 9, '10': 'numOfSets'},
  ],
};

/// Descriptor for `TableTennisScoreResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tableTennisScoreResponseDescriptor = $convert.base64Decode(
    'ChhUYWJsZVRlbm5pc1Njb3JlUmVzcG9uc2USNQoLbGl2ZV9zY29yZXMYASADKAsyFC5hcHAucH'
    'JvdG8uTGl2ZVNjb3JlUgpsaXZlU2NvcmVzEiQKDmhvbWVfc2V0X3Njb3JlGAIgASgFUgxob21l'
    'U2V0U2NvcmUSJAoOYXdheV9zZXRfc2NvcmUYAyABKAVSDGF3YXlTZXRTY29yZRIoChBob21lX3'
    'RvdGFsX3BvaW50GAQgASgFUg5ob21lVG90YWxQb2ludBIoChBhd2F5X3RvdGFsX3BvaW50GAUg'
    'ASgFUg5hd2F5VG90YWxQb2ludBIhCgxzZXJ2aW5nX3NpZGUYBiABKAlSC3NlcnZpbmdTaWRlEh'
    '8KC2N1cnJlbnRfc2V0GAcgASgFUgpjdXJyZW50U2V0Eh4KC251bV9vZl9zZXRzGAggASgJUglu'
    'dW1PZlNldHM=');

@$core.Deprecated('Use badmintonScoreResponseDescriptor instead')
const BadmintonScoreResponse$json = {
  '1': 'BadmintonScoreResponse',
  '2': [
    {
      '1': 'live_scores',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.LiveScore',
      '10': 'liveScores'
    },
    {'1': 'home_set_score', '3': 2, '4': 1, '5': 5, '10': 'homeSetScore'},
    {'1': 'away_set_score', '3': 3, '4': 1, '5': 5, '10': 'awaySetScore'},
    {'1': 'home_total_point', '3': 4, '4': 1, '5': 5, '10': 'homeTotalPoint'},
    {'1': 'away_total_point', '3': 5, '4': 1, '5': 5, '10': 'awayTotalPoint'},
    {'1': 'serving_side', '3': 6, '4': 1, '5': 9, '10': 'servingSide'},
    {'1': 'current_set', '3': 7, '4': 1, '5': 5, '10': 'currentSet'},
    {'1': 'num_of_sets', '3': 8, '4': 1, '5': 9, '10': 'numOfSets'},
  ],
};

/// Descriptor for `BadmintonScoreResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List badmintonScoreResponseDescriptor = $convert.base64Decode(
    'ChZCYWRtaW50b25TY29yZVJlc3BvbnNlEjUKC2xpdmVfc2NvcmVzGAEgAygLMhQuYXBwLnByb3'
    'RvLkxpdmVTY29yZVIKbGl2ZVNjb3JlcxIkCg5ob21lX3NldF9zY29yZRgCIAEoBVIMaG9tZVNl'
    'dFNjb3JlEiQKDmF3YXlfc2V0X3Njb3JlGAMgASgFUgxhd2F5U2V0U2NvcmUSKAoQaG9tZV90b3'
    'RhbF9wb2ludBgEIAEoBVIOaG9tZVRvdGFsUG9pbnQSKAoQYXdheV90b3RhbF9wb2ludBgFIAEo'
    'BVIOYXdheVRvdGFsUG9pbnQSIQoMc2VydmluZ19zaWRlGAYgASgJUgtzZXJ2aW5nU2lkZRIfCg'
    'tjdXJyZW50X3NldBgHIAEoBVIKY3VycmVudFNldBIeCgtudW1fb2Zfc2V0cxgIIAEoCVIJbnVt'
    'T2ZTZXRz');

@$core.Deprecated('Use marketResponseDescriptor instead')
const MarketResponse$json = {
  '1': 'MarketResponse',
  '2': [
    {
      '1': 'oddsList',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.OddsResponse',
      '10': 'oddsList'
    },
    {'1': 'sport_id', '3': 2, '4': 1, '5': 5, '10': 'sportId'},
    {'1': 'league_id', '3': 3, '4': 1, '5': 5, '10': 'leagueId'},
    {'1': 'event_id', '3': 4, '4': 1, '5': 3, '10': 'eventId'},
    {'1': 'market_id', '3': 5, '4': 1, '5': 5, '10': 'marketId'},
    {'1': 'is_suspended', '3': 6, '4': 1, '5': 8, '10': 'isSuspended'},
    {'1': 'is_parlay', '3': 7, '4': 1, '5': 8, '10': 'isParlay'},
    {'1': 'is_cash_out', '3': 8, '4': 1, '5': 8, '10': 'isCashOut'},
    {'1': 'promotion_type', '3': 9, '4': 1, '5': 5, '10': 'promotionType'},
    {'1': 'group_id', '3': 10, '4': 1, '5': 5, '10': 'groupId'},
  ],
};

/// Descriptor for `MarketResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketResponseDescriptor = $convert.base64Decode(
    'Cg5NYXJrZXRSZXNwb25zZRIzCghvZGRzTGlzdBgBIAMoCzIXLmFwcC5wcm90by5PZGRzUmVzcG'
    '9uc2VSCG9kZHNMaXN0EhkKCHNwb3J0X2lkGAIgASgFUgdzcG9ydElkEhsKCWxlYWd1ZV9pZBgD'
    'IAEoBVIIbGVhZ3VlSWQSGQoIZXZlbnRfaWQYBCABKANSB2V2ZW50SWQSGwoJbWFya2V0X2lkGA'
    'UgASgFUghtYXJrZXRJZBIhCgxpc19zdXNwZW5kZWQYBiABKAhSC2lzU3VzcGVuZGVkEhsKCWlz'
    'X3BhcmxheRgHIAEoCFIIaXNQYXJsYXkSHgoLaXNfY2FzaF9vdXQYCCABKAhSCWlzQ2FzaE91dB'
    'IlCg5wcm9tb3Rpb25fdHlwZRgJIAEoBVINcHJvbW90aW9uVHlwZRIZCghncm91cF9pZBgKIAEo'
    'BVIHZ3JvdXBJZA==');

@$core.Deprecated('Use oddsResponseDescriptor instead')
const OddsResponse$json = {
  '1': 'OddsResponse',
  '2': [
    {'1': 'selection_home_id', '3': 1, '4': 1, '5': 9, '10': 'selectionHomeId'},
    {'1': 'selection_away_id', '3': 2, '4': 1, '5': 9, '10': 'selectionAwayId'},
    {'1': 'selection_draw_id', '3': 3, '4': 1, '5': 9, '10': 'selectionDrawId'},
    {'1': 'points', '3': 4, '4': 1, '5': 9, '10': 'points'},
    {
      '1': 'odds_home',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.app.proto.OddsStyleResponse',
      '10': 'oddsHome'
    },
    {
      '1': 'odds_away',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.app.proto.OddsStyleResponse',
      '10': 'oddsAway'
    },
    {
      '1': 'odds_draw',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.app.proto.OddsStyleResponse',
      '10': 'oddsDraw'
    },
    {'1': 'str_offer_id', '3': 8, '4': 1, '5': 9, '10': 'strOfferId'},
    {'1': 'is_main_line', '3': 9, '4': 1, '5': 8, '10': 'isMainLine'},
    {'1': 'is_suspended', '3': 10, '4': 1, '5': 8, '10': 'isSuspended'},
    {'1': 'is_hidden', '3': 11, '4': 1, '5': 8, '10': 'isHidden'},
  ],
};

/// Descriptor for `OddsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List oddsResponseDescriptor = $convert.base64Decode(
    'CgxPZGRzUmVzcG9uc2USKgoRc2VsZWN0aW9uX2hvbWVfaWQYASABKAlSD3NlbGVjdGlvbkhvbW'
    'VJZBIqChFzZWxlY3Rpb25fYXdheV9pZBgCIAEoCVIPc2VsZWN0aW9uQXdheUlkEioKEXNlbGVj'
    'dGlvbl9kcmF3X2lkGAMgASgJUg9zZWxlY3Rpb25EcmF3SWQSFgoGcG9pbnRzGAQgASgJUgZwb2'
    'ludHMSOQoJb2Rkc19ob21lGAUgASgLMhwuYXBwLnByb3RvLk9kZHNTdHlsZVJlc3BvbnNlUghv'
    'ZGRzSG9tZRI5CglvZGRzX2F3YXkYBiABKAsyHC5hcHAucHJvdG8uT2Rkc1N0eWxlUmVzcG9uc2'
    'VSCG9kZHNBd2F5EjkKCW9kZHNfZHJhdxgHIAEoCzIcLmFwcC5wcm90by5PZGRzU3R5bGVSZXNw'
    'b25zZVIIb2Rkc0RyYXcSIAoMc3RyX29mZmVyX2lkGAggASgJUgpzdHJPZmZlcklkEiAKDGlzX2'
    '1haW5fbGluZRgJIAEoCFIKaXNNYWluTGluZRIhCgxpc19zdXNwZW5kZWQYCiABKAhSC2lzU3Vz'
    'cGVuZGVkEhsKCWlzX2hpZGRlbhgLIAEoCFIIaXNIaWRkZW4=');

@$core.Deprecated('Use oddsStyleResponseDescriptor instead')
const OddsStyleResponse$json = {
  '1': 'OddsStyleResponse',
  '2': [
    {'1': 'decimal', '3': 1, '4': 1, '5': 9, '10': 'decimal'},
    {'1': 'malay', '3': 2, '4': 1, '5': 9, '10': 'malay'},
    {'1': 'indo', '3': 3, '4': 1, '5': 9, '10': 'indo'},
    {'1': 'hk', '3': 4, '4': 1, '5': 9, '10': 'hk'},
  ],
};

/// Descriptor for `OddsStyleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List oddsStyleResponseDescriptor = $convert.base64Decode(
    'ChFPZGRzU3R5bGVSZXNwb25zZRIYCgdkZWNpbWFsGAEgASgJUgdkZWNpbWFsEhQKBW1hbGF5GA'
    'IgASgJUgVtYWxheRISCgRpbmRvGAMgASgJUgRpbmRvEg4KAmhrGAQgASgJUgJoaw==');

@$core.Deprecated('Use outrightOddsResponseDescriptor instead')
const OutrightOddsResponse$json = {
  '1': 'OutrightOddsResponse',
  '2': [
    {'1': 'selection_id', '3': 1, '4': 1, '5': 9, '10': 'selectionId'},
    {'1': 'selection_name', '3': 2, '4': 1, '5': 9, '10': 'selectionName'},
    {'1': 'selection_logo', '3': 3, '4': 1, '5': 9, '10': 'selectionLogo'},
    {'1': 'offer_id', '3': 4, '4': 1, '5': 9, '10': 'offerId'},
    {'1': 'odds', '3': 5, '4': 1, '5': 1, '10': 'odds'},
    {'1': 'cls', '3': 6, '4': 1, '5': 9, '10': 'cls'},
    {'1': 'is_suspended', '3': 7, '4': 1, '5': 8, '10': 'isSuspended'},
  ],
};

/// Descriptor for `OutrightOddsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outrightOddsResponseDescriptor = $convert.base64Decode(
    'ChRPdXRyaWdodE9kZHNSZXNwb25zZRIhCgxzZWxlY3Rpb25faWQYASABKAlSC3NlbGVjdGlvbk'
    'lkEiUKDnNlbGVjdGlvbl9uYW1lGAIgASgJUg1zZWxlY3Rpb25OYW1lEiUKDnNlbGVjdGlvbl9s'
    'b2dvGAMgASgJUg1zZWxlY3Rpb25Mb2dvEhkKCG9mZmVyX2lkGAQgASgJUgdvZmZlcklkEhIKBG'
    '9kZHMYBSABKAFSBG9kZHMSEAoDY2xzGAYgASgJUgNjbHMSIQoMaXNfc3VzcGVuZGVkGAcgASgI'
    'Ugtpc1N1c3BlbmRlZA==');

@$core.Deprecated('Use outrightEventResponseDescriptor instead')
const OutrightEventResponse$json = {
  '1': 'OutrightEventResponse',
  '2': [
    {
      '1': 'odds_list',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.OutrightOddsResponse',
      '10': 'oddsList'
    },
    {'1': 'event_id', '3': 2, '4': 1, '5': 3, '10': 'eventId'},
    {'1': 'event_name', '3': 3, '4': 1, '5': 9, '10': 'eventName'},
    {'1': 'is_suspended', '3': 4, '4': 1, '5': 8, '10': 'isSuspended'},
    {'1': 'end_date', '3': 5, '4': 1, '5': 9, '10': 'endDate'},
    {'1': 'end_time', '3': 6, '4': 1, '5': 3, '10': 'endTime'},
    {'1': 'league_id', '3': 7, '4': 1, '5': 5, '10': 'leagueId'},
    {'1': 'league_logo', '3': 8, '4': 1, '5': 9, '10': 'leagueLogo'},
    {'1': 'league_name', '3': 9, '4': 1, '5': 9, '10': 'leagueName'},
    {'1': 'league_name_en', '3': 10, '4': 1, '5': 9, '10': 'leagueNameEn'},
    {'1': 'league_order', '3': 11, '4': 1, '5': 5, '10': 'leagueOrder'},
    {
      '1': 'league_priority_order',
      '3': 12,
      '4': 1,
      '5': 5,
      '10': 'leaguePriorityOrder'
    },
    {'1': 'sport_id', '3': 13, '4': 1, '5': 5, '10': 'sportId'},
  ],
};

/// Descriptor for `OutrightEventResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outrightEventResponseDescriptor = $convert.base64Decode(
    'ChVPdXRyaWdodEV2ZW50UmVzcG9uc2USPAoJb2Rkc19saXN0GAEgAygLMh8uYXBwLnByb3RvLk'
    '91dHJpZ2h0T2Rkc1Jlc3BvbnNlUghvZGRzTGlzdBIZCghldmVudF9pZBgCIAEoA1IHZXZlbnRJ'
    'ZBIdCgpldmVudF9uYW1lGAMgASgJUglldmVudE5hbWUSIQoMaXNfc3VzcGVuZGVkGAQgASgIUg'
    'tpc1N1c3BlbmRlZBIZCghlbmRfZGF0ZRgFIAEoCVIHZW5kRGF0ZRIZCghlbmRfdGltZRgGIAEo'
    'A1IHZW5kVGltZRIbCglsZWFndWVfaWQYByABKAVSCGxlYWd1ZUlkEh8KC2xlYWd1ZV9sb2dvGA'
    'ggASgJUgpsZWFndWVMb2dvEh8KC2xlYWd1ZV9uYW1lGAkgASgJUgpsZWFndWVOYW1lEiQKDmxl'
    'YWd1ZV9uYW1lX2VuGAogASgJUgxsZWFndWVOYW1lRW4SIQoMbGVhZ3VlX29yZGVyGAsgASgFUg'
    'tsZWFndWVPcmRlchIyChVsZWFndWVfcHJpb3JpdHlfb3JkZXIYDCABKAVSE2xlYWd1ZVByaW9y'
    'aXR5T3JkZXISGQoIc3BvcnRfaWQYDSABKAVSB3Nwb3J0SWQ=');

@$core.Deprecated('Use betSlipStatusResponseDescriptor instead')
const BetSlipStatusResponse$json = {
  '1': 'BetSlipStatusResponse',
  '2': [
    {'1': 'ticket_id', '3': 1, '4': 1, '5': 9, '10': 'ticketId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `BetSlipStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List betSlipStatusResponseDescriptor = $convert.base64Decode(
    'ChVCZXRTbGlwU3RhdHVzUmVzcG9uc2USGwoJdGlja2V0X2lkGAEgASgJUgh0aWNrZXRJZBIWCg'
    'ZzdGF0dXMYAiABKAlSBnN0YXR1cw==');

@$core.Deprecated('Use hotEventsResponseDescriptor instead')
const HotEventsResponse$json = {
  '1': 'HotEventsResponse',
  '2': [
    {
      '1': 'events',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.app.proto.HotEventResponse',
      '10': 'events'
    },
  ],
};

/// Descriptor for `HotEventsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hotEventsResponseDescriptor = $convert.base64Decode(
    'ChFIb3RFdmVudHNSZXNwb25zZRIzCgZldmVudHMYASADKAsyGy5hcHAucHJvdG8uSG90RXZlbn'
    'RSZXNwb25zZVIGZXZlbnRz');

@$core.Deprecated('Use hotEventResponseDescriptor instead')
const HotEventResponse$json = {
  '1': 'HotEventResponse',
  '2': [
    {
      '1': 'event',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.app.proto.EventResponse',
      '10': 'event'
    },
    {'1': 'league_id', '3': 2, '4': 1, '5': 5, '10': 'leagueId'},
    {'1': 'league_name', '3': 3, '4': 1, '5': 9, '10': 'leagueName'},
    {'1': 'league_order', '3': 4, '4': 1, '5': 5, '10': 'leagueOrder'},
    {
      '1': 'league_priority_order',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'leaguePriorityOrder'
    },
    {'1': 'league_logo', '3': 6, '4': 1, '5': 9, '10': 'leagueLogo'},
  ],
};

/// Descriptor for `HotEventResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hotEventResponseDescriptor = $convert.base64Decode(
    'ChBIb3RFdmVudFJlc3BvbnNlEi4KBWV2ZW50GAEgASgLMhguYXBwLnByb3RvLkV2ZW50UmVzcG'
    '9uc2VSBWV2ZW50EhsKCWxlYWd1ZV9pZBgCIAEoBVIIbGVhZ3VlSWQSHwoLbGVhZ3VlX25hbWUY'
    'AyABKAlSCmxlYWd1ZU5hbWUSIQoMbGVhZ3VlX29yZGVyGAQgASgFUgtsZWFndWVPcmRlchIyCh'
    'VsZWFndWVfcHJpb3JpdHlfb3JkZXIYBSABKAVSE2xlYWd1ZVByaW9yaXR5T3JkZXISHwoLbGVh'
    'Z3VlX2xvZ28YBiABKAlSCmxlYWd1ZUxvZ28=');
