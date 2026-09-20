library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/app_config.dart';
import 'game/game_store.dart';
import 'screens/home_screen.dart';
import 'screens/play_screen.dart';
import 'screens/settings_screen.dart';

class HangmanApp extends StatelessWidget {
  const HangmanApp({required this.store, super.key});

  final GameStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppIdentity.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.paper,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => HomeScreen(store: store),
        AppRoutes.play: (_) => PlayScreen(store: store),
        AppRoutes.settings: (_) => SettingsScreen(store: store),
      },
    );
  }
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = GameStore();
  await store.load();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      systemNavigationBarColor: AppColors.paper,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(HangmanApp(store: store));
}
