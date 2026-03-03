// lib/features/matches/data/matches_sample_data.dart
//
// Hardcoded sample fixtures centred on FC Barcelona.
// Replace this list with your real API response when ready.
// All times are set relative to "today" so the widget always
// shows meaningful data regardless of when you run it.

import 'package:omen/component/matches/match_model.dart';

// ── Teams ─────────────────────────────────────────────────

const _barca = TeamModel(
  id: 'fcb',
  name: 'FC Barcelona',
  shortName: 'FCB',
  logoAsset: 'assets/logos/barcelona.png',
);

const _realmadrid = TeamModel(
  id: 'rma',
  name: 'Real Madrid',
  shortName: 'RMA',
  logoAsset: 'assets/logos/real_madrid.png',
);

const _atletico = TeamModel(
  id: 'atm',
  name: 'Atlético Madrid',
  shortName: 'ATM',
  logoAsset: 'assets/logos/atletico.png',
);

const _psg = TeamModel(
  id: 'psg',
  name: 'Paris Saint-Germain',
  shortName: 'PSG',
  logoAsset: 'assets/logos/psg.png',
);

const _inter = TeamModel(
  id: 'int',
  name: 'Inter Milan',
  shortName: 'INT',
  logoAsset: 'assets/logos/inter.png',
);

const _sevilla = TeamModel(
  id: 'sev',
  name: 'Sevilla FC',
  shortName: 'SEV',
  logoAsset: 'assets/logos/sevilla.png',
);

const _osasuna = TeamModel(
  id: 'osa',
  name: 'CA Osasuna',
  shortName: 'OSA',
  logoAsset: 'assets/logos/osasuna.png',
);

const _villarreal = TeamModel(
  id: 'vil',
  name: 'Villarreal CF',
  shortName: 'VIL',
  logoAsset: 'assets/logos/villarreal.png',
);

const _valencia = TeamModel(
  id: 'val',
  name: 'Valencia CF',
  shortName: 'VAL',
  logoAsset: 'assets/logos/valencia.png',
);

const _betis = TeamModel(
  id: 'bet',
  name: 'Real Betis',
  shortName: 'BET',
  logoAsset: 'assets/logos/betis.png',
);

const _getafe = TeamModel(
  id: 'get',
  name: 'Getafe CF',
  shortName: 'GET',
  logoAsset: 'assets/logos/getafe.png',
);

const _celta = TeamModel(
  id: 'cel',
  name: 'Celta Vigo',
  shortName: 'CEL',
  logoAsset: 'assets/logos/celta.png',
);

// ── Sample fixtures ───────────────────────────────────────

List<MatchModel> buildSampleMatches() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return [
    // ── LIVE ──────────────────────────────────────────────
    MatchModel(
      id: 'live_1',
      home: _barca,
      away: _realmadrid,
      competition: MatchCompetition.laLiga,
      status: MatchStatus.live,
      kickoff: today.add(const Duration(hours: 21)),
      homeScore: 2,
      awayScore: 1,
      minutePlayed: 67,
      isFavouriteMatch: true,
    ),

    // ── TODAY — UPCOMING ──────────────────────────────────
    MatchModel(
      id: 'today_1',
      home: _atletico,
      away: _sevilla,
      competition: MatchCompetition.laLiga,
      status: MatchStatus.upcoming,
      kickoff: today.add(const Duration(hours: 16)),
    ),
    MatchModel(
      id: 'today_2',
      home: _villarreal,
      away: _valencia,
      competition: MatchCompetition.laLiga,
      status: MatchStatus.upcoming,
      kickoff: today.add(const Duration(hours: 18, minutes: 30)),
    ),
    MatchModel(
      id: 'today_3',
      home: _betis,
      away: _osasuna,
      competition: MatchCompetition.laLiga,
      status: MatchStatus.upcoming,
      kickoff: today.add(const Duration(hours: 20)),
    ),
    MatchModel(
      id: 'today_4',
      home: _getafe,
      away: _celta,
      competition: MatchCompetition.laLiga,
      status: MatchStatus.upcoming,
      kickoff: today.add(const Duration(hours: 22)),
    ),

    // ── TODAY — FINISHED ──────────────────────────────────
    MatchModel(
      id: 'fin_1',
      home: _inter,
      away: _psg,
      competition: MatchCompetition.championsLeague,
      status: MatchStatus.finished,
      kickoff: today.add(const Duration(hours: 14)),
      homeScore: 1,
      awayScore: 3,
    ),

    // ── BARCA — UPCOMING (not today, used for "next match") ─
    MatchModel(
      id: 'barca_ucl',
      home: _barca,
      away: _inter,
      competition: MatchCompetition.championsLeague,
      status: MatchStatus.upcoming,
      kickoff: today.add(const Duration(days: 3, hours: 21)),
      isFavouriteMatch: true,
    ),
    MatchModel(
      id: 'barca_copa',
      home: _osasuna,
      away: _barca,
      competition: MatchCompetition.copaDelRey,
      status: MatchStatus.upcoming,
      kickoff: today.add(const Duration(days: 6, hours: 19)),
      isFavouriteMatch: true,
    ),
  ];
}
