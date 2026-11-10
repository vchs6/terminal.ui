#!/usr/bin/env python3
"""Physical acceptance uses original host pixels and complete DSR, no width model.

The old source must fail --expect preserved. --self-test validates the fixture
oracle using independently captured one-variable controls, not a product fix.
"""
import argparse, hashlib, json, pathlib, re, sys
from PIL import Image, ImageChops

HOSTS = {'xterm-default': (2, 59, 1002, 78), 'xfce-vte': (1, 85, 1001, 104)}

def row_box(size, box):
    # Frozen real-host window chrome; resize changes the number of 10px columns.
    base_width = 1004 if box[0] == 2 else 1017
    assert (size[0] - base_width) % 10 == 0, "unsupported capture cell geometry"
    return (box[0], box[1], box[2] + size[0] - base_width, box[3])

def image_equal(a, b, box):
    with Image.open(a) as ia, Image.open(b) as ib:
        assert ia.size == ib.size, 'capture geometry differs'
        actual_box = row_box(ia.size, box)
        return ImageChops.difference(ia.convert('RGB').crop(actual_box), ib.convert('RGB').crop(actual_box)).getbbox() is None

def positions(directory):
    records = [json.loads(line) for line in (directory/'dsr.jsonl').read_text().splitlines()]
    raw = (directory/'input.bin').read_bytes()
    output = (directory/'output.bin').read_bytes()
    offset = 0
    for record in records:
        response = bytes.fromhex(record['raw_hex'])
        assert record['matched_full_csi'] and re.fullmatch(rb'\x1b\[[0-9]+;[0-9]+R', response), 'incomplete DSR'
        expected = f"\x1b[{record['row']};{record['col']}R".encode()
        assert response == expected, 'DSR coordinate metadata differs from raw'
        assert raw[offset:record['input_end_offset']] == response, 'raw DSR offsets differ'
        assert output[record['output_end_offset']-4:record['output_end_offset']] == b'\x1b[6n', 'query offset differs'
        offset = record['input_end_offset']
    assert offset == len(raw), 'unaccounted native input'
    return records, {r['name']: (r['row'], r['col']) for r in records}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--fixtures', type=pathlib.Path, required=True)
    parser.add_argument('--expect', choices=['preserved'], default='preserved')
    parser.add_argument('--self-test', action='store_true')
    args = parser.parse_args()
    fixtures = args.fixtures
    provenance = json.loads((fixtures/'origins.json').read_text())
    for entry in provenance['entries']:
        assert hashlib.sha256((fixtures/entry['path']).read_bytes()).hexdigest() == entry['sha256'], 'fixture altered: '+entry['path']
    observations = []; controls = []; total_dsr = 0
    for host, box in HOSTS.items():
        d = fixtures/'native'/host
        records, pos = positions(d); total_dsr += len(records)
        assert len(records) == 58
        meta = json.loads((d/'metadata.json').read_text())
        assert meta['host_exit'] == 0 and (d/'exit.txt').read_text() == '0\n'
        events = (d/'events.txt').read_text().splitlines()
        assert events[0].split(' utc=')[0].split('termios=')[1] == events[-1].split(' utc=')[0].split('termios=')[1], 'termios not restored'
        for variant in ['original-0', 'original-1', 'replace_zwj_cjk-0', 'remove_zwj_only-0', 'padding_minus2-0']:
            for color in ['green', 'red']:
                name = variant+'-'+color
                same = image_equal(d/(variant+'-initial.png'), d/(name+'.png'), box)
                physical_position = pos[name]
                accepted = same and physical_position == (3, 100)
                item = dict(host=host, name=name, row4_box=box, row4_pixels_unchanged=same,
                            actual_dsr=physical_position, expected_dsr=[3,100], accepted=accepted)
                (observations if variant.startswith('original') else controls).append(item)
        # Opposite error: suffix after logical width2 VS16 must occupy col3 and
        # leave cursor at col4. This raw physical probe left cursor at col3.
        observations.append(dict(host=host, name='vs16_suffix', actual_dsr=pos['vs16_suffix'],
                                 expected_dsr=[15,4], accepted=pos['vs16_suffix'] == (15,4)))
        old = fixtures/'original083'/host
        oldmeta = json.loads((old/'metadata.json').read_text())
        assert oldmeta['source_commit'] == provenance['source_commit']
        assert oldmeta['fixture_source_sha256'] == 'dff0d2bca92115d1d2c2f1d9c8412e2cb94d95844ec33c5af6037144437fb8b3'
        assert oldmeta['expected_policy']['events'] == ['initial','t:Green','t:Red','resize','t:Green','q']
        for stage in ['green','red','resized-green']:
            before = 'resized' if stage == 'resized-green' else 'initial'
            # Same row4 cell origins remain after resize. Original PNGs are read,
            # never resampled, painted, OCR-reconstructed or written back.
            same = image_equal(old/f'example-{before}.png', old/f'example-{stage}.png', box)
            observations.append(dict(host=host, name='original083-'+stage, row4_pixels_unchanged=same, accepted=same))
    if args.self_test:
        assert all(not o['accepted'] for o in observations), 'old physical RED disappeared'
        assert all(c['accepted'] == (not c['name'].startswith('remove_zwj_only')) for c in controls), 'causal controls failed'
        print(json.dumps(dict(status='fixture_controls_pass', complete_dsr=total_dsr,
                              original_failures=len(observations), controls=controls,
                              observations=observations), indent=2))
        return 0
    failed = [o for o in observations if not o['accepted']]
    print(json.dumps(dict(status='FAIL' if failed else 'PASS', complete_dsr=total_dsr,
                          physical_cases=len(observations), failures=failed), indent=2))
    return 1 if failed else 0

if __name__ == '__main__':
    sys.exit(main())
