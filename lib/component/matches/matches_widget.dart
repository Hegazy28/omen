// lib/features/matches/widgets/matches_widget.dart
//
// DROP-IN USAGE:
//
//   import 'package:your_app/features/matches/matches.dart';
//
//   const MatchesWidget()   // fills its parent — wrap in Padding/Expanded
//
// Must be inside a ProviderScope.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/matches/matches_provider.dart';
import 'matches_theme.dart';
import 'live_match_hero.dart';
import 'next_match_card.dart';
import 'barca_fixtures_list.dart';
import 'today_matches_column.dart';

class MatchesWidget extends ConsumerWidget {
  const MatchesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveMatch = ref.watch(liveMatchProvider);
    final nextMatch = ref.watch(nextBarcaMatchProvider);
    final barcaFixtures = ref.watch(barcaUpcomingProvider);
    final live = ref.watch(liveMatchesProvider);
    final upcoming = ref.watch(upcomingMatchesProvider);
    final finished = ref.watch(finishedMatchesProvider);

    // Barca upcoming = all fixtures except the very next one (already shown
    // in NextMatchCard). Skip if it is today (shown in live hero instead).
    final fixturesExcludingNext = barcaFixtures.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Top bar ───────────────────────────────────────
        _TopBar(),
        const SizedBox(height: 20),

        // ── Content: two-column desktop layout ───────────
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left column: Barça section ─────────────
              SizedBox(
                width: 340,
                child: _BarcaColumn(
                  liveMatch: liveMatch,
                  nextMatch: nextMatch,
                  fixtures: fixturesExcludingNext,
                ),
              ),

              const SizedBox(width: 18),

              // ── Right column: Today's matches ──────────
              Expanded(
                child: _TodayColumn(
                  live: live,
                  upcoming: upcoming,
                  finished: finished,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dateLabel =
        '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matches', style: MatchTextStyles.heading(22)),
            const SizedBox(height: 2),
            Text(dateLabel,
                style: MatchTextStyles.body(13, color: MatchColors.text3)),
          ],
        ),
        const Spacer(),
        // Favourite team tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MatchColors.barcaBlue.withOpacity(0.25),
                MatchColors.barcaRed.withOpacity(0.20),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: MatchColors.barcaBlue.withOpacity(0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_rounded,
                  size: 13, color: MatchColors.barcaRed),
              const SizedBox(width: 6),
              Text('FC Barcelona',
                  style: MatchTextStyles.label(13, color: MatchColors.text1)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Left: Barça column ────────────────────────────────────

class _BarcaColumn extends StatelessWidget {
  final dynamic liveMatch;
  final dynamic nextMatch;
  final List fixtures;

  const _BarcaColumn({
    required this.liveMatch,
    required this.nextMatch,
    required this.fixtures,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MatchDecorations.glassCard(),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column accent bar — Barca colours
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [MatchColors.barcaBlue, MatchColors.barcaRed],
              ),
            ),
          ),

          // Column header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: MatchColors.barcaBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                        color: MatchColors.barcaBlue.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      size: 17, color: MatchColors.barcaRed),
                ),
                const SizedBox(width: 10),
                Text('FC Barcelona', style: MatchTextStyles.label(15)),
              ],
            ),
          ),

          Container(height: 1, color: MatchColors.glassBorder),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (liveMatch != null) ...[
                  LiveMatchHero(match: liveMatch),
                  const SizedBox(height: 14),
                ],
                if (nextMatch != null) ...[
                  NextMatchCard(match: nextMatch),
                  const SizedBox(height: 14),
                ],
                if (fixtures.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text('Upcoming Fixtures',
                        style: MatchTextStyles.label(13,
                            color: MatchColors.text3)),
                  ),
                  BarcaFixturesList(fixtures: List.from(fixtures)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Right: Today column ───────────────────────────────────

class _TodayColumn extends ConsumerWidget {
  final List live;
  final List upcoming;
  final List finished;

  const _TodayColumn({
    required this.live,
    required this.upcoming,
    required this.finished,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: MatchDecorations.glassCard(),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column accent bar
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MatchColors.primary,
                  MatchColors.primaryGlow,
                  Colors.transparent
                ],
              ),
            ),
          ),

          // Column header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: MatchColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                        color: MatchColors.primary.withOpacity(0.25)),
                  ),
                  child: const Icon(Icons.today_rounded,
                      size: 17, color: MatchColors.primary),
                ),
                const SizedBox(width: 10),
                Text('Today\'s Matches', style: MatchTextStyles.label(15)),
                const Spacer(),
                // Total count badge
                _CountBadge(
                    count: live.length + upcoming.length + finished.length),
              ],
            ),
          ),

          Container(height: 1, color: MatchColors.glassBorder),

          // Scrollable match list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: TodayMatchesColumn(
                live: List.from(live),
                upcoming: List.from(upcoming),
                finished: List.from(finished),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: MatchDecorations.pill(color: MatchColors.primary),
      child: Text('$count matches',
          style: MatchTextStyles.mono(10, color: MatchColors.primary)),
    );
  }
}
