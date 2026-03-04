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
              onTap: () =>
                  ref.read(activeSurahProvider.notifier).state = surahs[i],
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

    return Column(
      children: [
        // Back + header
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

        // Surah header
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

        // Ayat list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
            itemCount: ayatAsync.maybeWhen(data: (ayat) => ayat.isEmpty ? 1 : ayat.length + (surah.id != 9 ? 1 : 0), orElse: () => 1),
            itemBuilder: (_, i) {
              final ayat = ayatAsync.valueOrNull ?? const <AyahModel>[];
              // Basmala row
              if (surah.id != 9 && i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: QuranTextStyles.quranText.copyWith(
                      fontSize: 20,
                      color: QuranColors.gold,
                      shadows: [
                        Shadow(
                          color: QuranColors.gold.withOpacity(0.2),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final ayahIndex = surah.id != 9 ? i - 1 : i;

              if (ayatAsync.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (ayat.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text('لا توجد آيات متاحة حالياً',
                        style:
                            QuranTextStyles.body(13, color: QuranColors.text3)),
                  ),
                );
              }

              if (ayahIndex >= ayat.length) return const SizedBox.shrink();
              final ayah = ayat[ayahIndex];

              return _AyahRow(ayah: ayah);
            },
          ),
        ),
      ],
    );
  }
}

class _AyahRow extends StatelessWidget {
  final AyahModel ayah;
  const _AyahRow({required this.ayah});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: QuranColors.border2, width: 1),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ayah text
          Expanded(
            child: Text(
              '${ayah.text}  ﴿${ayah.number}﴾',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: QuranTextStyles.quranText,
            ),
          ),
        ],
      ),
    );
  }
}
