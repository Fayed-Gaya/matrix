"""Pinned Godot checks: focused locally, smoke by default, historical on demand."""

import argparse
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FOCUSED = {
    "pegasus",
    "bounce",
    "balls",
    "bug",
    "bubby",
    "busboy",
    "machine",
    "you",
    "mobile",
}


def regression_stages(root):
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
    ]
    return stages


def run_stage(engine, name, options, marker, verbose=False):
    logs = ROOT / "build/test-logs"
    logs.mkdir(parents=True, exist_ok=True)
    log = logs / (name + ".log")
    started = time.monotonic()
    try:
        result = subprocess.run(
            [
                engine,
                "--headless",
                "--path",
                str(ROOT),
                "--log-file",
                str(log),
                *options,
            ],
            capture_output=True,
            text=True,
            timeout=120,
        )
        output = result.stdout + result.stderr
        failed = (
            result.returncode
            or any(flag in output for flag in ("ERROR:", "were leaked at exit"))
            or (marker is not None and marker not in output)
        )
    except subprocess.TimeoutExpired as error:
        output = "".join(
            part.decode(errors="replace") if isinstance(part, bytes) else part or ""
            for part in (error.stdout, error.stderr)
        )
        output += "\nGodot check exceeded 120 seconds."
        failed = True
    log.write_text(output)
    if failed:
        raise SystemExit(f"FAIL {name}; diagnostics: {log}\n{output}")
    if verbose:
        print(output, end="")
    print(f"PASS {name} ({time.monotonic() - started:.2f}s)")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    parser.add_argument(
        "--only", nargs="+", type=str.lower, help="Focused components, or all/resources"
    )
    parser.add_argument(
        "--regression",
        action="store_true",
        help="Optional historical traces/walkthroughs",
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Also print successful engine logs"
    )
    args = parser.parse_args()
    requested = set(args.only or [])
    if args.regression:
        stages = regression_stages(ROOT)
        requested = {
            "bouncing_ball" if name == "bounce" else name for name in requested
        }
        known = {stage[0] for stage in stages}
        if requested:
            stages = [s for s in stages if s[0] in requested | {"import", "resources"}]
    else:
        requested = {
            "bounce" if name == "bouncing_ball" else name for name in requested
        }
        known = FOCUSED | {"all", "resources"}
        stages = [("import", ["--editor", "--import"], None)]
        if args.only:
            if "all" in requested:
                requested = (requested - {"all"}) | FOCUSED
            if "resources" in requested:
                stages.append(
                    (
                        "resources",
                        ["--script", "res://scripts/validation/project_check.gd"],
                        "Matrix project validation passed",
                    )
                )
            selected = sorted(requested - {"resources"})
            if selected:
                stages.append(
                    (
                        "focused",
                        [
                            "--script",
                            "res://scripts/validation/focused_check.gd",
                            "--",
                            *selected,
                        ],
                        "Focused checks passed",
                    )
                )
        else:
            stages.append(
                (
                    "smoke",
                    ["--script", "res://scripts/validation/smoke_check.gd"],
                    "Matrix integration smoke passed",
                )
            )
    if requested - known:
        parser.error(
            "Unknown check(s): "
            + ", ".join(sorted(requested - known))
            + "; choose "
            + ", ".join(sorted(known))
        )
    version = subprocess.check_output([args.godot, "--version"], text=True).strip()
    if not version.startswith("4.7.2.stable."):
        raise SystemExit(f"Expected Godot 4.7.2 stable; got {version}")
    started = time.monotonic()
    for name, options, marker in stages:
        run_stage(args.godot, name, options, marker, args.verbose)
    scope = (
        "historical regression"
        if args.regression
        else "focused"
        if args.only
        else "integration smoke"
    )
    print(
        f"PASS {scope}: {len(stages)} stages, {time.monotonic() - started:.2f}s total"
    )


if __name__ == "__main__":
    main()
