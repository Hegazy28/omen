import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:omen/component/matches/match_model.dart';

class SportsrcMatchesService {
  static const String _url =
      'https://api.sportsrc.org/?data=matches&category=football';

  Future<List<MatchModel>> fetchMatches() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch matches (${response.statusCode})');
    }

    if (response.body.trim().isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(response.body);
    final rawList = _extractList(decoded);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(_toMatch)
        .whereType<MatchModel>()
        .toList();
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      for (final key in ['matches', 'data', 'response', 'events']) {
        final value = decoded[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  MatchModel? _toMatch(Map<String, dynamic> json) {
    final homeName =
        (json['homeTeam'] ?? json['home'] ?? json['teamA'] ?? '').toString();
    final awayName =
        (json['awayTeam'] ?? json['away'] ?? json['teamB'] ?? '').toString();
    if (homeName.isEmpty || awayName.isEmpty) return null;

    final dateRaw = (json['date'] ?? json['kickoff'] ?? json['startTime'] ?? '')
        .toString();
    final kickoff = DateTime.tryParse(dateRaw) ?? DateTime.now();

    final statusRaw = (json['status'] ?? '').toString().toLowerCase();
    final status = _statusFrom(statusRaw);

    final score = (json['score'] ?? '').toString();
    final scoreParts = score.split(RegExp(r'\s*[-:]\s*'));
    final homeScore = int.tryParse(scoreParts.isNotEmpty ? scoreParts[0] : '');
    final awayScore = int.tryParse(scoreParts.length > 1 ? scoreParts[1] : '');

    final league =
        (json['league'] ?? json['competition'] ?? json['matchType'] ?? '')
            .toString();

    final home = TeamModel(
      id: homeName.toLowerCase().replaceAll(' ', '_'),
      name: homeName,
      shortName: _shortName(homeName),
      logoAsset: 'assets/Logo.png',
    );

    final away = TeamModel(
      id: awayName.toLowerCase().replaceAll(' ', '_'),
      name: awayName,
      shortName: _shortName(awayName),
      logoAsset: 'assets/Logo.png',
    );

    return MatchModel(
      id: (json['id'] ?? '$homeName-$awayName-${kickoff.toIso8601String()}')
          .toString(),
      home: home,
      away: away,
      competition: _competitionFrom(league),
      status: status,
      kickoff: kickoff,
      homeScore: status == MatchStatus.upcoming ? null : homeScore,
      awayScore: status == MatchStatus.upcoming ? null : awayScore,
      isFavouriteMatch:
          homeName.toLowerCase().contains('barcelona') ||
          awayName.toLowerCase().contains('barcelona'),
    );
  }

  String _shortName(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      final end = words.first.length < 3 ? words.first.length : 3;
      return words.first.substring(0, end).toUpperCase();
    }
    return words.take(3).map((word) => word[0]).join().toUpperCase();
  }

  MatchStatus _statusFrom(String raw) {
    if (raw.contains('live') || raw.contains('progress') || raw.contains('1h')) {
      return MatchStatus.live;
    }
    if (raw.contains('finished') || raw.contains('ft') || raw.contains('ended')) {
      return MatchStatus.finished;
    }
    return MatchStatus.upcoming;
  }

  MatchCompetition _competitionFrom(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('champions')) return MatchCompetition.championsLeague;
    if (value.contains('copa')) return MatchCompetition.copaDelRey;
    if (value.contains('super')) return MatchCompetition.supercopa;
    if (value.contains('liga')) return MatchCompetition.laLiga;
    if (value.contains('friend')) return MatchCompetition.friendly;
    return MatchCompetition.friendly;
  }
}
