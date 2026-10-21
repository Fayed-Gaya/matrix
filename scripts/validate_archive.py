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
    normalized = 0
    for entry in manifest["files"]:
        if entry["path"] in retained:
            continue
        archived = root / "legacy/pygame" / entry["path"]
        if not archived.is_file():
            failures.append(f"Missing: {archived.relative_to(root)}")
        else:
            content = archived.read_bytes()
            if hashlib.sha256(content).hexdigest() == entry["sha256"]:
                verified += 1
            elif b"\r\n" not in content and hashlib.sha256(
                content.replace(b"\n", b"\r\n")
            ).hexdigest() == entry["sha256"]:
                # core.autocrlf=input normalized tracked text on initial commit.
                # Reconstruct only in memory; never rewrite the preserved archive.
                normalized += 1
            else:
                failures.append(f"Changed: {archived.relative_to(root)}")
    if failures:
        raise SystemExit("\n".join(failures))
    print(f"Archive preservation passed: {verified} byte-identical; "
          f"{normalized} match after exact LF-to-CRLF reconstruction")


if __name__ == "__main__":
    main()
