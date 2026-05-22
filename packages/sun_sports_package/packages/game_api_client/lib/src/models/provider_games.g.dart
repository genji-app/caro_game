// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_games.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProviderGames _$ProviderGamesFromJson(Map<String, dynamic> json) =>
    _ProviderGames(
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      gameList: (json['gameList'] as List<dynamic>?)
              ?.map((e) => Game.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProviderGamesToJson(_ProviderGames instance) =>
    <String, dynamic>{
      'providerId': instance.providerId,
      'providerName': instance.providerName,
      'gameList': instance.gameList,
    };

_Game _$GameFromJson(Map<String, dynamic> json) => _Game(
      productId: json['productId'] as String,
      gameCode: json['gameCode'] as String,
      gameName: json['gameName'] as String,
      lang: json['lang'] as String,
      lobbyUrl: json['lobbyUrl'] as String,
      cashierUrl: json['cashierUrl'] as String,
      gameType: GameType.fromJson((json['gameType'] as num).toInt()),
      mobileLogin: json['mobileLogin'] as bool? ?? false,
    );

Map<String, dynamic> _$GameToJson(_Game instance) => <String, dynamic>{
      'productId': instance.productId,
      'gameCode': instance.gameCode,
      'gameName': instance.gameName,
      'lang': instance.lang,
      'lobbyUrl': instance.lobbyUrl,
      'cashierUrl': instance.cashierUrl,
      'gameType': GameType.toJson(instance.gameType),
      'mobileLogin': instance.mobileLogin,
    };
