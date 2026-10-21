"""Validate with the pinned engine; Python is development tooling only."""

import argparse
import subprocess
import tempfile
from pathlib import Path



def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    version = subprocess.check_output([args.godot, "--version"], text=True).strip()
    if not version.startswith("4.7.2.stable."):
        raise SystemExit(f"Expected Godot 4.7.2 stable; got {version}")
    with tempfile.TemporaryDirectory(prefix="matrix-godot-") as logs:
        descriptor = root / "scripts/validation/hub_map_reference.json"
        untitled_descriptor = root / "scripts/validation/untitled_map_reference.json"
        for name, options, marker in [
            ("import", ["--editor", "--import"], None),
            (
                "resources",
                ["--script", "res://scripts/validation/project_check.gd"],
                "Matrix project validation passed",
            ),
            (
                "hub",
                ["--script", "res://scripts/validation/hub_check.gd", "--", str(descriptor)],
                "Matrix hub integration passed",
            ),
            (
                "bouncing_ball",
                [
                    "--script",
                    "res://scripts/validation/bouncing_ball_check.gd",
                    "--",
                    str(root / "scripts/validation/bouncing_ball_reference.json"),
                ],
                "Bouncing Ball validation passed",
            ),
            (
                "balls",
                [
                    "--script",
                    "res://scripts/validation/balls_check.gd",
                    "--",
                    str(root / "scripts/validation/balls_reference.json"),
                ],
                "Balls validation passed",
            ),
            (
                "bug",
                ["--script", "res://scripts/validation/bug_check.gd"],
                "The Bug validation passed",
            ),
            (
                "pong",
                ["--script", "res://scripts/validation/pong_check.gd"],
                "Pong validation passed",
            ),
            (
                "jump",
                ["--script", "res://scripts/validation/jump_check.gd"],
                "Jump validation passed",
            ),
            (
                "untitled",
                [
                    "--script",
                    "res://scripts/validation/untitled_check.gd",
                    "--",
                    str(untitled_descriptor),
                ],
                "Untitled validation passed",
            ),
            (
                "mario",
                ["--script", "res://scripts/validation/mario_check.gd"],
                "Mario validation passed",
            ),
            (
                "zelda",
                ["--script", "res://scripts/validation/zelda_check.gd"],
                "Zelda validation passed",
            ),
            (
                "monsters",
                ["--script", "res://scripts/validation/monsters_check.gd"],
                "Monsters validation passed",
            ),
            (
                "you",
                ["--script", "res://scripts/validation/you_check.gd"],
                "You camera validation passed",
            ),
            ("startup", ["--quit-after", "5"], "Matrix hub ready"),
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
                or "were leaked at exit" in output
                or (marker is not None and marker not in output)
            ):
                raise SystemExit(f"Godot {name} validation failed")
    print(f"Godot {version}: all validation stages passed")


if __name__ == "__main__":
    main()
