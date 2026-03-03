// lib/features/matches/widgets/next_match_card.dart
//
// Displays the next upcoming Barça fixture with a live countdown.

import 'dart:async';
import 'package:flutter/material.dart';
import 'match_model.dart';
import 'matches_theme.dart';
import 'team_crest.dart';
import 'competition_badge.dart';

class NextMatchCard extends StatefulWidget {
  final MatchModel match;
  const NextMatchCard({super.key, required this.match});

  @override
  State<NextMatchCard> createState() => _NextMatchCardState();
}

class _NextMatchCardState extends State<NextMatchCard> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    final diff = widget.match.kickoff.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  String _twoDigit(int n) => n.toString().padLeft(2, '0');

  String get _dateLabel {
    final d = widget.match.kickoff;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} · '
        '${_twoDigit(d.hour)}:${_twoDigit(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Container(
      decoration: MatchDecorations.glassCard(
        radius: BorderRadius.circular(20),
        border: MatchColors.barcaBlue.withOpacity(0.25),
        shadows: [
          BoxShadow(
            color: MatchColors.barcaBlue.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Subtle blue glow top-left
          Positioned(
            left: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  MatchColors.barcaBlue.withOpacity(0.15),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Next Match',
                        style: MatchTextStyles.label(13,
                            color: MatchColors.text3)),
                    CompetitionBadge(competition: match.competition),
                  ],
                ),
                const SizedBox(height: 16),

                // Teams row
                Row(
                  children: [
                    TeamCrest(team: match.home, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(match.home.name,
                              style: MatchTextStyles.label(14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text('vs',
                              style: MatchTextStyles.body(11,
                                  color: MatchColors.text3)),
                          Text(match.away.name,
                              style: MatchTextStyles.label(14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    TeamCrest(team: match.away, size: 44),
                  ],
                ),

                const SizedBox(height: 16),
                Container(height: 1, color: MatchColors.glassBorder),
                const SizedBox(height: 16),

                // Date label
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: MatchColors.text3),
                    const SizedBox(width: 6),
                    Text(_dateLabel,
                        style:
                            MatchTextStyles.body(12, color: MatchColors.text3)),
                  ],
                ),
                const SizedBox(height: 12),

                // Countdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CountdownUnit(value: days, label: 'DAYS'),
                    _CountdownDivider(),
                    _CountdownUnit(value: hours, label: 'HRS'),
                    _CountdownDivider(),
                    _CountdownUnit(value: minutes, label: 'MIN'),
                    _CountdownDivider(),
                    _CountdownUnit(value: seconds, label: 'SEC'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final int value;
  final String label;

  const _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 46,
          decoration: BoxDecoration(
            color: MatchColors.glass,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: MatchColors.glassBorder, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toString().padLeft(2, '0'),
            style:
                MatchTextStyles.score(22).copyWith(color: MatchColors.primary),
          ),
        ),
        const SizedBox(height: 5),
        Text(label,
            style: MatchTextStyles.mono(8,
                color: MatchColors.text3, weight: FontWeight.w500)),
      ],
    );
  }
}

class _CountdownDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(':',
        style: MatchTextStyles.score(22).copyWith(color: MatchColors.text3));
  }
}
