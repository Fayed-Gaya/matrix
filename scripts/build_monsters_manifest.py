"""Export source Monsters TMX visuals/metadata and data into Godot-owned resources.

Run with the archived development environment; runtime never imports Python.
"""

import hashlib
import json
import os
import runpy
import wave
from pathlib import Path

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")
import pygame
from pytmx import TiledTileLayer
from pytmx.util_pygame import load_pygame

ROOT = Path(__file__).resolve().parent.parent
BASE = ROOT / "levels/monsters/assets"
PAGE = 2048


def main() -> None:
    pygame.init()
    pygame.display.set_mode((1, 1))
    # Godot rejects the source ADPCM WAV; preserve it and export SDL's decoded PCM.
    explosion = pygame.mixer.Sound(str(BASE.parent / "source/audio/explosion.wav"))
    frequency, sample_format, channels = pygame.mixer.get_init()
    assert sample_format == -16
    with wave.open(str(BASE / "audio/explosion.wav"), "wb") as output:
        output.setnchannels(channels)
        output.setsampwidth(2)
        output.setframerate(frequency)
        output.writeframes(explosion.get_raw())
    surfaces = []
    image_ids = {}

    def register(surface):
        if surface is None:
            return -1
        canonical = pygame.Surface(surface.get_size(), pygame.SRCALPHA)
        canonical.fill((0, 0, 0, 0))
        canonical.blit(surface, (0, 0))
        key = (
            canonical.get_size(),
            hashlib.sha256(pygame.image.tobytes(canonical, "RGBA")).hexdigest(),
        )
        if key not in image_ids:
            image_ids[key] = len(surfaces)
            surfaces.append(canonical)
        return image_ids[key]

    maps = {}
    for path in sorted((BASE / "data/maps").glob("*.tmx")):
        tiled = load_pygame(str(path))
        record = {
            "width": tiled.width,
            "height": tiled.height,
            "tile_size": tiled.tilewidth,
            "layers": [],
            "groups": {},
        }
        for layer in tiled.layers:
            if isinstance(layer, TiledTileLayer):
                if layer.name not in ["Terrain", "Terrain Top"]:
                    continue
                ids = {}
                cells = []
                for row in layer.data:
                    for gid in row:
                        if gid:
                            if gid not in ids:
                                ids[gid] = register(tiled.get_tile_image_by_gid(gid)) + 1
                            cells.append(ids[gid])
                        else:
                            cells.append(0)
                record["layers"].append({"name": layer.name, "cells": cells})
            else:
                entries = []
                for obj in layer:
                    surface = getattr(obj, "image", None)
                    entries.append(
                        {
                            "name": obj.name or "",
                            "position": [obj.x, obj.y],
                            "size": [obj.width, obj.height],
                            "image": register(surface),
                            "properties": dict(obj.properties),
                        }
                    )
                record["groups"][layer.name] = entries
        maps[path.stem] = record
    sheets = {}

    def cut_sheet(path, columns, rows):
        sheet = pygame.image.load(str(path)).convert_alpha()
        width, height = sheet.get_width() // columns, sheet.get_height() // rows
        pieces = {}
        for column in range(columns):
            for row in range(rows):
                surface = pygame.Surface((width, height))
                surface.fill("green")
                surface.set_colorkey("green")
                surface.blit(sheet, (0, 0), (column * width, row * height, width, height))
                pieces[column, row] = surface
        return pieces

    for path in sorted((BASE / "graphics/characters").glob("*.png")):
        pieces = cut_sheet(path, 4, 4)
        sheet = {}
        for row, direction in enumerate(["down", "left", "right", "up"]):
            sheet[direction] = [register(pieces[col, row]) for col in range(4)]
            sheet[direction + "_idle"] = [sheet[direction][0]]
        sheets["characters/" + path.stem] = sheet
    for path in sorted((BASE / "graphics/monsters").glob("*.png")):
        pieces = cut_sheet(path, 4, 2)
        sheet, outlines = {}, {}
        for row, state in enumerate(["idle", "attack"]):
            sheet[state], outlines[state] = [], []
            for column in range(4):
                surface = pieces[column, row]
                sheet[state].append(register(surface))
                white = pygame.mask.from_surface(surface).to_surface()
                white.set_colorkey("black")
                outline = pygame.Surface(
                    (surface.get_width() + 8, surface.get_height() + 8), pygame.SRCALPHA
                )
                for offset in [(0, 0), (4, 0), (8, 0), (8, 4), (8, 8), (4, 8), (0, 8), (0, 4)]:
                    outline.blit(white, offset)
                outlines[state].append(register(outline))
        sheets["monsters/" + path.stem] = sheet
        sheets["outlines/" + path.stem] = outlines
    for path in sorted((BASE / "graphics/attacks").glob("*.png")):
        pieces = cut_sheet(path, 4, 1)
        sheets["attacks/" + path.stem] = {"frames": [register(pieces[col, 0]) for col in range(4)]}
    coast = cut_sheet(BASE / "graphics/tilesets/coast.png", 24, 12)
    sides = {
        "topleft": (0, 0),
        "top": (1, 0),
        "topright": (2, 0),
        "left": (0, 1),
        "right": (2, 1),
        "bottomleft": (0, 2),
        "bottom": (1, 2),
        "bottomright": (2, 2),
    }
    for terrain_index, terrain in enumerate(
        ["grass", "grass_i", "sand_i", "sand", "rock", "rock_i", "ice", "ice_i"]
    ):
        sheets["coast/" + terrain] = {
            side: [register(coast[x + terrain_index * 3, y + row]) for row in range(0, 12, 3)]
            for side, (x, y) in sides.items()
        }
    pages = []
    atlas = pygame.Surface((PAGE, PAGE), pygame.SRCALPHA)
    atlas.fill((0, 0, 0, 0))
    x = y = row_height = 0
    images = []
    for surface in surfaces:
        width, height = surface.get_size()
        assert width + 2 <= PAGE and height + 2 <= PAGE
        if x + width + 2 > PAGE:
            x = 0
            y += row_height
            row_height = 0
        if y + height + 2 > PAGE:
            pages.append(atlas)
            atlas = pygame.Surface((PAGE, PAGE), pygame.SRCALPHA)
            atlas.fill((0, 0, 0, 0))
            x = y = row_height = 0
        atlas.blit(surface, (x + 1, y + 1))
        images.append(
            {
                "atlas": f"res://levels/monsters/assets/generated/world_{len(pages)}.png",
                "rect": [x + 1, y + 1, width, height],
            }
        )
        x += width + 2
        row_height = max(row_height, height + 2)
    pages.append(atlas)
    for index, page in enumerate(pages):
        pygame.image.save(page, str(BASE / f"generated/world_{index}.png"))
    frames = {}
    for path in sorted((BASE / "graphics").rglob("*.png")):
        frames.setdefault(path.parent.relative_to(BASE / "graphics").as_posix(), []).append(
            "res://" + path.relative_to(ROOT).as_posix()
        )
    for files in frames.values():
        files.sort(
            key=lambda path: (0, int(Path(path).stem))
            if Path(path).stem.isdigit()
            else (1, Path(path).name)
        )
    source = runpy.run_path(str(ROOT / "legacy/pygame/levels/monsters/code/game_data.py"))
    audio = {
        path.stem: "res://" + path.relative_to(ROOT).as_posix()
        for path in sorted((BASE / "audio").glob("*"))
        if path.is_file() and not path.name.startswith(".")
    }
    data = {
        "maps": maps,
        "images": images,
        "sheets": sheets,
        "frames": frames,
        "audio": audio,
        **{key: source[key] for key in ["TRAINER_DATA", "MONSTER_DATA", "ATTACK_DATA"]},
    }
    (BASE / "manifest.json").write_text(json.dumps(data, separators=(",", ":")) + "\n")
    pygame.quit()
    print(
        f"Monsters: {len(maps)} maps, {len(images)} deduplicated images, {len(pages)} atlas pages"
    )


if __name__ == "__main__":
    main()
