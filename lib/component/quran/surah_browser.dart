// lib/features/quran/widgets/surah_browser.dart
//
// Middle panel: searchable surah list that opens into a detail view.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/quran/quran_models.dart';
import 'package:omen/component/quran/quran_providers.dart';
import 'quran_theme.dart';

class SurahBrowser extends ConsumerWidget {
  const SurahBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSurahProvider);
    return active == null ? const _SurahList() : _SurahDetail(surah: active);
  }
}

// ── List view ─────────────────────────────────────────────

class _SurahList extends ConsumerWidget {
  const _SurahList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahs = ref.watch(filteredSurahsProvider);
    final query = ref.watch(surahSearchProvider);

    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: QuranTextStyles.label(12),
            decoration: InputDecoration(
              hintText: 'ابحث عن سورة...',
              hintStyle: QuranTextStyles.body(12, color: QuranColors.text3),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: QuranColors.border, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: QuranColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                    color: QuranColors.gold.withOpacity(0.35), width: 1),
              ),
            ),
            onChanged: (v) => ref.read(surahSearchProvider.notifier).state = v,
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            itemCount: surahs.length,
            itemBuilder: (_, i) => _SurahRow(
              surah: surahs[i],
              onTap: () {
                final selected = surahs[i];
                ref.read(activeSurahProvider.notifier).state = selected;
                ref.read(readingPositionProvider.notifier).update(
                      ReadingPosition(
                        surahId: selected.id,
                        ayahNumber: 1,
                        page: selected.page,
                      ),
                    );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SurahRow extends StatefulWidget {
  final SurahModel surah;
  final VoidCallback onTap;
  const _SurahRow({required this.surah, required this.onTap});

  @override
  State<_SurahRow> createState() => _SurahRowState();
}

class _SurahRowState extends State<_SurahRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? QuranColors.panelHover : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? QuranColors.border : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Number badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: QuranColors.border2, width: 1),
                ),
                alignment: Alignment.center,
                child: Text('${widget.surah.id}',
                    style: QuranTextStyles.mono(10, color: QuranColors.gold)),
              ),
              const SizedBox(width: 10),

              // Name + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.surah.name,
                        style:
                            QuranTextStyles.surahName.copyWith(fontSize: 16)),
                    Text('جزء ${widget.surah.juz}  ·  ص ${widget.surah.page}',
                        style:
                            QuranTextStyles.body(10, color: QuranColors.text3)),
                  ],
                ),
              ),

              // Type + ayat count
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _TypeBadge(type: widget.surah.type),
                  const SizedBox(height: 3),
                  Text('${widget.surah.ayatCount} آية',
                      style:
                          QuranTextStyles.body(10, color: QuranColors.text3)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final SurahType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isMakki = type == SurahType.makki;
    final color = isMakki ? QuranColors.gold : QuranColors.emerald;
    final label = isMakki ? 'مكية' : 'مدنية';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: QuranDecorations.pill(color: color),
      child: Text(label,
          style:
              QuranTextStyles.label(9, color: color, weight: FontWeight.w700)),
    );
  }
}

// ── Detail view ───────────────────────────────────────────

class _SurahDetail extends ConsumerWidget {
  final SurahModel surah;
  const _SurahDetail({required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayatAsync = ref.watch(activeSurahAyatProvider);
    final fontSize = ref.watch(surahFontSizeProvider);

    final currentPosition = ref.read(readingPositionProvider);
    if (currentPosition.surahId != surah.id) {
      ref.read(readingPositionProvider.notifier).update(
            ReadingPosition(surahId: surah.id, ayahNumber: 1, page: surah.page),
          );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () =>
                    ref.read(activeSurahProvider.notifier).state = null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration:
                      QuranDecorations.panel(radius: BorderRadius.circular(8)),
                  child: Text('← قائمة السور',
                      style:
                          QuranTextStyles.body(11, color: QuranColors.text3)),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(surah.name,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 30,
                    color: QuranColors.gold2,
                    fontWeight: FontWeight.w400,
                  )),
              const SizedBox(height: 4),
              Text(
                '${surah.ayatCount} آية  ·  جزء ${surah.juz}  ·  ${surah.type == SurahType.makki ? "مكية" : "مدنية"}',
                style: QuranTextStyles.body(11, color: QuranColors.text3),
              ),
            ],
          ),
        ),
        Container(
            height: 1,
            color: QuranColors.border2,
            margin: const EdgeInsets.symmetric(horizontal: 14)),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Row(
            children: [
              Text('A-', style: QuranTextStyles.mono(11, color: QuranColors.text3)),
              Expanded(
                child: Slider(
                  value: fontSize,
                  min: 20,
                  max: 40,
                  divisions: 10,
                  activeColor: QuranColors.gold,
                  inactiveColor: QuranColors.border,
                  onChanged: (value) =>
                      ref.read(surahFontSizeProvider.notifier).state = value,
                ),
              ),
              Text('A+', style: QuranTextStyles.mono(14, color: QuranColors.text3)),
            ],
          ),
        ),
        Expanded(
          child: ayatAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => Center(
              child: Text('تعذر تحميل السورة حالياً',
                  style: QuranTextStyles.body(13, color: QuranColors.text3)),
            ),
            data: (ayat) {
              if (ayat.isEmpty) {
                return Center(
                  child: Text('لا توجد آيات متاحة حالياً',
                      style: QuranTextStyles.body(13, color: QuranColors.text3)),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EBD7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD8C4A3), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x663A2A18),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (surah.id != 9) ...[
                        Text(
                          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: QuranTextStyles.quranText.copyWith(
                            fontSize: 24,
                            color: const Color(0xFF3B2A17),
                            height: 2.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text.rich(
                        TextSpan(children: _buildAyahSpans(ayat, fontSize)),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.justify,
                        style: QuranTextStyles.quranText.copyWith(
                          height: 2.2,
                          fontSize: fontSize,
                          color: const Color(0xFF111111),
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
    );
  }

  List<InlineSpan> _buildAyahSpans(List<AyahModel> ayat, double fontSize) {
    final spans = <InlineSpan>[];
    for (final ayah in ayat) {
      spans.add(TextSpan(text: '${ayah.text} '));
      spans.add(
        TextSpan(
          text: '۝${ayah.number} ',
          style: QuranTextStyles.quranText.copyWith(
            color: const Color(0xFF3B2A17),
            fontSize: fontSize - 5,
            height: 2.1,
          ),
        ),
      );
    }
    return spans;
  }
}
