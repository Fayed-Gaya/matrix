"""Guard centralized runtime media and Pegasus resource references."""

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MEDIA = {".png", ".jpg", ".jpeg", ".gif", ".wav", ".ogg", ".mp3", ".ttf", ".otf"}


class RepositoryLayout(unittest.TestCase):
    def test_editable_sources_are_excluded(self):
        self.assertTrue((ROOT / "assets/art/source/.gdignore").is_file())
        self.assertFalse(
            (ROOT / "art/.gdignore").is_file()
        )  # Private untracked art may remain.
        self.assertFalse((ROOT / "hub").exists())
        self.assertTrue((ROOT / "pegasus/pegasus.tscn").is_file())

    def test_active_modules_have_no_scattered_media(self):
        for folder in ("app", "pegasus", "levels", "shared"):
            for path in (ROOT / folder).rglob("*"):
                if "source" not in path.relative_to(ROOT).parts:
                    self.assertNotIn(path.suffix.lower(), MEDIA, str(path))

    def test_import_sidecars_point_to_their_relocated_sources(self):
        for folder in ("assets/art", "assets/audio"):
            for sidecar in (ROOT / folder).rglob("*.import"):
                source = sidecar.with_suffix("")
                self.assertTrue(source.is_file(), str(sidecar))
                expected = (
                    'source_file="res://' + source.relative_to(ROOT).as_posix() + '"'
                )
                self.assertIn(expected, sidecar.read_text(), str(sidecar))

    def test_literal_media_references_exist(self):
        for folder in ("app", "pegasus", "levels", "shared"):
            for path in (ROOT / folder).rglob("*"):
                if "source" in path.relative_to(ROOT).parts or path.suffix not in {
                    ".gd",
                    ".tscn",
                    ".tres",
                    ".json",
                }:
                    continue
                for reference in re.findall(
                    r'res://[^"\n]+\.(?:png|jpg|jpeg|gif|ogg|mp3|wav|ttf|otf)(?=")',
                    path.read_text(),
                ):
                    self.assertTrue(
                        (ROOT / reference[6:]).is_file(), f"{path}: {reference}"
                    )


if __name__ == "__main__":
    unittest.main()
