from __future__ import annotations

import sys
from pathlib import Path

MATRIX_DIR: Path = Path(__file__).resolve().parent
REPO_ROOT: Path = MATRIX_DIR.parent
_BUNDLE_ROOT: Path | None = (
    Path(sys._MEIPASS) if getattr(sys, "frozen", False) and hasattr(sys, "_MEIPASS") else None
)
RUNTIME_ROOT: Path = _BUNDLE_ROOT if _BUNDLE_ROOT is not None else REPO_ROOT
TILED_DIR: Path = RUNTIME_ROOT / "Tiled"
ASSETS_DIR: Path = RUNTIME_ROOT / "matrix" / "assets"
BACKGROUNDS_DIR: Path = ASSETS_DIR / "backgrounds"
SPRITES_DIR: Path = ASSETS_DIR / "sprites"
