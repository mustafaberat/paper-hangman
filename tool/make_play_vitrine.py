#!/usr/bin/env python3
"""Compose Play Store phone vitrines for Paper Hangman.

Reads play/gorseller/raw/{tr,en}/0*.png → play/gorseller/{tr,en}/0*.png

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
SOFT = (251, 248, 240)

FONT = "/System/Library/Fonts/SFNSRounded.ttf"
FALLBACK = "/System/Library/Fonts/Supplemental/Arial Unicode.ttf"
# Prefer game hand font when available
HAND = ROOT / "fonts" / "PatrickHand-Regular.ttf"
PEN_FONT = ROOT / "fonts" / "Caveat-Bold.ttf"

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


def font(size: int, hand: bool = False) -> ImageFont.FreeTypeFont:
    path = HAND if hand and HAND.exists() else FONT
    try:
        return ImageFont.truetype(str(path), size)
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
    # grid lines
    step = 28
    for y in range(0, H, step):
        d.line([(0, y), (W, y)], fill=GRID, width=1)
    for x in range(0, W, step):
        d.line([(x, 0), (x, H)], fill=GRID, width=1)
    # red margin
    d.line([(88, 0), (88, H)], fill=MARGIN, width=4)
    # soft bottom wash
    wash = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    wd = ImageDraw.Draw(wash)
    for i in range(180):
        a = int(40 * (i / 180))
        y = H - 180 + i
        wd.line([(0, y), (W, y)], fill=(30, 68, 214, a))
    return Image.alpha_composite(img.convert("RGBA"), wash).convert("RGB")


def rounded_phone(shot: Image.Image, phone_w: int = 860) -> Image.Image:
    aspect = shot.height / shot.width
    screen_w = phone_w - 36
    screen_h = int(screen_w * aspect)
    max_screen_h = 1480
    if screen_h > max_screen_h:
        screen_h = max_screen_h
        screen_w = int(screen_h / aspect)
        phone_w = screen_w + 36

    bezel = 18
    top_chrome = 42
    bottom_chrome = 28
    phone_h = screen_h + top_chrome + bottom_chrome
    phone = Image.new("RGBA", (phone_w, phone_h), (0, 0, 0, 0))
    d = ImageDraw.Draw(phone)
    d.rounded_rectangle([0, 0, phone_w - 1, phone_h - 1], radius=54, fill=(18, 20, 24, 255))
    d.rounded_rectangle(
        [bezel, top_chrome - 8, phone_w - bezel - 1, phone_h - bottom_chrome],
        radius=40,
        fill=(0, 0, 0, 255),
    )
    island_w, island_h = 140, 36
    ix = (phone_w - island_w) // 2
    d.rounded_rectangle([ix, 14, ix + island_w, 14 + island_h], radius=18, fill=(0, 0, 0, 255))

    screen = shot.resize((screen_w, screen_h), Image.Resampling.LANCZOS).convert("RGBA")
    mask = Image.new("L", (screen_w, screen_h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, screen_w - 1, screen_h - 1], radius=34, fill=255)
    phone.paste(screen, ((phone_w - screen_w) // 2, top_chrome), mask)

    shadow = Image.new("RGBA", (phone_w + 80, phone_h + 80), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [30, 40, phone_w + 50, phone_h + 60], radius=60, fill=(0, 0, 0, 70)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(28))
    out = Image.new("RGBA", shadow.size, (0, 0, 0, 0))
    out = Image.alpha_composite(out, shadow)
    out.paste(phone, (40, 20), phone)
    # slight tilt for presence
    return out.rotate(-5, expand=True, resample=Image.Resampling.BICUBIC)


def draw_title_block(
    canvas: Image.Image,
    brand: str,
    title: str,
    accent_word: str,
    sub: str,
    chips: list[str],
) -> int:
    d = ImageDraw.Draw(canvas)
    title_f = font(74, hand=True)
    sub_f = font(34, hand=True)
    chip_f = font(28, hand=True)
    brand_f = font(32, hand=False)

    pad_x = 72
    max_w = W - pad_x * 2
    y = 88

    bw = d.textlength(brand, font=brand_f) + 36
    d.rounded_rectangle([pad_x, y, pad_x + bw, y + 48], radius=24, fill=PEN)
    d.text((pad_x + 18, y + 8), brand, font=brand_f, fill=WHITE)
    y += 74

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
        y += 84

    y += 4
    for line in wrap(d, sub, sub_f, max_w):
        d.text((pad_x, y), line, font=sub_f, fill=MUTED)
        y += 44

    y += 22
    x = pad_x
    for chip in chips:
        cw = d.textlength(chip, font=chip_f) + 40
        if x + cw > W - pad_x:
            x = pad_x
            y += 54
        d.rounded_rectangle([x, y, x + cw, y + 44], radius=22, fill=SOFT)
        d.rounded_rectangle([x, y, x + cw, y + 44], radius=22, outline=PEN, width=2)
        d.text((x + 20, y + 6), chip, font=chip_f, fill=PEN)
        x += cw + 12

    return y + 64


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
    phone = rounded_phone(shot, phone_w=820)
    px = (W - phone.width) // 2
    py = min(max(y_after - 30, 520), H - phone.height + 60)
    if py + phone.height > H + 20:
        py = H - phone.height + 60
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
