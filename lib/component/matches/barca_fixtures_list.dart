// lib/features/matches/widgets/barca_fixtures_list.dart
//
// Compact vertical list of upcoming Barça fixtures beyond today.

import 'package:flutter/material.dart';
import 'package:omen/component/matches/match_model.dart';
import 'matches_theme.dart';
import 'team_crest.dart';
import 'competition_badge.dart';
import 'match_time_utils.dart';

class BarcaFixturesList extends StatelessWidget {
  final List<MatchModel> fixtures;

  const BarcaFixturesList({super.key, required this.fixtures});

  @override
  Widget build(BuildContext context) {
    if (fixtures.isEmpty) {
      return Center(
        child: Text('No upcoming fixtures',
            style: MatchTextStyles.body(13, color: MatchColors.text3)),
      );
    }

    return Column(
      children: fixtures
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FixtureRow(match: f),
              ))
          .toList(),
    );
  }
}

class _FixtureRow extends StatelessWidget {
  final MatchModel match;
  const _FixtureRow({required this.match});

  String _dateLabel(DateTime dt) => formatCairoDateTimeShort(dt);

  bool get _isHome => match.home.id == 'fcb';

  TeamModel get _opponent => _isHome ? match.away : match.home;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: MatchDecorations.glassCard(
        radius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Home / Away badge
          Container(
            width: 28,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: (_isHome ? MatchColors.barcaBlue : MatchColors.glass)
                  .withOpacity(0.20),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: (_isHome ? MatchColors.barcaBlue : MatchColors.text3)
                    .withOpacity(0.25),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _isHome ? 'H' : 'A',
              style: MatchTextStyles.mono(9,
                  color: _isHome ? MatchColors.barcaBlue : MatchColors.text3),
            ),
          ),
          const SizedBox(width: 12),

          // Opponent crest + name
          TeamCrest(team: _opponent, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _opponent.name,
              style: MatchTextStyles.label(13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Date + competition
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CompetitionBadge(competition: match.competition, short: true),
              const SizedBox(height: 4),
              Text(
                _dateLabel(match.kickoff),
                style: MatchTextStyles.mono(9,
                    color: MatchColors.text3, weight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
