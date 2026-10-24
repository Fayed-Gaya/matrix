"""Inventory active code/content and embedded font notices; never infer permission."""

import argparse
import hashlib
import json
import struct
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "docs/releases/alpha-0.2-third-party-inventory.json"
EXTENSIONS = {
    ".gd",
    ".gdshader",
    ".tscn",
    ".tres",
    ".json",
    ".png",
    ".jpg",
    ".jpeg",
    ".gif",
    ".wav",
    ".mp3",
    ".ogg",
    ".ttf",
    ".otf",
}


def font_notices(path):
    content = path.read_bytes()
    count = struct.unpack_from(">H", content, 4)[0]
    tables = {
        content[12 + i * 16 : 16 + i * 16].decode(): struct.unpack_from(
            ">II", content, 20 + i * 16
        )
        for i in range(count)
    }
    start, _ = tables["name"]
    _, count, storage = struct.unpack_from(">HHH", content, start)
    names = defaultdict(set)
    labels = {
        0: "copyright",
        1: "family",
        8: "manufacturer",
        9: "designer",
        13: "license",
        14: "license_url",
    }
    for i in range(count):
        platform, _, _, key, size, offset = struct.unpack_from(
            ">HHHHHH", content, start + 6 + i * 12
        )
        if key in labels:
            value = content[
                start + storage + offset : start + storage + offset + size
            ].decode(
                "utf-16-be" if platform in (0, 3) else "mac_roman", errors="replace"
            )
            names[labels[key]].add(value)
    return {key: sorted(values) for key, values in sorted(names.items())}


def inventory():
    # Frozen attribution evidence survives Pygame retirement; never dereference
    # its historical paths in the current working tree.
    baseline = json.loads(
        (ROOT / "docs/releases/third-party-inventory.json").read_text()
    )
    originals = {
        row["sha256"]: row["exact_archived_matches"] for row in baseline["files"]
    }
    rows = []
    for folder in ("app", "pegasus", "levels", "shared", "assets"):
        for path in sorted((ROOT / folder).rglob("*")):
            if not path.is_file() or path.suffix.lower() not in EXTENSIONS:
                continue
            checksum = hashlib.sha256(path.read_bytes()).hexdigest()
            relative = path.relative_to(ROOT)
            row = {
                "path": str(relative),
                "module": (
                    relative.parts[1]
                    if folder == "levels"
                    else relative.parts[2]
                    if folder == "assets"
                    else folder
                ),
                "type": path.suffix.lower(),
                "size": path.stat().st_size,
                "sha256": checksum,
                "exact_archived_matches": sorted(originals.get(checksum, [])),
                "source_reference": "source" in relative.parts,
                "assessment": "See alpha-0.2-licensing.md and licensing-audit.md; inventory is not license clearance",
            }
            if path.suffix.lower() in (".ttf", ".otf"):
                row["embedded_font_notices"] = font_notices(path)
            rows.append(row)
    return {
        "scope": "Active modules/art/audio plus excluded level sources; not an export manifest. exact_archived_matches are historical paths at provenance_revision, not current files. archive/godot, caches and import sidecars are excluded.",
        "provenance_revision": "55c803c4c8488db9dd17b36bbecd62f775cd52d8",
        "counts": dict(sorted(Counter(row["type"] for row in rows).items())),
        "files": rows,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    value = json.dumps(inventory(), indent=2, ensure_ascii=False) + "\n"
    if args.check:
        if not OUTPUT.is_file() or OUTPUT.read_text() != value:
            raise SystemExit(
                "Licensing inventory stale: python3 scripts/audit_licenses.py"
            )
        print("Licensing inventory matches current files (not distribution clearance)")
    else:
        OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        OUTPUT.write_text(value)
        print("Wrote " + str(OUTPUT))


if __name__ == "__main__":
    main()
