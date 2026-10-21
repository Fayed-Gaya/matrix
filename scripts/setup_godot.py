"""Install checksum-pinned official Linux editor and/or web templates locally."""

import argparse
import hashlib
import json
import os
import subprocess
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOCK = json.loads((ROOT / "scripts/release/godot-toolchain.json").read_text())


def digest(path):
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(chunk)
    return result.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--editor", action="store_true", help="Linux x86_64 editor")
    parser.add_argument("--templates", action="store_true")
    parser.add_argument("--archive", type=Path, help="Existing official templates TPZ")
    args = parser.parse_args()
    if not args.editor and not args.templates:
        parser.error("select --editor and/or --templates")
    target = ROOT / "build/toolchain/godot"
    target.mkdir(parents=True, exist_ok=True)
    for kind in (["linux_editor"] if args.editor else []) + (
        ["templates"] if args.templates else []
    ):
        entry = LOCK[kind]
        archive = args.archive if kind == "templates" and args.archive else target / entry["file"]
        if not archive.exists():
            partial = archive.with_suffix(archive.suffix + ".part")
            url = (
                "https://github.com/godotengine/godot-builds/releases/download/"
                + LOCK["release"]
                + "/"
                + entry["file"]
            )
            subprocess.run(
                ["curl", "--fail", "--location", "--retry", "3", "--output", str(partial), url],
                check=True,
            )
            if digest(partial) != entry["sha256"]:
                raise SystemExit("Checksum mismatch: " + str(partial))
            partial.replace(archive)
        if digest(archive) != entry["sha256"]:
            raise SystemExit("Checksum mismatch: " + str(archive))
        with zipfile.ZipFile(archive) as package:
            if kind == "templates":
                version = package.read("templates/version.txt").decode().strip()
                if version != "4.7.2.stable":
                    raise SystemExit("Unexpected template version: " + version)
                for name in ("web_nothreads_release.zip", "web_nothreads_debug.zip"):
                    (target / name).write_bytes(package.read("templates/" + name))
            else:
                (target / "godot").write_bytes(package.read("Godot_v4.7.2-stable_linux.x86_64"))
                os.chmod(target / "godot", 0o755)
        if archive.parent == target and not args.archive:
            archive.unlink()
        print("Verified and installed " + kind + " in " + str(target))


if __name__ == "__main__":
    main()
