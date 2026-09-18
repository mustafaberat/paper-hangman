library;

import 'game_config.dart';
import 'tokens.dart';

abstract final class AppStrings {
  static String titleFor(String language) {
    return language == 'en' ? 'Daily word' : 'Günün kelimesi';
  }

  static String remaining(int left, String language) {
    if (language == 'en') {
      return '$left left';
    }
    return '$left hak';
  }

  static String won(String language) {
    return language == 'en' ? 'Found it' : 'Buldun';
  }

  static String lost(String language) {
    return language == 'en' ? 'Tomorrow' : 'Yarın tekrar';
  }

  static String languageLabel(String code) {
    return code.toUpperCase();
  }

  static String developerLine() => '${AppIdentity.developer}  ·  v${AppIdentity.version}';

  static String emptyList(String language) {
    if (language == 'en') {
      return 'No words in languages/${GameConfig.defaultLanguage}.json';
    }
    return 'languages/$language.json boş';
  }
}
