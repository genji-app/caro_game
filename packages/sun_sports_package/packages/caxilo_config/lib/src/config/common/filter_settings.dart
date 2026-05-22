import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter_settings.freezed.dart';
part 'filter_settings.g.dart';

@JsonEnum(alwaysCreate: true)
// Formerly CasinoFilterStrategy.
enum CaxiloFilterStrategy {
  @JsonValue('collection')
  collection,
  @JsonValue('by_game_codes')
  byGameCodes,
  @JsonValue('by_game_type')
  byGameType,
  @JsonValue('by_provider')
  byProvider,
  @JsonValue('in_house')
  inHouse,
  @JsonValue('unknown')
  unknown;

  static CaxiloFilterStrategy fromJson(String? value) {
    return CaxiloFilterStrategy.values.firstWhere(
      (e) => e.name == value || _jsonValue(e) == value,
      orElse: () => CaxiloFilterStrategy.unknown,
    );
  }

  static String? _jsonValue(CaxiloFilterStrategy strategy) {
    switch (strategy) {
      case CaxiloFilterStrategy.collection:
        return 'collection';
      case CaxiloFilterStrategy.byGameCodes:
        return 'by_game_codes';
      case CaxiloFilterStrategy.byGameType:
        return 'by_game_type';
      case CaxiloFilterStrategy.byProvider:
        return 'by_provider';
      case CaxiloFilterStrategy.inHouse:
        return 'in_house';
      default:
        return null;
    }
  }

  String toJson() => _jsonValue(this) ?? name;
}

@freezed
// Formerly CasinoFilter.
abstract class CaxiloFilter with _$CaxiloFilter {
  const factory CaxiloFilter({
    @JsonKey(fromJson: CaxiloFilterStrategy.fromJson, toJson: _strategyToJson)
    required CaxiloFilterStrategy strategy,
    Map<String, dynamic>? params,
  }) = _CaxiloFilter;

  factory CaxiloFilter.fromJson(Map<String, dynamic> json) => _$CaxiloFilterFromJson(json);
}

String _strategyToJson(CaxiloFilterStrategy strategy) => strategy.toJson();
