#!/usr/bin/env python3
"""
Create app icon from source image (e.g. full logo: grandma + house + light green).
Output: 1024x1024 PNG for iOS AppIcon.
"""
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Install Pillow: pip install Pillow")
    raise

# Light green background if letterboxing (matches logo artwork)
LIGHT_GREEN = (232, 242, 239)  # #E8F2EF
SIZE = 1024
ROOT = Path(__file__).resolve().parent.parent
# Full logo: grandma in white house outline on light green
SOURCE_IMAGE = Path("/Users/yunqi/.cursor/projects/Users-yunqi-Desktop-My-Brickbook/assets/logo-89ba22ae-3366-4c83-9e06-8e803d60affd.png")
OUTPUT_DIR = ROOT / "My Brickbook/My Brickbook/Assets.xcassets/AppIcon.appiconset"
OUTPUT_PATH = OUTPUT_DIR / "AppIcon.png"


def main():
    if not SOURCE_IMAGE.exists():
        print("Source image not found at:", SOURCE_IMAGE)
        return 1

    img = Image.open(SOURCE_IMAGE).convert("RGBA")
    w, h = img.size
    scale = min(SIZE / w, SIZE / h)
    nw, nh = int(w * scale), int(h * scale)
    img = img.resize((nw, nh), Image.Resampling.LANCZOS)
    base = Image.new("RGBA", (SIZE, SIZE), (*LIGHT_GREEN, 255))
    x = (SIZE - nw) // 2
    y = (SIZE - nh) // 2
    mask = img.split()[3] if img.mode == "RGBA" and len(img.split()) >= 4 else None
    base.paste(img, (x, y), mask)
    out_rgb = base.convert("RGB")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    out_rgb.save(OUTPUT_PATH, "PNG")
    print("Saved:", OUTPUT_PATH)
    return 0


if __name__ == "__main__":
    exit(main())
