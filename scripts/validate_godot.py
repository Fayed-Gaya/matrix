"""Validate with the pinned engine; Python is development tooling only."""

import argparse
import subprocess
import tempfile
import time
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    parser.add_argument(
        "--only",
        nargs="+",
        type=str.lower,
        help="Targeted stages; imports/resources always run (e.g. pegasus, machine, bounce)",
    )
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    # Prevent reintroducing a second runtime map-authoring source.
    for folder in ("app", "pegasus", "levels", "shared", "assets"):
        obsolete = [
            p
            for p in (root / folder).rglob("*")
            if p.suffix in {".tmx", ".tsx", ".csv"}
        ]
        if obsolete:
            raise SystemExit(f"Obsolete map-authoring source remains: {obsolete[0]}")
    version = subprocess.check_output([args.godot, "--version"], text=True).strip()
    if not version.startswith("4.7.2.stable."):
        raise SystemExit(f"Expected Godot 4.7.2 stable; got {version}")
    with tempfile.TemporaryDirectory(prefix="matrix-godot-") as logs:
        descriptor = root / "scripts/validation/pegasus_map_reference.json"
        stages = [
            ("import", ["--editor", "--import"], None),
            (
                "resources",
                ["--script", "res://scripts/validation/project_check.gd"],
                "Matrix project validation passed",
            ),
            (
                "pegasus",
                [
                    "--script",
                    "res://scripts/validation/pegasus_check.gd",
                    "--",
                    str(descriptor),
                ],
                "Pegasus integration passed",
            ),
            (
                "mobile",
                ["--script", "res://scripts/validation/mobile_check.gd"],
                "Mobile input validation passed",
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
                "busboy",
                ["--script", "res://scripts/validation/busboy_check.gd"],
                "Busboy validation passed",
            ),
            (
                "bubby",
                ["--script", "res://scripts/validation/bubby_check.gd"],
                "Bubby validation passed",
            ),
            (
                "you",
                ["--script", "res://scripts/validation/you_check.gd"],
                "You camera validation passed",
            ),
            (
                "native_maps",
                [
                    "--script",
                    "res://scripts/validation/native_maps_check.gd",
                ],
                "Native map authoring validation passed",
            ),
            (
                "machine",
                ["--script", "res://scripts/validation/machine_check.gd"],
                "Machine validation passed",
            ),
            ("startup", ["--quit-after", "5"], "Pegasus ready"),
        ]
        aliases = {"bounce": "bouncing_ball"}
        requested = {aliases.get(name, name) for name in (args.only or [])}
        known = {stage[0] for stage in stages}
        if requested - known:
            parser.error(
                "Unknown check(s): "
                + ", ".join(sorted(requested - known))
                + "; choose "
                + ", ".join(sorted(known))
            )
        for name, options, marker in stages:
            if requested and name not in requested | {"import", "resources"}:
                continue
            started = time.monotonic()
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
            print(f"Stage {name}: passed in {time.monotonic() - started:.2f}s")
    scope = "selected" if args.only else "all"
    print(f"Godot {version}: {scope} validation stages passed")


if __name__ == "__main__":
    main()
