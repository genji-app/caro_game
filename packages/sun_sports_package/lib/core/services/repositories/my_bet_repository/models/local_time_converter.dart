import 'package:freezed_annotation/freezed_annotation.dart';

class LocalTimeConverter implements JsonConverter<DateTime, String> {
  const LocalTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json).toLocal();

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}
