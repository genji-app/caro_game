import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_history_model.freezed.dart';
part 'play_history_model.g.dart';

@freezed
sealed class PlayHistoryResponse with _$PlayHistoryResponse {
  const factory PlayHistoryResponse({
    @Default(0) int count,
    @Default([]) List<PlayHistoryItem> items,
  }) = _PlayHistoryResponse;

  factory PlayHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$PlayHistoryResponseFromJson(json);
}

@freezed
sealed class PlayHistoryItem with _$PlayHistoryItem {
  const factory PlayHistoryItem({
    @Default(0) int activityType,
    @Default(0) int createdTime,
    @Default('') String serviceName,
    @Default('') String description,
    @Default(0.0) num closingValue,
    @Default(0.0) num exchangeValue,
  }) = _PlayHistoryItem;

  factory PlayHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$PlayHistoryItemFromJson(json);
}
