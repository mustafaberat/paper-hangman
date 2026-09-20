/// Play Console görselleri: gerçek Hangman ekranlarını Play ölçülerinde PNG yazar.
///
/// Çalıştır: `APP_ROOT=. ../lib/scripts/generate_game_images.sh`
/// Çıktı: `play/gorseller/{ozellik-grafik,telefon,tablet,pc,chromebook}/`
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/app.dart';
import 'package:hangman/components/hangman_figure.dart';
import 'package:hangman/components/notebook_paper.dart';
import 'package:hangman/config/app_config.dart';
import 'package:hangman/game/game_store.dart';
import 'package:hangman/game/letters.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Play Console zorunlu / önerilen piksel ölçüleri (UI token değil).
const Size _featureSize = Size(1024, 500);
const Size _phoneSize = Size(1080, 1920);
const Size _tabletSize = Size(1440, 2560);
const Size _wideSize = Size(1920, 1080);

const String _outRoot = 'play/gorseller';

void main() {
  testWidgets('Play gorsellerini yaz', (tester) async {
    await tester.runAsync(_loadRealFonts);
    final shots = <String, Future<void> Function(WidgetTester, String)>{
      '01-anasayfa': _shotHome,
      '02-oyun': _shotPlay,
      '03-ayarlar': _shotSettings,
      '04-bitti': _shotResult,
    };

    _setView(tester, _featureSize);
    final featureKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: featureKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.paper,
          home: const _FeatureGraphic(),
        ),
      ),
    );
    await _settle(tester);
    await _writePng(
      tester,
      featureKey,
      '$_outRoot/ozellik-grafik/hangman-1024x500.png',
    );

    const devices = <String, Size>{
      'telefon': _phoneSize,
      'tablet': _tabletSize,
      'pc': _wideSize,
      'chromebook': _wideSize,
    };

    for (final device in devices.entries) {
      for (final shot in shots.entries) {
        _setView(tester, device.value);
        await shot.value(tester, '$_outRoot/${device.key}/${shot.key}.png');
      }
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}

Future<void> _loadRealFonts() async {
  Future<ByteData> fileBytes(String path) async {
    final data = await File(path).readAsBytes();
    return ByteData.sublistView(data);
  }

  Future<void> load(String family, String path) async {
    final loader = FontLoader(family);
    loader.addFont(fileBytes(path));
    await loader.load();
  }

  await load('PatrickHand', 'fonts/PatrickHand-Regular.ttf');
  await load('Caveat', 'fonts/Caveat-Bold.ttf');

  final root = Platform.environment['FLUTTER_ROOT'];
  expect(root, isNotNull, reason: 'FLUTTER_ROOT yok');
  final icons = FontLoader('MaterialIcons');
  icons.addFont(fileBytes('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf'));
  await icons.load();
}

Future<void> _settle(WidgetTester tester) {
  return tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

void _setView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding.zero;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
}

Future<(GlobalKey, GameStore)> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    AppPrefsKeys.language: 'tr',
    AppPrefsKeys.streak: 3,
    AppPrefsKeys.lastWinDay: '2026-09-19',
  });
  final store = GameStore();
  await store.load();
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: HangmanApp(store: store),
    ),
  );
  await _settle(tester);
  return (key, store);
}

Future<void> _shotHome(WidgetTester tester, String path) async {
  final shot = await _pumpApp(tester);
  await _writePng(tester, shot.$1, path);
}

Future<void> _shotPlay(WidgetTester tester, String path) async {
  final shot = await _pumpApp(tester);
  await _openPlay(tester);
  await _tapPartial(tester, shot.$2);
  await _writePng(tester, shot.$1, path);
}

Future<void> _shotSettings(WidgetTester tester, String path) async {
  final shot = await _pumpApp(tester);
  await tester.tap(find.text(AppStrings.settings('tr')));
  await _settle(tester);
  await _writePng(tester, shot.$1, path);
}

Future<void> _shotResult(WidgetTester tester, String path) async {
  final shot = await _pumpApp(tester);
  await _openPlay(tester);
  await _tapAllLetters(tester, shot.$2);
  await tester.pump();
  await _settle(tester);
  await _writePng(tester, shot.$1, path);
}

Future<void> _openPlay(WidgetTester tester) async {
  await tester.tap(find.text(AppStrings.play('tr')));
  await _settle(tester);
}

Future<void> _tapPartial(WidgetTester tester, GameStore store) async {
  final wordLetters = store.round!.letters.toSet();
  final hits = wordLetters.take(3).map((l) => l.toUpperCase());
  final miss = _firstMiss(store);
  await _tapLetters(tester, [...hits, miss]);
}

Future<void> _tapAllLetters(WidgetTester tester, GameStore store) async {
  final hits = store.round!.letters.toSet().map((l) => l.toUpperCase());
  await _tapLetters(tester, hits);
}

String _firstMiss(GameStore store) {
  const candidates = ['Y', 'T', 'K', 'N', 'Ö', 'Ş', 'P'];
  for (final letter in candidates) {
    if (!store.round!.letters.contains(foldLetter(letter, store.language))) {
      return letter;
    }
  }
  return 'Y';
}

Future<void> _tapLetters(WidgetTester tester, Iterable<String> letters) async {
  for (final letter in letters) {
    final finder = find.text(letter);
    if (finder.evaluate().isEmpty) continue;
    await tester.tap(finder.first);
    await tester.pump();
    await _settle(tester);
  }
}

Future<void> _writePng(WidgetTester tester, GlobalKey key, String path) async {
  await tester.pump();
  final bytes = await tester.binding.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
}

class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const NotebookPaper(),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 200,
                height: 200,
                child: HangmanFigure(mistakes: 6),
              ),
              const SizedBox(width: 36),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appTitle('tr'),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 56,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.tagline('tr'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 22,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
