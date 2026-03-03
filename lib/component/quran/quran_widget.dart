// lib/features/quran/widgets/quran_widget.dart
//
// DROP-IN USAGE:
//
//   import 'package:your_app/features/quran/quran.dart';
//
//   const QuranWidget()   // fills its parent — wrap in Padding/Expanded
//
// Must be inside a ProviderScope.

import 'package:flutter/material.dart';
import 'quran_theme.dart';
import 'werd_card.dart';
import 'continue_card.dart';
import 'ayah_of_day_card.dart';
import 'surah_browser.dart';
import 'azkar_panel.dart';

class QuranWidget extends StatelessWidget {
  const QuranWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Top bar ──────────────────────────────────────
        const _TopBar(),
        const SizedBox(height: 16),

        // ── Three-column layout ──────────────────────────
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LEFT — Werd + Continue + Ayah
              SizedBox(
                width: 270,
                child: _LeftColumn(),
              ),
              const SizedBox(width: 12),

              // CENTRE — Surah browser
              Expanded(
                child: _PanelShell(
                  stripeColors: const [QuranColors.gold, Color(0x4DC9A84C)],
                  iconBg:    QuranColors.goldDim,
                  iconBorder: Color(0x4DC9A84C),
                  iconColor: QuranColors.gold,
                  iconData:  Icons.menu_book_rounded,
                  title:     'السور القرآنية',
                  child:     const SurahBrowser(),
                  padding:   EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 12),

              // RIGHT — Azkar
              SizedBox(
                width: 250,
                child: _PanelShell(
                  stripeColors: const [QuranColors.emerald, Color(0x4D2DD4A0)],
                  iconBg:    QuranColors.emeraldDim,
                  iconBorder: Color(0x402DD4A0),
                  iconColor: QuranColors.emerald,
                  iconData:  Icons.nights_stay_outlined,
                  title:     'الأذكار',
                  child:     const AzkarPanel(),
                  padding:   EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  String _hijriLabel() {
    final now    = DateTime.now();
    const months = [
      'محرم','صفر','ربيع الأول','ربيع الآخر',
      'جمادى الأولى','جمادى الآخرة','رجب','شعبان',
      'رمضان','شوال','ذو القعدة','ذو الحجة',
    ];
    final approxYear  = (now.year - 621).toInt();
    final approxMonth = (now.month + 6) % 12;
    return '${now.day} ${months[approxMonth]} $approxYear هـ';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Brand
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: QuranColors.goldDim,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: QuranColors.gold.withOpacity(0.3), width: 1),
          ),
          alignment: Alignment.center,
          child: const Text('☽',
              style: TextStyle(fontSize: 18, color: QuranColors.gold)),
        ),
        const SizedBox(width: 12),
        Text('القرآن الكريم',
            style: QuranTextStyles.heading(20)),

        const Spacer(),

        // Hijri date
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: QuranDecorations.panel(
              radius: BorderRadius.circular(8)),
          child: Text(_hijriLabel(),
              style: QuranTextStyles.label(11,
                  color: QuranColors.gold,
                  weight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ── Left column ───────────────────────────────────────────

class _LeftColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          WerdCard(),
          SizedBox(height: 10),
          ContinueReadingCard(),
          SizedBox(height: 10),
          AyahOfDayCard(),
        ],
      ),
    );
  }
}

// ── Panel shell (column wrapper) ──────────────────────────

class _PanelShell extends StatelessWidget {
  final List<Color> stripeColors;
  final Color     iconBg;
  final Color     iconBorder;
  final Color     iconColor;
  final IconData  iconData;
  final String    title;
  final Widget    child;
  final EdgeInsets padding;

  const _PanelShell({
    required this.stripeColors,
    required this.iconBg,
    required this.iconBorder,
    required this.iconColor,
    required this.iconData,
    required this.title,
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: QuranDecorations.panel(),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Accent stripe
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [...stripeColors, Colors.transparent],
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: iconBorder, width: 1),
                  ),
                  child: Icon(iconData, size: 14, color: iconColor),
                ),
                const SizedBox(width: 9),
                Text(title,
                    style: QuranTextStyles.label(13)),
              ],
            ),
          ),

          Container(height: 1, color: QuranColors.border2),

          // Content
          Expanded(child: child),
        ],
      ),
    );
  }
}
