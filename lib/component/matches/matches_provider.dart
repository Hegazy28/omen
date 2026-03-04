import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/matches/data/sportsrc_matches_service.dart';
import 'package:omen/component/matches/match_model.dart';

class MatchesNotifier extends Notifier<List<MatchModel>> {
  final _service = SportsrcMatchesService();

  @override
  List<MatchModel> build() {
    Future.microtask(_refreshFromApi);
    return const [];
  }

  Future<void> _refreshFromApi() async {
    try {
      final remoteMatches = await _service.fetchMatches();
      state = remoteMatches;
    } catch (_) {
      state = const [];
    }
  }
}

final matchesProvider = NotifierProvider<MatchesNotifier, List<MatchModel>>(
  MatchesNotifier.new,
);

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

final nextBarcaMatchProvider = Provider<MatchModel?>((ref) {
  final upcoming = ref.watch(barcaUpcomingProvider);
  return upcoming.isEmpty ? null : upcoming.first;
});
