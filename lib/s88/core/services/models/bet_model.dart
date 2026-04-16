import 'package:freezed_annotation/freezed_annotation.dart';

part 'bet_model.freezed.dart';
part 'bet_model.g.dart';

/// Bet Selection Model
///
/// Represents a single bet selection in a bet slip.
@freezed
sealed class BetSelectionModel with _$BetSelectionModel {
  const factory BetSelectionModel({
    required int eventId,
    required String eventName,
    @JsonKey(name: 'selectionId') required String selectionId,
    @JsonKey(name: 'selectionName') required String selectionName,
    @JsonKey(name: 'offerId') required String offerId,
    @JsonKey(name: 'displayOdds') required String displayOdds,
    @JsonKey(name: 'oddsStyle') @Default('decimal') String oddsStyle,
    @JsonKey(name: 'cls') required String cls,
    @JsonKey(name: 'leagueId') String? leagueId,
    @JsonKey(name: 'matchTime') String? matchTime,
    @JsonKey(name: 'isLive') @Default(false) bool isLive,
    @JsonKey(name: 'sportId') @Default(1) int sportId,
    @JsonKey(name: 'homeScore') int? homeScore,
    @JsonKey(name: 'awayScore') int? awayScore,
    double? stake,
    double? winnings,
  }) = _BetSelectionModel;

  factory BetSelectionModel.fromJson(Map<String, dynamic> json) =>
      _$BetSelectionModelFromJson(json);
}

/// Calculate Bet Request Model
@freezed
sealed class CalculateBetRequest with _$CalculateBetRequest {
  const factory CalculateBetRequest({
    @JsonKey(name: 'leagueId') required String leagueId,
    @JsonKey(name: 'matchTime') required String matchTime,
    @JsonKey(name: 'isLive') @Default(false) bool isLive,
    @JsonKey(name: 'offerId') required String offerId,
    @JsonKey(name: 'selectionId') required String selectionId,
    @JsonKey(name: 'displayOdds') required String displayOdds,
    @JsonKey(name: 'oddsStyle') @Default('decimal') String oddsStyle,
  }) = _CalculateBetRequest;

  factory CalculateBetRequest.fromJson(Map<String, dynamic> json) =>
      _$CalculateBetRequestFromJson(json);
}

/// Calculate Bet Response Model
/// Used for both single bet and parlay bet calculations
@freezed
sealed class CalculateBetResponse with _$CalculateBetResponse {
  const factory CalculateBetResponse({
    // Use custom fromJson to handle double from API (50.0, 73643.51) -> int
    @JsonKey(name: 'minStake', fromJson: _numToInt) @Default(0) int minStake,
    @JsonKey(name: 'maxStake', fromJson: _numToInt) @Default(0) int maxStake,
    @JsonKey(name: 'maxPayout') @Default(0) int maxPayout,
    @JsonKey(name: 'displayOdds') @Default('') String displayOdds,
    @JsonKey(name: 'trueOdds') double? trueOdds,
    @JsonKey(name: 'errorCode') @Default(0) int errorCode,
    String? message,
    // Parlay specific fields
    @JsonKey(name: 'minMatches') @Default(2) int minMatches,
    @JsonKey(name: 'maxMatches') @Default(10) int maxMatches,
    @JsonKey(name: 'selectionIdOdds') Map<String, String>? selectionIdOdds,
  }) = _CalculateBetResponse;

  factory CalculateBetResponse.fromJson(Map<String, dynamic> json) =>
      _$CalculateBetResponseFromJson(json);
}

/// Convert num (int or double) to int
int _numToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.floor();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Place Bet Request Model
/// Used for both single bet and parlay bet
@freezed
sealed class PlaceBetRequest with _$PlaceBetRequest {
  const factory PlaceBetRequest({
    @JsonKey(name: 'acceptBetterOdds') @Default(true) bool acceptBetterOdds,
    @JsonKey(name: 'acceptMaxStake') @Default(true) bool acceptMaxStake,
    @JsonKey(name: 'matchId') required int matchId,
    @JsonKey(name: 'selections') required List<BetSelectionModel> selections,
    @JsonKey(name: 'singleBet') @Default(true) bool singleBet,
    // Parlay specific fields
    @JsonKey(name: 'parlay') @Default(false) bool parlay,
    @JsonKey(name: 'acceptAllOdds') @Default(true) bool acceptAllOdds,
  }) = _PlaceBetRequest;

  factory PlaceBetRequest.fromJson(Map<String, dynamic> json) =>
      _$PlaceBetRequestFromJson(json);
}

/// Place Bet Response Model
@freezed
sealed class PlaceBetResponse with _$PlaceBetResponse {
  const factory PlaceBetResponse({
    @JsonKey(name: 'ticketId') String? ticketId,
    required String status,
    @JsonKey(fromJson: _oddsToString) String? odds,
    @JsonKey(fromJson: _numToIntNullable) int? stake,
    @JsonKey(name: 'winning', fromJson: _numToIntNullable) int? winnings,
    @JsonKey(name: 'errorCode') @Default(0) int errorCode,
    String? message,
    @JsonKey(name: 'createdAt') String? createdAt,
  }) = _PlaceBetResponse;

  factory PlaceBetResponse.fromJson(Map<String, dynamic> json) =>
      _$PlaceBetResponseFromJson(json);
}

/// Convert odds (can be double or String) to String
String? _oddsToString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

/// Convert num to int (nullable)
int? _numToIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.floor();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Bet Selection Extensions
extension BetSelectionModelX on BetSelectionModel {
  /// Parse odds to double
  double get oddsValue => double.tryParse(displayOdds) ?? 0.0;

  /// Calculate potential winnings for a given stake
  double calculateWinnings(double stakeAmount) => stakeAmount * oddsValue;

  /// Convert to JSON for API request
  /// Note: API expects specific types:
  /// - homeScore/awayScore: String (not int)
  /// - displayOdds: double (not String)
  /// - stake/winnings: Integer (not double)
  Map<String, dynamic> toRequestJson(double stakeAmount) {
    return {
      'homeScore': homeScore?.toString() ?? '0',
      'awayScore': awayScore?.toString() ?? '0',
      'cls': cls,
      'displayOdds': oddsValue, // Convert string to double
      'oddsStyle': oddsStyle,
      'selectionId': selectionId,
      'selectionName': selectionName,
      'offerId': offerId,
      'stake': stakeAmount.toInt(), // Integer
      'trueOdds': 0,
      'winnings': calculateWinnings(stakeAmount).round(), // Integer (rounded)
      'sportId': sportId,
    };
  }
}

/// Calculate Bet Response Extensions
extension CalculateBetResponseX on CalculateBetResponse {
  /// Check if calculation was successful
  bool get isSuccess => errorCode == 0;

  /// Get min stake in K units
  double get minStakeK => minStake / 1000.0;

  /// Get max stake in K units
  double get maxStakeK => maxStake / 1000.0;

  /// Get max payout in K units
  double get maxPayoutK => maxPayout / 1000.0;
}

/// Place Bet Response Extensions
extension PlaceBetResponseX on PlaceBetResponse {
  /// Check if bet was placed successfully
  /// API returns status: "Active" when bet is placed successfully
  bool get isSuccess {
    // Success if has ticketId and no error
    if (ticketId != null && ticketId!.isNotEmpty && errorCode == 0) {
      return true;
    }
    // Also check for valid status values
    final validStatuses = ['Active', 'SUCCESS', 'Pending', 'Accepted'];
    return validStatuses.contains(status) && errorCode == 0;
  }

  /// Check if odds changed
  bool get oddsChanged => errorCode == 1002;

  /// Check if insufficient balance
  bool get insufficientBalance => errorCode == 1001;
}
