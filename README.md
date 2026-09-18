# Hangman

A minimal daily hangman word game.

Release, web, and device install scripts live outside this repo:

`../lib/scripts/`

Run them from this project root:

```bash
APP_ROOT=. ../lib/scripts/run_web.sh
APP_ROOT=. ../lib/scripts/build_play.sh
APP_ROOT=. ../lib/scripts/install_release.sh
```

| Script | What it does |
|---|---|
| `run_web.sh` | Chrome on port 8080 (`WEB_PORT=3000` to change) |
| `build_play.sh` | Play AAB + APK → `play/versions/{major}/` |
| `install_release.sh` | Build APK, adb install, launch |

Do not copy these into `scripts/`. Fixes go in `mobile-apps/lib/scripts/`.
