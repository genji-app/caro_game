// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_house_game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InHouseGame _$InHouseGameFromJson(Map<String, dynamic> json) => _InHouseGame(
  productId: json['product_id'] as String,
  gameCode: json['game_code'] as String,
  gameName: json['game_name'] as String,
  providerId: json['provider_id'] as String,
  providerName: json['provider_name'] as String,
  image: json['image'] as String,
  lang: json['lang'] as String,
  gameType: $enumDecode(_$GameTypeEnumMap, json['game_type']),
  launchStrategy: $enumDecode(_$GameLaunchStrategyEnumMap, json['launch_strategy']),
  baseUrlKey: json['base_url_key'] as String?,
  mobileOrientation: json['mobile_orientation'] == null
      ? GameOrientation.landscape
      : const GameOrientationListConverter().fromJson(json['mobile_orientation'] as List?),
  tabletOrientation: json['tablet_orientation'] == null
      ? GameOrientation.landscape
      : const GameOrientationListConverter().fromJson(json['tablet_orientation'] as List?),
  desktopOrientation: json['desktop_orientation'] == null
      ? GameOrientation.landscape
      : const GameOrientationListConverter().fromJson(json['desktop_orientation'] as List?),
  enableHostMessage: json['enable_host_message'] as bool? ?? true,
  gameId: (json['game_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$InHouseGameToJson(_InHouseGame instance) => <String, dynamic>{
  'product_id': instance.productId,
  'game_code': instance.gameCode,
  'game_name': instance.gameName,
  'provider_id': instance.providerId,
  'provider_name': instance.providerName,
  'image': instance.image,
  'lang': instance.lang,
  'game_type': instance.gameType.toJson(),
  'launch_strategy': instance.launchStrategy.toJson(),
  'base_url_key': instance.baseUrlKey,
  'mobile_orientation': const GameOrientationListConverter().toJson(instance.mobileOrientation),
  'tablet_orientation': const GameOrientationListConverter().toJson(instance.tabletOrientation),
  'desktop_orientation': const GameOrientationListConverter().toJson(instance.desktopOrientation),
  'enable_host_message': instance.enableHostMessage,
  'game_id': instance.gameId,
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

const _$GameLaunchStrategyEnumMap = {
  GameLaunchStrategy.standard: 'standard',
  GameLaunchStrategy.fish: 'fish',
  GameLaunchStrategy.underDevelopment: 'underDevelopment',
  GameLaunchStrategy.unknown: 'unknown',
};
