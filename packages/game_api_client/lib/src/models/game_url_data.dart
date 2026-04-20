import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_url_data.freezed.dart';
part 'game_url_data.g.dart';

/// Data model for /get-url endpoint response
@freezed
sealed class GameUrlData with _$GameUrlData {
  const factory GameUrlData({required String url}) = _GameUrlData;

  factory GameUrlData.fromJson(Map<String, dynamic> json) => _$GameUrlDataFromJson(json);
}
