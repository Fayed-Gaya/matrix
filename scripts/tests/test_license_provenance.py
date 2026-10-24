"""Retired source attribution remains reproducible without the Pygame tree."""

import hashlib
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts import audit_licenses


class HistoricalProvenance(unittest.TestCase):
    def test_frozen_inventory_supplies_attribution_without_retired_sources(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "assets/audio/probe.mp3"
            source.parent.mkdir(parents=True)
            source.write_bytes(b"original media")
            checksum = hashlib.sha256(source.read_bytes()).hexdigest()
            evidence = root / "docs/releases/third-party-inventory.json"
            evidence.parent.mkdir(parents=True)
            evidence.write_text(
                json.dumps(
                    {
                        "files": [
                            {
                                "sha256": checksum,
                                "exact_archived_matches": [
                                    "legacy/pygame/original.mp3"
                                ],
                            }
                        ]
                    }
                )
            )
            with patch.object(audit_licenses, "ROOT", root):
                rows = audit_licenses.inventory()["files"]
                self.assertEqual(
                    rows[0]["exact_archived_matches"], ["legacy/pygame/original.mp3"]
                )
                source.write_bytes(b"new media")
                self.assertEqual(
                    audit_licenses.inventory()["files"][0]["exact_archived_matches"], []
                )
            self.assertFalse((root / "legacy").exists())


if __name__ == "__main__":
    unittest.main()
