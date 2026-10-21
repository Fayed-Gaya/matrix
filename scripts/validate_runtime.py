"""Import and launch every code from a fresh, archive-free temporary project."""

import argparse
import shutil
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
    with tempfile.TemporaryDirectory(prefix="matrix-runtime-") as directory:
        project = Path(directory)
        for folder in ("app", "hub", "levels", "shared"):
            shutil.copytree(root / folder, project / folder)
        shutil.copy2(root / "project.godot", project / "project.godot")
        script = "scripts/validation/runtime_check.gd"
        (project / script).parent.mkdir(parents=True)
        shutil.copy2(root / script, project / script)
        for stage, options, marker in (
            ("import", ["--editor", "--import"], None),
            (
                "runtime",
                ["--script", "res://" + script],
                "Standalone runtime validation passed",
            ),
        ):
            result = subprocess.run(
                [
                    args.godot,
                    "--headless",
                    "--path",
                    str(project),
                    "--log-file",
                    str(project / f"{stage}.log"),
                    *options,
                ],
                text=True,
                capture_output=True,
                timeout=180,
            )
            output = result.stdout + result.stderr
            if (
                result.returncode
                or "ERROR:" in output
                or "were leaked at exit" in output
                or (marker and marker not in output)
            ):
                raise SystemExit(f"Isolated {stage} failed:\n{output}")
            print(f"Fresh {stage}: passed")
    print("Archive-free runtime passed; real camera and platform exports untested")


if __name__ == "__main__":
    main()
