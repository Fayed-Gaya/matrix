"""Protect local preview replacement semantics without running another engine."""

import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts import web_export


class LocalPreviewReplacement(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        template = self.root / "build/toolchain/godot/web_nothreads_release.zip"
        template.parent.mkdir(parents=True)
        template.touch()
        self.preview = self.root / "exports/web"
        self.preview.mkdir(parents=True)
        (self.preview / "index.pck").write_bytes(b"previous playable preview")
        (self.preview / "obsolete.worker.js").write_text("old threaded worker")
        self.patches = [
            patch.object(web_export, "ROOT", self.root),
            patch("sys.argv", ["web_export.py", "--godot", "test-engine"]),
            patch.object(
                web_export.subprocess, "check_output", return_value="4.7.2.stable.test"
            ),
        ]
        for item in self.patches:
            item.start()
            self.addCleanup(item.stop)

    def test_failed_build_preserves_previous_playable_preview(self):
        def failed(stage, *_):
            (stage / "index.pck").write_bytes(b"partial build")
            raise SystemExit("engine failed")

        with patch.object(web_export, "build", side_effect=failed):
            with self.assertRaises(SystemExit):
                web_export.main()
        self.assertEqual(
            (self.preview / "index.pck").read_bytes(), b"previous playable preview"
        )
        self.assertTrue((self.preview / "obsolete.worker.js").exists())
        self.assertEqual(sorted(p.name for p in self.preview.parent.iterdir()), ["web"])

    def test_successful_build_removes_stale_workers_and_sidecars(self):
        def complete(stage, *_):
            (stage / "index.pck").write_bytes(b"complete new preview")
            (stage / "index.html").write_text("new launcher")

        with patch.object(web_export, "build", side_effect=complete):
            web_export.main()
        self.assertEqual(
            (self.preview / "index.pck").read_bytes(), b"complete new preview"
        )
        self.assertTrue((self.preview / "index.html").exists())
        self.assertFalse((self.preview / "obsolete.worker.js").exists())
        self.assertEqual(sorted(p.name for p in self.preview.parent.iterdir()), ["web"])


if __name__ == "__main__":
    unittest.main()
