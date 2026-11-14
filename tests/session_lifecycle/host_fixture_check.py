"""Validate frozen host oracle using explicitly synthetic protocol metadata.

These are oracle fixtures layered on referenced author PTY artifacts, never
actual-host evidence. Original raw files stay untouched and are symlinked.
"""
import sys
sys.dont_write_bytecode = True
import argparse
import json
import pathlib
import tempfile
from host_verify import verify


def check(evidence, output):
    checked = []
    for case, cursor in [('stop', 'visible'), ('callback-close', 'hidden'),
                         ('stop', 'unknown'), ('initial-getter', 'visible'),
                         ('initial-draw', 'unknown')]:
        actual = evidence / (case + '-' + cursor)
        with tempfile.TemporaryDirectory(prefix='host-oracle-fixture-', dir=output.parent) as directory:
            out = pathlib.Path(directory)
            for path in actual.iterdir():
                if path.is_file(): (out / path.name).symlink_to(path.resolve())
            value = {'visible': 'set', 'hidden': 'reset', 'unknown': 'unknown'}[cursor]
            reply = {'visible': b'\x1b[?25;1$y', 'hidden': b'\x1b[?25;2$y', 'unknown': b''}[cursor]
            observations = {'25': {'state': value, 'responseHex': reply.hex()},
                            '2004': {'state': 'unknown', 'responseHex': ''}}
            (out / 'host-before.json').write_text(json.dumps({'observations': observations, 'SYNTHETIC': True}))
            (out / 'host-after.json').write_text(json.dumps({'observations': observations, 'SYNTHETIC': True}))
            if not (out / 'session-policy').exists(): (out / 'session-policy').write_text('DeclaredSupported-title-stress')
            (out / 'direct.exit').write_text('0\n'); (out / 'input.bin').write_bytes(reply * 2)
            verify(out, case)
            if not case.startswith('initial-'):
                wire = out / 'wire.bin'; raw = wire.read_bytes(); wire.unlink()
                host_auto = (out / 'session-policy').read_text() == 'Auto/NoTitleRequest'
                wire.write_bytes(raw + b'\x1b[23;2t' if host_auto else raw.replace(b'\x1b[23;2t', b'', 1))
                try: verify(out, case)
                except AssertionError: pass
                else: raise AssertionError('missing title pop must fail host oracle')
            checked.append(case + '-' + cursor)
    output.write_text(json.dumps({'passed': True, 'fixtures': checked,
        'scope': 'SYNTHETIC host protocol metadata + symlinked author PTY outputs; zero actual host runs',
        'negative': 'Auto unexpected title pop / declared missing owned pop rejected'}) + '\n')


if __name__ == '__main__':
    p = argparse.ArgumentParser(); p.add_argument('--pty-evidence', type=pathlib.Path, required=True)
    p.add_argument('--output', type=pathlib.Path, required=True); a = p.parse_args(); check(a.pty_evidence.resolve(), a.output.resolve())
