"""Build a clean single-threaded web preview atomically, without publishing."""

import argparse
import hashlib
import json
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def run(command):
    result = subprocess.run(
        command, cwd=ROOT, text=True, capture_output=True, timeout=240
    )
    output = result.stdout + result.stderr
    logs = ROOT / "build/test-logs"
    logs.mkdir(parents=True, exist_ok=True)
    name = (
        Path(command[command.index("--script") + 1]).stem
        if "--script" in command
        else "export"
        if "--export-release" in command
        else "import"
    )
    (logs / ("web-" + name + ".log")).write_text(output)
    if result.returncode or "ERROR:" in output or "were leaked at exit" in output:
        raise SystemExit(
            "Godot web export failed; previous local build retained\n" + output
        )


def build(destination, engine, version):
    run([engine, "--headless", "--path", ".", "--editor", "--import"])
    run(
        [
            engine,
            "--headless",
            "--path",
            ".",
            "--export-release",
            "Web",
            str(destination / "index.html"),
        ]
    )
    for name in ("index.html", "index.js", "index.wasm", "index.pck"):
        if not (destination / name).is_file():
            raise SystemExit("Missing export: " + name)
    shutil.copy2(
        ROOT / "THIRD_PARTY_NOTICES.md", destination / "THIRD_PARTY_NOTICES.md"
    )
    shutil.copytree(ROOT / "LICENSES", destination / "LICENSES")
    run(
        [
            engine,
            "--headless",
            "--path",
            ".",
            "--script",
            "res://scripts/release/engine_notices.gd",
            "--",
            str(destination),
        ]
    )
    (destination / ".nojekyll").touch()
    revision = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True
    ).strip()
    # Editable source/private art and docs do not make unchanged runtime bytes dirty.
    build_inputs = [
        "app",
        "pegasus",
        "levels",
        "shared",
        "assets",
        ":(exclude)assets/art/source",
        "project.godot",
        "export_presets.cfg",
        "THIRD_PARTY_NOTICES.md",
        "LICENSES",
        "scripts/web_export.py",
        "scripts/release",
    ]
    dirty = bool(
        subprocess.check_output(
            [
                "git",
                "status",
                "--porcelain",
                "--untracked-files=all",
                "--",
                *build_inputs,
            ],
            cwd=ROOT,
            text=True,
        ).strip()
    )
    (destination / "build-info.json").write_text(
        json.dumps(
            {
                "engine": version,
                "commit": revision,
                "dirty": dirty,
                "milestone": "Alpha 0.2 development (unreleased)",
                "threads": False,
                "pack_sha256": hashlib.sha256(
                    (destination / "index.pck").read_bytes()
                ).hexdigest(),
            },
            indent=2,
        )
        + "\n"
    )
    # Audit the staged bytes before replacing a previously playable local build.
    run(
        [
            "python3",
            str(ROOT / "scripts/check_web_pack.py"),
            "--godot",
            engine,
            "--pack",
            str(destination / "index.pck"),
        ]
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    version = subprocess.check_output([args.godot, "--version"], text=True).strip()
    if not version.startswith("4.7.2.stable."):
        raise SystemExit("Expected Godot 4.7.2 stable, got " + version)
    if not (ROOT / "build/toolchain/godot/web_nothreads_release.zip").is_file():
        raise SystemExit(
            "Run make web-templates first (official checksum-pinned templates)"
        )
    exports = ROOT / "exports"
    exports.mkdir(exist_ok=True)
    destination = exports / "web"
    with tempfile.TemporaryDirectory(prefix=".matrix-web-", dir=exports) as directory:
        stage = Path(directory) / "web"
        stage.mkdir()
        build(stage, args.godot, version)
        previous = Path(directory) / "previous"
        if destination.exists():
            destination.rename(previous)
        try:
            stage.rename(destination)
        except OSError:
            if previous.exists():
                previous.rename(destination)
            raise
    print(
        "Web export ready: exports/web/index.html (clean local preview; not published)"
    )


if __name__ == "__main__":
    main()
