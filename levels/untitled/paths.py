from __future__ import annotations

from pathlib import Path

UNTITLED_DIR: Path = Path(__file__).resolve().parent
REPO_ROOT: Path = UNTITLED_DIR.parent.parent
TILED_DIR: Path = REPO_ROOT / "Tiled"
ASSETS_DIR: Path = UNTITLED_DIR / "assets"
BACKGROUNDS_DIR: Path = ASSETS_DIR / "backgrounds"
AUDIO_DIR: Path = ASSETS_DIR / "audio"
MAPS_DIR: Path = ASSETS_DIR / "maps"
SPRITES_DIR: Path = ASSETS_DIR / "sprites"
TILESETS_DIR: Path = ASSETS_DIR / "tilesets"
