import 'dart:async';
import 'package:sport_socket/sport_socket.dart';

/// Orchestrates multi-sport subscriptions for BetSlip support.
///
/// V2 Channel-Based Subscriptions:
/// - Supports dual-channel subscription (league + match)
/// - Tracks subscribed channels instead of just sports
/// - Uses Base64 encoding for messages
///
/// Responsibilities:
/// - Track active sport (user's current tab)
/// - Track BetSlip sports (selections from other sports)
/// - Track current time range (LIVE/TODAY/EARLY)
/// - Sync subscriptions: required = active ∪ betSlip
/// - Delegate to SportSocketClient for SUB/UNSUB
/// - Handle race condition: BetSlip may load before WebSocket connects
class SubscriptionManager {
  /// Global instance for easy access from non-Riverpod contexts (e.g., ParlayStateNotifier)
  static SubscriptionManager? _instance;
  static SubscriptionManager? get instance => _instance;

  final SportSocketClient _client;

  // V2 Configuration
  final String _language;
  final bool _useV2Protocol;

  // State tracking
  int _activeSportId;
  int _activeTimeRange;
  final Set<int> _betSlipSportIds = {};

  // V2: Track subscribed channels
  final Set<String> _subscribedChannels = {};

  // V2: Track sources for each channel to prevent duplicate subscribe/unsubscribe
  // channel → Set<source> where source can be 'sport', 'match_detail', 'betslip'
  final Map<String, Set<String>> _channelSources = {};

  // Connection state
  bool _initialized = false;
  bool _isConnected = false;
  Set<int>? _pendingBetSlipSports; // Store until connected

  // Stream for active sport changes
  final _activeSportController = StreamController<int>.broadcast();
  Stream<int> get onActiveSportChanged => _activeSportController.stream;

  // Debounce timer for rapid tab switching
  Timer? _timeRangeDebounceTimer;
  static const _debounceDelay = Duration(milliseconds: 200);

  SubscriptionManager({
    required SportSocketClient client,
    int initialSportId = 1,
    int initialTimeRange = V2TimeRange.live,
    String language = V2SubscriptionHelper.defaultLanguage,
    bool useV2Protocol = false,
  }) : _client = client,
       _useV2Protocol = useV2Protocol,
       _activeSportId = initialSportId,
       _activeTimeRange = initialTimeRange,
       _language = language {
    // Set global instance for easy access from non-Riverpod contexts
    _instance = this;
  }

  int get activeSportId => _activeSportId;
  int get activeTimeRange => _activeTimeRange;
  String get language => _language;
  Set<int> get betSlipSportIds => Set.unmodifiable(_betSlipSportIds);
  Set<int> get subscribedSportIds => _client.subscribedSports;
  Set<String> get subscribedChannels => Set.unmodifiable(_subscribedChannels);
  bool get isInitialized => _initialized;

  // ===== Initialization =====

  /// Called when WebSocket FIRST connected.
  /// For V1: subscribes using SUB:s:{sportId} format
  /// For V2: subscribes using Base64 encoded SUBSCRIBE:ln:{lang}:s:{sportId}:l format
  void init() {
    if (_initialized) return;
    _initialized = true;
    _isConnected = true;

    // Apply pending BetSlip sports if any (loaded before connect)
    if (_pendingBetSlipSports != null) {
      _betSlipSportIds.addAll(_pendingBetSlipSports!);
      _pendingBetSlipSports = null;
    }

    if (_useV2Protocol) {
      // V2: Subscribe using channel-based format (Base64 encoded)
      // Subscribe to active sport's league + match channels
      subscribeMatchList(_activeSportId, _activeTimeRange);

      // Subscribe to BetSlip sports (league + match channels for each)
      for (final sportId in _betSlipSportIds) {
        if (sportId != _activeSportId) {
          subscribeMatchList(sportId, _activeTimeRange);
        }
      }
      print(
        '[SubscriptionManager] ✅ V2 Init complete - subscribed channels: $_subscribedChannels',
      );
    } else {
      // V1: Subscribe using sport-based format (legacy)
      // ALWAYS subscribe sport 1 FIRST (server requirement)
      _client.subscribeSport(1);
      _client.setPrimarySport(_activeSportId);

      // Subscribe other required sports
      final others = {_activeSportId, ..._betSlipSportIds}..remove(1);
      for (final sportId in others) {
        _client.subscribeSport(sportId);
      }
      print('[SubscriptionManager] ✅ V1 Init complete');
    }
  }

  /// Called when user switches sport tab.
  void setActiveSport(int sportId) {
    if (sportId == _activeSportId) return;

    final oldSportId = _activeSportId;
    _activeSportId = sportId;

    if (!_isConnected) return; // Wait until connected

    // Update library's primary sport for routing
    _client.setPrimarySport(sportId);

    // Sync subscriptions (may UNSUB old sport if not in BetSlip)
    _syncSubscriptions();

    _activeSportController.add(sportId);

    // Log for debugging
    print(
      '[SubscriptionManager] 🔄 Active sport changed: $oldSportId → $sportId',
    );
  }

  /// Called when BetSlip selections change.
  void syncBetSlipSports(Set<int> sportIds) {
    _betSlipSportIds
      ..clear()
      ..addAll(sportIds);

    if (_isConnected) {
      _syncSubscriptions();
    } else {
      // Store for later sync when connected
      _pendingBetSlipSports = Set.from(sportIds);
    }

    // Log for debugging
    print('[SubscriptionManager] 🎫 BetSlip sports synced: $sportIds');
  }

  /// Called on WebSocket reconnect.
  void onReconnected() {
    _isConnected = true;

    if (_useV2Protocol) {
      // V2: Resubscribe all tracked channels (Base64 encoded)
      _resubscribeAllChannels();
      print(
        '[SubscriptionManager] 🔄 V2 Reconnected - resubscribed ${_subscribedChannels.length} channels',
      );
    } else {
      // V1: Resubscribe using sport-based format
      // ALWAYS subscribe sport 1 FIRST (server requirement)
      _client.subscribeSport(1);

      // Then subscribe other required sports
      final others = {_activeSportId, ..._betSlipSportIds}..remove(1);
      for (final sportId in others) {
        _client.subscribeSport(sportId);
      }

      // Restore primary sport routing
      _client.setPrimarySport(_activeSportId);
      print('[SubscriptionManager] 🔄 V1 Reconnected - subscriptions restored');
    }
  }

  /// Called when WebSocket disconnected.
  void onDisconnected() {
    _isConnected = false;
    print('[SubscriptionManager] 🔌 Disconnected');
  }

  /// Sync subscriptions with server.
  void _syncSubscriptions() {
    final required = {_activeSportId, ..._betSlipSportIds};

    if (_useV2Protocol) {
      // V2: Build required channels and sync
      final requiredChannels = <String>{};
      for (final sportId in required) {
        requiredChannels.add(
          V2SubscriptionHelper.leagueChannel(sportId, lang: _language),
        );
        requiredChannels.add(
          V2SubscriptionHelper.matchChannel(
            sportId,
            _activeTimeRange,
            lang: _language,
          ),
        );
      }

      // Subscribe new channels
      for (final channel in requiredChannels.difference(_subscribedChannels)) {
        _subscribeChannel(channel);
      }

      // Unsubscribe old channels
      for (final channel in _subscribedChannels.difference(requiredChannels)) {
        _unsubscribeChannel(channel);
      }

      print(
        '[SubscriptionManager] 📊 V2 Synced: ${_subscribedChannels.length} channels',
      );
    } else {
      // V1: Sync using sport-based subscriptions
      final current = _client.subscribedSports;

      // Subscribe new (sport 1 first if needed)
      final toSubscribe = required.difference(current);
      if (toSubscribe.contains(1)) {
        _client.subscribeSport(1);
        toSubscribe.remove(1);
      }
      for (final sportId in toSubscribe) {
        _client.subscribeSport(sportId);
      }

      // Unsubscribe old (IMMEDIATELY)
      for (final sportId in current.difference(required)) {
        _client.unsubscribeSport(sportId);
      }

      print(
        '[SubscriptionManager] 📊 V1 Synced: required=$required, current=$current',
      );
    }
  }

  // ===== V2 Channel-Based Methods =====

  /// Subscribe to match list (V2 format).
  /// CRITICAL: Always subscribes BOTH league and match channels.
  ///
  /// [sportId] - Sport ID (1=Soccer, 2=Basketball, etc.)
  /// [timeRange] - Time range (0=Live, 1=Today, 2=Early)
  /// [sportTypeId] - Optional sport type ID for combat sports
  void subscribeMatchList(int sportId, int timeRange, {int? sportTypeId}) {
    if (!_isConnected) {
      print('[SubscriptionManager] ⚠️ Not connected, cannot subscribe');
      return;
    }

    // Build channels
    final leagueChannel = V2SubscriptionHelper.leagueChannel(
      sportId,
      lang: _language,
    );
    final matchChannel = V2SubscriptionHelper.matchChannel(
      sportId,
      timeRange,
      lang: _language,
      sportTypeId: sportTypeId,
    );

    // Subscribe to both channels - MATCH FIRST (what user sees), then league
    _subscribeChannel(matchChannel);
    _subscribeChannel(leagueChannel);

    print(
      '[SubscriptionManager] 📺 Subscribed match list: '
      'sport=$sportId, timeRange=$timeRange, sportType=$sportTypeId',
    );
  }

  /// Unsubscribe from match list (V2 format).
  void unsubscribeMatchList(int sportId, int timeRange, {int? sportTypeId}) {
    if (!_isConnected) return;

    // Build channels
    final leagueChannel = V2SubscriptionHelper.leagueChannel(
      sportId,
      lang: _language,
    );
    final matchChannel = V2SubscriptionHelper.matchChannel(
      sportId,
      timeRange,
      lang: _language,
      sportTypeId: sportTypeId,
    );

    // Unsubscribe from both channels
    _unsubscribeChannel(leagueChannel);
    _unsubscribeChannel(matchChannel);

    print(
      '[SubscriptionManager] 📴 Unsubscribed match list: '
      'sport=$sportId, timeRange=$timeRange',
    );
  }

  /// Subscribe to match detail (V2 format) with source tracking.
  ///
  /// [source] identifies the subscriber: 'match_detail', 'betslip', etc.
  /// Multiple sources can subscribe to the same channel.
  /// Only unsubscribes when all sources have unsubscribed.
  void subscribeMatchDetail(int eventId, {required String source}) {
    final channel = V2SubscriptionHelper.matchDetailChannel(
      eventId,
      lang: _language,
    );
    subscribeChannelWithSource(channel, source: source);

    print(
      '[SubscriptionManager] 📺 Subscribed match detail: eventId=$eventId (source: $source)',
    );
  }

  /// Unsubscribe from match detail with source tracking.
  void unsubscribeMatchDetail(int eventId, {required String source}) {
    final channel = V2SubscriptionHelper.matchDetailChannel(
      eventId,
      lang: _language,
    );
    unsubscribeChannelWithSource(channel, source: source);

    print(
      '[SubscriptionManager] 📴 Unsubscribed match detail: eventId=$eventId (source: $source)',
    );
  }

  /// Unsubscribe from match detail with specific language (for language change handling).
  void unsubscribeMatchDetailWithLang(
    int eventId, {
    required String lang,
    required String source,
  }) {
    final channel = V2SubscriptionHelper.matchDetailChannel(
      eventId,
      lang: lang,
    );
    unsubscribeChannelWithSource(channel, source: source);

    print(
      '[SubscriptionManager] 📴 Unsubscribed match detail: eventId=$eventId, lang=$lang (source: $source)',
    );
  }

  /// Subscribe to a channel with source tracking.
  ///
  /// Only sends SUBSCRIBE if this is the first source for this channel.
  /// Multiple sources can subscribe to the same channel without duplicates.
  void subscribeChannelWithSource(String channel, {required String source}) {
    _channelSources[channel] ??= {};
    final isNewChannel = _channelSources[channel]!.isEmpty;
    _channelSources[channel]!.add(source);

    if (isNewChannel && _isConnected) {
      _sendSubscribe(channel);
      print('[SubscriptionManager] 📺 Subscribed: $channel (source: $source)');
    } else if (!isNewChannel) {
      print(
        '[SubscriptionManager] 📺 Added source to existing channel: $channel (source: $source, all: ${_channelSources[channel]})',
      );
    }
  }

  /// Unsubscribe from a channel with source tracking.
  ///
  /// Only sends UNSUBSCRIBE if this was the last source for this channel.
  void unsubscribeChannelWithSource(String channel, {required String source}) {
    if (!_channelSources.containsKey(channel)) return;

    _channelSources[channel]!.remove(source);

    if (_channelSources[channel]!.isEmpty) {
      _channelSources.remove(channel);
      if (_isConnected) {
        _sendUnsubscribe(channel);
        print(
          '[SubscriptionManager] 📴 Unsubscribed: $channel (last source: $source)',
        );
      }
    } else {
      print(
        '[SubscriptionManager] 📺 Removed source: $channel (remaining: ${_channelSources[channel]})',
      );
    }
  }

  /// Send raw SUBSCRIBE message to server.
  void _sendSubscribe(String channel) {
    final message = V2SubscriptionHelper.subscribeMessage(channel);
    _client.sendRaw(message);
  }

  /// Send raw UNSUBSCRIBE message to server.
  void _sendUnsubscribe(String channel) {
    final message = V2SubscriptionHelper.unsubscribeMessage(channel);
    _client.sendRaw(message);
  }

  /// Subscribe to hot matches (V2 format).
  void subscribeHotMatches(int sportId) {
    if (!_isConnected) return;

    final channel = V2SubscriptionHelper.hotChannel(sportId, lang: _language);
    _subscribeChannel(channel);

    print('[SubscriptionManager] 📺 Subscribed hot matches: sportId=$sportId');
  }

  /// Unsubscribe from hot matches.
  void unsubscribeHotMatches(int sportId) {
    if (!_isConnected) return;

    final channel = V2SubscriptionHelper.hotChannel(sportId, lang: _language);
    _unsubscribeChannel(channel);

    print(
      '[SubscriptionManager] 📴 Unsubscribed hot matches: sportId=$sportId',
    );
  }

  /// Subscribe to outright events (V2 format).
  void subscribeOutright(int sportId) {
    if (!_isConnected) return;

    final channel = V2SubscriptionHelper.outrightChannel(
      sportId,
      lang: _language,
    );
    _subscribeChannel(channel);

    print('[SubscriptionManager] 📺 Subscribed outright: sportId=$sportId');
  }

  /// Unsubscribe from outright events.
  void unsubscribeOutright(int sportId) {
    if (!_isConnected) return;

    final channel = V2SubscriptionHelper.outrightChannel(
      sportId,
      lang: _language,
    );
    _unsubscribeChannel(channel);

    print('[SubscriptionManager] 📴 Unsubscribed outright: sportId=$sportId');
  }

  /// Update active time range and resubscribe (with debounce for rapid switching).
  ///
  /// Debounce prevents excessive unsub/sub when user rapidly switches tabs.
  /// Only the final tab selection will trigger actual channel switch.
  void setActiveTimeRange(int timeRange) {
    // Cancel any pending switch
    _timeRangeDebounceTimer?.cancel();

    if (timeRange == _activeTimeRange) return;

    // Debounce: wait before executing switch
    _timeRangeDebounceTimer = Timer(_debounceDelay, () {
      _executeTimeRangeSwitch(timeRange);
    });
  }

  /// Execute the actual time range switch (called after debounce).
  void _executeTimeRangeSwitch(int timeRange) {
    final oldTimeRange = _activeTimeRange;
    _activeTimeRange = timeRange;

    if (!_isConnected) {
      print(
        '[SubscriptionManager] ⚠️ Not connected, timeRange saved for reconnect: '
        '${V2TimeRange.toStringValue(timeRange)}',
      );
      return;
    }

    // Unsubscribe from old match channel, subscribe to new
    final oldMatchChannel = V2SubscriptionHelper.matchChannel(
      _activeSportId,
      oldTimeRange,
      lang: _language,
    );
    final newMatchChannel = V2SubscriptionHelper.matchChannel(
      _activeSportId,
      timeRange,
      lang: _language,
    );

    _unsubscribeChannel(oldMatchChannel);
    _subscribeChannel(newMatchChannel);

    print(
      '[SubscriptionManager] ⏰ Time range changed: '
      '${V2TimeRange.toStringValue(oldTimeRange)} → ${V2TimeRange.toStringValue(timeRange)}',
    );
  }

  /// Set time range from string (LIVE/TODAY/EARLY).
  void setTimeRangeFromString(String timeRange) {
    setActiveTimeRange(V2TimeRange.fromString(timeRange));
  }

  // ===== Internal Methods =====

  /// Subscribe to a channel (sends Base64 encoded message).
  void _subscribeChannel(String channel) {
    if (_subscribedChannels.contains(channel)) return;

    final message = V2SubscriptionHelper.subscribeMessage(channel);
    _client.sendRaw(message);

    _subscribedChannels.add(channel);
    print('[SubscriptionManager] → SUBSCRIBE: $channel');
  }

  /// Unsubscribe from a channel (sends Base64 encoded message).
  void _unsubscribeChannel(String channel) {
    if (!_subscribedChannels.contains(channel)) return;

    final message = V2SubscriptionHelper.unsubscribeMessage(channel);
    _client.sendRaw(message);

    _subscribedChannels.remove(channel);
    print('[SubscriptionManager] → UNSUBSCRIBE: $channel');
  }

  /// Resubscribe all tracked channels (called on reconnect).
  void _resubscribeAllChannels() {
    // Resubscribe sport/timerange channels
    for (final channel in _subscribedChannels.toList()) {
      final message = V2SubscriptionHelper.subscribeMessage(channel);
      _client.sendRaw(message);
      print('[SubscriptionManager] → RESUBSCRIBE: $channel');
    }

    // Resubscribe source-tracked channels (match detail, betslip events)
    for (final channel in _channelSources.keys) {
      if (!_subscribedChannels.contains(channel)) {
        final message = V2SubscriptionHelper.subscribeMessage(channel);
        _client.sendRaw(message);
        print('[SubscriptionManager] → RESUBSCRIBE (source-tracked): $channel');
      }
    }

    print(
      '[SubscriptionManager] 🔄 Resubscribed: ${_subscribedChannels.length} sport + ${_channelSources.length} source-tracked channels',
    );
  }

  void dispose() {
    _timeRangeDebounceTimer?.cancel();
    _activeSportController.close();
    _subscribedChannels.clear();
    _channelSources.clear();
  }
}
