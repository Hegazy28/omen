// lib/features/quran/widgets/azkar_panel.dart
//
// Right panel: category tabs + zikr cards with tap counter and SVG ring.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/quran/quran_models.dart';
import 'package:omen/component/quran/quran_providers.dart';
import 'quran_theme.dart';

class AzkarPanel extends ConsumerWidget {
  const AzkarPanel({super.key});

  static const _categories = [
    (label: 'صباح', cat: ZikrCategory.morning),
    (label: 'مساء', cat: ZikrCategory.evening),
    (label: 'عام', cat: ZikrCategory.general),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(azkarCategoryProvider);
    final progress = ref.watch(azkarProgressProvider);

    return Column(
      children: [
        // Header tabs + progress badge
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Row(
            children: [
              // Tabs
              ..._categories.map((c) {
                final active = current == c.cat;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(azkarCategoryProvider.notifier).state = c.cat,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: active ? QuranColors.goldDim : QuranColors.panel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: active
                              ? QuranColors.gold.withOpacity(0.3)
                              : QuranColors.border,
                          width: 1,
                        ),
                      ),
                      child: Text(c.label,
                          style: QuranTextStyles.label(11,
                              color: active
                                  ? QuranColors.gold
                                  : QuranColors.text3)),
                    ),
                  ),
                );
              }),

              const Spacer(),

              // Done badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: QuranDecorations.pill(color: QuranColors.emerald),
                child: Text(
                  '${progress.$1}/${progress.$2}',
                  style: QuranTextStyles.label(9,
                      color: QuranColors.emerald, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),

        // Zikr list
        Expanded(
          child: _ZikrList(),
        ),
      ],
    );
  }
}

class _ZikrList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(filteredAzkarProvider);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
      itemCount: list.length,
      itemBuilder: (_, i) => _ZikrCard(zikr: list[i]),
    );
  }
}

class _ZikrCard extends ConsumerWidget {
  final ZikrModel zikr;
  const _ZikrCard({required this.zikr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: zikr.isDone
          ? null
          : () {
              HapticFeedback.selectionClick();
              ref.read(azkarProvider.notifier).tap(zikr.id);
            },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: zikr.isDone ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: QuranDecorations.panel(radius: BorderRadius.circular(11)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Zikr text
              Text(
                zikr.text,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  height: 2.0,
                  color: QuranColors.text1,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),

              // Footer: ring + label / done badge
              Row(
                children: [
                  _ZikrRing(count: zikr.count, total: zikr.total),
                  const SizedBox(width: 8),
                  if (!zikr.isDone)
                    Text(
                      'اضغط للعدّ  ·  ${zikr.total - zikr.count} متبقي',
                      style: QuranTextStyles.body(10, color: QuranColors.text3),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration:
                          QuranDecorations.pill(color: QuranColors.emerald),
                      child: Text('✓ تم',
                          style: QuranTextStyles.label(10,
                              color: QuranColors.emerald)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Progress ring ─────────────────────────────────────────

class _ZikrRing extends StatelessWidget {
  final int count;
  final int total;
  const _ZikrRing({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct =
        total == 1 ? (count >= 1 ? 1.0 : 0.0) : (count / total).clamp(0.0, 1.0);

    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(32, 32),
            painter: _RingPainter(progress: pct),
          ),
          Text(
            '$count',
            style: QuranTextStyles.mono(8,
                color: QuranColors.gold, weight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2 - 2;

    // Track
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Fill arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = QuranColors.gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
