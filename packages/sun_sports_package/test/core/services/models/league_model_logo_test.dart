import 'package:flutter_test/flutter_test.dart';
import 'package:sun_sports/core/services/models/league_model.dart';

/// Test logo fallback logic
/// Verifies that homeLogo and awayLogo getters match Web logic:
/// - homeLogo = hf || hl || ''
/// - awayLogo = af || al || ''
void main() {
  group('LeagueEventData Logo Fallback Logic', () {
    test('homeLogo returns hf when both hf and hl exist', () {
      final event = LeagueEventData(
        homeLogoFirst: 'https://cdn.example.com/team-primary.png',
        homeLogoLast: 'https://cdn.example.com/team-fallback.png',
      );

      expect(event.homeLogo, 'https://cdn.example.com/team-primary.png');
    });

    test('homeLogo returns hl when hf is null', () {
      final event = LeagueEventData(
        homeLogoFirst: null,
        homeLogoLast: 'https://cdn.example.com/team-fallback.png',
      );

      expect(event.homeLogo, 'https://cdn.example.com/team-fallback.png');
    });

    test('homeLogo returns hl when hf is empty', () {
      final event = LeagueEventData(
        homeLogoFirst: '',
        homeLogoLast: 'https://cdn.example.com/team-fallback.png',
      );

      expect(event.homeLogo, 'https://cdn.example.com/team-fallback.png');
    });

    test('homeLogo returns empty string when both are null', () {
      final event = LeagueEventData(homeLogoFirst: null, homeLogoLast: null);

      expect(event.homeLogo, '');
    });

    test('homeLogo returns empty string when both are empty', () {
      final event = LeagueEventData(homeLogoFirst: '', homeLogoLast: '');

      expect(event.homeLogo, '');
    });

    test('awayLogo returns af when both af and al exist', () {
      final event = LeagueEventData(
        awayLogoFirst: 'https://cdn.example.com/away-primary.png',
        awayLogoLast: 'https://cdn.example.com/away-fallback.png',
      );

      expect(event.awayLogo, 'https://cdn.example.com/away-primary.png');
    });

    test('awayLogo returns al when af is null', () {
      final event = LeagueEventData(
        awayLogoFirst: null,
        awayLogoLast: 'https://cdn.example.com/away-fallback.png',
      );

      expect(event.awayLogo, 'https://cdn.example.com/away-fallback.png');
    });

    test('awayLogo returns al when af is empty', () {
      final event = LeagueEventData(
        awayLogoFirst: '',
        awayLogoLast: 'https://cdn.example.com/away-fallback.png',
      );

      expect(event.awayLogo, 'https://cdn.example.com/away-fallback.png');
    });

    test('awayLogo returns empty string when both are null', () {
      final event = LeagueEventData(awayLogoFirst: null, awayLogoLast: null);

      expect(event.awayLogo, '');
    });

    test('awayLogo returns empty string when both are empty', () {
      final event = LeagueEventData(awayLogoFirst: '', awayLogoLast: '');

      expect(event.awayLogo, '');
    });

    test('fromJson parses logo fields correctly', () {
      final json = {
        'ei': 12345,
        'hn': 'Man Utd',
        'an': 'Liverpool',
        'hf': 'https://cdn.example.com/manutd.png',
        'hl': 'https://cdn.example.com/manutd-fallback.png',
        'af': 'https://cdn.example.com/liverpool.png',
        'al': 'https://cdn.example.com/liverpool-fallback.png',
        'st': 1234567890000,
        'hs': 2,
        'as': 1,
        'il': true,
        'min': 45,
        'm': <dynamic>[],
      };

      final event = LeagueEventData.fromJson(json);

      expect(event.homeLogoFirst, 'https://cdn.example.com/manutd.png');
      expect(event.homeLogoLast, 'https://cdn.example.com/manutd-fallback.png');
      expect(event.awayLogoFirst, 'https://cdn.example.com/liverpool.png');
      expect(
        event.awayLogoLast,
        'https://cdn.example.com/liverpool-fallback.png',
      );

      // Test getter logic
      expect(event.homeLogo, 'https://cdn.example.com/manutd.png'); // Uses hf
      expect(
        event.awayLogo,
        'https://cdn.example.com/liverpool.png',
      ); // Uses af
    });

    test('fromJson with missing logo fields uses fallback', () {
      final json = {
        'ei': 12345,
        'hn': 'Man Utd',
        'an': 'Liverpool',
        'hl': 'https://cdn.example.com/manutd-fallback.png',
        'al': 'https://cdn.example.com/liverpool-fallback.png',
        'st': 1234567890000,
        'hs': 2,
        'as': 1,
        'il': false,
        'm': <dynamic>[],
      };

      final event = LeagueEventData.fromJson(json);

      expect(event.homeLogoFirst, isNull);
      expect(event.homeLogoLast, 'https://cdn.example.com/manutd-fallback.png');
      expect(event.awayLogoFirst, isNull);
      expect(
        event.awayLogoLast,
        'https://cdn.example.com/liverpool-fallback.png',
      );

      // Test getter logic - should use fallback
      expect(event.homeLogo, 'https://cdn.example.com/manutd-fallback.png');
      expect(event.awayLogo, 'https://cdn.example.com/liverpool-fallback.png');
    });

    test('LeagueData parses leagueLogo correctly', () {
      final json = {
        'li': 100,
        'ln': 'Premier League',
        'lg': 'https://cdn.example.com/premier-league.png',
        'e': <dynamic>[],
      };

      final league = LeagueData.fromJson(json);

      expect(league.leagueLogo, 'https://cdn.example.com/premier-league.png');
    });
  });
}
