import importlib.machinery
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from urllib.parse import parse_qs, urlsplit


ROOT = Path(__file__).resolve().parents[2]
LOADER = importlib.machinery.SourceFileLoader("release_publication", str(ROOT / ".github/scripts/publish-release"))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
publisher = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(publisher)


class ReleaseLookupTests(unittest.TestCase):
    def find(self, pages, tag="v1.0.0"):
        with patch.object(publisher, "gh", return_value=json.dumps(pages)) as call:
            result = publisher.find_release("computer-mcp/apple-cli", tag)
        self.assertIn("--paginate", call.call_args.args)
        self.assertIn("--slurp", call.call_args.args)
        return result

    def test_draft_is_found_by_its_release_identity(self):
        draft = {"id": 42, "tag_name": "v1.0.0", "draft": True}
        self.assertEqual(self.find([[draft]]), draft)

    def test_published_release_is_retained(self):
        published = {"id": 42, "tag_name": "v1.0.0", "draft": False}
        self.assertEqual(self.find([[published]]), published)

    def test_paginated_draft_is_found(self):
        other = {"id": 1, "tag_name": "v2.0.0", "draft": False}
        draft = {"id": 42, "tag_name": "v1.0.0", "draft": True}
        self.assertEqual(self.find([[other], [draft]]), draft)

    def test_different_tag_and_missing_release_do_not_match(self):
        self.assertIsNone(self.find([[{"id": 1, "tag_name": "v1.0.1", "draft": True}]]))
        self.assertIsNone(self.find([[]]))

    def test_ambiguous_tag_is_rejected(self):
        duplicate = {"id": 42, "tag_name": "v1.0.0", "draft": True}
        with self.assertRaises(ValueError):
            self.find([[duplicate], [duplicate]])


class PublicationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        root = Path(self.temporary.name)
        self.files = {}
        for name in ("archive.tar.gz", "archive.tar.gz.sha256", "archive.provenance.json", "archive.verification.json"):
            path = root / name
            path.write_bytes(name.encode())
            self.files[name] = path
        self.repository = "computer-mcp/apple-cli"
        self.tag = "v0.1.0-alpha.1"
        self.manifest = {"version": self.tag[1:], "source_commit": "a" * 40}
        self.release = {"id": 42, "tag_name": self.tag, "draft": True, "prerelease": True, "assets": [],
                        "upload_url": f"https://uploads.github.com/repos/{self.repository}/releases/42/assets{{?name,label}}"}
        self.uploads = []
        self.writes = []
        self.tag_checks = self.enterContext(patch.object(publisher, "require_remote_tag"))
        self.enterContext(patch.object(publisher, "release_notes", return_value="Release notes\nSecond line"))
        self.enterContext(patch.object(publisher, "gh", side_effect=self.upload))
        self.enterContext(patch.object(publisher, "api", side_effect=self.request))

    def asset(self, name):
        path = self.files[name]
        return {"name": name, "state": "uploaded", "size": path.stat().st_size, "digest": "sha256:" + publisher.digest(path)}

    def upload(self, *arguments, **kwargs):
        name = parse_qs(urlsplit(arguments[-1]).query)["name"][0]
        self.assertEqual(Path(arguments[-2]), self.files[name])
        self.assertEqual(urlsplit(arguments[-1]).path, f"/repos/{self.repository}/releases/42/assets")
        self.uploads.append(name)
        self.release["assets"].append(self.asset(name))
        return json.dumps(self.release["assets"][-1])

    def request(self, endpoint, method="GET", payload=None):
        if method == "POST":
            self.assertEqual(endpoint, f"repos/{self.repository}/releases")
            self.assertTrue(payload["draft"])
            self.assertTrue(payload["prerelease"])
            self.assertEqual(payload["make_latest"], "false")
            self.assertEqual(payload["tag_name"], self.tag)
            self.assertEqual(payload["target_commitish"], self.manifest["source_commit"])
        else:
            self.assertEqual(endpoint, f"repos/{self.repository}/releases/42")
        if method != "GET":
            self.writes.append((method, payload))
        if method == "PATCH":
            self.release["draft"] = payload["draft"]
        return json.loads(json.dumps(self.release))

    def publish(self, existing):
        # An immediately repeated list query is not allowed to discover the
        # newly created draft. Uploads must use the creation response instead.
        with patch.object(publisher, "find_release", side_effect=[existing]) as lookup:
            publisher.publish_files(self.repository, self.tag, self.manifest, {}, self.files)
        self.assertEqual(lookup.call_count, 1)

    def test_new_draft_uses_creation_identity_without_rediscovery(self):
        self.publish(None)
        self.assertEqual(set(self.uploads), set(self.files))
        self.assertEqual([method for method, _ in self.writes], ["POST", "PATCH"])
        self.assertFalse(self.release["draft"])
        self.assertEqual(self.tag_checks.call_count, 2)

    def test_partial_draft_only_uploads_missing_accepted_files(self):
        present = next(iter(self.files))
        self.release["assets"] = [self.asset(present)]
        self.publish(json.loads(json.dumps(self.release)))
        self.assertEqual(set(self.uploads), set(self.files) - {present})
        self.assertEqual([method for method, _ in self.writes], ["PATCH"])

    def test_matching_published_release_is_read_only(self):
        self.release["draft"] = False
        self.release["assets"] = [self.asset(name) for name in self.files]
        self.publish(self.release)
        self.assertEqual(self.uploads, [])
        self.assertEqual(self.writes, [])

    def test_published_preview_cannot_have_stable_status(self):
        self.release["draft"] = False
        self.release["prerelease"] = False
        self.release["assets"] = [self.asset(name) for name in self.files]
        with self.assertRaisesRegex(ValueError, "preview status mismatch"):
            self.publish(self.release)
        self.assertEqual(self.uploads, [])
        self.assertEqual(self.writes, [])

    def test_changed_existing_asset_keeps_draft_unpublished(self):
        changed = self.asset(next(iter(self.files)))
        changed["digest"] = "sha256:" + "0" * 64
        self.release["assets"] = [changed]
        with self.assertRaisesRegex(ValueError, "differs from the accepted bytes"):
            self.publish(self.release)
        self.assertEqual(self.uploads, [])
        self.assertEqual(self.writes, [])
        self.assertTrue(self.release["draft"])

    def test_upload_endpoint_must_belong_to_the_release(self):
        self.release["upload_url"] = f"https://uploads.github.com/repos/{self.repository}/releases/43/assets{{?name,label}}"
        with self.assertRaisesRegex(ValueError, "Unexpected release upload endpoint"):
            self.publish(self.release)
        self.assertEqual(self.uploads, [])
        self.assertEqual(self.writes, [])

    def test_incomplete_uploads_cannot_be_published(self):
        with patch.object(publisher, "gh", return_value="{}"):
            with self.assertRaisesRegex(ValueError, "Release assets are incomplete"):
                self.publish(self.release)
        self.assertEqual(self.writes, [])
        self.assertTrue(self.release["draft"])
