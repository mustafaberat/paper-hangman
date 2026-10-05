#!/usr/bin/env python3
"""Compose Play Store phone vitrines for Paper Hangman.

Reads play/gorseller/raw/{tr,en}/0*.png → play/gorseller/{tr,en}/0*.png

Header style A: bold modern sans (Arial Black) + filled blue chips.

  python3 tool/make_play_vitrine.py
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
GORSELLER = ROOT / "play" / "gorseller"
RAW = GORSELLER / "raw"

W, H = 1170, 2532
# Notebook palette (matches AppColors)
PAPER = (247, 243, 232)  # #F7F3E8
INK = (26, 26, 26)  # #1A1A1A
PEN = (30, 68, 214)  # #1E44D6
MARGIN = (225, 91, 91)  # #E15B5B
GRID = (183, 205, 216)  # #B7CDD8
MUTED = (110, 103, 92)
WHITE = (255, 255, 255)

FONT_SF = "/System/Library/Fonts/SFNS.ttf"
FONT_SF_R = "/System/Library/Fonts/SFNSRounded.ttf"
FONT_TITLE = "/System/Library/Fonts/Supplemental/Arial Black.ttf"
FALLBACK = "/System/Library/Fonts/Supplemental/Arial Unicode.ttf"

SLIDES = {
    "tr": [
        {
            "file": "01-home.png",
            "brand": "Adam Asmaca",
            "title": "İstediğin kadar oyna",
            "accent_word": "İstediğin",
            "sub": "Kareli defterde klasik adam asmaca — limit yok.",
            "chips": ["Sınırsız tur", "TR / EN", "6 hak"],
        },
        {
            "file": "02-play.png",
            "brand": "Adam Asmaca",
            "title": "Harfleri tahmin et",
            "accent_word": "tahmin",
            "sub": "Doğru harfler açılır; yanlışlarda figür çizilir.",
            "chips": ["Klavye", "Kelime", "Seri"],
        },
        {
            "file": "03-settings.png",
            "brand": "Adam Asmaca",
            "title": "Dili sen seç",
            "accent_word": "sen",
            "sub": "Türkçe veya İngilizce kelime listesi — anında değişir.",
            "chips": ["TR", "EN"],
        },
    ],
    "en": [
        {
            "file": "01-home.png",
            "brand": "Paper Hangman",
            "title": "Play without limits",
            "accent_word": "without",
            "sub": "Classic hangman on notebook paper — unlimited rounds.",
            "chips": ["Unlimited", "TR / EN", "6 misses"],
        },
        {
            "file": "02-play.png",
            "brand": "Paper Hangman",
            "title": "Guess the letters",
            "accent_word": "letters",
            "sub": "Hits open the word; misses draw the figure.",
            "chips": ["Keyboard", "Word", "Streak"],
        },
        {
            "file": "03-settings.png",
            "brand": "Paper Hangman",
            "title": "Pick your language",
            "accent_word": "language",
            "sub": "Turkish or English word lists — switch anytime.",
            "chips": ["TR", "EN"],
        },
    ],
}


def font(path: str, size: int) -> ImageFont.FreeTypeFont:
    try:
        return ImageFont.truetype(path, size)
    except OSError:
        return ImageFont.truetype(FALLBACK, size)


def wrap(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.FreeTypeFont, max_w: int) -> list[str]:
    words = text.split()
    if not words:
        return []
    lines: list[str] = []
    cur = words[0]
    for w in words[1:]:
        trial = f"{cur} {w}"
        if draw.textlength(trial, font=fnt) <= max_w:
            cur = trial
        else:
            lines.append(cur)
            cur = w
    lines.append(cur)
    return lines


def paper_bg() -> Image.Image:
    img = Image.new("RGB", (W, H), PAPER)
    d = ImageDraw.Draw(img)
    step = 28
    for y in range(0, H, step):
        d.line([(0, y), (W, y)], fill=GRID, width=1)
    for x in range(0, W, step):
        d.line([(x, 0), (x, H)], fill=GRID, width=1)
    d.line([(88, 0), (88, H)], fill=MARGIN, width=4)
    wash = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    wd = ImageDraw.Draw(wash)
    for i in range(180):
        a = int(40 * (i / 180))
        wd.line([(0, H - 180 + i), (W, H - 180 + i)], fill=(30, 68, 214, a))
    return Image.alpha_composite(img.convert("RGBA"), wash).convert("RGB")


def rounded_phone(shot: Image.Image, phone_w: int = 1000) -> Image.Image:
    """Close-up phone: fills most of the 1170-wide canvas."""
    aspect = shot.height / shot.width
    screen_w = phone_w - 40
    screen_h = int(screen_w * aspect)
    max_screen_h = 1760
    if screen_h > max_screen_h:
        screen_h = max_screen_h
        screen_w = int(screen_h / aspect)
        phone_w = screen_w + 40

    bezel = 20
    top_chrome = 46
    bottom_chrome = 30
    phone_h = screen_h + top_chrome + bottom_chrome
    phone = Image.new("RGBA", (phone_w, phone_h), (0, 0, 0, 0))
    d = ImageDraw.Draw(phone)
    d.rounded_rectangle([0, 0, phone_w - 1, phone_h - 1], radius=58, fill=(18, 20, 24, 255))
    d.rounded_rectangle(
        [bezel, top_chrome - 8, phone_w - bezel - 1, phone_h - bottom_chrome],
        radius=42,
        fill=(0, 0, 0, 255),
    )
    island_w, island_h = 150, 38
    ix = (phone_w - island_w) // 2
    d.rounded_rectangle([ix, 14, ix + island_w, 14 + island_h], radius=19, fill=(0, 0, 0, 255))

    screen = shot.resize((screen_w, screen_h), Image.Resampling.LANCZOS).convert("RGBA")
    mask = Image.new("L", (screen_w, screen_h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, screen_w - 1, screen_h - 1], radius=36, fill=255)
    phone.paste(screen, ((phone_w - screen_w) // 2, top_chrome), mask)

    shadow = Image.new("RGBA", (phone_w + 80, phone_h + 80), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [30, 40, phone_w + 50, phone_h + 60], radius=64, fill=(0, 0, 0, 75)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(30))
    out = Image.new("RGBA", shadow.size, (0, 0, 0, 0))
    out = Image.alpha_composite(out, shadow)
    out.paste(phone, (40, 20), phone)
    tilted = out.rotate(-3.5, expand=True, resample=Image.Resampling.BICUBIC)
    target_w = int(W * 0.92)
    scale = target_w / tilted.width
    new_size = (target_w, max(1, int(tilted.height * scale)))
    return tilted.resize(new_size, Image.Resampling.LANCZOS)


def draw_title_block(
    canvas: Image.Image,
    brand: str,
    title: str,
    accent_word: str,
    sub: str,
    chips: list[str],
) -> int:
    """Style A — bold sans headline + filled chips."""
    d = ImageDraw.Draw(canvas)
    brand_f = font(FONT_SF_R, 28)
    title_f = font(FONT_TITLE, 76)
    sub_f = font(FONT_SF, 32)
    chip_f = font(FONT_SF_R, 26)

    pad_x = 64
    max_w = W - pad_x * 2
    y = 56

    label = brand.upper()
    d.text((pad_x, y), label, font=brand_f, fill=PEN)
    tw = d.textlength(label, font=brand_f)
    d.rectangle([pad_x, y + 36, pad_x + tw, y + 40], fill=PEN)
    y += 58

    for line in wrap(d, title, title_f, max_w):
        if accent_word and accent_word in line:
            parts = line.split(accent_word)
            x = pad_x
            for i, part in enumerate(parts):
                if part:
                    d.text((x, y), part, font=title_f, fill=INK)
                    x += d.textlength(part, font=title_f)
                if i < len(parts) - 1:
                    d.text((x, y), accent_word, font=title_f, fill=PEN)
                    x += d.textlength(accent_word, font=title_f)
        else:
            d.text((pad_x, y), line, font=title_f, fill=INK)
        y += 88

    y += 6
    for line in wrap(d, sub, sub_f, max_w):
        d.text((pad_x, y), line, font=sub_f, fill=MUTED)
        y += 40

    y += 22
    x = pad_x
    for chip in chips:
        cw = d.textlength(chip, font=chip_f) + 40
        if x + cw > W - pad_x:
            x = pad_x
            y += 56
        d.rounded_rectangle([x, y, x + cw, y + 44], radius=22, fill=PEN)
        d.text((x + 20, y + 8), chip, font=chip_f, fill=WHITE)
        x += cw + 12

    return y + 56


def compose(lang: str, slide: dict) -> Image.Image:
    raw_path = RAW / lang / slide["file"]
    if not raw_path.exists():
        raise FileNotFoundError(raw_path)

    canvas = paper_bg().convert("RGBA")
    y_after = draw_title_block(
        canvas,
        slide["brand"],
        slide["title"],
        slide.get("accent_word", ""),
        slide["sub"],
        slide.get("chips") or [],
    )

    shot = Image.open(raw_path).convert("RGBA")
    phone = rounded_phone(shot, phone_w=1000)
    px = (W - phone.width) // 2
    py = min(max(y_after - 20, 420), H - phone.height + 140)
    if py + phone.height > H + 120:
        py = H - phone.height + 140
    canvas.alpha_composite(phone, (px, py))
    return canvas.convert("RGB")


def main() -> int:
    for lang, slides in SLIDES.items():
        out_dir = GORSELLER / lang
        out_dir.mkdir(parents=True, exist_ok=True)
        for slide in slides:
            img = compose(lang, slide)
            dest = out_dir / slide["file"]
            img.save(dest, "PNG", optimize=True)
            print(f"wrote {dest.relative_to(ROOT)} {img.size}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
