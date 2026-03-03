// lib/features/matches/widgets/team_crest.dart
//
// Renders a team crest from an asset path.
// Falls back to a styled initials badge if the asset isn't found yet —
// safe to use before you add real logo assets.

import 'package:flutter/material.dart';
import 'package:omen/component/matches/match_model.dart';
import 'matches_theme.dart';

class TeamCrest extends StatelessWidget {
  final TeamModel team;
  final double size;

  const TeamCrest({
    super.key,
    required this.team,
    this.size = 40,
  });

  // Pick a deterministic accent colour from the team id
  Color _accentFor(String id) {
    const palette = [
      MatchColors.barcaBlue,
      MatchColors.ucl,
      MatchColors.laLiga,
      MatchColors.copa,
      MatchColors.win,
      MatchColors.primary,
    ];
    return palette[id.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        team.logoAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _FallbackCrest(
          shortName: team.shortName,
          size: size,
          color: _accentFor(team.id),
        ),
      ),
    );
  }
}

class _FallbackCrest extends StatelessWidget {
  final String shortName;
  final double size;
  final Color color;

  const _FallbackCrest({
    required this.shortName,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        shortName.length > 3 ? shortName.substring(0, 3) : shortName,
        style: MatchTextStyles.mono(
          size * 0.26,
          color: color,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}
