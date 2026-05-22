// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExternalProviderConfig _$ExternalProviderConfigFromJson(
  Map<String, dynamic> json,
) => _ExternalProviderConfig(
  gameType: $enumDecodeNullable(_$GameTypeEnumMap, json['game_type']),
  mobileOrientation: const GameOrientationListConverter().fromJson(
    json['mobile_orientation'] as List?,
  ),
  tabletOrientation: const GameOrientationListConverter().fromJson(
    json['tablet_orientation'] as List?,
  ),
  desktopOrientation: const GameOrientationListConverter().fromJson(
    json['desktop_orientation'] as List?,
  ),
  forceLandscapeViewportOnIpad:
      json['force_landscape_viewport_on_ipad'] as bool?,
  openInNewTabOnIOSSafariWeb:
      json['open_in_new_tab_on_ios_safari_web'] as bool?,
  requiresSessionGuard: json['requires_session_guard'] as bool?,
  loadStopDebounceMs: (json['load_stop_debounce_ms'] as num?)?.toInt(),
  games:
      (json['games'] as List<dynamic>?)
          ?.map((e) => ExternalGame.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ExternalProviderConfigToJson(
  _ExternalProviderConfig instance,
) => <String, dynamic>{
  'game_type': instance.gameType?.toJson(),
  'mobile_orientation':
      _$JsonConverterToJson<List<dynamic>?, List<GameOrientation>>(
        instance.mobileOrientation,
        const GameOrientationListConverter().toJson,
      ),
  'tablet_orientation':
      _$JsonConverterToJson<List<dynamic>?, List<GameOrientation>>(
        instance.tabletOrientation,
        const GameOrientationListConverter().toJson,
      ),
  'desktop_orientation':
      _$JsonConverterToJson<List<dynamic>?, List<GameOrientation>>(
        instance.desktopOrientation,
        const GameOrientationListConverter().toJson,
      ),
  'force_landscape_viewport_on_ipad': instance.forceLandscapeViewportOnIpad,
  'open_in_new_tab_on_ios_safari_web': instance.openInNewTabOnIOSSafariWeb,
  'requires_session_guard': instance.requiresSessionGuard,
  'load_stop_debounce_ms': instance.loadStopDebounceMs,
  'games': instance.games.map((e) => e.toJson()).toList(),
};

const _$GameTypeEnumMap = {
  GameType.slot: 'slot',
  GameType.sport: 'sport',
  GameType.jackpot: 'jackpot',
  GameType.card: 'card',
  GameType.dice: 'dice',
  GameType.live: 'live',
  GameType.lottery: 'lottery',
  GameType.miniGame: 'miniGame',
  GameType.fishing: 'fish',
  GameType.others: 'others',
  GameType.unknown: 'unknown',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_ExternalConfig _$ExternalConfigFromJson(Map<String, dynamic> json) =>
    _ExternalConfig(
      testMode: json['test_mode'] as bool? ?? false,
      providerConfigs:
          (json['provider_configs'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              ExternalProviderConfig.fromJson(e as Map<String, dynamic>),
            ),
          ) ??
          const {},
    );

Map<String, dynamic> _$ExternalConfigToJson(_ExternalConfig instance) =>
    <String, dynamic>{
      'test_mode': instance.testMode,
      'provider_configs': instance.providerConfigs.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
    };
