import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';
import 'package:sport_socket/src/processor/payload_router.dart';
import 'package:sport_socket/src/data/sport_data_store.dart';
import 'package:sport_socket/src/proto/proto.dart';

void main() {
  group('PayloadRouter', () {
    late PayloadRouter router;
    late SportDataStore store;

    setUp(() {
      router = PayloadRouter();
      store = SportDataStore();
    });

    tearDown(() {
      store.dispose();
    });

    group('Channel Pattern Detection', () {
      test('detects league channel correctly', () {
        final payload = Payload()
          ..channel = 'ln:vi:s:1:l'
          ..type = 'i'
          ..league = (LeagueResponse()
            ..leagueId = 100
            ..sportId = 1
            ..leagueName = 'Test League');

        // Should route without error
        router.route(payload, store);

        expect(store.hasLeague(100), isTrue);
      });

      test('detects match channel correctly', () {
        // First create league
        store.upsertLeagueFromJson({'leagueId': 100, 'sportId': 1});

        final payload = Payload()
          ..channel = 'ln:vi:s:1:tr:0:e'
          ..type = 'u'
          ..event = (EventResponse()
            ..eventId = Int64(1000)
            ..leagueId = 100
            ..sportId = 1
            ..homeName = 'Home Team'
            ..awayName = 'Away Team');

        router.route(payload, store);

        expect(store.hasEvent(1000), isTrue);
      });

      test('detects hot channel correctly', () {
        final hotEvent = HotEventResponse()
          ..leagueId = 200
          ..leagueName = 'Hot League'
          ..leagueOrder = 1
          ..leaguePriorityOrder = 10
          ..event = (EventResponse()
            ..eventId = Int64(2000)
            ..leagueId = 200
            ..sportId = 1
            ..homeName = 'Hot Home'
            ..awayName = 'Hot Away');

        final payload = Payload()
          ..channel = 'ln:vi:s:1:e:hot'
          ..type = 'u'
          ..hotEvent = (HotEventsResponse()..events.add(hotEvent));

        router.route(payload, store);

        expect(store.hasLeague(200), isTrue);
        expect(store.hasEvent(2000), isTrue);
      });

      test('detects outright channel correctly', () {
        final payload = Payload()
          ..channel = 'ln:vi:s:1:e:ort'
          ..type = 'u'
          ..outright = (OutrightEventResponse()
            ..eventId = Int64(3000)
            ..sportId = 1
            ..leagueId = 300
            ..eventName = 'Tournament Winner');

        router.route(payload, store);

        final outright = store.getEvent(3000);
        expect(outright, isNotNull);
        expect(outright!.homeName, equals('Tournament Winner'));
      });

      test('detects match detail channel correctly', () {
        // First create league
        store.upsertLeagueFromJson({'leagueId': 100, 'sportId': 1});

        final payload = Payload()
          ..channel = 'ln:vi:e:12345'
          ..type = 'u'
          ..event = (EventResponse()
            ..eventId = Int64(12345)
            ..leagueId = 100
            ..sportId = 1
            ..homeName = 'Detail Home'
            ..awayName = 'Detail Away');

        router.route(payload, store);

        expect(store.hasEvent(12345), isTrue);
      });
    });

    group('Message Type Handling', () {
      test('handles league insert (i) type', () {
        router.subscribeTimeRange(0);

        final payload = Payload()
          ..channel = 'ln:vi:s:1:l'
          ..type = 'i'
          ..timeRange = 0
          ..league = (LeagueResponse()
            ..leagueId = 500
            ..sportId = 1
            ..leagueName = 'Inserted League');

        router.route(payload, store);

        expect(store.hasLeague(500), isTrue);
      });

      test('handles event update (u) type', () {
        store.upsertLeagueFromJson({'leagueId': 100, 'sportId': 1});

        final payload = Payload()
          ..channel = 'ln:vi:s:1:tr:0:e'
          ..type = 'u'
          ..event = (EventResponse()
            ..eventId = Int64(5000)
            ..leagueId = 100
            ..sportId = 1
            ..homeName = 'Updated Home'
            ..awayName = 'Updated Away');

        router.route(payload, store);

        final event = store.getEvent(5000);
        expect(event, isNotNull);
        expect(event!.homeName, equals('Updated Home'));
      });

      test('handles event remove (r) type', () {
        store.upsertLeagueFromJson({'leagueId': 100, 'sportId': 1});
        store.upsertEventFromJson({
          'eventId': 6000,
          'leagueId': 100,
          'sportId': 1,
          'homeName': 'To Remove',
          'awayName': 'Away',
        });

        expect(store.hasEvent(6000), isTrue);

        final payload = Payload()
          ..channel = 'ln:vi:s:1:tr:0:e'
          ..type = 'r'
          ..event = (EventResponse()..eventId = Int64(6000));

        router.route(payload, store);

        expect(store.hasEvent(6000), isFalse);
      });
    });

    group('Time Range Filtering', () {
      test('filters league insert by subscribed timeRange', () {
        // Subscribe to timeRange 0 (live)
        router.subscribeTimeRange(0);

        // Insert for timeRange 1 (today) - should be filtered
        final payload = Payload()
          ..channel = 'ln:vi:s:1:l'
          ..type = 'i'
          ..timeRange = 1
          ..league = (LeagueResponse()
            ..leagueId = 700
            ..sportId = 1
            ..leagueName = 'Filtered League');

        router.route(payload, store);

        // Should NOT be inserted because timeRange 1 is not subscribed
        expect(store.hasLeague(700), isFalse);
      });

      test('allows league insert for subscribed timeRange', () {
        router.subscribeTimeRange(1);

        final payload = Payload()
          ..channel = 'ln:vi:s:1:l'
          ..type = 'i'
          ..timeRange = 1
          ..league = (LeagueResponse()
            ..leagueId = 800
            ..sportId = 1
            ..leagueName = 'Allowed League');

        router.route(payload, store);

        expect(store.hasLeague(800), isTrue);
      });

      test('clearTimeRangeSubscriptions clears all subscriptions', () {
        router.subscribeTimeRange(0);
        router.subscribeTimeRange(1);
        router.clearTimeRangeSubscriptions();

        // With no subscriptions, all timeRanges should be allowed
        final payload = Payload()
          ..channel = 'ln:vi:s:1:l'
          ..type = 'i'
          ..timeRange = 2
          ..league = (LeagueResponse()
            ..leagueId = 900
            ..sportId = 1
            ..leagueName = 'Any TimeRange League');

        router.route(payload, store);

        expect(store.hasLeague(900), isTrue);
      });
    });

    group('Nested Data Parsing', () {
      test('parses markets from event', () {
        store.upsertLeagueFromJson({'leagueId': 100, 'sportId': 1});

        final market = MarketResponse()
          ..marketId = 10
          ..sportId = 1
          ..leagueId = 100
          ..eventId = Int64(10000);

        final payload = Payload()
          ..channel = 'ln:vi:s:1:tr:0:e'
          ..type = 'u'
          ..event = (EventResponse()
            ..eventId = Int64(10000)
            ..leagueId = 100
            ..sportId = 1
            ..homeName = 'Home'
            ..awayName = 'Away'
            ..markets.add(market));

        router.route(payload, store);

        expect(store.hasMarket(10000, 10), isTrue);
      });

      test('parses odds from market', () {
        store.upsertLeagueFromJson({'leagueId': 100, 'sportId': 1});

        final odds = OddsResponse()
          ..strOfferId = 'offer123'
          ..selectionHomeId = 'h1'
          ..selectionAwayId = 'a1'
          ..oddsHome = (OddsStyleResponse()..decimal = '1.85')
          ..oddsAway = (OddsStyleResponse()..decimal = '2.10');

        final market = MarketResponse()
          ..marketId = 20
          ..sportId = 1
          ..leagueId = 100
          ..eventId = Int64(20000)
          ..oddsList.add(odds);

        final payload = Payload()
          ..channel = 'ln:vi:s:1:tr:0:e'
          ..type = 'u'
          ..event = (EventResponse()
            ..eventId = Int64(20000)
            ..leagueId = 100
            ..sportId = 1
            ..homeName = 'Home'
            ..awayName = 'Away'
            ..markets.add(market));

        router.route(payload, store);

        expect(store.hasOdds(20000, 20, 'offer123'), isTrue);
      });
    });

    group('Batch Processing', () {
      test('routeBatch processes multiple payloads', () {
        store.upsertLeagueFromJson({'leagueId': 100, 'sportId': 1});

        final payloads = [
          Payload()
            ..channel = 'ln:vi:s:1:tr:0:e'
            ..type = 'u'
            ..event = (EventResponse()
              ..eventId = Int64(30001)
              ..leagueId = 100
              ..sportId = 1
              ..homeName = 'Home 1'
              ..awayName = 'Away 1'),
          Payload()
            ..channel = 'ln:vi:s:1:tr:0:e'
            ..type = 'u'
            ..event = (EventResponse()
              ..eventId = Int64(30002)
              ..leagueId = 100
              ..sportId = 1
              ..homeName = 'Home 2'
              ..awayName = 'Away 2'),
          Payload()
            ..channel = 'ln:vi:s:1:tr:0:e'
            ..type = 'u'
            ..event = (EventResponse()
              ..eventId = Int64(30003)
              ..leagueId = 100
              ..sportId = 1
              ..homeName = 'Home 3'
              ..awayName = 'Away 3'),
        ];

        router.routeBatch(payloads, store);

        expect(store.hasEvent(30001), isTrue);
        expect(store.hasEvent(30002), isTrue);
        expect(store.hasEvent(30003), isTrue);
      });
    });
  });
}
