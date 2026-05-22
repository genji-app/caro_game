// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayHistoryResponse _$PlayHistoryResponseFromJson(Map<String, dynamic> json) =>
    _PlayHistoryResponse(
      count: (json['count'] as num?)?.toInt() ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => PlayHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PlayHistoryResponseToJson(
  _PlayHistoryResponse instance,
) => <String, dynamic>{
  'count': instance.count,
  'items': instance.items.map((e) => e.toJson()).toList(),
};

_PlayHistoryItem _$PlayHistoryItemFromJson(Map<String, dynamic> json) =>
    _PlayHistoryItem(
      activityType: (json['activityType'] as num?)?.toInt() ?? 0,
      createdTime: (json['createdTime'] as num?)?.toInt() ?? 0,
      serviceName: json['serviceName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      closingValue: json['closingValue'] as num? ?? 0.0,
      exchangeValue: json['exchangeValue'] as num? ?? 0.0,
    );

Map<String, dynamic> _$PlayHistoryItemToJson(_PlayHistoryItem instance) =>
    <String, dynamic>{
      'activityType': instance.activityType,
      'createdTime': instance.createdTime,
      'serviceName': instance.serviceName,
      'description': instance.description,
      'closingValue': instance.closingValue,
      'exchangeValue': instance.exchangeValue,
    };
