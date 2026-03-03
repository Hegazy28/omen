// lib/features/quran/widgets/continue_card.dart
//
// Tappable card that navigates back to the last reading position.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/quran/quran_providers.dart';
import 'quran_theme.dart';

class ContinueReadingCard extends ConsumerWidget {
  const ContinueReadingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surah = ref.watch(lastReadSurahProvider);
    final position = ref.watch(readingPositionProvider);
    if (surah == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => ref.read(activeSurahProvider.notifier).state = surah,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: QuranDecorations.emeraldCard(),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('↩  أكمل القراءة',
                      style: QuranTextStyles.label(10,
                          color: QuranColors.emerald, weight: FontWeight.w700)),
                  const SizedBox(height: 7),
                  Text(surah.name,
                      style: QuranTextStyles.surahName.copyWith(fontSize: 18)),
                  const SizedBox(height: 3),
                  Text(
                    'صفحة ${position.page}  ·  آية ${position.ayahNumber}',
                    style: QuranTextStyles.body(11, color: QuranColors.text3),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: QuranColors.emerald),
          ],
        ),
      ),
    );
  }
}
