"""Source skill metadata stays loadable by strict YAML skill loaders."""

from pathlib import Path
import unittest


SOURCE = Path(__file__).resolve().parents[2]
PLAIN_SCALAR_START = set("!&*[]{}|>'\"%@`#,?:-")


def frontmatter(path):
    lines = path.read_text().split("\n")
    if lines[0] != "---" or "---" not in lines[1:]:
        raise AssertionError(f"{path}: missing frontmatter")
    return lines[1:lines.index("---", 1)]


class SkillMetadataTests(unittest.TestCase):
    def test_source_skill_frontmatter_is_valid(self):
        skills = sorted((SOURCE / "skills").glob("*/SKILL.md"))
        self.assertTrue(skills)
        for path in skills:
            fields = {}
            for line in frontmatter(path):
                key, separator, value = line.partition(": ")
                self.assertTrue(separator and key.isidentifier(), f"{path}: {line}")
                fields[key] = value
                if value[:1] == '"':
                    self.assertTrue(len(value) > 1 and value.endswith('"'), f"{path}: {key}")
                else:
                    self.assertNotIn(value[:1], PLAIN_SCALAR_START, f"{path}: {key}")
                    self.assertNotIn(": ", value, f"{path}: quote {key}")
                    self.assertNotIn(" #", value, f"{path}: quote {key}")
            self.assertEqual(fields.get("name"), path.parent.name)
            self.assertTrue(fields.get("description"))


if __name__ == "__main__":
    unittest.main()
