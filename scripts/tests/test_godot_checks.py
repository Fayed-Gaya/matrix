"""Protect selector isolation and failure detection in the small test runner."""

import contextlib
import io
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts import validate_godot


class GodotChecks(unittest.TestCase):
    def selected_stages(self, *args):
        with (
            patch("sys.argv", ["validate_godot.py", *args]),
            patch.object(
                validate_godot.subprocess,
                "check_output",
                return_value="4.7.2.stable.test",
            ),
            patch.object(validate_godot, "run_stage") as stage,
            contextlib.redirect_stdout(io.StringIO()),
        ):
            validate_godot.main()
            return stage.call_args_list

    def test_focused_selection_does_not_run_unrelated_levels_or_global_resources(self):
        calls = self.selected_stages("--only", "busboy")
        self.assertEqual([c.args[1] for c in calls], ["import", "focused"])
        self.assertEqual(calls[-1].args[2][-2:], ["--", "busboy"])

    def test_default_smoke_has_one_import_and_one_runtime(self):
        calls = self.selected_stages()
        self.assertEqual([c.args[1] for c in calls], ["import", "smoke"])

    def test_unknown_selector_fails_before_starting_godot(self):
        with (
            patch("sys.argv", ["validate_godot.py", "--only", "typo"]),
            patch.object(validate_godot.subprocess, "check_output") as engine,
            contextlib.redirect_stderr(io.StringIO()),
        ):
            with self.assertRaises(SystemExit) as error:
                validate_godot.main()
            self.assertEqual(error.exception.code, 2)
            engine.assert_not_called()

    def test_historical_walkthroughs_require_explicit_opt_in(self):
        calls = self.selected_stages("--regression", "--only", "busboy")
        self.assertEqual([c.args[1] for c in calls], ["import", "resources", "busboy"])

    def test_script_error_on_zero_exit_is_failure_with_saved_diagnostics(self):
        with (
            tempfile.TemporaryDirectory() as directory,
            patch.object(validate_godot, "ROOT", Path(directory)),
            patch.object(
                validate_godot.subprocess,
                "run",
                return_value=subprocess.CompletedProcess(
                    [], 0, "success marker\nSCRIPT ERROR: broken resource", ""
                ),
            ),
        ):
            with self.assertRaises(SystemExit):
                validate_godot.run_stage("godot", "probe", [], "success marker")
            self.assertIn(
                "broken resource",
                (Path(directory) / "build/test-logs/probe.log").read_text(),
            )

    def test_missing_completion_marker_is_failure(self):
        with (
            tempfile.TemporaryDirectory() as directory,
            patch.object(validate_godot, "ROOT", Path(directory)),
            patch.object(
                validate_godot.subprocess,
                "run",
                return_value=subprocess.CompletedProcess([], 0, "", ""),
            ),
        ):
            with self.assertRaises(SystemExit):
                validate_godot.run_stage("godot", "probe", [], "required marker")


if __name__ == "__main__":
    unittest.main()
