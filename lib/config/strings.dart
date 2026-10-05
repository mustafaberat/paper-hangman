library;

import 'game_config.dart';
import 'tokens.dart';

abstract final class AppStrings {
  static String appTitle(String language) =>
      language == 'en' ? 'Paper Hangman' : 'Adam Asmaca';

  static String tagline(String language) =>
      language == 'en' ? 'Guess as many words as you like' : 'İstediğin kadar kelime tahmin et';

  static String play(String language) => language == 'en' ? 'Play' : 'Oyna';

  static String continuePlay(String language) =>
      language == 'en' ? 'Continue' : 'Devam et';

  static String playAgain(String language) =>
      language == 'en' ? 'Play again' : 'Tekrar oyna';

  static String settings(String language) =>
      language == 'en' ? 'Settings' : 'Ayarlar';

  static String language(String language) =>
      language == 'en' ? 'Language' : 'Dil';

  static String howTo(String language) =>
      language == 'en' ? 'How to play' : 'Nasıl oynanır';

  static String remaining(int left, String language) {
    if (language == 'en') {
      return '$left left';
    }
    return '$left hak';
  }

  static String won(String language) {
    return language == 'en' ? 'You got it' : 'Bildin';
  }

  static String lost(String language) {
    return language == 'en' ? 'So close' : 'Bu sefer olmadı';
  }

  static String theWord(String word, String language) {
    return language == 'en' ? 'The word: $word' : 'Kelime: $word';
  }

  static String ok(String language) => language == 'en' ? 'OK' : 'Tamam';

  static String back(String language) => language == 'en' ? 'Back' : 'Geri';

  static String languageName(String code, String ui) {
    if (code == 'tr') return ui == 'en' ? 'Turkish' : 'Türkçe';
    return 'English';
  }

  static String languageLabel(String code) => code.toUpperCase();

  static String streakLine(int streak, String language) {
    if (streak <= 0) return '';
    if (language == 'en') {
      return streak == 1 ? '1 win streak' : '$streak win streak';
    }
    return streak == 1 ? '1 kazanma serisi' : '$streak kazanma serisi';
  }

  static String howToLines(String language) {
    if (language == 'en') {
      return 'Guess the hidden word.\n${GameConfig.maxMistakes} wrong guesses.\nPlay as many rounds as you want.';
    }
    return 'Gizli kelimeyi bul.\n${GameConfig.maxMistakes} yanlış hakkın var.\nİstediğin kadar tur oyna.';
  }

  static String versionLine() => 'v${AppIdentity.version}';

  static String emptyList(String language) {
    if (language == 'en') {
      return 'No words in languages/${GameConfig.defaultLanguage}.json';
    }
    return 'languages/$language.json boş';
  }
}
