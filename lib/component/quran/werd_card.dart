// lib/features/quran/widgets/werd_card.dart
//
// Daily reading goal tracker with progress bar and page counter.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/quran/quran_providers.dart';
import 'quran_theme.dart';

class WerdCard extends ConsumerWidget {
  const WerdCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(werdProvider);
    final goal = ref.watch(werdGoalProvider);
    final progress = ref.watch(werdProgressProvider);
    final done = ref.watch(werdDoneProvider);
    final remaining = (goal - pages).clamp(0, goal);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: QuranDecorations.goldCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الورد اليومي',
                  style: QuranTextStyles.label(11,
                      color: QuranColors.gold, weight: FontWeight.w700)),
              if (done)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: QuranDecorations.pill(color: QuranColors.emerald),
                  child: Text('✓ مكتمل',
                      style: QuranTextStyles.label(10,
                          color: QuranColors.emerald)),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الهدف $goal صفحات',
                  style: QuranTextStyles.body(10, color: QuranColors.text3)),
              Text('${(progress * 100).toInt()}%',
                  style: QuranTextStyles.mono(10)),
            ],
          ),
          const SizedBox(height: 5),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Stack(children: [
              Container(
                height: 4,
                color: Colors.white.withOpacity(0.06),
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                widthFactor: progress,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [QuranColors.gold, QuranColors.gold2],
                    ),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: QuranColors.gold.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // Stat boxes
          Row(
            children: [
              _StatBox(value: '$pages', label: 'مقروء'),
              const SizedBox(width: 6),
              _StatBox(value: '$remaining', label: 'متبقي'),
              const SizedBox(width: 6),
              _StatBox(value: '$goal', label: 'الهدف'),
            ],
          ),
          const SizedBox(height: 10),

          // Action button
          GestureDetector(
            onTap: done
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    ref.read(werdProvider.notifier).addPage();
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                gradient: done
                    ? null
                    : const LinearGradient(
                        colors: [QuranColors.gold, QuranColors.gold2]),
                color: done ? QuranColors.emeraldDim : null,
                borderRadius: BorderRadius.circular(8),
                border: done
                    ? Border.all(color: QuranColors.emerald.withOpacity(0.3))
                    : null,
                boxShadow: done
                    ? null
                    : [
                        BoxShadow(
                          color: QuranColors.gold.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ],
              ),
              alignment: Alignment.center,
              child: Text(
                done ? 'أحسنت! الورد مكتمل ✓' : '+ سجّل صفحة',
                style: QuranTextStyles.label(12,
                    color: done ? QuranColors.emerald : QuranColors.bg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: Column(
          children: [
            Text(value,
                style: QuranTextStyles.mono(18,
                    color: QuranColors.gold2, weight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: QuranTextStyles.body(9, color: QuranColors.text3)),
          ],
        ),
      ),
    );
  }
}
