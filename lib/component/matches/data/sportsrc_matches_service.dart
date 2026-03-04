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
    final rawEvents = _extractPotentialEvents(decoded);

    final matches = rawEvents
        .map(_toMatch)
        .whereType<MatchModel>()
        .toList();

    // Deduplicate by generated id.
    final byId = <String, MatchModel>{};
    for (final match in matches) {
      byId[match.id] = match;
    }

    return byId.values.toList();
  }

  List<Map<String, dynamic>> _extractPotentialEvents(dynamic node) {
    final found = <Map<String, dynamic>>[];

    void walk(dynamic current) {
      if (current is List) {
        for (final item in current) {
          walk(item);
        }
        return;
      }

      if (current is Map<String, dynamic>) {
        if (_looksLikeEvent(current)) {
          found.add(current);
        }

        for (final value in current.values) {
          walk(value);
        }
      }
    }

    walk(node);
    return found;
  }

  bool _looksLikeEvent(Map<String, dynamic> json) {
    final home = _extractTeamName(json, isHome: true);
    final away = _extractTeamName(json, isHome: false);
    return home.isNotEmpty && away.isNotEmpty;
  }

  MatchModel? _toMatch(Map<String, dynamic> json) {
    final homeName = _extractTeamName(json, isHome: true);
    final awayName = _extractTeamName(json, isHome: false);
    if (homeName.isEmpty || awayName.isEmpty) return null;

    final kickoff = _extractKickoff(json);
    final status = _statusFrom(_extractString(json, const [
      'status',
      'strStatus',
      'match_status',
      'state',
    ]).toLowerCase());

    final parsedScore = _extractScore(json);
    final homeLogo = _extractTeamLogo(json, isHome: true);
    final awayLogo = _extractTeamLogo(json, isHome: false);
    final league = _extractString(json, const [
      'league',
      'strLeague',
      'competition',
      'tournament',
      'matchType',
    ]);

    final home = TeamModel(
      id: homeName.toLowerCase().replaceAll(' ', '_'),
      name: homeName,
      shortName: _shortName(homeName),
      logoAsset: homeLogo.isNotEmpty ? homeLogo : 'assets/Logo.png',
    );

    final away = TeamModel(
      id: awayName.toLowerCase().replaceAll(' ', '_'),
      name: awayName,
      shortName: _shortName(awayName),
      logoAsset: awayLogo.isNotEmpty ? awayLogo : 'assets/Logo.png',
    );

    final eventId = _extractString(json, const [
      'id',
      'idEvent',
      'event_id',
      'match_id',
      'fixture_id',
    ]);

    return MatchModel(
      id: eventId.isNotEmpty
          ? eventId
          : '$homeName-$awayName-${kickoff.toIso8601String()}',
      home: home,
      away: away,
      competition: _competitionFrom(league),
      status: status,
      kickoff: kickoff,
      homeScore: status == MatchStatus.upcoming ? null : parsedScore.$1,
      awayScore: status == MatchStatus.upcoming ? null : parsedScore.$2,
      isFavouriteMatch:
          homeName.toLowerCase().contains('barcelona') ||
          awayName.toLowerCase().contains('barcelona'),
    );
  }

  DateTime _extractKickoff(Map<String, dynamic> json) {
    final date = _extractString(json, const [
      'date',
      'dateEvent',
      'dateEventLocal',
      'dateEventUTC',
      'kickoff',
      'startTime',
      'datetime',
      'commence_time',
    ]);

    final time = _extractString(json, const [
      'time',
      'strTime',
      'timeEvent',
    ]);

    final dateTimeCandidates = <String>[
      if (date.isNotEmpty && time.isNotEmpty) '$date $time',
      if (date.isNotEmpty) date,
      if (time.isNotEmpty) time,
    ];

    for (final candidate in dateTimeCandidates) {
      final parsed = DateTime.tryParse(candidate.replaceFirst(' ', 'T')) ??
          DateTime.tryParse(candidate);
      if (parsed != null) return parsed.toLocal();
    }

    return DateTime.now();
  }

  (int?, int?) _extractScore(Map<String, dynamic> json) {
    final homeRaw = _extractString(json, const [
      'homeScore',
      'intHomeScore',
      'scoreHome',
      'home_score',
    ]);
    final awayRaw = _extractString(json, const [
      'awayScore',
      'intAwayScore',
      'scoreAway',
      'away_score',
    ]);

    final directHome = int.tryParse(homeRaw);
    final directAway = int.tryParse(awayRaw);
    if (directHome != null || directAway != null) {
      return (directHome, directAway);
    }

    final scoreText = _extractString(json, const [
      'score',
      'strScore',
      'result',
    ]);
    final parts = scoreText.split(RegExp(r'\s*[-:]\s*'));
    final home = int.tryParse(parts.isNotEmpty ? parts.first : '');
    final away = int.tryParse(parts.length > 1 ? parts[1] : '');
    return (home, away);
  }

  String _extractTeamName(Map<String, dynamic> json, {required bool isHome}) {
    final keys = isHome
        ? const [
            'homeTeam',
            'home',
            'teamA',
            'strHomeTeam',
            'home_name',
            'localteam_name',
          ]
        : const [
            'awayTeam',
            'away',
            'teamB',
            'strAwayTeam',
            'away_name',
            'visitorteam_name',
          ];

    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is Map<String, dynamic>) {
        final nested = _extractString(value, const [
          'name',
          'team_name',
          'shortName',
          'displayName',
          'title',
        ]);
        if (nested.isNotEmpty) return nested;
      }
    }

    final nestedSide = json['teams'];
    if (nestedSide is Map<String, dynamic>) {
      final side = nestedSide[isHome ? 'home' : 'away'];
      if (side is Map<String, dynamic>) {
        final nested = _extractString(side, const [
          'name',
          'team_name',
          'shortName',
          'displayName',
          'title',
        ]);
        if (nested.isNotEmpty) return nested;
      }
    }

    return '';
  }


  String _extractTeamLogo(Map<String, dynamic> json, {required bool isHome}) {
    final keys = isHome
        ? const [
            'homeLogo',
            'home_logo',
            'strHomeTeamBadge',
            'homeBadge',
            'homeCrest',
          ]
        : const [
            'awayLogo',
            'away_logo',
            'strAwayTeamBadge',
            'awayBadge',
            'awayCrest',
          ];

    final direct = _extractString(json, keys);
    if (_isUrl(direct)) return direct;

    final nestedSide = json['teams'];
    if (nestedSide is Map<String, dynamic>) {
      final side = nestedSide[isHome ? 'home' : 'away'];
      if (side is Map<String, dynamic>) {
        final nested = _extractString(side, const [
          'logo',
          'badge',
          'crest',
          'strTeamBadge',
          'image',
          'icon',
        ]);
        if (_isUrl(nested)) return nested;
      }
    }

    final teamNode = json[isHome ? 'homeTeam' : 'awayTeam'];
    if (teamNode is Map<String, dynamic>) {
      final nested = _extractString(teamNode, const [
        'logo',
        'badge',
        'crest',
        'strTeamBadge',
        'image',
        'icon',
      ]);
      if (_isUrl(nested)) return nested;
    }

    return '';
  }

  bool _isUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  String _extractString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return '';
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
    if (raw.contains('live') ||
        raw.contains('progress') ||
        raw.contains('1h') ||
        raw.contains('2h') ||
        raw.contains('in_play')) {
      return MatchStatus.live;
    }
    if (raw.contains('finished') ||
        raw == 'ft' ||
        raw.contains('ended') ||
        raw.contains('full')) {
      return MatchStatus.finished;
    }
    return MatchStatus.upcoming;
  }

  MatchCompetition _competitionFrom(String raw) {
    final value = raw.toLowerCase();

    final isPremier = value.contains('premier') ||
        value.contains('english league') ||
        value.contains('epl') ||
        value.contains('eng.1') ||
        value.contains('pl ');
    if (isPremier) return MatchCompetition.premierLeague;

    final isLaLiga = value.contains('la liga') ||
        value.contains('laliga') ||
        value.contains('primera') ||
        value.contains('spanish league') ||
        value.contains('esp.1') ||
        value.contains('liga');
    if (isLaLiga) return MatchCompetition.laLiga;

    if (value.contains('champions')) return MatchCompetition.championsLeague;
    if (value.contains('copa')) return MatchCompetition.copaDelRey;
    if (value.contains('super')) return MatchCompetition.supercopa;
    if (value.contains('friend')) return MatchCompetition.friendly;
    return MatchCompetition.friendly;
  }
}
