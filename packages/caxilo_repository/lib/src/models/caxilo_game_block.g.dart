// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caxilo_game_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaxiloGameBlockLiveStream _$CaxiloGameBlockLiveStreamFromJson(
  Map<String, dynamic> json,
) => CaxiloGameBlockLiveStream(
  providerId: json['providerId'] as String,
  providerName: json['providerName'] as String,
  image: json['image'] as String,
  productId: json['productId'] as String,
  gameCode: json['gameCode'] as String,
  gameName: json['gameName'] as String,
  lang: json['lang'] as String,
  gameType: GameType.fromJson(json['gameType']),
  lobbyUrl: json['lobbyUrl'] as String,
  cashierUrl: json['cashierUrl'] as String,
  mobileLogin: json['mobileLogin'] as bool? ?? false,
  mobileOrientation: json['mobileOrientation'] == null
      ? caxiloconfig.GameOrientation.portrait
      : const GameOrientationListConverter().fromJson(
          json['mobileOrientation'] as List?,
        ),
  tabletOrientation: json['tabletOrientation'] == null
      ? caxiloconfig.GameOrientation.landscape
      : const GameOrientationListConverter().fromJson(
          json['tabletOrientation'] as List?,
        ),
  desktopOrientation: json['desktopOrientation'] == null
      ? caxiloconfig.GameOrientation.all
      : const GameOrientationListConverter().fromJson(
          json['desktopOrientation'] as List?,
        ),
  loadStopDebounce: json['loadStopDebounce'] == null
      ? null
      : Duration(microseconds: (json['loadStopDebounce'] as num).toInt()),
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 999,
  forceLandscapeViewportOnIpad:
      json['forceLandscapeViewportOnIpad'] as bool? ?? false,
  openInNewTabOnIOSSafariWeb:
      json['openInNewTabOnIOSSafariWeb'] as bool? ?? false,
  requiresSessionGuard: json['requiresSessionGuard'] as bool? ?? false,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CaxiloGameBlockLiveStreamToJson(
  CaxiloGameBlockLiveStream instance,
) => <String, dynamic>{
  'providerId': instance.providerId,
  'providerName': instance.providerName,
  'image': instance.image,
  'productId': instance.productId,
  'gameCode': instance.gameCode,
  'gameName': instance.gameName,
  'lang': instance.lang,
  'gameType': GameType.staticToJson(instance.gameType),
  'lobbyUrl': instance.lobbyUrl,
  'cashierUrl': instance.cashierUrl,
  'mobileLogin': instance.mobileLogin,
  'mobileOrientation': const GameOrientationListConverter().toJson(
    instance.mobileOrientation,
  ),
  'tabletOrientation': const GameOrientationListConverter().toJson(
    instance.tabletOrientation,
  ),
  'desktopOrientation': const GameOrientationListConverter().toJson(
    instance.desktopOrientation,
  ),
  'loadStopDebounce': instance.loadStopDebounce?.inMicroseconds,
  'sortOrder': instance.sortOrder,
  'forceLandscapeViewportOnIpad': instance.forceLandscapeViewportOnIpad,
  'openInNewTabOnIOSSafariWeb': instance.openInNewTabOnIOSSafariWeb,
  'requiresSessionGuard': instance.requiresSessionGuard,
  'runtimeType': instance.$type,
};

CaxiloGameBlockInHouse _$CaxiloGameBlockInHouseFromJson(
  Map<String, dynamic> json,
) => CaxiloGameBlockInHouse(
  providerId: json['providerId'] as String,
  providerName: json['providerName'] as String,
  image: json['image'] as String,
  productId: json['productId'] as String,
  gameCode: json['gameCode'] as String,
  gameName: json['gameName'] as String,
  lang: json['lang'] as String,
  gameType: GameType.fromJson(json['gameType']),
  mobileOrientation: json['mobileOrientation'] == null
      ? caxiloconfig.GameOrientation.portrait
      : const GameOrientationListConverter().fromJson(
          json['mobileOrientation'] as List?,
        ),
  tabletOrientation: json['tabletOrientation'] == null
      ? caxiloconfig.GameOrientation.all
      : const GameOrientationListConverter().fromJson(
          json['tabletOrientation'] as List?,
        ),
  desktopOrientation: json['desktopOrientation'] == null
      ? caxiloconfig.GameOrientation.all
      : const GameOrientationListConverter().fromJson(
          json['desktopOrientation'] as List?,
        ),
  loadStopDebounce: json['loadStopDebounce'] == null
      ? null
      : Duration(microseconds: (json['loadStopDebounce'] as num).toInt()),
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 999,
  enableHostMessage: json['enableHostMessage'] as bool? ?? false,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CaxiloGameBlockInHouseToJson(
  CaxiloGameBlockInHouse instance,
) => <String, dynamic>{
  'providerId': instance.providerId,
  'providerName': instance.providerName,
  'image': instance.image,
  'productId': instance.productId,
  'gameCode': instance.gameCode,
  'gameName': instance.gameName,
  'lang': instance.lang,
  'gameType': GameType.staticToJson(instance.gameType),
  'mobileOrientation': const GameOrientationListConverter().toJson(
    instance.mobileOrientation,
  ),
  'tabletOrientation': const GameOrientationListConverter().toJson(
    instance.tabletOrientation,
  ),
  'desktopOrientation': const GameOrientationListConverter().toJson(
    instance.desktopOrientation,
  ),
  'loadStopDebounce': instance.loadStopDebounce?.inMicroseconds,
  'sortOrder': instance.sortOrder,
  'enableHostMessage': instance.enableHostMessage,
  'runtimeType': instance.$type,
};
