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

    final body = response.body.trim();
    if (body.isEmpty) return const [];

    final decoded = jsonDecode(body);
    final rawEvents = _extractEvents(decoded);

    final matches = rawEvents.map(_toMatch).whereType<MatchModel>().toList();

    final unique = <String, MatchModel>{};
    for (final match in matches) {
      unique[match.id] = match;
    }

    final output = unique.values.toList()
      ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
    return output;
  }

  List<Map<String, dynamic>> _extractEvents(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) {
        return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }

    // Fallback to permissive recursive extraction.
    final found = <Map<String, dynamic>>[];

    void walk(dynamic node) {
      if (node is List) {
        for (final item in node) {
          walk(item);
        }
        return;
      }

      if (node is Map) {
        final json = Map<String, dynamic>.from(node);
        if (_looksLikeEvent(json)) {
          found.add(json);
        }
        for (final value in json.values) {
          walk(value);
        }
      }
    }

    walk(decoded);
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
    final status = _statusFrom(
      _extractString(json, const ['status', 'state', 'match_status']).toLowerCase(),
    );

    final score = _extractScore(json);
    final homeLogo = _extractTeamLogo(json, isHome: true);
    final awayLogo = _extractTeamLogo(json, isHome: false);

    final league = _extractString(json, const [
      'league',
      'competition',
      'tournament',
      'category',
    ]);

    final home = TeamModel(
      id: _teamId(homeName),
      name: homeName,
      shortName: _shortName(homeName),
      logoAsset: homeLogo.isNotEmpty ? homeLogo : 'assets/Logo.png',
    );

    final away = TeamModel(
      id: _teamId(awayName),
      name: awayName,
      shortName: _shortName(awayName),
      logoAsset: awayLogo.isNotEmpty ? awayLogo : 'assets/Logo.png',
    );

    final eventId = _extractString(json, const ['id', 'event_id', 'match_id']);
    final isPopular = _extractBool(json, const ['popular', 'isPopular', 'important']);

    final competition = _competitionFrom(league);

    return MatchModel(
      id: eventId.isNotEmpty ? eventId : '${_teamId(homeName)}-${_teamId(awayName)}-${kickoff.millisecondsSinceEpoch}',
      home: home,
      away: away,
      competition: competition,
      status: status,
      kickoff: kickoff,
      homeScore: status == MatchStatus.upcoming ? null : score.$1,
      awayScore: status == MatchStatus.upcoming ? null : score.$2,
      isFavouriteMatch:
          homeName.toLowerCase().contains('barcelona') || awayName.toLowerCase().contains('barcelona'),
      isImportant: isPopular ||
          homeName.toLowerCase().contains('barcelona') ||
          awayName.toLowerCase().contains('barcelona') ||
          competitionIsImportant(competition),
    );
  }

  DateTime _extractKickoff(Map<String, dynamic> json) {
    final rawDate = json['date'];

    if (rawDate is int) {
      // Sportsrc uses Unix epoch in milliseconds.
      return DateTime.fromMillisecondsSinceEpoch(rawDate, isUtc: true);
    }

    if (rawDate is String && rawDate.trim().isNotEmpty) {
      final asInt = int.tryParse(rawDate.trim());
      if (asInt != null) {
        final millis = rawDate.trim().length >= 13 ? asInt : asInt * 1000;
        return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
      }

      final parsed = DateTime.tryParse(rawDate.trim());
      if (parsed != null) return parsed.toUtc();
    }

    final fallbackRaw = _extractString(json, const [
      'kickoff',
      'startTime',
      'datetime',
      'commence_time',
    ]);
    final fallback = DateTime.tryParse(fallbackRaw);
    if (fallback != null) return fallback.toUtc();

    return DateTime.now().toUtc();
  }

  (int?, int?) _extractScore(Map<String, dynamic> json) {
    final homeRaw = _extractString(json, const ['homeScore', 'scoreHome', 'home_score']);
    final awayRaw = _extractString(json, const ['awayScore', 'scoreAway', 'away_score']);

    final home = int.tryParse(homeRaw);
    final away = int.tryParse(awayRaw);
    if (home != null || away != null) return (home, away);

    final scoreText = _extractString(json, const ['score', 'result']);
    final parts = scoreText.split(RegExp(r'\s*[-:]\s*'));
    return (
      int.tryParse(parts.isNotEmpty ? parts.first : ''),
      int.tryParse(parts.length > 1 ? parts[1] : ''),
    );
  }

  String _extractTeamName(Map<String, dynamic> json, {required bool isHome}) {
    final directKeys = isHome
        ? const ['homeTeam', 'home', 'strHomeTeam', 'home_name']
        : const ['awayTeam', 'away', 'strAwayTeam', 'away_name'];

    for (final key in directKeys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is Map) {
        final nested = _extractString(Map<String, dynamic>.from(value), const ['name', 'team_name', 'title']);
        if (nested.isNotEmpty) return nested;
      }
    }

    final teams = json['teams'];
    if (teams is Map) {
      final side = teams[isHome ? 'home' : 'away'];
      if (side is Map) {
        final nested = _extractString(Map<String, dynamic>.from(side), const ['name', 'team_name', 'title']);
        if (nested.isNotEmpty) return nested;
      }
    }

    return '';
  }

  String _extractTeamLogo(Map<String, dynamic> json, {required bool isHome}) {
    final keys = isHome
        ? const ['homeLogo', 'home_logo', 'homeBadge', 'homeCrest']
        : const ['awayLogo', 'away_logo', 'awayBadge', 'awayCrest'];

    final direct = _extractString(json, keys);
    if (_isUrl(direct)) return direct;

    final teams = json['teams'];
    if (teams is Map) {
      final side = teams[isHome ? 'home' : 'away'];
      if (side is Map) {
        final nested = _extractString(Map<String, dynamic>.from(side), const [
          'badge',
          'logo',
          'crest',
          'image',
          'icon',
        ]);
        if (_isUrl(nested)) return nested;
      }
    }

    return '';
  }

  bool _extractBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
      if (value == null) continue;
      final text = value.toString().trim().toLowerCase();
      if (text == 'true' || text == '1' || text == 'yes') return true;
      if (text == 'false' || text == '0' || text == 'no') return false;
    }
    return false;
  }

  String _extractString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return '';
  }

  bool _isUrl(String value) => value.startsWith('http://') || value.startsWith('https://');

  String _teamId(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
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
    if (raw.contains('live') || raw.contains('progress') || raw.contains('in_play')) {
      return MatchStatus.live;
    }
    if (raw.contains('finished') || raw == 'ft' || raw.contains('ended')) {
      return MatchStatus.finished;
    }
    return MatchStatus.upcoming;
  }

  bool competitionIsImportant(MatchCompetition competition) {
    return competition == MatchCompetition.laLiga ||
        competition == MatchCompetition.premierLeague ||
        competition == MatchCompetition.championsLeague;
  }

  MatchCompetition _competitionFrom(String raw) {
    final value = raw.toLowerCase();

    if (value.contains('premier') || value.contains('epl') || value.contains('eng.1')) {
      return MatchCompetition.premierLeague;
    }
    if (value.contains('la liga') || value.contains('laliga') || value.contains('primera') || value.contains('esp.1')) {
      return MatchCompetition.laLiga;
    }
    if (value.contains('champions')) return MatchCompetition.championsLeague;
    if (value.contains('copa')) return MatchCompetition.copaDelRey;
    if (value.contains('super')) return MatchCompetition.supercopa;

    return MatchCompetition.friendly;
  }
}
