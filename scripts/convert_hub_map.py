"""Convert the hub's finite orthogonal CSV TMX into native Godot resources."""

import argparse
import json
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MAP = ROOT / "hub/assets/maps/matrix.tmx"


def describe_map() -> dict:
    source = ET.parse(MAP).getroot()
    if source.get("orientation") != "orthogonal" or source.get("infinite") != "0":
        raise ValueError("Only finite orthogonal hub maps are supported")
    width, height = int(source.attrib["width"]), int(source.attrib["height"])
    tile_size = int(source.attrib["tilewidth"])
    assert tile_size == int(source.attrib["tileheight"])
    result = {
        "bounds": [width * tile_size, height * tile_size],
        "tile_size": tile_size,
        "tilesets": [],
        "layers": [],
        "collision": [],
    }
    for entry in source.findall("tileset"):
        path = (MAP.parent / entry.attrib["source"]).resolve()
        tileset = ET.parse(path).getroot()
        image = tileset.find("image")
        assert image is not None
        assert not tileset.findall("tile"), "Animated/custom tile data needs a converter extension"
        result["tilesets"].append(
            {
                "firstgid": int(entry.attrib["firstgid"]),
                "columns": int(tileset.attrib["columns"]),
                "count": int(tileset.attrib["tilecount"]),
                "texture": "res://"
                + (path.parent / image.attrib["source"]).resolve().relative_to(ROOT).as_posix(),
            }
        )
    for layer in source.findall("layer"):
        assert int(layer.attrib["width"]) == width and int(layer.attrib["height"]) == height
        assert not any(float(layer.get(k, "0")) for k in ["offsetx", "offsety", "x", "y"])
        data = layer.find("data")
        assert data is not None and data.get("encoding") == "csv"
        gids = [int(v) for v in data.text.strip().replace("\n", "").split(",")]
        assert len(gids) == width * height
        assert all(gid < (1 << 28) for gid in gids), "Tile transforms need explicit conversion"
        result["layers"].append(
            {
                "name": layer.attrib["name"],
                "width": width,
                "visible": layer.get("visible", "1") != "0",
                "cells": gids,
            }
        )
    for group in source.findall("objectgroup"):
        for obj in group.findall("object"):
            x, y = round(float(obj.get("x", "0"))), round(float(obj.get("y", "0")))
            w, h = round(float(obj.get("width", "0"))), round(float(obj.get("height", "0")))
            if group.get("name") == "Collision":
                assert not obj.findall("polygon") and not obj.findall("ellipse")
                assert float(obj.get("rotation", "0")) == 0
                result["collision"].append([x, y, w, h])
            elif obj.get("name") == "player_spawn":
                result["spawn"] = [x, y]
            elif obj.get("name") == "level_terminal":
                result["terminal"] = [x, y, w, h] if w and h else [x - 12, y - 12, 24, 24]
    assert "spawn" in result and "terminal" in result
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    version = subprocess.check_output([args.godot, "--version"], text=True).strip()
    if not version.startswith("4.7.2.stable."):
        raise SystemExit("Use Godot 4.7.2 stable")
    with tempfile.TemporaryDirectory(prefix="matrix-map-") as temporary:
        data = Path(temporary) / "hub.json"
        data.write_text(json.dumps(describe_map()))
        result = subprocess.run(
            [
                args.godot,
                "--headless",
                "--path",
                str(ROOT),
                "--log-file",
                str(Path(temporary) / "build.log"),
                "--script",
                "res://scripts/tools/build_hub_map.gd",
                "--",
                str(data),
            ],
            capture_output=True,
            text=True,
            timeout=120,
        )
        output = result.stdout + result.stderr
        print(output, end="")
        if result.returncode or "ERROR:" in output or "Hub map saved" not in output:
            raise SystemExit("Hub map conversion failed")


if __name__ == "__main__":
    main()
