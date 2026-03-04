// lib/features/matches/widgets/today_matches_column.dart
//
// Scrollable column showing all today's matches grouped by status:
// Live → Upcoming → Finished.

import 'package:flutter/material.dart';
import 'package:omen/component/matches/match_model.dart';
import 'matches_theme.dart';
import 'match_row_card.dart';

class TodayMatchesColumn extends StatelessWidget {
  final List<MatchModel> live;
  final List<MatchModel> upcoming;
  final List<MatchModel> finished;
  final List<MatchModel> yesterday;

  const TodayMatchesColumn({
    super.key,
    required this.live,
    required this.upcoming,
    required this.finished,
    required this.yesterday,
  });

  bool get _isEmpty =>
      live.isEmpty && upcoming.isEmpty && finished.isEmpty && yesterday.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_soccer_rounded,
                color: MatchColors.text3.withOpacity(0.3), size: 40),
            const SizedBox(height: 12),
            Text('No matches today',
                style: MatchTextStyles.body(13, color: MatchColors.text3)),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (live.isNotEmpty) ...[
          _SectionLabel(label: 'Live Now', color: MatchColors.live),
          const SizedBox(height: 8),
          ...live.map((m) => MatchRowCard(match: m)),
          const SizedBox(height: 16),
        ],
        if (upcoming.isNotEmpty) ...[
          _SectionLabel(label: 'Upcoming', color: MatchColors.primary),
          const SizedBox(height: 8),
          ...upcoming.map((m) => MatchRowCard(match: m)),
          const SizedBox(height: 16),
        ],
        if (finished.isNotEmpty) ...[
          _SectionLabel(label: 'Finished', color: MatchColors.text3),
          const SizedBox(height: 8),
          ...finished.map((m) => MatchRowCard(match: m)),
          const SizedBox(height: 16),
        ],
        if (yesterday.isNotEmpty) ...[
          _SectionLabel(label: 'Yesterday', color: MatchColors.text2),
          const SizedBox(height: 8),
          ...yesterday.map((m) => MatchRowCard(match: m)),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: MatchTextStyles.label(12, color: color)),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
