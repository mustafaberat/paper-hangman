# Hangman

A minimal daily hangman word game.

Ortak scriptler oyun dışında: `../lib/scripts/`

```bash
APP_ROOT=. ../lib/scripts/run_web.sh
APP_ROOT=. ../lib/scripts/install_release.sh
APP_ROOT=. ../lib/scripts/generate_game_images.sh
```

| Script | What it does |
|---|---|
| `run_web.sh` | Chrome on port 8080 (`WEB_PORT=3000` to change) |
| `install_release.sh` | Play AAB + APK → `play/versions/{major}/`; sürüm notunu basar |
| `generate_game_images.sh` | Play telefon/tablet/pc görselleri |

Play görselleri:

- `play/icon-512.png` — mağaza / launcher ikonu
- `play/feature-graphic.png` — 1024×500 özellik grafiği
- `play/icon.png` — orijinal kare kaynak
- `play/gorseller/` — telefon / tablet / pc / chromebook ekranları
- `play/whatsnew.txt` — 6 dil sürüm notu (şablon: `../lib/play/whatsnew.template.txt`)

Ekran senaryosu: `tool/capture_play_shots.dart`. Ortak scriptleri `scripts/` altına kopyalama.
