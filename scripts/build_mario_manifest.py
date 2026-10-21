"""Rebuild Mario's explicit resource paths and source CSV data for Godot."""

import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BASE = ROOT / "levels/mario/assets"


def main() -> None:
    graphics = BASE / "graphics"
    folders = {}
    for path in sorted(graphics.rglob("*.png")):
        folders.setdefault(path.parent.relative_to(graphics).as_posix(), []).append(
            "res://" + path.relative_to(ROOT).as_posix()
        )
    maps = []
    for index in range(3):
        layers = {}
        for path in sorted((BASE / "levels" / str(index)).glob("*.csv")):
            with path.open() as source:
                layers[path.stem.replace(f"level_{index}_", "").replace("_", " ")] = [
                    [int(value) for value in row] for row in csv.reader(source)
                ]
        maps.append(layers)
    (BASE / "manifest.json").write_text(
        json.dumps({"frames": folders, "maps": maps}, separators=(",", ":")) + "\n"
    )


if __name__ == "__main__":
    main()
