import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/quran/azkar_data.dart';
import 'package:omen/component/quran/data/quran_api_service.dart';
import 'package:omen/component/quran/quran_models.dart';
import 'package:omen/component/quran/surahs_data.dart';

class WerdNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void addPage() => state = state + 1;
  void reset() => state = 0;
}

final werdProvider = NotifierProvider<WerdNotifier, int>(WerdNotifier.new);
final werdGoalProvider = Provider<int>((_) => 5);

final werdProgressProvider = Provider<double>((ref) {
  final read = ref.watch(werdProvider);
  final goal = ref.watch(werdGoalProvider);
  return (read / goal).clamp(0.0, 1.0);
});

final werdDoneProvider = Provider<bool>(
    (ref) => ref.watch(werdProvider) >= ref.watch(werdGoalProvider));

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

final lastReadSurahProvider = Provider<SurahModel?>((ref) {
  final pos = ref.watch(readingPositionProvider);
  try {
    return kSurahs.firstWhere((s) => s.id == pos.surahId);
  } catch (_) {
    return null;
  }
});

final surahsProvider = Provider<List<SurahModel>>((_) => kSurahs);
final surahSearchProvider = StateProvider<String>((_) => '');

final filteredSurahsProvider = Provider<List<SurahModel>>((ref) {
  final query = ref.watch(surahSearchProvider).trim();
  final surahs = ref.watch(surahsProvider);
  if (query.isEmpty) return surahs;
  final q = query.toLowerCase();
  return surahs
      .where((s) => s.name.contains(query) || s.ename.toLowerCase().contains(q))
      .toList();
});

final activeSurahProvider = StateProvider<SurahModel?>((_) => null);

final quranApiServiceProvider = Provider<QuranApiService>((_) => QuranApiService());

final activeSurahAyatProvider = FutureProvider<List<AyahModel>>((ref) async {
  final surah = ref.watch(activeSurahProvider);
  if (surah == null) return [];

  try {
    return await ref.read(quranApiServiceProvider).fetchSurahAyat(surah.id);
  } catch (_) {
    final raw = kSampleAyat[surah.id] ?? [];
    return raw
        .asMap()
        .entries
        .map((e) => AyahModel(number: e.key + 1, text: e.value))
        .toList();
  }
});

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

final ayahOfDayProvider = FutureProvider<AyahOfDay>((ref) async {
  try {
    return await ref.read(quranApiServiceProvider).fetchAyahOfTheDay();
  } catch (_) {
    return todayAyah;
  }
});
