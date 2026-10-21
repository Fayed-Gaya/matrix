"""Validate the exported PCK in isolation, never against checkout resources."""

import argparse
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="matrix-web-pack-") as directory:
        result = subprocess.run(
            [
                args.godot,
                "--headless",
                "--path",
                directory,
                "--main-pack",
                str(ROOT / "exports/web/index.pck"),
                "--log-file",
                str(Path(directory) / "pack.log"),
                "--script",
                str(ROOT / "scripts/validation/web_pack_check.gd"),
            ],
            text=True,
            capture_output=True,
            timeout=180,
        )
        output = result.stdout + result.stderr
        print(output, end="")
        if (
            result.returncode
            or "ERROR:" in output
            or "were leaked at exit" in output
            or "Exported web pack validation passed" not in output
        ):
            raise SystemExit("Exported pack validation failed")


if __name__ == "__main__":
    main()
