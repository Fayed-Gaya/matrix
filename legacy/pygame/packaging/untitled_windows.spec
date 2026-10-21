from __future__ import annotations

from pathlib import Path


PROJECT_ROOT = Path.cwd()
ENTRYPOINT = PROJECT_ROOT / "packaging" / "untitled_main.py"

datas = [
    (str(PROJECT_ROOT / "levels" / "untitled" / "assets"), "levels/untitled/assets"),
    (str(PROJECT_ROOT / "shared_assets"), "shared_assets"),
]


a = Analysis(
    [str(ENTRYPOINT)],
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
