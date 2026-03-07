// lib/features/quran/widgets/surah_browser.dart
//
// Middle panel: searchable surah list that opens into a detail view.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/quran/quran_models.dart';
import 'package:omen/component/quran/quran_providers.dart';
import 'quran_theme.dart';
import 'package:omen/ui/quran_screen/surah_reader_screen.dart';

class SurahBrowser extends ConsumerWidget {
  const SurahBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _SurahList();
  }
}

// ── List view ─────────────────────────────────────────────

class _SurahList extends ConsumerWidget {
  const _SurahList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahs = ref.watch(filteredSurahsProvider);

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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SurahReaderScreen(surah: selected),
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
