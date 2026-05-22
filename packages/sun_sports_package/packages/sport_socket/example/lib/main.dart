import 'dart:async';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:sport_socket/sport_socket.dart';
import 'sport_api_service.dart';
import 'sport_switching/sport_switch_state.dart';
import 'sport_switching/sport_switching_service.dart';

void main() {
  runApp(const SportSocketExampleApp());
}

class SportSocketExampleApp extends StatelessWidget {
  const SportSocketExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sport Socket Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        cardColor: const Color(0xFF16213E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0F3460),
          secondary: Color(0xFFE94560),
          surface: Color(0xFF16213E),
        ),
      ),
      home: const SportSocketTestPage(),
    );
  }
}

class SportSocketTestPage extends StatefulWidget {
  const SportSocketTestPage({super.key});

  @override
  State<SportSocketTestPage> createState() => _SportSocketTestPageState();
}

class _SportSocketTestPageState extends State<SportSocketTestPage> {
  // Config Controllers
  final _wsUrlController = TextEditingController(
    text:
        'wss://antensun.sb21.net/ws?clientId=sun&token=32-9273be0e73cec91d9e2dda42b7eb2e25',
  );
  final _domainController = TextEditingController(
    text: 'https://gali.sb21.net',
  );
  final _tokenController = TextEditingController(
    text: '32-f34764d76cb202483d403d9c5fb2dfb8',
  );

  // Client and API Service
  SportSocketClient? _client;
  ExampleApiService? _apiService;
  SportSwitchingService? _sportSwitchingService;
  StreamSubscription<SportSwitchState>? _sportSwitchSubscription;

  // Settings
  bool _useApiIntegration = true;
  bool _useTripleProtection = true; // Toggle for testing
  int _selectedSportId = 1;

  // State
  bool _isConnected = false;
  bool _isConnecting = false;
  String _connectionStatus = 'Disconnected';
  String _metrics = '';
  String _autoRefreshStatus = '';
  String _sportSwitchStatus = ''; // Triple Protection status
  int _pendingQueueSize = 0;

  // Data
  List<LeagueData> _leagues = [];
  Map<int, List<EventData>> _eventsByLeague = {};
  Map<int, List<MarketData>> _marketsByEvent = {};
  Map<String, List<OddsData>> _oddsByMarket = {};

  @override
  void dispose() {
    _sportSwitchSubscription?.cancel();
    _sportSwitchingService?.dispose();
    _client?.disconnect();
    _apiService?.dispose();
    _wsUrlController.dispose();
    _domainController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
      _connectionStatus = 'Connecting...';
    });

    try {
      // Create client with production config
      _client = SportSocketClient(
        config: SocketConfig.liveMode(
          url: _wsUrlController.text,
          logger: const ConsoleLogger(minLevel: LogLevel.debug),
          autoRefreshConfig: const AutoRefreshConfig(
            refreshInterval: Duration(seconds: 30), // 30s for production
            pendingQueueThreshold: 300, // 300 for production
            enabled: true,
            minRefreshGap: Duration(seconds: 5), // 5s for production
            maxRetries: 3,
          ),
        ),
      );

      // Listen to connection state
      _client!.onConnectionChanged.listen((event) {
        setState(() {
          _isConnected = event.currentState == ConnectionState.connected;
          _connectionStatus = event.currentState.name;
        });
      });

      // Listen to data changes
      _client!.onDataChanged.listen((_) {
        _refreshData();
      });

      // Listen to metrics
      _client!.onMetrics.listen((metrics) {
        setState(() {
          _metrics = 'Msg/s: ${metrics.receivedPerSecond} | '
              'Processed: ${metrics.processedTotal} | '
              'Pending: ${metrics.pendingQueueSize}';
          _pendingQueueSize = metrics.pendingQueueSize;
        });
      });

      if (_useApiIntegration) {
        // With API Integration - use initialize()
        _apiService = ExampleApiService(
          baseUrl: _domainController.text,
          agentId: '32',
          token:
              _tokenController.text.isNotEmpty ? _tokenController.text : null,
        );

        setState(() {
          _connectionStatus = 'Initializing (WebSocket + API)...';
        });

        await _client!.initialize(
          apiService: _apiService!,
          sportId: _selectedSportId,
          fetchHot: true,
        );

        // Also populate store with full data hierarchy
        await _apiService!.fetchAndPopulateStore(
          sportId: _selectedSportId,
          store: _client!.dataStore,
          fetchHot: true,
        );

        // Initialize SportSwitchingService with Triple Protection
        if (_useTripleProtection) {
          _sportSwitchingService = SportSwitchingService(
            client: _client!,
            apiService: _apiService!,
          );
          await _sportSwitchingService!.initialize(_selectedSportId);

          // Listen to sport switch state changes
          _sportSwitchSubscription =
              _sportSwitchingService!.stateStream.listen((state) {
            setState(() {
              _sportSwitchStatus =
                  '${state.status.name} (v${state.requestVersion})';
              if (state.status == SportSwitchStatus.ready) {
                _selectedSportId = state.currentSportId;
                _refreshData();
              }
            });
          });
        }

        // Start monitoring auto refresh
        _startAutoRefreshMonitor();

        // Log status immediately after init
        _client!.autoRefreshManager?.logStatus();

        setState(() {
          _isConnecting = false;
          _autoRefreshStatus = 'AutoRefresh: Active (10s interval for testing)';
        });
      } else {
        // WebSocket only - legacy mode
        await _client!.connect();
        _client!.subscribeSport(_selectedSportId);

        setState(() {
          _isConnecting = false;
          _autoRefreshStatus = 'AutoRefresh: Disabled (WebSocket only)';
        });
      }

      _refreshData();
    } catch (e) {
      setState(() {
        _connectionStatus = 'Error: $e';
        _isConnecting = false;
      });
    }
  }

  void _startAutoRefreshMonitor() {
    final autoRefresh = _client?.autoRefreshManager;
    if (autoRefresh == null) return;

    autoRefresh.onRefresh.listen((result) {
      setState(() {
        _autoRefreshStatus = 'Last refresh: ${result.trigger.description} '
            '(${result.success ? 'OK' : 'FAIL'}) '
            '${result.duration.inMilliseconds}ms';
      });
      // Refresh UI data after auto refresh
      _refreshData();
    });
  }

  Future<void> _triggerManualRefresh() async {
    if (_client == null || !_useApiIntegration) return;

    final autoRefresh = _client!.autoRefreshManager;
    if (autoRefresh == null) return;

    setState(() {
      _autoRefreshStatus = 'Manual refresh in progress...';
    });

    await autoRefresh.triggerRefresh(AutoRefreshTrigger.manual);
    _refreshData();
  }

  void _logAutoRefreshStatus() {
    final autoRefresh = _client?.autoRefreshManager;
    if (autoRefresh == null) {
      debugPrint('[DEBUG] autoRefreshManager is NULL');
      setState(() {
        _autoRefreshStatus = '⚠️ AutoRefreshManager is NULL!';
      });
      return;
    }

    // Log status to console (uses print() for immediate output)
    autoRefresh.logStatus();

    // Also get diagnostics and show in UI
    final diag = autoRefresh.getDiagnostics();
    setState(() {
      _autoRefreshStatus = '📊 running: ${diag['isRunning']}, '
          'ticks: ${diag['tickCount']}, '
          'next: ${diag['secondsUntilNextTick'] ?? 'N/A'}s, '
          'interval: ${diag['config']['refreshInterval']}s';
    });
  }

  void _disconnect() {
    _sportSwitchSubscription?.cancel();
    _sportSwitchSubscription = null;
    _sportSwitchingService?.dispose();
    _sportSwitchingService = null;
    _client?.disconnect();
    _apiService?.dispose();
    _apiService = null;

    setState(() {
      _isConnected = false;
      _isConnecting = false;
      _connectionStatus = 'Disconnected';
      _autoRefreshStatus = '';
      _sportSwitchStatus = '';
      _leagues = [];
      _eventsByLeague = {};
      _marketsByEvent = {};
      _oddsByMarket = {};
      _pendingQueueSize = 0;
    });
  }

  void _changeSport(int sportId) async {
    if (!_isConnected || !_useApiIntegration) return;

    // Use Triple Protection if enabled
    if (_useTripleProtection && _sportSwitchingService != null) {
      // Just call changeSport - the service handles debounce, version check, cancel
      _sportSwitchingService!.changeSport(sportId);
      // State updates come through the stream subscription
      return;
    }

    // Legacy mode - direct switch without protection
    setState(() {
      _selectedSportId = sportId;
      _connectionStatus = 'Changing sport to $sportId...';
    });

    try {
      await _client!.changeSport(sportId);

      // Re-populate store with new sport data
      await _apiService?.fetchAndPopulateStore(
        sportId: sportId,
        store: _client!.dataStore,
        fetchHot: true,
      );

      _refreshData();
      setState(() {
        _connectionStatus = 'connected';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Error: $e';
      });
    }
  }

  void _refreshData() {
    if (_client == null) return;

    final store = _client!.dataStore;

    // Get leagues for selected sport
    final leagues = store.getLeaguesBySport(_selectedSportId);
    final eventsByLeague = <int, List<EventData>>{};
    final marketsByEvent = <int, List<MarketData>>{};
    final oddsByMarket = <String, List<OddsData>>{};

    // DEBUG: Track leagues with/without events
    final leaguesWithEvents = <String>[];
    final leaguesWithoutEvents = <String>[];

    for (final league in leagues) {
      final events = store.getEventsByLeague(league.leagueId);
      if (events.isNotEmpty) {
        eventsByLeague[league.leagueId] = events;
        leaguesWithEvents.add(
            '${league.name} (${league.leagueId}): ${events.length} events');

        for (final event in events) {
          final markets = store.getMarketsByEvent(event.eventId);
          marketsByEvent[event.eventId] = markets;

          for (final market in markets) {
            final odds = store.getOddsByMarket(event.eventId, market.marketId);
            oddsByMarket[market.marketKey] = odds;
          }
        }
      } else {
        leaguesWithoutEvents
            .add('${league.name} (${league.leagueId}): 0 events');
      }
    }

    // DEBUG: Print league analysis
    // ignore: avoid_print
    print('\n╔══════════════════════════════════════════════════════════════');
    // ignore: avoid_print
    print('║ 📊 LEAGUE ANALYSIS - Total: ${leagues.length} leagues');
    // ignore: avoid_print
    print('╠══════════════════════════════════════════════════════════════');
    // ignore: avoid_print
    print('║ ✅ WITH EVENTS (${leaguesWithEvents.length}):');
    for (final l in leaguesWithEvents) {
      // ignore: avoid_print
      print('║    - $l');
    }
    // ignore: avoid_print
    print('║ ❌ WITHOUT EVENTS (${leaguesWithoutEvents.length}):');
    for (final l in leaguesWithoutEvents) {
      // ignore: avoid_print
      print('║    - $l');
    }
    // ignore: avoid_print
    print('╚══════════════════════════════════════════════════════════════\n');

    setState(() {
      _leagues =
          leagues.where((l) => eventsByLeague.containsKey(l.leagueId)).toList();
      _eventsByLeague = eventsByLeague;
      _marketsByEvent = marketsByEvent;
      _oddsByMarket = oddsByMarket;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: _leagues.isEmpty ? _buildEmptyState() : _buildLeagueList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              const Icon(Icons.sports_soccer, color: Colors.green, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Sport Socket Test',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Connection status
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _connectionStatus,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Input row
          Row(
            children: [
              // WS URL
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _wsUrlController,
                  decoration: const InputDecoration(
                    labelText: 'WebSocket URL',
                    hintText: 'wss://...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  enabled: !_isConnected,
                ),
              ),
              const SizedBox(width: 12),

              // Domain
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _domainController,
                  decoration: const InputDecoration(
                    labelText: 'API Domain',
                    hintText: 'https://...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  enabled: !_isConnected && _useApiIntegration,
                ),
              ),
              const SizedBox(width: 12),

              // Token
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    labelText: 'API Token',
                    hintText: 'agent-token...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  enabled: !_isConnected && _useApiIntegration,
                ),
              ),
              const SizedBox(width: 12),

              // Connect/Disconnect button
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isConnected ? _disconnect : _connect,
                  icon: Icon(_isConnected ? Icons.stop : Icons.play_arrow),
                  label: Text(_isConnected ? 'Disconnect' : 'Connect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConnected ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Settings row
          Row(
            children: [
              // Use API Integration toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: _useApiIntegration,
                    onChanged: _isConnected
                        ? null
                        : (value) => setState(() => _useApiIntegration = value),
                    activeTrackColor: Colors.green.withValues(alpha: 0.5),
                    activeThumbColor: Colors.green,
                  ),
                  Text(
                    'API Integration',
                    style: TextStyle(
                      color: _useApiIntegration ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Triple Protection toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: _useTripleProtection,
                    onChanged: _isConnected
                        ? null
                        : (value) =>
                            setState(() => _useTripleProtection = value),
                    activeTrackColor: Colors.orange.withValues(alpha: 0.5),
                    activeThumbColor: Colors.orange,
                  ),
                  Text(
                    'Triple Protection',
                    style: TextStyle(
                      color: _useTripleProtection ? Colors.orange : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Sport selector
              const Text('Sport: '),
              DropdownButton<int>(
                value: _selectedSportId,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Football')),
                  DropdownMenuItem(value: 2, child: Text('Basketball')),
                  DropdownMenuItem(value: 4, child: Text('Tennis')),
                  DropdownMenuItem(value: 5, child: Text('Volleyball')),
                ],
                onChanged: _isConnected && _useApiIntegration
                    ? (value) => _changeSport(value ?? 1)
                    : null,
              ),
              const Spacer(),

              // Manual refresh button
              if (_isConnected && _useApiIntegration) ...[
                TextButton.icon(
                  onPressed: _triggerManualRefresh,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Manual Refresh'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _logAutoRefreshStatus,
                  icon: const Icon(Icons.bug_report, size: 18),
                  label: const Text('Debug'),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
              ],
            ],
          ),

          // Metrics row
          if (_metrics.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _metrics,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                if (_pendingQueueSize > 100)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          _pendingQueueSize > 300 ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Pending: $_pendingQueueSize',
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],

          // Auto refresh status
          if (_autoRefreshStatus.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _autoRefreshStatus,
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue[300],
              ),
            ),
          ],

          // Sport switch status (Triple Protection)
          if (_sportSwitchStatus.isNotEmpty && _useTripleProtection) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border:
                        Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Triple Protection: $_sportSwitchStatus',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isConnected ? Icons.hourglass_empty : Icons.wifi_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _isConnected
                ? 'Waiting for data...'
                : 'Connect to WebSocket to see data',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (!_isConnected) ...[
            const SizedBox(height: 8),
            Text(
              _useApiIntegration
                  ? 'API Integration enabled - will fetch initial data from API'
                  : 'WebSocket only - data comes from socket messages',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeagueList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _leagues.length,
      itemBuilder: (context, index) {
        final league = _leagues[index];
        final events = _eventsByLeague[league.leagueId] ?? [];

        return _LeagueCard(
          league: league,
          events: events,
          marketsByEvent: _marketsByEvent,
          oddsByMarket: _oddsByMarket,
        );
      },
    );
  }
}

/// League Card Widget
class _LeagueCard extends StatefulWidget {
  final LeagueData league;
  final List<EventData> events;
  final Map<int, List<MarketData>> marketsByEvent;
  final Map<String, List<OddsData>> oddsByMarket;

  const _LeagueCard({
    required this.league,
    required this.events,
    required this.marketsByEvent,
    required this.oddsByMarket,
  });

  @override
  State<_LeagueCard> createState() => _LeagueCardState();
}

class _LeagueCardState extends State<_LeagueCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          // League Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(4),
                  bottom: _isExpanded ? Radius.zero : const Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.league.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.events.length} matches',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Events
          if (_isExpanded)
            Column(
              children: [
                // Market Header
                const _MarketHeader(),

                // Event Rows
                ...widget.events.map((event) => _EventRow(
                      event: event,
                      markets: widget.marketsByEvent[event.eventId] ?? [],
                      oddsByMarket: widget.oddsByMarket,
                    )),
              ],
            ),
        ],
      ),
    );
  }
}

/// Market Header (6 columns)
class _MarketHeader extends StatelessWidget {
  const _MarketHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          // Team names column
          const Expanded(
            flex: 3,
            child: Text(
              'Match',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ),
          // 6 Market columns
          ..._marketColumns.map((col) => Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    col.shortName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

/// Event Row Widget
class _EventRow extends StatelessWidget {
  final EventData event;
  final List<MarketData> markets;
  final Map<String, List<OddsData>> oddsByMarket;

  const _EventRow({
    required this.event,
    required this.markets,
    required this.oddsByMarket,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          // Team names
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Home team
                Row(
                  children: [
                    if (event.isLive)
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                              fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        event.homeName,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (event.isLive && event.homeScore != null)
                      Text(
                        '${event.homeScore}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Away team
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.awayName,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (event.isLive && event.awayScore != null)
                      Text(
                        '${event.awayScore}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 6 Market columns
          ..._marketColumns.map((col) {
            final market = _findMarket(col.marketId);
            final odds = market != null
                ? oddsByMarket[market.marketKey] ?? []
                : <OddsData>[];
            final mainOdds = odds.isNotEmpty ? odds.first : null;

            return Expanded(
              flex: 2,
              child: _OddsCell(
                marketType: col.type,
                odds: mainOdds,
                isSuspended: market?.isSuspended ?? true,
              ),
            );
          }),
        ],
      ),
    );
  }

  MarketData? _findMarket(int marketId) {
    try {
      return markets.firstWhere((m) => m.marketId == marketId);
    } catch (_) {
      return null;
    }
  }
}

/// Odds Cell Widget
class _OddsCell extends StatelessWidget {
  final MarketType marketType;
  final OddsData? odds;
  final bool isSuspended;

  const _OddsCell({
    required this.marketType,
    required this.odds,
    required this.isSuspended,
  });

  @override
  Widget build(BuildContext context) {
    if (odds == null || isSuspended) {
      return const Center(
        child: Text(
          '-',
          style: TextStyle(color: Colors.grey, fontSize: 10),
        ),
      );
    }

    // Determine display based on market type
    switch (marketType) {
      case MarketType.oneXTwo:
        return _build1X2Odds();
      case MarketType.asianHandicap:
        return _buildHandicapOdds();
      case MarketType.overUnder:
        return _buildOverUnderOdds();
    }
  }

  Widget _build1X2Odds() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildOddButton(odds!.oddsHome, '1', odds!.homeDirection),
        _buildOddButton(odds!.oddsDraw, 'X', odds!.drawDirection),
        _buildOddButton(odds!.oddsAway, '2', odds!.awayDirection),
      ],
    );
  }

  Widget _buildHandicapOdds() {
    final points = odds!.points ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Home with handicap
        _buildOddRow(
          points.isNotEmpty ? points : '-',
          odds!.oddsHome,
          odds!.homeDirection,
        ),
        const SizedBox(height: 2),
        // Away with handicap
        _buildOddRow(
          points.isNotEmpty ? _invertPoints(points) : '-',
          odds!.oddsAway,
          odds!.awayDirection,
        ),
      ],
    );
  }

  Widget _buildOverUnderOdds() {
    final points = odds!.points ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Over
        _buildOddRow(
          points.isNotEmpty ? 'O $points' : 'O',
          odds!.oddsHome,
          odds!.homeDirection,
        ),
        const SizedBox(height: 2),
        // Under
        _buildOddRow(
          points.isNotEmpty ? 'U $points' : 'U',
          odds!.oddsAway,
          odds!.awayDirection,
        ),
      ],
    );
  }

  Widget _buildOddButton(double? value, String label, OddsDirection direction) {
    final color = _getDirectionColor(direction);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        value != null ? value.toStringAsFixed(2) : '-',
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOddRow(String label, double? value, OddsDirection direction) {
    final color = _getDirectionColor(direction);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.white60),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            value != null ? value.toStringAsFixed(2) : '-',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Color _getDirectionColor(OddsDirection direction) {
    switch (direction) {
      case OddsDirection.up:
        return Colors.green;
      case OddsDirection.down:
        return Colors.red;
      case OddsDirection.none:
        return Colors.white;
    }
  }

  String _invertPoints(String points) {
    if (points.isEmpty) return points;
    if (points.startsWith('-')) {
      return points.substring(1);
    } else if (points.startsWith('+')) {
      return '-${points.substring(1)}';
    } else {
      return '-$points';
    }
  }
}

// ============ Market Column Definitions ============

enum MarketType { oneXTwo, asianHandicap, overUnder }

class MarketColumn {
  final int marketId;
  final String name;
  final String shortName;
  final MarketType type;

  const MarketColumn({
    required this.marketId,
    required this.name,
    required this.shortName,
    required this.type,
  });
}

/// 6 Market Columns
/// | 1 | Market1X2FT     | 1X2 Full Time        |
/// | 2 | Market1X2HT     | 1X2 Half Time        |
/// | 3 | OverUnderFT     | Over/Under Full Time |
/// | 4 | OverUnderHT     | Over/Under Half Time |
/// | 5 | AsianHandicapFT | Asian Handicap FT    |
/// | 6 | AsianHandicapHT | Asian Handicap HT    |
const List<MarketColumn> _marketColumns = [
  MarketColumn(
    marketId: 1,
    name: '1X2 Full Time',
    shortName: '1X2 FT',
    type: MarketType.oneXTwo,
  ),
  MarketColumn(
    marketId: 2,
    name: '1X2 Half Time',
    shortName: '1X2 HT',
    type: MarketType.oneXTwo,
  ),
  MarketColumn(
    marketId: 3,
    name: 'Over/Under Full Time',
    shortName: 'O/U FT',
    type: MarketType.overUnder,
  ),
  MarketColumn(
    marketId: 4,
    name: 'Over/Under Half Time',
    shortName: 'O/U HT',
    type: MarketType.overUnder,
  ),
  MarketColumn(
    marketId: 5,
    name: 'Asian Handicap Full Time',
    shortName: 'HDP FT',
    type: MarketType.asianHandicap,
  ),
  MarketColumn(
    marketId: 6,
    name: 'Asian Handicap Half Time',
    shortName: 'HDP HT',
    type: MarketType.asianHandicap,
  ),
];
