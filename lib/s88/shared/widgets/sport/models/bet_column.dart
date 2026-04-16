import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart';
import 'package:co_caro_flame/s88/shared/domain/enums/league_enums.dart';

export 'package:co_caro_flame/s88/shared/domain/enums/betting_enums.dart'
    show BetColumnType, BetColumnTypeX, OddsChangeDirection;

class BetItem {
  final String? label;
  final String? value;

  /// SelectionId để track thay đổi odds từ WebSocket
  final String? selectionId;

  /// Odds data - needed for betting popup
  final LeagueOddsData? oddsData;

  /// Market data - needed for betting popup
  final LeagueMarketData? marketData;

  /// Odds type - home/away/draw
  final OddsType? oddsType;

  const BetItem({
    this.label,
    this.value,
    this.selectionId,
    this.oddsData,
    this.marketData,
    this.oddsType,
  });
}

class BetColumn {
  final BetColumnType type;
  final List<BetItem> items;

  const BetColumn({required this.type, this.items = const []});

  String get title => type.title;
}
