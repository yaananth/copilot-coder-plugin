import unittest

from legacy import legacy_display_name


class LegacyDisplayNameTests(unittest.TestCase):
    def test_preserves_existing_title_case_contract(self):
        self.assertEqual("Legacy Name", legacy_display_name("legacy name"))


if __name__ == "__main__":
    unittest.main()
