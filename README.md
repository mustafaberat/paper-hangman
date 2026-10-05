# Paper Hangman

Notebook-style hangman. Play as many rounds as you want.

Package: `com.arusoft.hangman` · Display: **Paper Hangman** / **Adam Asmaca**  
Repo: [mustafaberat/paper-hangman](https://github.com/mustafaberat/paper-hangman)

Ortak scriptler: `../lib/scripts/`

```bash
APP_ROOT=. ../lib/scripts/run_web.sh
APP_ROOT=. ../lib/scripts/install_release.sh
APP_ROOT=. ../lib/scripts/generate_game_images.sh
```

| Script | What it does |
|---|---|
| `run_web.sh` | Chrome on port 8080 (`WEB_PORT=3000` to change) |
| `install_release.sh` | Play AAB + APK → `play/versions/{major}/` |
| `generate_game_images.sh` | Play screenshots |

Play:

- `play/listings.json` — store title/short/full (tr / en)
- `play/whatsnew.txt` — release notes
- `play/gorseller/{tr,en}/` — vitrin phone shots (commit)
- `play/gorseller/raw/` — plain UI (gitignore)

```bash
APP_ROOT=. ../lib/scripts/generate_game_images.sh
python3 tool/make_play_vitrine.py
```
