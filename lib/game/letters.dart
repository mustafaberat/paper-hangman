library;

String foldLetter(String raw, String language) {
  var s = raw.trim();
  if (s.isEmpty) return '';
  if (language == 'tr') {
    s = s.replaceAll('İ', 'i').replaceAll('I', 'ı');
  }
  return s.toLowerCase();
}

List<String> graphemes(String word, String language) {
  return word
      .characters
      .map((c) => foldLetter(c, language))
      .where((c) => c.isNotEmpty)
      .toList();
}

extension on String {
  Iterable<String> get characters sync* {
    for (final rune in runes) {
      yield String.fromCharCode(rune);
    }
  }
}
