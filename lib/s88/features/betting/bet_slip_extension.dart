import 'package:co_caro_flame/s88/core/services/repositories/my_bet_repository/my_bet_repository.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

extension BetSlipX on BetSlip {
  OddsStyle get oddsStyleEnum {
    return switch (oddsStyle.toLowerCase()) {
      'ma' || 'malay' || 'my' => OddsStyle.malay,
      'indo' || 'id' => OddsStyle.indo,
      'hk' || 'hongkong' => OddsStyle.hongKong,
      'de' => OddsStyle.decimal,
      _ => OddsStyle.decimal,
    };
  }
}
