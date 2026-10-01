import importlib.machinery
import importlib.util
import json
from pathlib import Path
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
LOADER = importlib.machinery.SourceFileLoader("release_publication", str(ROOT / ".github/scripts/publish-release"))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
publisher = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(publisher)


class ReleaseLookupTests(unittest.TestCase):
    def find(self, pages, tag="v1.0.0"):
        with patch.object(publisher, "gh", return_value=json.dumps(pages)) as call:
            result = publisher.find_release("computer-mcp/apple-cli", tag)
        self.assertEqual(call.call_args.args, ("api", "--paginate", "--slurp", "repos/computer-mcp/apple-cli/releases?per_page=100"))
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
