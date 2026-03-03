// lib/features/quran/providers/quran_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/quran/azkar_data.dart';
import 'package:omen/component/quran/quran_models.dart';
import 'package:omen/component/quran/surahs_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  WERD — daily reading goal
// ─────────────────────────────────────────────────────────────────────────────

class WerdNotifier extends Notifier<int> {
  @override
  int build() => 0; // pages read today — wire to SharedPreferences later

  void addPage() => state = state + 1;
  void reset() => state = 0;
}

final werdProvider = NotifierProvider<WerdNotifier, int>(WerdNotifier.new);

/// Daily goal in pages — change to suit user preference.
final werdGoalProvider = Provider<int>((_) => 5);

/// Progress 0.0 – 1.0
final werdProgressProvider = Provider<double>((ref) {
  final read = ref.watch(werdProvider);
  final goal = ref.watch(werdGoalProvider);
  return (read / goal).clamp(0.0, 1.0);
});

final werdDoneProvider = Provider<bool>(
    (ref) => ref.watch(werdProvider) >= ref.watch(werdGoalProvider));

// ─────────────────────────────────────────────────────────────────────────────
//  READING POSITION — last surah + page
// ─────────────────────────────────────────────────────────────────────────────

class ReadingPositionNotifier extends Notifier<ReadingPosition> {
  @override
  ReadingPosition build() => const ReadingPosition(
        surahId: 1,
        ayahNumber: 1,
        page: 1,
      );

  void update(ReadingPosition pos) => state = pos;

  void updatePage(int page) => state = state.copyWith(page: page);
}

final readingPositionProvider =
    NotifierProvider<ReadingPositionNotifier, ReadingPosition>(
  ReadingPositionNotifier.new,
);

/// Convenience: the last-read SurahModel
final lastReadSurahProvider = Provider<SurahModel?>((ref) {
  final pos = ref.watch(readingPositionProvider);
  try {
    return kSurahs.firstWhere((s) => s.id == pos.surahId);
  } catch (_) {
    return null;
  }
});

// ─────────────────────────────────────────────────────────────────────────────
//  SURAH BROWSER
// ─────────────────────────────────────────────────────────────────────────────

/// All surahs — static list.
final surahsProvider = Provider<List<SurahModel>>((_) => kSurahs);

/// Search query string.
final surahSearchProvider = StateProvider<String>((_) => '');

/// Filtered list based on search query.
final filteredSurahsProvider = Provider<List<SurahModel>>((ref) {
  final query = ref.watch(surahSearchProvider).trim();
  final surahs = ref.watch(surahsProvider);
  if (query.isEmpty) return surahs;
  final q = query.toLowerCase();
  return surahs
      .where((s) => s.name.contains(query) || s.ename.toLowerCase().contains(q))
      .toList();
});

/// Currently open surah (null = show list).
final activeSurahProvider = StateProvider<SurahModel?>((_) => null);

/// Ayat for the active surah — sample data, wire API later.
final activeSurahAyatProvider = Provider<List<AyahModel>>((ref) {
  final surah = ref.watch(activeSurahProvider);
  if (surah == null) return [];
  final raw = kSampleAyat[surah.id] ?? [];
  return raw
      .asMap()
      .entries
      .map((e) => AyahModel(number: e.key + 1, text: e.value))
      .toList();
});

// ─────────────────────────────────────────────────────────────────────────────
//  AZKAR
// ─────────────────────────────────────────────────────────────────────────────

class AzkarNotifier extends Notifier<List<ZikrModel>> {
  @override
  List<ZikrModel> build() => buildAzkar();

  void tap(String id) {
    state = [
      for (final z in state)
        if (z.id == id && !z.isDone) z.copyWith(count: z.count + 1) else z,
    ];
  }

  void resetAll() => state = buildAzkar();
}

final azkarProvider =
    NotifierProvider<AzkarNotifier, List<ZikrModel>>(AzkarNotifier.new);

final azkarCategoryProvider =
    StateProvider<ZikrCategory>((_) => ZikrCategory.morning);

final filteredAzkarProvider = Provider<List<ZikrModel>>((ref) {
  final all = ref.watch(azkarProvider);
  final category = ref.watch(azkarCategoryProvider);
  return all.where((z) => z.category == category).toList();
});

final azkarProgressProvider = Provider<(int done, int total)>((ref) {
  final list = ref.watch(filteredAzkarProvider);
  return (list.where((z) => z.isDone).length, list.length);
});

// ─────────────────────────────────────────────────────────────────────────────
//  AYAH OF THE DAY
// ─────────────────────────────────────────────────────────────────────────────

final ayahOfDayProvider = Provider<AyahOfDay>((_) => todayAyah);
