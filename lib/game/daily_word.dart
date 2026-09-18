library;

import 'dart:convert';

import 'package:flutter/services.dart';

import '../config/game_config.dart';

class DailyWord {
  const DailyWord({
    required this.word,
    required this.index,
    required this.dayKey,
    required this.language,
  });

  final String word;
  final int index;
  final String dayKey;
  final String language;
}

String dayKeyFor(DateTime utcDay) {
  final y = utcDay.year.toString().padLeft(4, '0');
  final m = utcDay.month.toString().padLeft(2, '0');
  final d = utcDay.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

int dailyIndex({
  required String dayKey,
  required String language,
  required int length,
}) {
  if (length <= 0) return 0;
  final seed = '$dayKey|$language';
  var hash = 2166136261;
  for (final unit in seed.codeUnits) {
    hash ^= unit;
    hash = (hash * 16777619) & 0x7fffffff;
  }
  return hash % length;
}

Future<List<String>> loadWords(String language) async {
  final code = GameConfig.supportedLanguages.contains(language)
      ? language
      : GameConfig.defaultLanguage;
  final path = '${GameConfig.languagesAssetDir}/$code.json';
  final raw = await rootBundle.loadString(path);
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const [];
  return decoded
      .whereType<String>()
      .map((w) => w.trim())
      .where((w) => w.isNotEmpty)
      .toList();
}

Future<DailyWord?> pickDailyWord({
  required String language,
  DateTime? nowUtc,
}) async {
  final words = await loadWords(language);
  if (words.isEmpty) return null;
  final day = nowUtc ?? DateTime.now().toUtc();
  final key = dayKeyFor(DateTime.utc(day.year, day.month, day.day));
  final index = dailyIndex(
    dayKey: key,
    language: language,
    length: words.length,
  );
  return DailyWord(
    word: words[index],
    index: index,
    dayKey: key,
    language: language,
  );
}
