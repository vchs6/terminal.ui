#!/usr/bin/env python3
"""Tool-only wire-oracle mutations; never a product or native PTY pass."""
import importlib.util
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("composite_pty_driver", Path(__file__).with_name("pty.py"))
driver = importlib.util.module_from_spec(spec)
spec.loader.exec_module(driver)
check = driver.assert_unanswered_probe_modes
ENABLE = b"\x1b[?2004h"
DISABLE = b"\x1b[?2004l"
QUERY = b"\x1b[?25$p"
RAW = ENABLE + QUERY + b"M_WIDGETS_READY" + DISABLE
SENT = b"\x1b[C#\r \x1b[200~ \x1b[201~\x1b#q"


class UnansweredModeOracleTests(unittest.TestCase):
    def test_hand_authored_positive(self):
        observed = check(RAW, SENT)
        self.assertEqual(observed["query_count"], 1)
        self.assertEqual(observed["valid_input_reports"], 0)
        self.assertEqual(observed["mode25_hlsr"], [0, 0, 0, 0])
        self.assertEqual(observed["alternate1049_hl"], [0, 0])
        self.assertEqual(observed["paste2004_hl"], [1, 1])

    def test_query_missing_repeated_or_nonexact_is_rejected(self):
        for raw in [RAW.replace(QUERY, b""), RAW + QUERY,
                    RAW.replace(QUERY, b"\x1b[?025$p"), RAW + b"\x1b[?25;2004$p"]:
            with self.subTest(raw=raw), self.assertRaises(AssertionError):
                check(raw, SENT)

    def test_every_mode25_transition_and_save_restore_is_rejected(self):
        for action in [b"h", b"l", b"s", b"r"]:
            with self.subTest(action=action), self.assertRaises(AssertionError):
                check(RAW + b"\x1b[?25" + action, SENT)
        for extra in [b"\x1b[?025h", b"\x1b[?2004;25h"]:
            with self.subTest(extra=extra), self.assertRaises(AssertionError):
                check(RAW + extra, SENT)

    def test_alternate_screen_entry_and_exit_are_rejected(self):
        for action in [b"h", b"l"]:
            with self.subTest(action=action), self.assertRaises(AssertionError):
                check(RAW + b"\x1b[?1049" + action, SENT)

    def test_injected_protocol_report_breaks_no_reply_fixture(self):
        for status in [b"0", b"1", b"2", b"3", b"4"]:
            with self.subTest(status=status), self.assertRaises(AssertionError):
                check(RAW, SENT + b"\x1b[?25;" + status + b"$y")

    def test_paste_pair_count_and_order_remain_strict(self):
        for raw in [RAW.replace(ENABLE, b""), RAW.replace(DISABLE, b""),
                    RAW + ENABLE, RAW + DISABLE, DISABLE + QUERY + ENABLE,
                    RAW + b"\x1b[?2004;999h"]:
            with self.subTest(raw=raw), self.assertRaises(AssertionError):
                check(raw, SENT)


if __name__ == "__main__":
    unittest.main()
