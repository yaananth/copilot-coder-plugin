import unittest

from slug import normalize_slug


class NormalizeSlugTests(unittest.TestCase):
    def test_repeated_whitespace_collapses(self):
        self.assertEqual("hello-world", normalize_slug("  Hello   World  "))


if __name__ == "__main__":
    unittest.main()
