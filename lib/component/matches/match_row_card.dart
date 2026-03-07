// lib/features/matches/widgets/match_row_card.dart
//
// Compact horizontal card for a single match.
// Used in the Today's Matches scrollable list.

import 'package:flutter/material.dart';
import 'package:omen/component/matches/match_model.dart';
import 'matches_theme.dart';
import 'team_crest.dart';
import 'competition_badge.dart';
import 'live_indicator.dart';
import 'match_time_utils.dart';

class MatchRowCard extends StatelessWidget {
  final MatchModel match;

  const MatchRowCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: MatchDecorations.glassCard(
        radius: BorderRadius.circular(16),
        border: match.status == MatchStatus.live
            ? MatchColors.live.withOpacity(0.30)
            : null,
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Status accent bar
            _StatusBar(status: match.status),

            // Main content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Home team
                    Expanded(
                      child: _TeamCell(team: match.home, alignEnd: false),
                    ),

                    // Centre: score / time
                    _CentreBlock(match: match),

                    // Away team
                    Expanded(
                      child: _TeamCell(team: match.away, alignEnd: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status bar ────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  final MatchStatus status;
  const _StatusBar({required this.status});

  Color get _color => switch (status) {
        MatchStatus.live => MatchColors.live,
        MatchStatus.finished => MatchColors.text3,
        MatchStatus.upcoming => MatchColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      decoration: BoxDecoration(
        color: _color,
        boxShadow: status == MatchStatus.live
            ? [BoxShadow(color: _color.withOpacity(0.5), blurRadius: 6)]
            : null,
      ),
    );
  }
}

// ── Team cell ─────────────────────────────────────────────

class _TeamCell extends StatelessWidget {
  final TeamModel team;
  final bool alignEnd;

  const _TeamCell({required this.team, required this.alignEnd});

  @override
  Widget build(BuildContext context) {
    final children = [
      TeamCrest(team: team, size: 32),
      const SizedBox(width: 10),
      Flexible(
        child: Text(
          team.name,
          style: MatchTextStyles.label(13),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        ),
      ),
    ];

    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd ? children.reversed.toList() : children,
    );
  }
}

// ── Centre block ──────────────────────────────────────────

class _CentreBlock extends StatelessWidget {
  final MatchModel match;
  const _CentreBlock({required this.match});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Score or kickoff time
          if (match.status == MatchStatus.upcoming)
            _KickoffTime(kickoff: match.kickoff)
          else
            _Score(match: match),

          const SizedBox(height: 5),

          // Competition badge or live indicator
          if (match.status == MatchStatus.live)
            LiveIndicator(minute: match.minutePlayed)
          else
            CompetitionBadge(competition: match.competition, short: true),
        ],
      ),
    );
  }
}

class _KickoffTime extends StatelessWidget {
  final DateTime kickoff;
  const _KickoffTime({required this.kickoff});

  String _format(DateTime dt) => formatCairoTime12h(dt);

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(kickoff),
      style: MatchTextStyles.mono(18, color: MatchColors.text1),
    );
  }
}

class _Score extends StatelessWidget {
  final MatchModel match;
  const _Score({required this.match});

  @override
  Widget build(BuildContext context) {
    final color = match.status == MatchStatus.finished
        ? MatchColors.text2
        : MatchColors.text1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${match.homeScore}',
            style: MatchTextStyles.score(22).copyWith(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('–',
              style:
                  MatchTextStyles.score(16).copyWith(color: MatchColors.text3)),
        ),
        Text('${match.awayScore}',
            style: MatchTextStyles.score(22).copyWith(color: color)),
      ],
    );
  }
}
