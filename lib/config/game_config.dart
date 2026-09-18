/// Oyun kuralları. UI ölçüleri [AppDimens] içindedir.
library;

abstract final class GameConfig {
  /// Yanlış harf tavanı. Figür bu kadar parçada çizilir.
  static const int maxMistakes = 6;

  static const String defaultLanguage = 'tr';

  static const List<String> supportedLanguages = ['tr', 'en'];

  static const String languagesAssetDir = 'languages';

  /// Dil kodu → klavye satırları.
  static const Map<String, List<String>> keyboards = {
    'tr': [
      'ERTYUIOPĞÜ',
      'ASDFGHJKLŞİ',
      'ZCVBNMÖÇ',
    ],
    'en': [
      'QWERTYUIOP',
      'ASDFGHJKL',
      'ZXCVBNM',
    ],
  };

  static List<String> keyboardFor(String language) {
    return keyboards[language] ?? keyboards[defaultLanguage]!;
  }
}
