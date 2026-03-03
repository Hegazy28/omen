// lib/features/quran/widgets/ayah_of_day_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/quran/quran_providers.dart';
import 'quran_theme.dart';

class AyahOfDayCard extends ConsumerWidget {
  const AyahOfDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayah = ref.watch(ayahOfDayProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: QuranDecorations.panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('آية اليوم',
              style: QuranTextStyles.label(10,
                  color: QuranColors.text3, weight: FontWeight.w700)),
          const SizedBox(height: 10),

          // Decorative ornament
          Text('❧',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: QuranColors.gold.withOpacity(0.4),
                height: 1,
              )),
          const SizedBox(height: 8),

          // Ayah text
          Text(
            ayah.text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: QuranTextStyles.quranText.copyWith(fontSize: 18),
          ),

          const SizedBox(height: 10),

          // Reference
          Text(
            '﴿ ${ayah.surahName}  —  ${ayah.ayahRef} ﴾',
            textAlign: TextAlign.center,
            style: QuranTextStyles.label(11, color: QuranColors.gold),
          ),
        ],
      ),
    );
  }
}
