#!/usr/bin/env python3
"""Acceptance for a fresh external replay of actual captured product bytes."""
import argparse, json, pathlib, sys
from oracle import HOSTS, image_equal, positions

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--replay', type=pathlib.Path, required=True)
    parser.add_argument('--kind', choices=['zwj','vs16'], required=True)
    args = parser.parse_args()
    expected_prefix = (3,12) if args.kind == 'zwj' else (3,3)
    observations = []
    for host, box in HOSTS.items():
        d=args.replay/'raw'/host
        records, pos=positions(d)
        assert len(records)==5 and (d/'exit.txt').read_text()=='0\n'
        meta=json.loads((d/'metadata.json').read_text())
        assert meta['host_exit']==0
        events=(d/'events.txt').read_text().splitlines()
        assert events[0].split(' utc=')[0].split('termios=')[1] == events[-1].split(' utc=')[0].split('termios=')[1]
        for stage in ['green','red']:
            same=image_equal(d/'initial.png',d/(stage+'.png'),box)
            observations.append(dict(host=host,stage=stage,row4_pixels_unchanged=same,
                prefix_dsr=pos[stage+'-prefix'],expected_prefix_dsr=expected_prefix,
                final_dsr=pos[stage],expected_final_dsr=[3,100],
                accepted=same and pos[stage+'-prefix']==expected_prefix and pos[stage]==(3,100)))
    failed=[o for o in observations if not o['accepted']]
    print(json.dumps(dict(status='FAIL' if failed else 'PASS',observations=observations),indent=2))
    return 1 if failed else 0

if __name__=='__main__':sys.exit(main())
