library;

import 'game_config.dart';
import 'tokens.dart';

abstract final class AppStrings {
  static String appTitle(String language) =>
      language == 'en' ? 'Hangman' : 'Adam Asmaca';

  static String tagline(String language) =>
      language == 'en' ? 'One word a day' : 'Her gün bir kelime';

  static String play(String language) => language == 'en' ? 'Play' : 'Oyna';

  static String continuePlay(String language) =>
      language == 'en' ? 'Continue' : 'Devam et';

  static String seeToday(String language) =>
      language == 'en' ? 'See today' : 'Bugünü gör';

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
    return language == 'en' ? 'Today is your day' : 'Bugün senin günün';
  }

  static String lost(String language) {
    return language == 'en'
        ? 'Today is not your day'
        : 'Bugün senin günün değil';
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
      return streak == 1 ? '1 day streak' : '$streak day streak';
    }
    return streak == 1 ? '1 günlük seri' : '$streak günlük seri';
  }

  static String howToLines(String language) {
    if (language == 'en') {
      return 'One word each day.\n${GameConfig.maxMistakes} wrong guesses.\nCome back tomorrow.';
    }
    return 'Her gün bir kelime.\n${GameConfig.maxMistakes} yanlış hakkın var.\nYarın yeni kelime.';
  }

  static String todayLabel(String dayKey, String language) {
    final parts = dayKey.split('-');
    if (parts.length != 3) return dayKey;
    final month = int.tryParse(parts[1]) ?? 1;
    final day = int.tryParse(parts[2]) ?? 1;
    if (language == 'en') {
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[month - 1]} $day';
    }
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '$day ${months[month - 1]}';
  }

  static String versionLine() => 'v${AppIdentity.version}';

  static String emptyList(String language) {
    if (language == 'en') {
      return 'No words in languages/${GameConfig.defaultLanguage}.json';
    }
    return 'languages/$language.json boş';
  }
}
