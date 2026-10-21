"""Build Zelda resource paths, map cells, and the original data tables."""

import csv
import json
import runpy
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BASE = ROOT / "levels/zelda/assets"


def main() -> None:
    # Read source data without importing its broken package launcher.
    code = ROOT / "legacy/pygame/levels/zelda/code"
    sys.path.insert(0, str(code))
    source = runpy.run_path(str(code / "settings.py"))
    folders = {}
    for path in sorted((BASE / "graphics").rglob("*.png")):
        folders.setdefault(path.parent.relative_to(BASE / "graphics").as_posix(), []).append(
            "res://" + path.relative_to(ROOT).as_posix()
        )
    maps = {}
    for path in sorted((BASE / "map").glob("*.csv")):
        with path.open() as stream:
            maps[path.stem] = [[int(value) for value in row] for row in csv.reader(stream)]
    tables = {key: source[key] for key in ["weapon_data", "magic_data", "monster_data"]}
    data = json.dumps({"frames": folders, "maps": maps, **tables}, separators=(",", ":"))
    data = data.replace(str(ROOT / "legacy/pygame/levels/zelda"), "res://levels/zelda/assets")
    (BASE / "manifest.json").write_text(data + "\n")


if __name__ == "__main__":
    main()
