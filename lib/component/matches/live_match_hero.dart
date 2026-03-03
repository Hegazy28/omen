// lib/features/matches/widgets/live_match_hero.dart
//
// Large hero card shown at the top when Barça are playing live.
// Displays both crests, live score, minute, and competition.

import 'package:flutter/material.dart';
import 'package:omen/component/matches/match_model.dart';
import 'matches_theme.dart';
import 'team_crest.dart';
import 'competition_badge.dart';
import 'live_indicator.dart';

class LiveMatchHero extends StatelessWidget {
  final MatchModel match;

  const LiveMatchHero({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: MatchDecorations.glassCard(
        radius: BorderRadius.circular(24),
        border: MatchColors.live.withOpacity(0.25),
        shadows: [
          BoxShadow(
            color: MatchColors.live.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: MatchColors.skyDeep.withOpacity(0.6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Background glow blobs
          Positioned(
            left: -40,
            top: -30,
            child: _GlowBlob(color: MatchColors.barcaBlue),
          ),
          Positioned(
            right: -40,
            bottom: -30,
            child: _GlowBlob(color: MatchColors.barcaRed),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            child: Column(
              children: [
                // Top row: competition + live badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CompetitionBadge(competition: match.competition),
                    LiveIndicator(minute: match.minutePlayed),
                  ],
                ),
                const SizedBox(height: 22),

                // Teams + score row
                Row(
                  children: [
                    // Home
                    Expanded(
                        child: _TeamBlock(team: match.home, alignEnd: false)),
                    // Score
                    _ScoreBlock(match: match),
                    // Away
                    Expanded(
                        child: _TeamBlock(team: match.away, alignEnd: true)),
                  ],
                ),

                const SizedBox(height: 18),

                // Bottom: venue hint
                Text(
                  'Estadio Olímpico Lluís Companys · Barcelona',
                  style: MatchTextStyles.body(11, color: MatchColors.text3),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  const _GlowBlob({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.18), Colors.transparent],
        ),
      ),
    );
  }
}

class _TeamBlock extends StatelessWidget {
  final TeamModel team;
  final bool alignEnd;

  const _TeamBlock({required this.team, required this.alignEnd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        TeamCrest(team: team, size: 52),
        const SizedBox(height: 10),
        Text(
          team.name,
          style: MatchTextStyles.label(13),
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ScoreBlock extends StatelessWidget {
  final MatchModel match;
  const _ScoreBlock({required this.match});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${match.homeScore ?? 0}',
                style: MatchTextStyles.score(52),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '–',
                  style: MatchTextStyles.score(36)
                      .copyWith(color: MatchColors.text3),
                ),
              ),
              Text(
                '${match.awayScore ?? 0}',
                style: MatchTextStyles.score(52),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "HT",
            style: MatchTextStyles.mono(10, color: MatchColors.text3),
          ),
        ],
      ),
    );
  }
}
