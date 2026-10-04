#!/usr/bin/env python3
"""Render a real command transcript excerpt as a readable PNG evidence image."""

from __future__ import annotations

import argparse
import textwrap
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = (
        "/System/Library/Fonts/SFNSMono.ttf",
        "/System/Library/Fonts/Menlo.ttc",
        "/Library/Fonts/Arial Unicode.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
    )
    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            try:
                index = 1 if bold and path.suffix == ".ttc" else 0
                return ImageFont.truetype(str(path), size=size, index=index)
            except OSError:
                continue
    return ImageFont.load_default()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--title", required=True)
    parser.add_argument("--anchor", default="")
    parser.add_argument("--lines", type=int, default=30)
    args = parser.parse_args()

    raw_lines = args.input.read_text(encoding="utf-8", errors="replace").splitlines()
    start = 0
    if args.anchor:
        start = next(
            (index for index, line in enumerate(raw_lines) if args.anchor.lower() in line.lower()),
            0,
        )
    excerpt = raw_lines[start : start + args.lines]
    wrapped: list[str] = []
    for line in excerpt:
        wrapped.extend(textwrap.wrap(line, width=105, replace_whitespace=False) or [""])
    wrapped = wrapped[:48]

    width = 1540
    top = 132
    line_height = 27
    height = max(720, top + (len(wrapped) + 4) * line_height)
    image = Image.new("RGB", (width, height), "#0d1117")
    draw = ImageDraw.Draw(image)
    title_font = load_font(28, bold=True)
    body_font = load_font(20)
    small_font = load_font(17)

    draw.rounded_rectangle((24, 24, width - 24, height - 24), radius=18, fill="#161b22", outline="#30363d", width=2)
    for index, color in enumerate(("#ff5f56", "#ffbd2e", "#27c93f")):
        x = 54 + index * 34
        draw.ellipse((x, 52, x + 18, 70), fill=color)
    draw.text((54, 88), args.title, font=title_font, fill="#f0f6fc")
    draw.line((54, 124, width - 54, 124), fill="#30363d", width=2)

    y = top + 16
    for line in wrapped:
        color = "#7ee787" if line.startswith(("PASS", "SUCCESS", "deployment", "service", "pod/")) else "#c9d1d9"
        draw.text((54, y), line, font=body_font, fill=color)
        y += line_height

    footer = f"Genuine runtime transcript: {args.input.as_posix()}"
    draw.text((54, height - 58), footer, font=small_font, fill="#8b949e")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    image.save(args.output, optimize=True)


if __name__ == "__main__":
    main()
