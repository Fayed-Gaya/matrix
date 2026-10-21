"""Build a single-threaded desktop web preview, without publishing it."""

import argparse
import json
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def run(command):
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=240)
    output = result.stdout + result.stderr
    print(output, end="")
    if result.returncode or "ERROR:" in output or "were leaked at exit" in output:
        raise SystemExit("Godot web export failed")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    version = subprocess.check_output([args.godot, "--version"], text=True).strip()
    if not version.startswith("4.7.2.stable."):
        raise SystemExit("Expected Godot 4.7.2 stable, got " + version)
    template = ROOT / "build/toolchain/godot/web_nothreads_release.zip"
    if not template.is_file():
        raise SystemExit("Run make web-templates first (official checksum-pinned templates)")
    destination = ROOT / "exports/web"
    destination.mkdir(parents=True, exist_ok=True)
    run([args.godot, "--headless", "--path", ".", "--editor", "--import"])
    run(
        [
            args.godot,
            "--headless",
            "--path",
            ".",
            "--export-release",
            "Web",
            "exports/web/index.html",
        ]
    )
    for name in ("index.html", "index.js", "index.wasm", "index.pck"):
        if not (destination / name).is_file():
            raise SystemExit("Missing export: " + name)
    shutil.copy2(ROOT / "THIRD_PARTY_NOTICES.md", destination / "THIRD_PARTY_NOTICES.md")
    shutil.copytree(ROOT / "LICENSES", destination / "LICENSES", dirs_exist_ok=True)
    run(
        [
            args.godot,
            "--headless",
            "--path",
            ".",
            "--script",
            "res://scripts/release/engine_notices.gd",
        ]
    )
    (destination / ".nojekyll").touch()
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    (destination / "build-info.json").write_text(
        json.dumps(
            {
                "engine": version,
                "commit": revision,
                "dirty": bool(
                    subprocess.check_output(
                        ["git", "status", "--porcelain"], cwd=ROOT, text=True
                    ).strip()
                ),
                "milestone": "Alpha 0.1 technical preview",
                "threads": False,
            },
            indent=2,
        )
        + "\n"
    )
    print("Web export ready: exports/web/index.html (not published)")


if __name__ == "__main__":
    main()
