// lib/features/matches/providers/matches_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/matches/match_model.dart';
import 'package:omen/component/matches/matches_sample_data.dart';

// ── Source of truth ───────────────────────────────────────

final matchesProvider = Provider<List<MatchModel>>(
  (_) => buildSampleMatches(),
);

// ── Derived — live match (Barca) ──────────────────────────

final liveMatchProvider = Provider<MatchModel?>((ref) {
  final matches = ref.watch(matchesProvider);
  try {
    return matches.firstWhere(
      (m) => m.status == MatchStatus.live && m.isFavouriteMatch,
    );
  } catch (_) {
    return null;
  }
});

// ── Derived — today's matches (all, sorted by kickoff) ───

final todayMatchesProvider = Provider<List<MatchModel>>((ref) {
  final matches = ref.watch(matchesProvider);
  final today = DateTime.now();

  return matches
      .where((m) =>
          m.kickoff.year == today.year &&
          m.kickoff.month == today.month &&
          m.kickoff.day == today.day)
      .toList()
    ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
});

// ── Derived — today split by status ──────────────────────

final liveMatchesProvider = Provider<List<MatchModel>>((ref) => ref
    .watch(todayMatchesProvider)
    .where((m) => m.status == MatchStatus.live)
    .toList());

final upcomingMatchesProvider = Provider<List<MatchModel>>((ref) => ref
    .watch(todayMatchesProvider)
    .where((m) => m.status == MatchStatus.upcoming)
    .toList());

final finishedMatchesProvider = Provider<List<MatchModel>>((ref) => ref
    .watch(todayMatchesProvider)
    .where((m) => m.status == MatchStatus.finished)
    .toList());

// ── Derived — Barca upcoming fixtures ────────────────────

final barcaUpcomingProvider = Provider<List<MatchModel>>((ref) {
  final matches = ref.watch(matchesProvider);
  final now = DateTime.now();

  return matches
      .where((m) =>
          m.isFavouriteMatch &&
          m.status == MatchStatus.upcoming &&
          m.kickoff.isAfter(now))
      .toList()
    ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
});

// ── Derived — next Barca match ────────────────────────────

final nextBarcaMatchProvider = Provider<MatchModel?>((ref) {
  final upcoming = ref.watch(barcaUpcomingProvider);
  return upcoming.isEmpty ? null : upcoming.first;
});
