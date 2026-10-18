"""Public content scanning against synthetic repositories."""

from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[2]


class PublicContentTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="apple-cli-public-content-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name) / "repository"
        self.outside = Path(temporary.name) / "artifacts"
        self.outside.mkdir()
        script = self.root / "Scripts/validate-public-content"
        script.parent.mkdir(parents=True)
        shutil.copy2(SOURCE / "Scripts/validate-public-content", script)
        self.write("README.md", "[Guide](Documentation/Guide.md)\n")
        self.write("Documentation/Guide.md", "Run `apple --help`.\n")
        subprocess.run(["git", "init", "--quiet"], cwd=self.root, check=True)

    def write(self, name, text):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def scan(self, *arguments):
        return subprocess.run(
            ["swift", str(self.root / "Scripts/validate-public-content"), *arguments],
            cwd=self.root, capture_output=True, text=True, timeout=600,
        )

    def test_clean_tree_with_test_fixture_paths_passes(self):
        self.write("Tests/Fixtures/identity.json", '{"home": "/Users/example/"}\n')
        result = self.scan()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Validated 2 Markdown files", result.stdout)

    def test_reports_every_finding(self):
        # Assembled at runtime so this file does not match the credential scan.
        token = "gh" + "p_" + "A" * 36
        self.write("Documentation/Setup.md", "Run from /Users/jane/project.\n\n[Missing](Missing.md)\n")
        self.write("Scripts/configure", "TOKEN=" + token + "\n")
        self.write("Sources/Version.swift", 'let version = "0.0.0-dev"\n')
        artifact = self.outside / "release-notes.txt"
        artifact.write_text("Built in /Users/jane/build.\n")
        result = self.scan("--artifact", str(artifact))
        self.assertEqual(result.returncode, 1)
        self.assertEqual(result.stderr.splitlines(), [
            "Documentation/Setup.md: machine-local absolute path",
            "Documentation/Setup.md: missing local link Missing.md",
            "Scripts/configure: credential pattern requires review",
            "Sources/Version.swift: development version bypasses the canonical version",
            "release-notes.txt: release artifact contains a machine-local path",
        ])


if __name__ == "__main__":
    unittest.main()
