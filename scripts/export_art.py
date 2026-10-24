"""Export one explicit single-frame Aseprite sheet with isolated batch settings."""

import argparse
import os
import struct
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--aseprite", default="/Applications/Aseprite.app/Contents/MacOS/aseprite"
    )
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    source, output = args.source.resolve(), args.output.resolve()
    if not source.is_relative_to(ROOT / "art") or source.suffix not in {
        ".aseprite",
        ".ase",
    }:
        parser.error("Choose an explicit editable .aseprite/.ase source under art/")
    if (
        not output.is_relative_to(ROOT)
        or output.suffix != ".png"
        or output.relative_to(ROOT).parts[0] not in {"pegasus", "levels", "shared"}
    ):
        parser.error("Output must be a runtime PNG under pegasus/, levels/ or shared/")
    header = source.read_bytes()[:128]
    if len(header) < 128 or struct.unpack_from("<H", header, 4)[0] != 0xA5E0:
        parser.error("Invalid Aseprite source")
    frames, width, height = struct.unpack_from("<HHH", header, 6)
    if frames != 1:
        parser.error(
            "Animated files need a deliberate sprite-sheet layout; this helper does not silently flatten/repack them"
        )
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="matrix-art-") as directory:
        stage = Path(directory) / "sheet.png"
        result = subprocess.run(
            [args.aseprite, "--batch", str(source), "--save-as", str(stage)],
            env={**os.environ, "ASEPRITE_USER_FOLDER": directory},
            capture_output=True,
            text=True,
            timeout=60,
        )
        if result.returncode or not stage.is_file():
            raise SystemExit("Aseprite export failed: " + result.stdout + result.stderr)
        png = stage.read_bytes()
        if png[:8] != b"\x89PNG\r\n\x1a\n" or struct.unpack_from(">II", png, 16) != (
            width,
            height,
        ):
            raise SystemExit("Export changed sheet dimensions")
        # Same filesystem staging avoids truncating a prior runtime PNG on failure.
        with tempfile.NamedTemporaryFile(
            dir=output.parent, prefix=".art-", delete=False
        ) as stream:
            pending = Path(stream.name)
            stream.write(png)
        try:
            pending.replace(output)
        finally:
            pending.unlink(missing_ok=True)
    print(
        f"Exported {source.relative_to(ROOT)} → {output.relative_to(ROOT)} ({width}×{height}); source/preferences unchanged"
    )


if __name__ == "__main__":
    main()
