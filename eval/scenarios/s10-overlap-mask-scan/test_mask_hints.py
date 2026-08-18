import unittest

from feature_client import FeatureClient
from mask_hints import (
    BROAD_PATTERN,
    LEGACY_PATTERN,
    NARROW_PATTERN,
    build_mask_hints,
)
from pipeline import redact_assignment_output
from request_handler import AssignmentRequest, Claims, build_assignment


class PrimaryFeatures:
    def __init__(self, enabled):
        self.enabled = enabled
        self.calls = []

    def is_enabled(self, feature, actor):
        self.calls.append((feature, actor))
        return (feature, actor) in self.enabled


class MaskHintTests(unittest.TestCase):
    def test_static_flag_combinations(self):
        cases = (
            (False, False, [LEGACY_PATTERN]),
            (True, False, [LEGACY_PATTERN, NARROW_PATTERN]),
            (False, True, [LEGACY_PATTERN, BROAD_PATTERN]),
            (True, True, [LEGACY_PATTERN, BROAD_PATTERN]),
        )
        for narrow, broad, expected in cases:
            with self.subTest(narrow=narrow, broad=broad):
                self.assertEqual(
                    expected,
                    [hint.pattern for hint in build_mask_hints(narrow, broad)],
                )

    def test_request_owner_uses_live_lookup_on_preload_miss(self):
        owner = "workspace:42"
        primary = PrimaryFeatures({("mask_variable_access_ids", owner)})
        features = FeatureClient(primary)
        response = build_assignment(
            AssignmentRequest(owner),
            Claims("workspace:7", "account:1"),
            features,
            {},
        )
        self.assertEqual(
            [LEGACY_PATTERN, NARROW_PATTERN],
            [hint.pattern for hint in response.masks],
        )
        self.assertEqual(2, len(primary.calls))

    def test_assignment_output_is_masked(self):
        response = type(
            "Response",
            (),
            {"masks": build_mask_hints(True, False)},
        )()
        self.assertEqual(
            "token=***",
            redact_assignment_output(response, "token=ac_" + "z" * 20),
        )

    def test_identifier_concatenated_with_log_key_is_masked(self):
        response = type(
            "Response",
            (),
            {"masks": build_mask_hints(True, False)},
        )()
        self.assertEqual(
            "trace***",
            redact_assignment_output(response, "traceac_" + "z" * 20),
        )

    def test_opaque_identifier_body_has_no_fixed_maximum(self):
        response = type(
            "Response",
            (),
            {"masks": build_mask_hints(True, False)},
        )()
        body = ("segment_1." * 40) + "tail-value"
        self.assertEqual(
            "id=*** done",
            redact_assignment_output(response, "id=ac_" + body + " done"),
        )


if __name__ == "__main__":
    unittest.main()
