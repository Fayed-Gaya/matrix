from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DIST_DIR = PROJECT_ROOT / "dist"
BUILD_DIR = PROJECT_ROOT / "build"
SPEC_PATH = PROJECT_ROOT / "packaging" / "untitled_windows.spec"
OUTPUT_NAME = "untitled-windows"


def main() -> None:
    shutil.rmtree(DIST_DIR, ignore_errors=True)
    shutil.rmtree(BUILD_DIR, ignore_errors=True)

    subprocess.run(
        ["pyinstaller", "--noconfirm", str(SPEC_PATH)],
        cwd=PROJECT_ROOT,
        check=True,
    )

    bundle_dir = DIST_DIR / "Untitled"
    archive_base = DIST_DIR / OUTPUT_NAME
    shutil.make_archive(
        str(archive_base), "zip", root_dir=bundle_dir.parent, base_dir=bundle_dir.name
    )
    print(archive_base.with_suffix(".zip"))


if __name__ == "__main__":
    main()
