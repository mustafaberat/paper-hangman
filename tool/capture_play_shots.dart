/// Play phone raw captures for Paper Hangman (tr / en).
///
/// Output: `play/gorseller/raw/{tr,en}/01-home|02-play|03-settings.png`
/// Size: 390×844 @3× → 1170×2532.
///
/// Run: `APP_ROOT=. ../lib/scripts/generate_game_images.sh`
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

const Size _logicalPhone = Size(390, 844);
const double _dpr = 3;
const Size _featureSize = Size(1024, 500);
const String _outRoot = 'play/gorseller/raw';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Play gorsellerini yaz', (tester) async {
    await tester.runAsync(_loadRealFonts);

    // Feature graphic (shared, TR branding).
    _setView(tester, _featureSize, dpr: 1);
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
      'play/gorseller/ozellik-grafik/hangman-1024x500.png',
      pixelRatio: 1,
    );
    final featureSrc =
        File('play/gorseller/ozellik-grafik/hangman-1024x500.png');
    for (final lang in ['tr', 'en']) {
      final dest = File('play/gorseller/$lang/feature.png');
      dest.parent.createSync(recursive: true);
      featureSrc.copySync(dest.path);
    }

    const langs = ['tr', 'en'];
    for (final lang in langs) {
      await _shotHome(tester, lang, '$_outRoot/$lang/01-home.png');
      await _shotPlay(tester, lang, '$_outRoot/$lang/02-play.png');
      await _shotSettings(tester, lang, '$_outRoot/$lang/03-settings.png');
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
  icons.addFont(
    fileBytes(
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ),
  );
  await icons.load();
}

Future<void> _settle(WidgetTester tester) {
  return tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

void _setView(WidgetTester tester, Size size, {double dpr = _dpr}) {
  tester.view.physicalSize = Size(size.width * dpr, size.height * dpr);
  tester.view.devicePixelRatio = dpr;
  tester.view.padding = FakeViewPadding.zero;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
}

Future<(GlobalKey, GameStore)> _pumpApp(
  WidgetTester tester,
  String lang,
) async {
  _setView(tester, _logicalPhone);
  SharedPreferences.setMockInitialValues({
    AppPrefsKeys.language: lang,
    AppPrefsKeys.streak: 3,
  });
  final store = GameStore();
  // Deterministic word for screenshots.
  await store.load();
  // Re-seed a known mid-length word via prefs wipe + fixed random path:
  // load already picked random; for play shot we just use whatever was picked.
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: MediaQuery(
        data: MediaQueryData(
          size: _logicalPhone,
          devicePixelRatio: _dpr,
          padding: const EdgeInsets.only(top: 47, bottom: 34),
          textScaler: TextScaler.noScaling,
        ),
        child: HangmanApp(store: store),
      ),
    ),
  );
  await _settle(tester);
  return (key, store);
}

Future<void> _shotHome(WidgetTester tester, String lang, String path) async {
  final shot = await _pumpApp(tester, lang);
  await _writePng(tester, shot.$1, path);
}

Future<void> _shotPlay(WidgetTester tester, String lang, String path) async {
  final shot = await _pumpApp(tester, lang);
  await tester.tap(find.text(AppStrings.play(lang)));
  await _settle(tester);
  await _tapPartial(tester, shot.$2);
  await _writePng(tester, shot.$1, path);
}

Future<void> _shotSettings(
  WidgetTester tester,
  String lang,
  String path,
) async {
  final shot = await _pumpApp(tester, lang);
  await tester.tap(find.text(AppStrings.settings(lang)));
  await _settle(tester);
  await _writePng(tester, shot.$1, path);
}

Future<void> _tapPartial(WidgetTester tester, GameStore store) async {
  final wordLetters = store.round!.letters.toSet();
  final hits = wordLetters.take(2).map((l) => l.toUpperCase());
  final miss = _firstMiss(store);
  await _tapLetters(tester, [...hits, miss]);
}

String _firstMiss(GameStore store) {
  const candidates = ['Y', 'T', 'K', 'N', 'Ö', 'Ş', 'P', 'X', 'Q'];
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

Future<void> _writePng(
  WidgetTester tester,
  GlobalKey key,
  String path, {
  double pixelRatio = _dpr,
}) async {
  await tester.pump();
  final bytes = await tester.binding.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
  // ignore: avoid_print
  print('wrote $path (${bytes.length} bytes)');
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
                child: HangmanFigure(mistakes: 4),
              ),
              const SizedBox(width: 36),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appTitle('en'),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 52,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.tagline('en'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 20,
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
