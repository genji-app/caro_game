import 'package:co_caro_flame/s88/features/search/data/models/search_result_item.dart';

/// Response from GET /api/app/search?txtSearch=...
/// Keys: "0" = leagues (array), "1" = events (array of SearchResultItem).
class SearchResponseModel {
  const SearchResponseModel({this.leagues = const [], this.events = const []});

  final List<dynamic> leagues;
  final List<SearchResultItem> events;

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    final raw0 = json['0'];
    final raw1 = json['1'];

    final leaguesList = raw0 is List ? raw0 : <dynamic>[];
    final eventsList = <SearchResultItem>[];
    if (raw1 is List) {
      for (final item in raw1) {
        if (item is Map) {
          eventsList.add(
            SearchResultItem.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return SearchResponseModel(leagues: leaguesList, events: eventsList);
  }
}
