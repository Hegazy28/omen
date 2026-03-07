// lib/features/quran/models/quran_models.dart

import 'package:flutter/foundation.dart';

// ── Surah ─────────────────────────────────────────────────

enum SurahType { makki, madani }

@immutable
class SurahModel {
  final int id;
  final String name;         // Arabic name
  final String ename;        // English transliteration
  final int ayatCount;
  final int juz;
  final int page;
  final SurahType type;

  const SurahModel({
    required this.id,
    required this.name,
    required this.ename,
    required this.ayatCount,
    required this.juz,
    required this.page,
    required this.type,
  });
}

// ── Ayah ──────────────────────────────────────────────────

@immutable
class AyahModel {
  final int number;         // within surah
  final String text;        // Arabic text
  final int? page;          // mushaf page if available

  const AyahModel({required this.number, required this.text, this.page});
}

// ── Reading position ──────────────────────────────────────

@immutable
class ReadingPosition {
  final int surahId;
  final int ayahNumber;
  final int page;

  const ReadingPosition({
    required this.surahId,
    required this.ayahNumber,
    required this.page,
  });

  ReadingPosition copyWith({int? surahId, int? ayahNumber, int? page}) =>
      ReadingPosition(
        surahId:     surahId     ?? this.surahId,
        ayahNumber:  ayahNumber  ?? this.ayahNumber,
        page:        page        ?? this.page,
      );
}

// ── Ayah of the day ───────────────────────────────────────

@immutable
class AyahOfDay {
  final String text;
  final String surahName;
  final String ayahRef;    // e.g. "45" or "5-6"

  const AyahOfDay({
    required this.text,
    required this.surahName,
    required this.ayahRef,
  });
}

// ── Zikr ──────────────────────────────────────────────────

enum ZikrCategory { morning, evening, general }

class ZikrModel {
  final String id;
  final String text;
  final ZikrCategory category;
  final int total;         // how many times to repeat
  int count;              // current tap count

  ZikrModel({
    required this.id,
    required this.text,
    required this.category,
    required this.total,
    this.count = 0,
  });

  bool get isDone => count >= total;

  ZikrModel copyWith({int? count}) =>
      ZikrModel(
        id:       id,
        text:     text,
        category: category,
        total:    total,
        count:    count ?? this.count,
      );
}
