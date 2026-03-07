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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeSurahProvider.notifier).state = widget.surah;
      ref.read(readingPositionProvider.notifier).update(
            ReadingPosition(
              surahId: widget.surah.id,
              ayahNumber: 1,
              page: widget.surah.page,
            ),
          );
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
            Text(widget.surah.ename, style: QuranTextStyles.body(10, color: QuranColors.text3)),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x1AF4EBD6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x55D9C09A)),
                ),
                child: Column(
                  children: [
                    Text(
                      '${widget.surah.ename}  •  ${widget.surah.ayatCount} آية  •  ${widget.surah.type == SurahType.makki ? 'مكية' : 'مدنية'}',
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
              ),
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
                            if (widget.surah.id != 9)
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
                            Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0DFC2),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: const Color(0xFFC39A63), width: 1),
                              ),
                              child: Text(
                                '﷽  Surah ${widget.surah.id}',
                                style: QuranTextStyles.mono(10, color: const Color(0xFF6A4B2A)),
                              ),
                            ),
                            Text.rich(
                              TextSpan(children: _buildAyahSpans(ayat, fontSize)),
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<InlineSpan> _buildAyahSpans(List<AyahModel> ayat, double fontSize) {
    final spans = <InlineSpan>[];
    for (final ayah in ayat) {
      final text = _readableAyahText(ayah);
      spans.add(TextSpan(text: '$text '));
      spans.add(
        TextSpan(
          text: '۝${ayah.number} ',
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
      return quran.getVerse(widget.surah.id, ayah.number, verseEndSymbol: false);
    } catch (_) {
      return ayah.text;
    }
  }
}
