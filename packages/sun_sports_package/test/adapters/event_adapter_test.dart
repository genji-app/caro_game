import 'package:flutter_test/flutter_test.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/core/services/adapters/league_adapter.dart';

void main() {
  group('EventAdapter', () {
    group('toFreezed', () {
      test('converts event with all fields', () {
        final source = socket.EventData(
          eventId: 100,
          leagueId: 123,
          sportId: 1,
          homeName: 'Manchester United',
          awayName: 'Liverpool',
          homeId: 1,
          awayId: 2,
          homeLogo: 'https://example.com/mu.png',
          awayLogo: 'https://example.com/lfc.png',
          isLive: true,
          isGoingLive: false,
          isLiveStream: true,
          status: 'ACTIVE',
          startDate: DateTime(2024, 1, 15, 20, 0),
          homeScore: 2,
          awayScore: 1,
          gameTime: 3600000, // 60 min
          gamePart: 2,
          stoppageTime: 180000, // 3 min stoppage
          cornersHome: 6,
          cornersAway: 4,
          redCardsHome: 0,
          redCardsAway: 1,
          yellowCardsHome: 2,
          yellowCardsAway: 3,
        );

        final result = EventAdapter.toFreezed(source);

        expect(result.eventId, equals(100));
        expect(result.homeName, equals('Manchester United'));
        expect(result.awayName, equals('Liverpool'));
        expect(result.homeId, equals(1));
        expect(result.awayId, equals(2));
        expect(result.homeLogoFirst, equals('https://example.com/mu.png'));
        expect(result.awayLogoFirst, equals('https://example.com/lfc.png'));
        expect(result.isLive, isTrue);
        expect(result.isGoingLive, isFalse);
        expect(result.isLivestream, isTrue);
        expect(result.isSuspended, isFalse);
        expect(result.homeScore, equals(2));
        expect(result.awayScore, equals(1));
        expect(result.gameTime, equals(3600000));
        expect(result.gamePart, equals(2));
        expect(result.stoppageTime, equals(180000));
        expect(result.cornersHome, equals(6));
        expect(result.cornersAway, equals(4));
        expect(result.redCardsHome, equals(0));
        expect(result.redCardsAway, equals(1));
        expect(result.yellowCardsHome, equals(2));
        expect(result.yellowCardsAway, equals(3));
      });

      test('converts pre-match event', () {
        final source = socket.EventData(
          eventId: 200,
          leagueId: 123,
          sportId: 1,
          homeName: 'Barcelona',
          awayName: 'Real Madrid',
          isLive: false,
          status: 'ACTIVE',
          startDate: DateTime(2024, 1, 20, 21, 0),
        );

        final result = EventAdapter.toFreezed(source);

        expect(result.isLive, isFalse);
        expect(result.homeScore, equals(0));
        expect(result.awayScore, equals(0));
        expect(result.gameTime, equals(0));
        expect(result.gamePart, equals(0));
      });

      test('marks suspended events correctly', () {
        final source = socket.EventData(
          eventId: 300,
          leagueId: 123,
          sportId: 1,
          homeName: 'Team A',
          awayName: 'Team B',
          status: 'SUSPENDED',
        );

        final result = EventAdapter.toFreezed(source);

        expect(result.isSuspended, isTrue);
        expect(result.eventStatus, equals('SUSPENDED'));
      });
    });

    group('toFreezedWithMarkets', () {
      test('converts event with markets and odds', () {
        final source = socket.EventData(
          eventId: 100,
          leagueId: 123,
          sportId: 1,
          homeName: 'Team A',
          awayName: 'Team B',
          isLive: true,
        );

        final markets = [
          socket.MarketData(marketId: 5, eventId: 100), // Handicap
          socket.MarketData(marketId: 3, eventId: 100), // Over/Under
          socket.MarketData(marketId: 1, eventId: 100), // 1X2
        ];

        final oddsPerMarket = <String, List<socket.OddsData>>{
          '100_5': [
            socket.OddsData(
              offerId: 'hcp1',
              eventId: 100,
              marketId: 5,
              points: '-0.5',
              isMainLine: true,
              oddsHome: 1.90,
              oddsAway: 1.95,
            ),
          ],
          '100_3': [
            socket.OddsData(
              offerId: 'ou1',
              eventId: 100,
              marketId: 3,
              points: '2.5',
              isMainLine: true,
              oddsHome: 1.85, // Under (API sends Under in home field)
              oddsAway: 2.00, // Over (API sends Over in away field)
            ),
          ],
          '100_1': [
            socket.OddsData(
              offerId: '1x2',
              eventId: 100,
              marketId: 1,
              oddsHome: 2.20,
              oddsAway: 3.50,
              oddsDraw: 3.10,
            ),
          ],
        };

        final result = EventAdapter.toFreezedWithMarkets(
          source,
          markets,
          oddsPerMarket,
        );

        expect(result.eventId, equals(100));
        expect(result.markets.length, equals(3));
        expect(result.totalMarketsCount, equals(3));

        // Check Handicap market
        final handicapMarket = result.markets.firstWhere(
          (m) => m.marketId == 5,
        );
        expect(handicapMarket.odds.length, equals(1));
        expect(handicapMarket.odds[0].points, equals('-0.5'));
        expect(handicapMarket.odds[0].isMainLine, isTrue);

        // Check 1X2 market
        final x2Market = result.markets.firstWhere((m) => m.marketId == 1);
        expect(x2Market.odds.length, equals(1));
        expect(x2Market.odds[0].oddsHome.decimal, equals(2.20));
        expect(x2Market.odds[0].oddsDraw.decimal, equals(3.10));
      });

      test('handles empty markets', () {
        final source = socket.EventData(
          eventId: 100,
          leagueId: 123,
          sportId: 1,
          homeName: 'Team A',
          awayName: 'Team B',
        );

        final result = EventAdapter.toFreezedWithMarkets(source, [], {});

        expect(result.markets, isEmpty);
        expect(result.totalMarketsCount, equals(0));
      });
    });

    group('updateFreezed', () {
      test('updates score and time', () {
        final existing = EventAdapter.toFreezed(
          socket.EventData(
            eventId: 100,
            leagueId: 123,
            sportId: 1,
            homeName: 'Team A',
            awayName: 'Team B',
            homeScore: 0,
            awayScore: 0,
            gameTime: 0,
          ),
        );

        final update = socket.EventData(
          eventId: 100,
          leagueId: 123,
          sportId: 1,
          homeName: 'Team A',
          awayName: 'Team B',
          isLive: true,
          homeScore: 2,
          awayScore: 1,
          gameTime: 2700000, // 45 min
          gamePart: 1,
        );

        final result = EventAdapter.updateFreezed(existing, update);

        expect(result.homeScore, equals(2));
        expect(result.awayScore, equals(1));
        expect(result.gameTime, equals(2700000));
        expect(result.gamePart, equals(1));
        expect(result.isLive, isTrue);
      });

      test('updates cards and corners', () {
        final existing = EventAdapter.toFreezed(
          socket.EventData(
            eventId: 100,
            leagueId: 123,
            sportId: 1,
            homeName: 'Team A',
            awayName: 'Team B',
          ),
        );

        final update = socket.EventData(
          eventId: 100,
          leagueId: 123,
          sportId: 1,
          homeName: 'Team A',
          awayName: 'Team B',
          isLive: true,
          cornersHome: 5,
          cornersAway: 3,
          redCardsHome: 1,
          redCardsAway: 0,
          yellowCardsHome: 3,
          yellowCardsAway: 2,
        );

        final result = EventAdapter.updateFreezed(existing, update);

        expect(result.cornersHome, equals(5));
        expect(result.cornersAway, equals(3));
        expect(result.redCardsHome, equals(1));
        expect(result.redCardsAway, equals(0));
        expect(result.yellowCardsHome, equals(3));
        expect(result.yellowCardsAway, equals(2));
      });

      test('preserves original fields not in update', () {
        final existing = EventAdapter.toFreezed(
          socket.EventData(
            eventId: 100,
            leagueId: 123,
            sportId: 1,
            homeName: 'Team A',
            awayName: 'Team B',
            homeId: 10,
            awayId: 20,
            homeLogo: 'logo_a.png',
            awayLogo: 'logo_b.png',
            startDate: DateTime(2024, 1, 15, 20, 0),
          ),
        );

        final update = socket.EventData(
          eventId: 100,
          leagueId: 123,
          sportId: 1,
          homeName: 'Team A',
          awayName: 'Team B',
          homeScore: 1,
        );

        final result = EventAdapter.updateFreezed(existing, update);

        // Updated fields
        expect(result.homeScore, equals(1));

        // Preserved fields
        expect(result.homeName, equals('Team A'));
        expect(result.awayName, equals('Team B'));
        expect(result.homeId, equals(10));
        expect(result.awayId, equals(20));
      });
    });
  });

  group('Integration scenarios', () {
    test('full conversion chain: league -> events -> markets -> odds', () {
      // Create source data
      final league = socket.LeagueData(
        leagueId: 1,
        sportId: 1,
        name: 'Premier League',
        priorityOrder: 1,
        logoUrl: 'https://example.com/pl.png',
      );

      final events = [
        socket.EventData(
          eventId: 100,
          leagueId: 1,
          sportId: 1,
          homeName: 'Man Utd',
          awayName: 'Liverpool',
          isLive: true,
          homeScore: 1,
          awayScore: 1,
          gameTime: 3000000,
        ),
        socket.EventData(
          eventId: 101,
          leagueId: 1,
          sportId: 1,
          homeName: 'Chelsea',
          awayName: 'Arsenal',
          isLive: false,
          startDate: DateTime(2024, 1, 20, 17, 30),
        ),
      ];

      final marketsPerEvent = <int, List<socket.MarketData>>{
        100: [
          socket.MarketData(marketId: 5, eventId: 100),
          socket.MarketData(marketId: 3, eventId: 100),
        ],
        101: [socket.MarketData(marketId: 1, eventId: 101)],
      };

      final oddsPerMarket = <String, List<socket.OddsData>>{
        '100_5': [
          socket.OddsData(
            offerId: 'o1',
            eventId: 100,
            marketId: 5,
            points: '0',
            isMainLine: true,
            oddsHome: 1.90,
            oddsAway: 1.95,
          ),
        ],
        '100_3': [
          socket.OddsData(
            offerId: 'o2',
            eventId: 100,
            marketId: 3,
            points: '2.5',
            oddsHome: 1.85,
            oddsAway: 2.00,
          ),
        ],
        '101_1': [
          socket.OddsData(
            offerId: 'o3',
            eventId: 101,
            marketId: 1,
            oddsHome: 2.50,
            oddsAway: 2.80,
            oddsDraw: 3.20,
          ),
        ],
      };

      // Convert
      final result = LeagueAdapter.toFreezedWithEvents(
        league,
        events,
        marketsPerEvent,
        oddsPerMarket,
      );

      // Verify structure
      expect(result.leagueId, equals(1));
      expect(result.leagueName, equals('Premier League'));
      expect(result.events.length, equals(2));

      // Verify first event (live)
      final liveEvent = result.events[0];
      expect(liveEvent.eventId, equals(100));
      expect(liveEvent.isLive, isTrue);
      expect(liveEvent.homeScore, equals(1));
      expect(liveEvent.markets.length, equals(2));

      // Verify second event (pre-match)
      final preMatchEvent = result.events[1];
      expect(preMatchEvent.eventId, equals(101));
      expect(preMatchEvent.isLive, isFalse);
      expect(preMatchEvent.markets.length, equals(1));
      expect(preMatchEvent.markets[0].odds[0].oddsHome.decimal, equals(2.50));
    });
  });
}
