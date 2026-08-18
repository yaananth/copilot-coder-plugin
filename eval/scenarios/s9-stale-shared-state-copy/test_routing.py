import unittest

from routing import Router


class RouterTests(unittest.TestCase):
    def test_runtime_target_replaces_route(self):
        router = Router(["central", "east-2", "east"])
        router.set_target(1, "east")
        self.assertEqual("east", router.route(1))


if __name__ == "__main__":
    unittest.main()
