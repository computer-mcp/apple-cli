"""Archive document acceptance with synthetic bytes; no executable acceptance."""

import json
from pathlib import Path
import runpy
import shutil
import subprocess
import tarfile
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[2]
checker = runpy.run_path(str(SOURCE / "Scripts/verify-release"))


class ArchiveDocumentTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="apple-cli-archive-fixture-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.source = self.root / "source"
        self.source.mkdir()
        self.output = self.root / "artifacts"
        self.output.mkdir()
        self.package_name = "apple-cli-0.1.0-alpha.1-macos-arm64"
        self.package = self.root / self.package_name
        self.package.mkdir()
        for name in [
            "LICENSE", "THIRD_PARTY_NOTICES.md", "Documentation/Reference/ReleaseGuide.md",
            "Documentation/Architecture/VersioningAndRelease.md",
        ]:
            for destination in [self.source, self.package]:
                target = destination / name
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(SOURCE / name, target)
        licenses = "Documentation/Reference/ThirdPartyLicenses"
        for destination in [self.source, self.package]:
            shutil.copytree(SOURCE / licenses, destination / licenses)
            (destination / "CHANGELOG.md").write_text(
                "# Changelog\n\n## 0.1.0-alpha.1 — Unreleased\n\nSynthetic archive fixture.\n",
            )
        version = self.source / "Sources/Utility/CLIVersion.swift"
        version.parent.mkdir(parents=True)
        version.write_text('public enum CLIVersion {\n  public static let current = "0.1.0-alpha.1"\n}\n')
        (self.source / "Package.resolved").write_text('{"pins": [], "version": 3}\n')
        (self.package / "bin").mkdir()
        binaries = []
        for name in ["apple", "apple-cli-mcp"]:
            path = self.package / "bin" / name
            path.write_bytes(b"Synthetic executable bytes for document acceptance.\n")
            binaries.append({
                "path": "bin/" + name, "sha256": checker["digest"](path),
                "run_paths": ["@loader_path"], "dynamic_libraries": [],
            })
        self.git("init", "--quiet")
        self.git("add", ".")
        self.git(
            "-c", "user.name=Release Fixture", "-c", "user.email=fixture@example.invalid",
            "-c", "commit.gpgsign=false", "commit", "--quiet", "-m", "Synthetic archive source",
        )
        self.manifest = {
            "schema_version": 1, "repository": checker["REPOSITORY"],
            "version": "0.1.0-alpha.1", "tag": None, "architecture": "arm64",
            "source_commit": self.git("rev-parse", "HEAD"),
            "source_tree": self.git("rev-parse", "HEAD^{tree}"),
            "package_resolved_sha256": checker["digest"](self.source / "Package.resolved"),
            "validation": [
                {"check": name, "result": "passed", "log_sha256": "a" * 64}
                for name in sorted(checker["BUILD_CHECKS"])
            ],
            "binaries": binaries, "swift_runtime_libraries": [],
        }

    def git(self, *arguments):
        return subprocess.check_output(
            ["git", *arguments], cwd=self.source, text=True, stderr=subprocess.PIPE,
        ).strip()

    def archive(self):
        (self.package / "provenance.json").write_text(json.dumps(self.manifest))
        archive = self.output / (self.package_name + ".tar.gz")
        with tarfile.open(archive, "w:gz") as output:
            output.add(self.package, arcname=self.package_name)
        digest = checker["digest"](archive)
        manifest = dict(self.manifest, archive={"filename": archive.name, "sha256": digest})
        (self.output / (self.package_name + ".provenance.json")).write_text(json.dumps(manifest))
        (self.output / (archive.name + ".sha256")).write_text(f"{digest}  {archive.name}\n")

    def test_accepts_self_contained_release_and_version_guides(self):
        self.archive()
        accepted = checker["verify"](self.output, self.source)
        self.assertEqual(accepted[0]["version"], "0.1.0-alpha.1")

    def test_requires_version_policy_in_the_archive(self):
        (self.package / "Documentation/Architecture/VersioningAndRelease.md").unlink()
        self.archive()
        with self.assertRaises(FileNotFoundError):
            checker["verify"](self.output, self.source)

    def test_rejects_version_policy_drift_from_source(self):
        policy = self.package / "Documentation/Architecture/VersioningAndRelease.md"
        policy.write_text(policy.read_text() + "\nDifferent archived rule.\n")
        self.archive()
        with self.assertRaisesRegex(ValueError, "Source input mismatch"):
            checker["verify"](self.output, self.source)
