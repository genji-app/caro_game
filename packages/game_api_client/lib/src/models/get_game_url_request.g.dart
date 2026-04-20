// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_game_url_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GetGameUrlRequest _$GetGameUrlRequestFromJson(Map<String, dynamic> json) =>
    _GetGameUrlRequest(
      providerId: json['providerId'] as String,
      productId: json['productId'] as String,
      gameCode: json['gameCode'] as String,
      lang: json['lang'] as String?,
      isMobileLogin: json['isMobileLogin'] as bool?,
    );

Map<String, dynamic> _$GetGameUrlRequestToJson(_GetGameUrlRequest instance) =>
    <String, dynamic>{
      'providerId': instance.providerId,
      'productId': instance.productId,
      'gameCode': instance.gameCode,
      'lang': instance.lang,
      'isMobileLogin': instance.isMobileLogin,
    };
