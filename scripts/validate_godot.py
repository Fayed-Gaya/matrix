"""Validate with the pinned engine; Python is development tooling only."""

import argparse
from pathlib import Path
import subprocess
import tempfile


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    version = subprocess.check_output([args.godot, "--version"], text=True).strip()
    if not version.startswith("4.7.2.stable."):
        raise SystemExit(f"Expected Godot 4.7.2 stable; got {version}")
    with tempfile.TemporaryDirectory(prefix="matrix-godot-") as logs:
        for name, options, marker in [
            ("import", ["--editor", "--import"], None),
            (
                "resources",
                ["--script", "res://scripts/validation/project_check.gd"],
                "Matrix project validation passed",
            ),
            ("startup", ["--quit-after", "5"], "Matrix foundation ready"),
        ]:
            result = subprocess.run(
                [
                    args.godot,
                    "--headless",
                    "--path",
                    str(root),
                    "--log-file",
                    str(Path(logs) / f"{name}.log"),
                    *options,
                ],
                capture_output=True,
                text=True,
                timeout=120,
            )
            output = result.stdout + result.stderr
            print(output, end="")
            # Godot may report script errors while returning exit status zero.
            if (
                result.returncode
                or "SCRIPT ERROR:" in output
                or "ERROR:" in output
                or (marker is not None and marker not in output)
            ):
                raise SystemExit(f"Godot {name} validation failed")
    print(f"Godot {version}: import, resources, and startup passed")


if __name__ == "__main__":
    main()
