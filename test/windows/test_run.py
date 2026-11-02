import contextlib
import csv
import io
import pathlib
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

import run


class RunnerArgumentsTest(unittest.TestCase):
    def test_forwards_requested_arguments_and_exit_code(self):
        with patch.object(sys, "argv", [
            "run.py", "--max", "4", "--start-index", "3", "--output", "test output",
        ]), patch.object(run.subprocess, "call", return_value=7) as invoke:
            self.assertEqual(run.main(), 7)
        args = invoke.call_args.args[0]
        self.assertEqual(args[args.index("-MaxTurn") + 1], "4")
        self.assertEqual(args[args.index("-StartRound") + 1], "3")
        self.assertEqual(
            pathlib.Path(args[args.index("-OutputDirectory") + 1]),
            pathlib.Path("test output").resolve(),
        )

    def test_rejects_invalid_round_bounds_before_launch(self):
        for values in [("0", "1"), ("2", "3"), ("101", "1")]:
            with self.subTest(values=values), patch.object(sys, "argv", [
                "run.py", "--max", values[0], "--start-index", values[1],
            ]), patch.object(run.subprocess, "call") as invoke:
                with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as error:
                    run.main()
                self.assertEqual(error.exception.code, 2)
                invoke.assert_not_called()

    @unittest.skipUnless(sys.platform == "win32", "PowerShell runner is Windows-only")
    def test_creates_output_and_requires_previous_report(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = pathlib.Path(temporary) / "new output"
            result = self.invoke_powershell(output)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(b"Previous round report is required", result.stderr)
            self.assertTrue(output.is_dir())
            self.assertFalse((output / "第2轮").exists())

    @unittest.skipUnless(sys.platform == "win32", "PowerShell runner is Windows-only")
    def test_no_retry_for_pass_or_todo(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = pathlib.Path(temporary)
            previous = output / "第1轮"
            previous.mkdir()
            (previous / "results.tsv").write_text(
                "AUTH-001\tRegister\tPASS\nCHAT-001\tChat\tTODO\n", encoding="utf-8",
            )
            result = self.invoke_powershell(output)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(b"no remaining cases", result.stdout)
            self.assertFalse((output / "第2轮").exists())

    @unittest.skipUnless(sys.platform == "win32", "PowerShell runner is Windows-only")
    def test_rejects_unknown_previous_case(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = pathlib.Path(temporary)
            previous = output / "第1轮"
            previous.mkdir()
            (previous / "results.tsv").write_text(
                "UNKNOWN-999\tUnknown\tFAIL\n", encoding="utf-8",
            )
            result = self.invoke_powershell(output)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(b"Unknown case in previous report", result.stderr)

    @unittest.skipUnless(sys.platform == "win32", "PowerShell runner is Windows-only")
    def test_retries_only_previous_nonpass_ids_with_issue_descriptions(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = pathlib.Path(temporary)
            previous = output / "第1轮"
            previous.mkdir()
            catalogue = pathlib.Path(__file__).with_name("case.list")
            with catalogue.open(encoding="utf-8") as source:
                rows = csv.reader(source, delimiter="\t")
                next(rows)
                titles = {row[0]: row[1] for row in rows}
            (previous / "results.tsv").write_text(
                "AUTH-001\tLogin\tPASS\nAUTH-002\tWrong password\tFAIL\n"
                "AUTH-003\tUnknown account\tNOT_RUN\nAUTH-008\tPassword change\tBLOCKED\n"
                "CHAT-001\tChat\tTODO\n", encoding="utf-8",
            )
            issue = previous / "issues" / f"{titles['AUTH-002']}-AUTH-002"
            issue.mkdir(parents=True)
            (issue / "issue.txt").write_text(
                "AUTH-002\tWrong password\nFAIL\nOriginal diagnosis retained.\n", encoding="utf-8",
            )
            # Stop before deployment without overwriting existing evidence.
            current = output / "第2轮"
            current.mkdir()
            (current / "results.tsv").write_text("unchanged", encoding="utf-8")
            result = self.invoke_powershell(output)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(b"Round already has results", result.stderr)
            selection = (output / "need_test.list").read_text(encoding="utf-8")
            self.assertIn("Original diagnosis retained.", selection)
            self.assertIn("AUTH-003", selection)
            self.assertIn("AUTH-008", selection)
            self.assertNotIn("AUTH-001", selection)
            self.assertNotIn("CHAT-001", selection)
            self.assertEqual((current / "results.tsv").read_text(), "unchanged")

    @staticmethod
    def invoke_powershell(output):
        return subprocess.run([
            "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass",
            "-File", str(pathlib.Path(__file__).with_name("Run.ps1")),
            "-MaxTurn", "2", "-StartRound", "2", "-OutputDirectory", str(output),
        ], capture_output=True, timeout=30)


if __name__ == "__main__":
    unittest.main()
