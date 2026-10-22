"""Run the complete original Godot suite in an isolated historical checkout.

Never changes the working tree, tag, archive, or current public catalog.
"""

import argparse
import subprocess
import tarfile
import tempfile
from pathlib import Path

BASELINE = "145771f06735b98a6348f6c3d9bc014af899cd7f"
ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="matrix-archived-godot-") as directory:
        project = Path(directory)
        bundle = project / "baseline.tar"
        subprocess.run(
            ["git", "archive", "--format=tar", "-o", str(bundle), BASELINE],
            cwd=ROOT,
            check=True,
        )
        with tarfile.open(bundle) as archive:
            # Trusted, pinned repository tree; extract without following links.
            members = archive.getmembers()
            if any(
                m.issym()
                or m.islnk()
                or Path(m.name).is_absolute()
                or ".." in Path(m.name).parts
                for m in members
            ):
                raise SystemExit("Unexpected path/link in historical tree")
            archive.extractall(project, members=members)
        subprocess.run(
            ["python3", "scripts/validate_godot.py", "--godot", args.godot],
            cwd=project,
            check=True,
        )


if __name__ == "__main__":
    main()
