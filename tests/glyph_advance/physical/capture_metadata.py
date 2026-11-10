#!/usr/bin/env python3
import datetime, hashlib, json, pathlib, sys
args=sys.argv[1:]
d=pathlib.Path(args[0])
h=lambda p: hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
record=dict(schema='glyph-advance-real-capture-v1',profile=args[1],host=args[2],host_version=pathlib.Path(args[3]).read_text(),
 source_commit=args[9],fixture_commit=args[10],fixture_source_sha256=args[11],fixture_binary_sha256=args[12],harness_sha256=args[13],
 scene=args[8],scenario=args[7],x11_before=pathlib.Path(args[4]).read_text(),x11_after=pathlib.Path(args[5]).read_text(),
 inner_tty=(d/'inner-tty.txt').read_text(),outer_tty=(d/'outer-tty.txt').read_text(),
 captured_at_utc_by_stage={n:(d/f'example-{n}-captured-at-utc.txt').read_text().strip() for n in ['initial','green','red','resized','resized-green']},
 events=['initial','t','t','actual resize','t','q'],metadata_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
 physical_scope='Original X11 captures and actual product bytes; use replay.py for full DSR and pixel-row4 oracle. No logical grid parser establishes physical PASS.')
(d/'metadata.json').write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n')
