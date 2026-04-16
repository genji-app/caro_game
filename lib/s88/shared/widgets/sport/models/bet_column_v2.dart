import 'package:co_caro_flame/s88/core/services/models/api_v2/market_model_v2.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/odds_model_v2.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

export 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart'
    show BetColumnType, BetColumnTypeX, OddsChangeDirection;

/// Bet item for V2 models
class BetItemV2 {
  final String? label;
  final String? value;

  /// SelectionId để track thay đổi odds từ WebSocket
  final String? selectionId;

  /// Odds data - V2 model
  final OddsModelV2? oddsData;

  /// Market data - V2 model
  final MarketModelV2? marketData;

  /// Odds type - home/away/draw
  final OddsType? oddsType;

  const BetItemV2({
    this.label,
    this.value,
    this.selectionId,
    this.oddsData,
    this.marketData,
    this.oddsType,
  });
}

/// Bet column for V2 models
class BetColumnV2 {
  final BetColumnType type;
  final List<BetItemV2> items;

  const BetColumnV2({required this.type, this.items = const []});

  String get title => type.title;
}
