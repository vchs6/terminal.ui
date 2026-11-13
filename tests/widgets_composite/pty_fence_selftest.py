#!/usr/bin/env python3
"""Pause a tool-only file writer; exercise actual harness reader closures."""
import ast
import copy
import tempfile
import unittest
from pathlib import Path

DRIVER = Path(__file__).with_name("pty.py")


def reader_namespace(directory, writer, mutate_escape=False):
    run = next(node for node in ast.parse(DRIVER.read_text()).body
               if isinstance(node, ast.FunctionDef) and node.name == "run")
    functions = copy.deepcopy([node for node in run.body
                               if isinstance(node, ast.FunctionDef) and node.name in {"fence", "escape"}])
    if mutate_escape:
        escape = next(node for node in functions if node.name == "escape")
        predicate = next(node for node in ast.walk(escape) if isinstance(node, ast.Compare))
        predicate.ops = [ast.NotEq()]
        predicate.comparators = [ast.Name(id="old_count", ctx=ast.Load())]
    events, sent = [], []

    def text(name):
        path = directory / name
        return path.read_text() if path.exists() else ""

    def await_condition(predicate, _label):
        for boundary in writer:
            ready = predicate()
            events.append((boundary, ready))
            if ready:
                return
        raise AssertionError("completion fence never published")

    namespace = dict(text=text, send=sent.append, await_condition=await_condition,
                     focus_expected=["p"], escape_expected=[9], old_count="9")
    tree = ast.fix_missing_locations(ast.Module(body=functions, type_ignores=[]))
    exec(compile(tree, str(DRIVER), "exec"), namespace)
    return namespace, events, sent


def paused_writer(directory, fields):
    """Yield with the real file truncated, partly written, then complete."""
    for name, value in fields:
        with (directory / name).open("w") as stream:
            yield name + ":truncated"
            cut = len(value) // 2
            stream.write(value[:cut])
            stream.flush()
            yield name + ":partial"
            stream.write(value[cut:])
            stream.flush()
            yield name + ":complete"


class PublicationFenceTests(unittest.TestCase):
    def exercise_focus(self, marker_first=False):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            for name, value in [("focus", "p;"), ("open", "true"), ("reason", "Requested")]:
                (directory / name).write_text(value)
            fields = [("open", "false"), ("reason", "Escape"), ("focus", "p;c;")]
            if marker_first:
                fields = [fields[-1]] + fields[:-1]
            writer = paused_writer(directory, fields)
            try:
                reader, events, sent = reader_namespace(directory, writer)
                reader["fence"]("c")
                self.assertEqual(sent, [b"#"])
                self.assertEqual((directory / "open").read_text(), "false")
                self.assertEqual((directory / "reason").read_text(), "Escape")
                self.assertEqual(events[-1], ("focus:complete", True))
                self.assertTrue(all(not ready for _, ready in events[:-1]))
            finally:
                writer.close()

    def test_marker_last_blocks_at_every_partial_payload_boundary(self):
        self.exercise_focus()

    def test_marker_first_mutation_is_detected_as_early_payload_read(self):
        with self.assertRaises(AssertionError):
            self.exercise_focus(marker_first=True)

    def exercise_escape(self, mutant=False):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            (directory / "escape_seen").write_text("9")
            writer = paused_writer(directory, [("escape_seen", "10")])
            try:
                reader, events, sent = reader_namespace(directory, writer, mutate_escape=mutant)
                reader["escape"]()
                self.assertEqual(sent, [b"\x1b"])
                self.assertEqual((directory / "escape_seen").read_text(), "10")
                self.assertEqual(events, [("escape_seen:truncated", False),
                                          ("escape_seen:partial", False), ("escape_seen:complete", True)])
            finally:
                writer.close()

    def test_exact_next_counter_ignores_truncation_and_partial_digits(self):
        self.exercise_escape()

    def test_any_change_counter_mutation_is_detected(self):
        with self.assertRaises(AssertionError):
            self.exercise_escape(mutant=True)


if __name__ == "__main__":
    unittest.main()
