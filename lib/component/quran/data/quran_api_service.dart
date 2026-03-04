import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:omen/component/quran/quran_models.dart';

class QuranApiService {
  Future<List<AyahModel>> fetchSurahAyat(int surahId) async {
    final url = Uri.parse('https://api.alquran.cloud/v1/surah/$surahId');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch surah $surahId');
    }

    if (response.body.trim().isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>?;
    final ayahs = data?['ayahs'] as List<dynamic>? ?? [];

    return ayahs
        .whereType<Map<String, dynamic>>()
        .map(
          (ayah) => AyahModel(
            number: (ayah['numberInSurah'] as num?)?.toInt() ?? 0,
            text: (ayah['text'] ?? '').toString(),
          ),
        )
        .where((ayah) => ayah.text.isNotEmpty)
        .toList();
  }

  Future<AyahOfDay> fetchAyahOfTheDay() async {
    final number = DateTime.now().difference(DateTime(2024)).inDays % 6236 + 1;
    final url =
        Uri.parse('https://api.alquran.cloud/v1/ayah/$number/ar.alafasy');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch ayah of the day');
    }

    if (response.body.trim().isEmpty) {
      throw Exception('Empty ayah response');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>?;
    final surah = data?['surah'] as Map<String, dynamic>?;

    return AyahOfDay(
      text: (data?['text'] ?? '').toString(),
      surahName: (surah?['name'] ?? '').toString(),
      ayahRef: (data?['numberInSurah'] ?? '').toString(),
    );
  }
}
