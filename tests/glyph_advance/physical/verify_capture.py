#!/usr/bin/env python3
"""Check actual capture restoration, untouched rows and literal public payload.

Suffix placement is checked separately by verify_replay.py using actual DSR.
No terminal/grid/width simulation is used here.
"""
import argparse, json, pathlib, re, sys
from PIL import Image, ImageChops
from oracle import HOSTS, row_box

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--captures',type=pathlib.Path,required=True)
    parser.add_argument('--kind',choices=['zwj','vs16'],required=True)
    args=parser.parse_args();observations=[]
    for host,box in HOSTS.items():
        d=args.captures/host/'q'
        meta=json.loads((d/'metadata.json').read_text())
        for name in ['inner-tty.txt','outer-tty.txt']:
            text=(d/name).read_text()
            assert re.search(r'^exit_status=0$',text,re.M)
            before=re.search(r'^ready_termios=(.+)$',text,re.M).group(1)
            after=re.search(r'^exit_termios=(.+)$',text,re.M).group(1)
            assert before==after,'termios not restored'
        assert (d/'host-wait-status.txt').read_text()=='0\n'
        assert (d/'process-reaping.txt').is_file()
        for stage in ['green','red','resized-green']:
            initial='resized' if stage=='resized-green' else 'initial'
            with Image.open(d/f'example-{initial}.png') as a, Image.open(d/f'example-{stage}.png') as b:
                assert a.size==b.size
                actual_box=row_box(a.size,box)
                same=ImageChops.difference(a.convert('RGB').crop(actual_box),b.convert('RGB').crop(actual_box)).getbbox() is None
            raw=(d/f'example-{stage}.raw').read_bytes()
            # The public VS16 fixture deliberately has no ZWJ on row3; its
            # physical failure cannot cancel the opposite-sign ZWJ error.
            expected_payload=b'??' in raw
            forbidden=('👩\u200d💻'.encode() in raw) if args.kind=='zwj' else any(v.encode() in raw for v in ['❤️','☀️','1️⃣'])
            rows=[int(r) for r in re.findall(rb'\x1b\[([0-9]+);[0-9]+H',raw)]
            observations.append(dict(host=host,stage=stage,row4_pixels_unchanged=same,only_cup_rows=rows,
                literal_fallback_present=expected_payload,unsafe_sequence_present=forbidden,
                accepted=same and expected_payload and not forbidden and set(rows)=={3}))
        if args.kind=='vs16':
            initial=(d/'example-initial.raw').read_bytes()
            for original in ['A','界','e\u0301','👩','💻','🇨🇳']:
                assert original.encode() in initial,'preserved public Unicode missing: '+original
    failed=[o for o in observations if not o['accepted']]
    print(json.dumps(dict(status='FAIL' if failed else 'PASS',observations=observations),indent=2))
    return 1 if failed else 0

if __name__=='__main__':sys.exit(main())
