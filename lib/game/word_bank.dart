library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../config/game_config.dart';

class PickedWord {
  const PickedWord({
    required this.word,
    required this.index,
    required this.roundId,
    required this.language,
  });

  final String word;
  final int index;
  final String roundId;
  final String language;
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

/// Random word for unlimited play. Avoids repeating [avoidWord] when possible.
Future<PickedWord?> pickWord({
  required String language,
  String? avoidWord,
  Random? random,
}) async {
  final words = await loadWords(language);
  if (words.isEmpty) return null;

  final rng = random ?? Random();
  var index = rng.nextInt(words.length);
  if (words.length > 1 &&
      avoidWord != null &&
      words[index].toLowerCase() == avoidWord.toLowerCase()) {
    index = (index + 1 + rng.nextInt(words.length - 1)) % words.length;
  }

  final roundId =
      'r-${DateTime.now().toUtc().millisecondsSinceEpoch}-$index';
  return PickedWord(
    word: words[index],
    index: index,
    roundId: roundId,
    language: language,
  );
}
