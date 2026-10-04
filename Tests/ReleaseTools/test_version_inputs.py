"""Release identity gates exercised with isolated source, notes and Git tags."""

import json
from pathlib import Path
import runpy
import subprocess
import sys
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[2]
checker = runpy.run_path(str(SOURCE / "Scripts/verify-release"))
validate = checker["validate_version_inputs"]


class VersionInputTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="apple-cli-version-test-")
        self.addCleanup(temporary.cleanup)
        self.source = Path(temporary.name)
        self.version_file = self.source / "Sources/Utility/CLIVersion.swift"
        self.version_file.parent.mkdir(parents=True)
        self.changelog = self.source / "CHANGELOG.md"
        self.write_source()

    def write_source(self, version="0.1.0-alpha.1"):
        self.version_file.write_text(f'public enum CLIVersion {{\n  public static let current = "{version}"\n}}\n')
        self.changelog.write_text(f"# Changelog\n\n## {version} — Unreleased\n\nDescribe the accepted change.\n")

    def git(self, *arguments):
        return subprocess.check_output(
            ["git", *arguments], cwd=self.source, text=True, stderr=subprocess.PIPE,
        ).strip()

    def commit(self):
        self.git("add", ".")
        self.git(
            "-c", "user.name=Release Fixture", "-c", "user.email=fixture@example.invalid",
            "-c", "commit.gpgsign=false", "commit", "--quiet", "-m", "Release fixture",
        )

    def test_accepts_release_and_preview_stages(self):
        for version in ["0.1.0", "1.0.0", "2.3.14", "0.1.0-alpha.1", "0.1.0-alpha.12", "0.1.0-beta.1", "0.1.0-rc.1"]:
            with self.subTest(version=version):
                self.write_source(version)
                self.assertEqual(validate(self.source), version)

    def test_rejects_ambiguous_or_unsupported_version_identity(self):
        for version in [
            "01.2.3", "1.02.3", "1.2.03", "0.1.0-alpha.01", "0.1.0-alpha.0",
            "0.1.0-beta.00", "0.1.0-rc.01", "0.1.0-dev.1", "0.1.0-alpha",
            "0.1.0-alpha.1+build.2", "v0.1.0", "0.1", "１.2.3",
        ]:
            with self.subTest(version=version):
                self.write_source(version)
                with self.assertRaisesRegex(ValueError, "Invalid product version"):
                    validate(self.source)

    def test_requires_one_version_declaration(self):
        for source in [
            "public enum CLIVersion {}\n",
            self.version_file.read_text() + 'public static let current = "1.0.0"\n',
        ]:
            with self.subTest(source=source):
                self.version_file.write_text(source)
                with self.assertRaisesRegex(ValueError, "exactly one canonical"):
                    validate(self.source)

    def test_requires_existing_inputs(self):
        for path in [self.version_file, self.changelog]:
            with self.subTest(path=path.name):
                self.write_source()
                path.unlink()
                with self.assertRaises(FileNotFoundError):
                    validate(self.source)

    def test_requires_matching_changelog_entry(self):
        self.changelog.write_text("# Changelog\n\n## 0.1.0-alpha.2\n\nOther candidate.\n")
        with self.assertRaisesRegex(ValueError, "exactly one Changelog entry"):
            validate(self.source)

    def test_rejects_duplicate_changelog_entries(self):
        self.changelog.write_text(self.changelog.read_text() + "\n## 0.1.0-alpha.1\n\nDuplicate.\n")
        with self.assertRaisesRegex(ValueError, "exactly one Changelog entry"):
            validate(self.source)

    def test_other_version_notes_cannot_fill_empty_entry(self):
        self.changelog.write_text(
            "# Changelog\n\n## 0.1.0-alpha.1 — Unreleased\n\n## 0.0.1\n\nOld changes.\n",
        )
        with self.assertRaisesRegex(ValueError, "entry.*empty"):
            validate(self.source)

    def test_extracts_only_current_notes(self):
        self.changelog.write_text(
            "# Changelog\n\n## 0.1.0-alpha.1 — Unreleased\n\n### Fixed\n\nCurrent changes.\n\n## 0.0.1\n\nOld changes.\n",
        )
        self.assertEqual(checker["changelog_notes"](self.source, "0.1.0-alpha.1"), "### Fixed\n\nCurrent changes.")
        self.assertEqual(validate(self.source), "0.1.0-alpha.1")

    def test_rejects_wrong_or_empty_tag(self):
        for tag in ["", "0.1.0-alpha.1", "v0.1.0", "v0.1.0-alpha.2"]:
            with self.subTest(tag=tag), self.assertRaisesRegex(ValueError, "Version tag mismatch"):
                validate(self.source, tag)

    def test_requires_tag_to_exist(self):
        self.git("init", "--quiet")
        self.commit()
        with self.assertRaises(subprocess.CalledProcessError):
            validate(self.source, "v0.1.0-alpha.1")

    def test_accepts_lightweight_and_annotated_tags_at_head(self):
        self.git("init", "--quiet")
        self.commit()
        self.git("-c", "tag.gpgsign=false", "tag", "v0.1.0-alpha.1")
        self.assertEqual(validate(self.source, "v0.1.0-alpha.1"), "0.1.0-alpha.1")
        self.write_source("0.1.0-beta.1")
        self.commit()
        self.git(
            "-c", "user.name=Release Fixture", "-c", "user.email=fixture@example.invalid",
            "-c", "tag.gpgsign=false", "tag", "-a", "v0.1.0-beta.1", "-m", "Release fixture",
        )
        self.assertEqual(validate(self.source, "v0.1.0-beta.1"), "0.1.0-beta.1")

    def test_rejects_tag_on_another_commit(self):
        self.git("init", "--quiet")
        self.commit()
        self.git("-c", "tag.gpgsign=false", "tag", "v0.1.0-alpha.1")
        self.changelog.write_text(self.changelog.read_text() + "\nAnother accepted change.\n")
        self.commit()
        with self.assertRaisesRegex(ValueError, "Tag commit mismatch"):
            validate(self.source, "v0.1.0-alpha.1")

    def test_cli_returns_metadata_without_modifying_source(self):
        before = {path: path.read_bytes() for path in [self.version_file, self.changelog]}
        result = subprocess.run(
            [sys.executable, str(SOURCE / "Scripts/validate-version"), "--source", str(self.source), "--json"],
            check=True, text=True, capture_output=True,
        )
        self.assertEqual(json.loads(result.stdout), {
            "version": "0.1.0-alpha.1", "expected_tag": "v0.1.0-alpha.1",
            "prerelease": True, "tag_checked": False,
        })
        self.assertEqual(before, {path: path.read_bytes() for path in before})

    def test_cli_fails_without_repairing_invalid_inputs(self):
        self.write_source("0.1.0-alpha.01")
        before = self.version_file.read_bytes()
        result = subprocess.run(
            [sys.executable, str(SOURCE / "Scripts/validate-version"), "--source", str(self.source)],
            text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("Invalid product version", result.stderr)
        self.assertEqual(result.stdout, "")
        self.assertEqual(before, self.version_file.read_bytes())

    def test_publisher_uses_the_same_notes_entry_as_preflight(self):
        self.changelog.write_text(
            "# Changelog\n\n##   0.1.0-alpha.1 — Unreleased\n\nCurrent changes.\n"
            "[Guide](Documentation/Reference/ReleaseGuide.md)\n\n## 0.0.1\n\nOld changes.\n",
        )
        self.assertEqual(validate(self.source), "0.1.0-alpha.1")
        publisher = runpy.run_path(str(SOURCE / "Scripts/publish-release"))
        notes = publisher["release_notes"]
        notes.__globals__["SOURCE"] = self.source
        body = notes({
            "version": "0.1.0-alpha.1", "repository": "computer-mcp/apple-cli",
            "tag": "v0.1.0-alpha.1", "source_commit": "a" * 40,
        }, {"ci": {"run_url": "https://github.com/computer-mcp/apple-cli/actions/runs/1"}})
        self.assertIn("Current changes.", body)
        self.assertNotIn("Old changes.", body)
        self.assertIn("https://github.com/computer-mcp/apple-cli/blob/v0.1.0-alpha.1/Documentation/Reference/ReleaseGuide.md", body)
