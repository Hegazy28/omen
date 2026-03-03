// lib/features/matches/widgets/competition_badge.dart

import 'package:flutter/material.dart';
import 'package:omen/component/matches/match_model.dart';
import 'matches_theme.dart';

class CompetitionBadge extends StatelessWidget {
  final MatchCompetition competition;
  final bool short;

  const CompetitionBadge({
    super.key,
    required this.competition,
    this.short = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = competition.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: MatchDecorations.pill(color: color),
      child: Text(
        short ? competition.shortLabel : competition.label,
        style: MatchTextStyles.mono(9, color: color),
      ),
    );
  }
}
