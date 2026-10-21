"""Verify the tracked Pygame archive against the pre-migration SHA-256 baseline."""

import hashlib
import json
from pathlib import Path


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    manifest = json.loads((root / "docs/migration/baseline-files.json").read_text())
    retained = {
        ".github/workflows/build-untitled-windows.yml",
        ".github/workflows/checks.yml",
        ".gitignore",
        "scripts/notion_mcp.sh",
    }
    failures = []
    verified = 0
    for entry in manifest["files"]:
        if entry["path"] in retained:
            continue
        archived = root / "legacy/pygame" / entry["path"]
        if not archived.is_file():
            failures.append(f"Missing: {archived.relative_to(root)}")
        elif hashlib.sha256(archived.read_bytes()).hexdigest() != entry["sha256"]:
            failures.append(f"Changed: {archived.relative_to(root)}")
        else:
            verified += 1
    if failures:
        raise SystemExit("\n".join(failures))
    print(f"Archive preservation passed: {verified} original files byte-identical")


if __name__ == "__main__":
    main()
