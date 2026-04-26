from __future__ import annotations

from pathlib import Path


PROJECT_ROOT = Path.cwd()

datas = [
    (str(PROJECT_ROOT / "Tiled"), "Tiled"),
    (str(PROJECT_ROOT / "levels" / "untitled" / "assets"), "levels/untitled/assets"),
]


a = Analysis(
    ["packaging/untitled_main.py"],
    pathex=[str(PROJECT_ROOT)],
    binaries=[],
    datas=datas,
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name="Untitled",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
)

coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name="Untitled",
)
