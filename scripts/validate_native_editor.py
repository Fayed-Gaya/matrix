"""Open and edit all native maps in a disposable real Godot editor project.

Requires a desktop display. Does not touch repository scenes
or project configuration. Python is validation tooling only.
"""

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
    with tempfile.TemporaryDirectory(prefix="matrix-native-editor-") as directory:
        project = Path(directory)
        for folder in ("app", "hub", "levels", "shared"):
            shutil.copytree(root / folder, project / folder)
        shutil.copy2(root / "project.godot", project / "project.godot")
        for stage, options, marker in (
            ("import", ["--headless", "--editor", "--import"], None),
            ("editor", ["--editor"], "Native Godot editor validation passed"),
        ):
            if stage == "editor":
                plugin = project / "addons/native_editor_validation"
                plugin.mkdir(parents=True)
                shutil.copy2(
                    root / "scripts/validation/editor_native_check.gd", plugin / "plugin.gd"
                )
                (plugin / "plugin.cfg").write_text(
                    '[plugin]\nname="Native map validation"\n'
                    'description="Disposable editor validation"\n'
                    'author="Matrix"\nversion="1.0"\nscript="plugin.gd"\n'
                )
                with (project / "project.godot").open("a") as stream:
                    stream.write(
                        '\n[editor_plugins]\nenabled=PackedStringArray("res://addons/native_editor_validation/plugin.cfg")\n'
                    )
            result = subprocess.run(
                [
                    args.godot,
                    "--path",
                    str(project),
                    "--log-file",
                    str(project / f"{stage}.log"),
                    *options,
                ],
                capture_output=True,
                text=True,
                timeout=240,
            )
            output = result.stdout + result.stderr
            if (
                result.returncode
                or "ERROR:" in output
                or "were leaked at exit" in output
                or (marker and marker not in output)
            ):
                raise SystemExit(f"Native editor {stage} failed:\n{output}")
            if stage == "editor":
                print("\n".join(line for line in output.splitlines() if "passed" in line))
    print("Native editor verification passed; manual gameplay acceptance still required")


if __name__ == "__main__":
    main()
