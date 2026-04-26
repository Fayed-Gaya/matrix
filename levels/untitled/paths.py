from __future__ import annotations

import sys
from pathlib import Path

UNTITLED_DIR: Path = Path(__file__).resolve().parent
REPO_ROOT: Path = UNTITLED_DIR.parent.parent
_BUNDLE_ROOT: Path | None = (
    Path(sys._MEIPASS) if getattr(sys, "frozen", False) and hasattr(sys, "_MEIPASS") else None
)
RUNTIME_ROOT: Path = _BUNDLE_ROOT if _BUNDLE_ROOT is not None else REPO_ROOT
TILED_DIR: Path = RUNTIME_ROOT / "Tiled"
ASSETS_DIR: Path = RUNTIME_ROOT / "levels" / "untitled" / "assets"
BACKGROUNDS_DIR: Path = ASSETS_DIR / "backgrounds"
AUDIO_DIR: Path = ASSETS_DIR / "audio"
MAPS_DIR: Path = ASSETS_DIR / "maps"
SPRITES_DIR: Path = ASSETS_DIR / "sprites"
TILESETS_DIR: Path = ASSETS_DIR / "tilesets"
