// lib/features/matches/models/match_model.dart

import 'package:flutter/foundation.dart';

enum MatchStatus { upcoming, live, finished }

enum MatchCompetition {
  laLiga,
  championsLeague,
  copaDelRey,
  supercopa,
  friendly,
}

@immutable
class TeamModel {
  final String id;
  final String name;
  final String shortName; // e.g. "FCB"
  final String logoAsset; // e.g. "assets/logos/barcelona.png"
  // → replace with your real asset paths

  const TeamModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.logoAsset,
  });
}

@immutable
class MatchModel {
  final String id;
  final TeamModel home;
  final TeamModel away;
  final MatchCompetition competition;
  final MatchStatus status;
  final DateTime kickoff; // local time

  /// Null when status == upcoming
  final int? homeScore;
  final int? awayScore;

  /// Live only — minute elapsed (e.g. 67)
  final int? minutePlayed;

  /// Whether either team is the user's favourite
  final bool isFavouriteMatch;

  const MatchModel({
    required this.id,
    required this.home,
    required this.away,
    required this.competition,
    required this.status,
    required this.kickoff,
    this.homeScore,
    this.awayScore,
    this.minutePlayed,
    this.isFavouriteMatch = false,
  });

  bool get isBarcelona => home.id == 'fcb' || away.id == 'fcb';

  /// Convenience: score string e.g. "2 – 1"
  String get scoreString {
    if (homeScore == null || awayScore == null) return '– –';
    return '$homeScore – $awayScore';
  }
}
