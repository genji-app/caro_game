import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';
import 'package:co_caro_flame/s88/core/services/models/api_v2/v2_to_legacy_adapter.dart';
import 'package:co_caro_flame/s88/core/services/models/league_model.dart';
import 'package:co_caro_flame/s88/core/services/network/sb_http_manager.dart';
import 'package:co_caro_flame/s88/core/services/storage/sport_storage.dart';
import 'package:co_caro_flame/s88/features/sport/data/model/special_outright_model.dart';

/// Sport Remote Data Source
///
/// Handles API calls for sport/league data.
/// Data layer responsibility: communicate with external data sources.
abstract class SportRemoteDataSource {
  /// Fetch leagues from API
  Future<List<LeagueData>> getLeagues({int? days, bool? isLive});

  /// Fetch hot leagues from API
  Future<List<LeagueData>> getHotLeagues();

  /// Fetch outright leagues from API
  Future<List<LeagueData>> getOutrightLeagues();

  /// Fetch special outright data from API for [sportId].
  /// Returns List<SpecialOutrightModel> for special tab.
  Future<List<SpecialOutrightModel>> getSpecialOutright(int sportId);

  /// Change sport type
  Future<void> changeSport(int sportId);

  /// Get current sport ID
  int get currentSportId;
}

/// Sport Remote Data Source Implementation
///
/// Concrete implementation using SbHttpManager and SportStorage.
class SportRemoteDataSourceImpl implements SportRemoteDataSource {
  final SbHttpManager _httpManager;
  final SportStorage _storage;

  SportRemoteDataSourceImpl(this._httpManager, this._storage);

  @override
  Future<List<LeagueData>> getLeagues({int? days, bool? isLive}) async {
    return await _httpManager.getLeagues(days: days, isLive: isLive);
  }

  @override
  Future<List<LeagueData>> getHotLeagues() async {
    final leaguesV2 = await _httpManager.getHotLeagues();
    return leaguesV2.toLegacy();
  }

  @override
  Future<List<LeagueData>> getOutrightLeagues() async {
    return await _httpManager.getOutrightLeagues();
  }

  @override
  Future<List<SpecialOutrightModel>> getSpecialOutright(int sportId) async {
    if (_httpManager.urlHomeExposeService.isEmpty) {
      throw Exception('Expose service URL not set. Call getSetting() first.');
    }

    final agentId = SbConfig.agentId;
    final token = SbHttpManager.instance.userTokenSb;
    const days = 1;
    const isLive = false;

    final url =
        '${_httpManager.urlHomeExposeService}/api/v1/outright/events'
        '?sportId=$sportId';

    final response = await _httpManager.send(url, json: true);
    debugPrint('response: $response');
    List<dynamic> rawList;
    if (response is List) {
      rawList = response;
    } else if (response is Map<String, dynamic>) {
      final data = response['data'] ?? <dynamic>[];
      rawList = data is List ? data : <dynamic>[];
    } else {
      return [];
    }

    // Parse and filter: only include items where field "2" (outrightName) contains "Winner"
    return rawList
        .where((json) {
          final item = json as Map<String, dynamic>;
          final field2 = item['2']?.toString() ?? '';
          return field2.contains('Winner');
        })
        .map((json) =>
            SpecialOutrightModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> changeSport(int sportId) async {
    await _storage.saveSportId(sportId);
    _httpManager.sportTypeId = sportId;
  }

  @override
  int get currentSportId => _httpManager.sportTypeId;
}
