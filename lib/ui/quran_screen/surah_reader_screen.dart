import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/quran/quran_models.dart';
import 'package:omen/component/quran/quran_providers.dart';
import 'package:omen/component/quran/quran_theme.dart';
import 'package:quran_library/quran_library.dart' as quran;

class SurahReaderScreen extends ConsumerStatefulWidget {
  final SurahModel surah;

  const SurahReaderScreen({super.key, required this.surah});

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  int _currentPageIndex = 0;
  bool _pageInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeSurahProvider.notifier).state = widget.surah;

      final pos = ref.read(readingPositionProvider);
      if (pos.surahId != widget.surah.id) {
        ref.read(readingPositionProvider.notifier).update(
              ReadingPosition(
                surahId: widget.surah.id,
                ayahNumber: 1,
                page: widget.surah.page,
              ),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ayatAsync = ref.watch(activeSurahAyatProvider);
    final fontSize = ref.watch(surahFontSizeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF101318),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.surah.name, style: QuranTextStyles.surahName),
            Text(
              widget.surah.ename,
              style: QuranTextStyles.body(10, color: QuranColors.text3),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            children: [
              _ReaderHeader(surah: widget.surah, fontSize: fontSize),
              const SizedBox(height: 14),
              Expanded(
                child: ayatAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Text(
                      'تعذر تحميل السورة حالياً',
                      style: QuranTextStyles.body(14, color: QuranColors.text3),
                    ),
                  ),
                  data: (ayat) {
                    if (ayat.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد آيات متاحة',
                          style: QuranTextStyles.body(14, color: QuranColors.text3),
                        ),
                      );
                    }

                    final pageGroups = _groupAyatByPage(ayat);
                    _ensureInitialPage(pageGroups);

                    final entry = pageGroups[_currentPageIndex];
                    final pageNumber = entry.$1;
                    final pageAyat = entry.$2;
                    final firstAyah = pageAyat.first.number;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _currentPageIndex > 0
                                    ? () => _goToPage(pageGroups, _currentPageIndex - 1)
                                    : null,
                                icon: const Icon(Icons.chevron_left_rounded),
                                label: const Text('الصفحة السابقة'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _currentPageIndex < pageGroups.length - 1
                                    ? () => _goToPage(pageGroups, _currentPageIndex + 1)
                                    : null,
                                icon: const Icon(Icons.chevron_right_rounded),
                                label: const Text('الصفحة التالية'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  ref.read(werdProvider.notifier).addPage();
                                  ref.read(readingPositionProvider.notifier).update(
                                        ReadingPosition(
                                          surahId: widget.surah.id,
                                          ayahNumber: firstAyah,
                                          page: pageNumber,
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم تسجيل صفحة مقروءة'),
                                      duration: Duration(milliseconds: 900),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.auto_stories_rounded),
                                label: const Text('أنهيت هذه الصفحة +1'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: _QuranPageCard(
                            pageNumber: pageNumber,
                            pageIndex: _currentPageIndex + 1,
                            totalPages: pageGroups.length,
                            showBismillah:
                                _currentPageIndex == 0 && widget.surah.id != 9,
                            ayat: pageAyat,
                            fontSize: fontSize,
                            surahId: widget.surah.id,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _ensureInitialPage(List<(int, List<AyahModel>)> pageGroups) {
    if (_pageInitialized) return;

    final last = ref.read(readingPositionProvider);
    final index = pageGroups.indexWhere((entry) => entry.$1 == last.page);
    _currentPageIndex = index == -1 ? 0 : index;
    _pageInitialized = true;
  }

  void _goToPage(List<(int, List<AyahModel>)> pageGroups, int index) {
    final safe = index.clamp(0, pageGroups.length - 1);
    final page = pageGroups[safe];
    final firstAyah = page.$2.first.number;

    setState(() => _currentPageIndex = safe);
    ref.read(readingPositionProvider.notifier).update(
          ReadingPosition(
            surahId: widget.surah.id,
            ayahNumber: firstAyah,
            page: page.$1,
          ),
        );
  }

  List<(int, List<AyahModel>)> _groupAyatByPage(List<AyahModel> ayat) {
    final grouped = <int, List<AyahModel>>{};

    for (final a in ayat) {
      final page = a.page ?? widget.surah.page;
      grouped.putIfAbsent(page, () => []).add(a);
    }

    final pages = grouped.keys.toList()..sort();
    return pages.map((p) => (p, grouped[p]!)).toList();
  }
}

class _ReaderHeader extends ConsumerWidget {
  final SurahModel surah;
  final double fontSize;

  const _ReaderHeader({required this.surah, required this.fontSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1AF4EBD6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x55D9C09A)),
      ),
      child: Column(
        children: [
          Text(
            '${surah.ename}  •  ${surah.ayatCount} آية  •  ${surah.type == SurahType.makki ? 'مكية' : 'مدنية'}',
            style: QuranTextStyles.body(12, color: QuranColors.text3),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('A-', style: QuranTextStyles.mono(11, color: QuranColors.text3)),
              Expanded(
                child: Slider(
                  value: fontSize,
                  min: 20,
                  max: 44,
                  divisions: 12,
                  activeColor: QuranColors.gold,
                  inactiveColor: QuranColors.border,
                  onChanged: (value) =>
                      ref.read(surahFontSizeProvider.notifier).state = value,
                ),
              ),
              Text('A+', style: QuranTextStyles.mono(14, color: QuranColors.text3)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuranPageCard extends StatelessWidget {
  final int pageNumber;
  final int pageIndex;
  final int totalPages;
  final bool showBismillah;
  final List<AyahModel> ayat;
  final double fontSize;
  final int surahId;

  const _QuranPageCard({
    required this.pageNumber,
    required this.pageIndex,
    required this.totalPages,
    required this.showBismillah,
    required this.ayat,
    required this.fontSize,
    required this.surahId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F1DD), Color(0xFFF3E5C7)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCFB48A), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xAA3F2E19).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0DFC2),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: const Color(0xFFC39A63), width: 1),
              ),
              child: Text(
                'الصفحة $pageNumber  •  $pageIndex/$totalPages',
                style: QuranTextStyles.mono(10, color: const Color(0xFF6A4B2A)),
              ),
            ),
            if (showBismillah)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: QuranTextStyles.quranText.copyWith(
                    color: const Color(0xFF4A3320),
                    fontSize: fontSize - 2,
                    height: 2,
                  ),
                ),
              ),
            Text.rich(
              TextSpan(children: _buildAyahSpans()),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              style: QuranTextStyles.quranText.copyWith(
                fontSize: fontSize,
                height: 2.1,
                color: const Color(0xFF17120B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _buildAyahSpans() {
    final spans = <InlineSpan>[];
    for (final ayah in ayat) {
      final text = _readableAyahText(ayah);
      spans.add(TextSpan(text: '$text '));
      spans.add(
        TextSpan(
          text: '${_ornateAyahNumber(ayah.number)} ',
          style: QuranTextStyles.quranText.copyWith(
            color: const Color(0xFF6A4B2A),
            fontSize: fontSize - 6,
            height: 2,
          ),
        ),
      );
    }
    return spans;
  }

  String _readableAyahText(AyahModel ayah) {
    try {
      return quran.getVerse(surahId, ayah.number, verseEndSymbol: false);
    } catch (_) {
      return ayah.text;
    }
  }

  String _ornateAyahNumber(int number) {
    final arabicIndic = _toArabicIndic(number);
    return '﴿$arabicIndic﴾';
  }

  String _toArabicIndic(int value) {
    const latin = '0123456789';
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    return value
        .toString()
        .split('')
        .map((digit) => arabic[latin.indexOf(digit)])
        .join();
  }
}
