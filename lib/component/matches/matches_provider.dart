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

enum MatchViewScope { all, important }

enum MatchLeagueCategory { all, laLiga, premierLeague }

final matchViewScopeProvider =
    StateProvider<MatchViewScope>((_) => MatchViewScope.important);
final matchLeagueCategoryProvider =
    StateProvider<MatchLeagueCategory>((_) => MatchLeagueCategory.all);

bool _isImportantLeague(MatchCompetition competition) {
  return competition == MatchCompetition.laLiga ||
      competition == MatchCompetition.premierLeague;
}

final visibleMatchesProvider = Provider<List<MatchModel>>((ref) {
  final all = ref.watch(matchesProvider);
  final scope = ref.watch(matchViewScopeProvider);
  final category = ref.watch(matchLeagueCategoryProvider);

  Iterable<MatchModel> result = all;

  if (scope == MatchViewScope.important) {
    result = result.where((match) => _isImportantLeague(match.competition));
  }

  switch (category) {
    case MatchLeagueCategory.all:
      break;
    case MatchLeagueCategory.laLiga:
      result = result.where((m) => m.competition == MatchCompetition.laLiga);
      break;
    case MatchLeagueCategory.premierLeague:
      result =
          result.where((m) => m.competition == MatchCompetition.premierLeague);
      break;
  }

  return result.toList();
});

final liveMatchProvider = Provider<MatchModel?>((ref) {
  final matches = ref.watch(visibleMatchesProvider);
  try {
    return matches.firstWhere(
      (m) => m.status == MatchStatus.live && m.isFavouriteMatch,
    );
  } catch (_) {
    return null;
  }
});

final todayMatchesProvider = Provider<List<MatchModel>>((ref) {
  final matches = ref.watch(visibleMatchesProvider);
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

final yesterdayMatchesProvider = Provider<List<MatchModel>>((ref) {
  final matches = ref.watch(visibleMatchesProvider);
  final now = DateTime.now();
  final yesterday = DateTime(now.year, now.month, now.day).subtract(
    const Duration(days: 1),
  );

  return matches
      .where((m) =>
          m.kickoff.year == yesterday.year &&
          m.kickoff.month == yesterday.month &&
          m.kickoff.day == yesterday.day)
      .toList()
    ..sort((a, b) => b.kickoff.compareTo(a.kickoff));
});

final barcaUpcomingProvider = Provider<List<MatchModel>>((ref) {
  final matches = ref.watch(visibleMatchesProvider);
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
