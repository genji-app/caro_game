/// One item from GET /api/v1/leagues/pin response.
/// Keys: "0"=?, "1"=leagueId, "2"=name, "3"=logoUrl, "4"=sortOrder.
class LeaguePinItem {
  const LeaguePinItem({
    required this.leagueId,
    required this.name,
    required this.logoUrl,
    required this.sortOrder,
  });

  final int leagueId;
  final String name;
  final String logoUrl;
  final int sortOrder;
}
