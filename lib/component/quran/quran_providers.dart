import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:omen/component/quran/azkar_data.dart';
import 'package:omen/component/quran/data/quran_api_service.dart';
import 'package:omen/component/quran/quran_models.dart';
import 'package:omen/component/quran/surahs_data.dart';

const String kQuranDailyBoxName = 'quran_daily_box';
const String _kDayKey = 'day_key';
const String _kWerdPagesKey = 'werd_pages';
const String _kAzkarCountsKey = 'azkar_counts';

Future<void> initQuranDailyStorage() async {
  if (!Hive.isBoxOpen(kQuranDailyBoxName)) {
    await Hive.openBox(kQuranDailyBoxName);
  }
}

String _todayQuranKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

final quranDayTickerProvider = StreamProvider<String>((ref) async* {
  while (true) {
    yield _todayQuranKey();
    await Future<void>.delayed(const Duration(minutes: 1));
  }
});

class WerdNotifier extends Notifier<int> {
  Box<dynamic> get _box => Hive.box(kQuranDailyBoxName);

  @override
  int build() {
    ref.watch(quranDayTickerProvider);
    _ensureDailyReset();
    return (_box.get(_kWerdPagesKey) as int?) ?? 0;
  }

  void addPage() {
    _ensureDailyReset();
    state = state + 1;
    _box.put(_kWerdPagesKey, state);
  }

  void reset() {
    state = 0;
    _box.put(_kWerdPagesKey, state);
  }

  void _ensureDailyReset() {
    final today = _todayQuranKey();
    final storedDay = _box.get(_kDayKey) as String?;

    if (storedDay != today) {
      _box.put(_kDayKey, today);
      _box.put(_kWerdPagesKey, 0);
      _box.put(_kAzkarCountsKey, <String, int>{});
      state = 0;
    }
  }
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

final surahFontSizeProvider = StateProvider<double>((_) => 27);

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
  Box<dynamic> get _box => Hive.box(kQuranDailyBoxName);

  @override
  List<ZikrModel> build() {
    ref.watch(quranDayTickerProvider);

    final today = _todayQuranKey();
    final storedDay = _box.get(_kDayKey) as String?;
    if (storedDay != today) {
      _box.put(_kDayKey, today);
      _box.put(_kAzkarCountsKey, <String, int>{});
      return buildAzkar();
    }

    final base = buildAzkar();
    final countsRaw = _box.get(_kAzkarCountsKey);
    if (countsRaw is Map) {
      final counts = countsRaw.map((key, value) =>
          MapEntry(key.toString(), (value as num?)?.toInt() ?? 0));

      return [
        for (final z in base)
          if (counts.containsKey(z.id)) z.copyWith(count: counts[z.id]!) else z,
      ];
    }

    return base;
  }

  void tap(String id) {
    state = [
      for (final z in state)
        if (z.id == id && !z.isDone) z.copyWith(count: z.count + 1) else z,
    ];
    _persistCounts();
  }

  void resetAll() {
    state = buildAzkar();
    _persistCounts();
  }

  void _persistCounts() {
    _box.put(_kAzkarCountsKey, {
      for (final z in state) z.id: z.count,
    });
  }
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
  ref.watch(quranDayTickerProvider).valueOrNull;

  try {
    return await ref.read(quranApiServiceProvider).fetchAyahOfTheDay();
  } catch (_) {
    return todayAyah;
  }
});
