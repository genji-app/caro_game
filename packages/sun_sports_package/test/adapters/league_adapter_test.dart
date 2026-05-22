import 'package:flutter_test/flutter_test.dart';
import 'package:sport_socket/sport_socket.dart' as socket;
import 'package:sun_sports/core/services/adapters/league_adapter.dart';

void main() {
  group('LeagueAdapter', () {
    group('toFreezed', () {
      test('converts basic league data', () {
        final source = socket.LeagueData(
          leagueId: 123,
          sportId: 1,
          name: 'Premier League',
          priorityOrder: 1,
          logoUrl: 'https://example.com/logo.png',
        );

        final result = LeagueAdapter.toFreezed(source);

        expect(result.leagueId, equals(123));
        expect(result.leagueName, equals('Premier League'));
        expect(result.leagueLogo, equals('https://example.com/logo.png'));
        expect(result.priorityOrder, equals(1));
        expect(result.events, isEmpty);
      });

      test('handles null logoUrl', () {
        final source = socket.LeagueData(
          leagueId: 123,
          sportId: 1,
          name: 'La Liga',
        );

        final result = LeagueAdapter.toFreezed(source);

        expect(result.leagueLogo, isEmpty);
      });
    });

    group('toFreezedList', () {
      test('converts multiple leagues', () {
        final sources = [
          socket.LeagueData(leagueId: 1, sportId: 1, name: 'League 1'),
          socket.LeagueData(leagueId: 2, sportId: 1, name: 'League 2'),
          socket.LeagueData(leagueId: 3, sportId: 1, name: 'League 3'),
        ];

        final result = LeagueAdapter.toFreezedList(sources);

        expect(result.length, equals(3));
        expect(result[0].leagueName, equals('League 1'));
        expect(result[1].leagueName, equals('League 2'));
        expect(result[2].leagueName, equals('League 3'));
      });
    });

    group('toFreezedWithEvents', () {
      test('converts league with events and markets', () {
        final league = socket.LeagueData(
          leagueId: 123,
          sportId: 1,
          name: 'Premier League',
        );

        final events = [
          socket.EventData(
            eventId: 100,
            leagueId: 123,
            sportId: 1,
            homeName: 'Team A',
            awayName: 'Team B',
            isLive: true,
            homeScore: 2,
            awayScore: 1,
          ),
        ];

        final marketsPerEvent = <int, List<socket.MarketData>>{
          100: [socket.MarketData(marketId: 5, eventId: 100)],
        };

        final oddsPerMarket = <String, List<socket.OddsData>>{
          '100_5': [
            socket.OddsData(
              offerId: 'offer1',
              eventId: 100,
              marketId: 5,
              oddsHome: 1.5,
              oddsAway: 2.5,
            ),
          ],
        };

        final result = LeagueAdapter.toFreezedWithEvents(
          league,
          events,
          marketsPerEvent,
          oddsPerMarket,
        );

        expect(result.leagueId, equals(123));
        expect(result.events.length, equals(1));
        expect(result.events[0].eventId, equals(100));
        expect(result.events[0].homeName, equals('Team A'));
        expect(result.events[0].homeScore, equals(2));
        expect(result.events[0].isLive, isTrue);
        expect(result.events[0].markets.length, equals(1));
        expect(result.events[0].markets[0].marketId, equals(5));
        expect(result.events[0].markets[0].odds.length, equals(1));
      });
    });
  });

  group('EventAdapter', () {
    group('toFreezed', () {
      test('converts basic event data', () {
        final source = socket.EventData(
          eventId: 100,
          leagueId: 123,
          sportId: 1,
          homeName: 'Manchester United',
          awayName: 'Liverpool',
          homeId: 1,
          awayId: 2,
          isLive: false,
          status: 'ACTIVE',
        );

        final result = EventAdapter.toFreezed(source);

        expect(result.eventId, equals(100));
        expect(result.homeName, equals('Manchester United'));
        expect(result.awayName, equals('Liverpool'));
        expect(result.homeId, equals(1));
        expect(result.awayId, equals(2));
        expect(result.isLive, isFalse);
        expect(result.isSuspended, isFalse);
      });

      test('converts live event with scores', () {
        final source = socket.EventData(
          eventId: 100,
          leagueId: 123,
          sportId: 1,
          homeName: 'Team A',
          awayName: 'Team B',
          isLive: true,
          homeScore: 3,
          awayScore: 2,
          gameTime: 2700000, // 45 minutes in ms
          gamePart: 1,
          cornersHome: 5,
          cornersAway: 3,
          redCardsHome: 0,
          redCardsAway: 1,
        );

        final result = EventAdapter.toFreezed(source);

        expect(result.isLive, isTrue);
        expect(result.homeScore, equals(3));
        expect(result.awayScore, equals(2));
        expect(result.gameTime, equals(2700000));
        expect(result.gamePart, equals(1));
        expect(result.cornersHome, equals(5));
        expect(result.cornersAway, equals(3));
        expect(result.redCardsHome, equals(0));
        expect(result.redCardsAway, equals(1));
      });

      test('handles suspended status', () {
        final source = socket.EventData(
          eventId: 100,
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

    group('updateFreezed', () {
      test('updates existing event with new live data', () {
        final existing = EventAdapter.toFreezed(
          socket.EventData(
            eventId: 100,
            leagueId: 123,
            sportId: 1,
            homeName: 'Team A',
            awayName: 'Team B',
            homeScore: 0,
            awayScore: 0,
          ),
        );

        final source = socket.EventData(
          eventId: 100,
          leagueId: 123,
          sportId: 1,
          homeName: 'Team A',
          awayName: 'Team B',
          isLive: true,
          homeScore: 1,
          awayScore: 0,
          gameTime: 600000, // 10 minutes
        );

        final result = EventAdapter.updateFreezed(existing, source);

        expect(result.homeScore, equals(1));
        expect(result.awayScore, equals(0));
        expect(result.isLive, isTrue);
        expect(result.gameTime, equals(600000));
        // Original fields preserved
        expect(result.homeName, equals('Team A'));
        expect(result.awayName, equals('Team B'));
      });
    });
  });

  group('MarketAdapter', () {
    group('toFreezed', () {
      test('converts market with odds', () {
        final source = socket.MarketData(marketId: 5, eventId: 100);

        final odds = [
          socket.OddsData(
            offerId: 'offer1',
            eventId: 100,
            marketId: 5,
            points: '-0.5',
            isMainLine: true,
            oddsHome: 1.85,
            oddsAway: 2.00,
          ),
          socket.OddsData(
            offerId: 'offer2',
            eventId: 100,
            marketId: 5,
            points: '-1.0',
            isMainLine: false,
            oddsHome: 2.10,
            oddsAway: 1.75,
          ),
        ];

        final result = MarketAdapter.toFreezed(source, odds);

        expect(result.marketId, equals(5));
        expect(result.odds.length, equals(2));
        expect(result.odds[0].points, equals('-0.5'));
        expect(result.odds[0].isMainLine, isTrue);
        expect(result.odds[1].points, equals('-1.0'));
        expect(result.odds[1].isMainLine, isFalse);
      });
    });
  });

  group('OddsAdapter', () {
    group('toFreezed', () {
      test('converts odds with all values', () {
        final source = socket.OddsData(
          offerId: 'offer1',
          eventId: 100,
          marketId: 5,
          points: '-0.5',
          isMainLine: true,
          oddsHome: 1.85,
          oddsAway: 2.00,
          oddsDraw: 3.50,
          malayHome: '0.85',
          malayAway: '-1.00',
          hkHome: '0.85',
          hkAway: '1.00',
        );

        final result = OddsAdapter.toFreezed(source);

        expect(result.points, equals('-0.5'));
        expect(result.isMainLine, isTrue);
        expect(result.offerId, equals('offer1'));
        expect(result.oddsHome.decimal, equals(1.85));
        expect(result.oddsAway.decimal, equals(2.00));
        expect(result.oddsDraw.decimal, equals(3.50));
        expect(result.oddsHome.malay, equals(0.85));
        expect(result.oddsHome.hongKong, equals(0.85));
      });

      test('handles missing optional values', () {
        final source = socket.OddsData(
          offerId: 'offer1',
          eventId: 100,
          marketId: 5,
          oddsHome: 1.50,
          oddsAway: 2.50,
        );

        final result = OddsAdapter.toFreezed(source);

        expect(result.points, isEmpty);
        expect(result.isMainLine, isFalse);
        expect(result.oddsHome.decimal, equals(1.50));
        expect(result.oddsAway.decimal, equals(2.50));
        expect(result.oddsDraw.decimal, equals(-100));
        expect(result.oddsHome.malay, equals(-100));
      });
    });
  });
}
