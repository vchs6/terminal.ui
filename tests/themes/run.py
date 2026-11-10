#!/usr/bin/env python3
"""Run real public consumers and gated compile-failure contracts, preserving exits."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
from generate_inputs import generate

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
FIXTURES = {
    'dark.toml': '1a6feada861eefb42e9d6598138c2010d7f1e34b65ecece893b66e680d5cb8d0',
    'light.toml': '677951bafdc3d9d0dce62031ebe63f44254e0a5c13bfc05d079b5ef087176bcd',
    'high-contrast.toml': 'e933cb0c54ef211c41c2b6cc83c16dc5eb091151e706dfbf439eddec8d48166c',
    'classic.toml': '73491254d0fc5b7624677b9b40216d3c82664c7c4784964b384b6a9d55a4aac9',
}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('mode', choices=['values', 'integration', 'negative', 'all'], nargs='?', default='all')
    parser.add_argument('--logs', type=Path)
    options = parser.parse_args()
    logs = options.logs or Path(tempfile.mkdtemp(prefix='cjtui-theme-evidence-'))
    logs.mkdir(parents=True, exist_ok=True)
    sha = subprocess.check_output(['git','rev-parse','HEAD'], cwd=ROOT, text=True).strip()
    hashes = {str(p.relative_to(HERE)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in HERE.rglob('*') if p.is_file() and not any(x in p.parts for x in ['target','.scratch','.negative-run','__pycache__'])
              and p.name not in ['cangjie-repo.toml','cjpm.lock']}
    (logs/'source-hashes.json').write_text(json.dumps(hashes, indent=2)+'\n')
    for name, wanted in FIXTURES.items():
        actual = hashlib.sha256((HERE/'fixtures'/name).read_bytes()).hexdigest()
        if actual != wanted:
            raise RuntimeError(f'frozen fixture drift: {name}: {actual}')
    generate(HERE/'.scratch')
    generated = {str(p.relative_to(HERE/'.scratch')): hashlib.sha256(p.read_bytes()).hexdigest() for p in (HERE/'.scratch').rglob('*') if p.is_file()}
    (logs/'generated-input-hashes.json').write_text(json.dumps(generated, indent=2)+'\n')
    print(f'evidence: {logs}', flush=True)
    def run(name, command, cwd, negative=False):
        begin = datetime.datetime.now(datetime.timezone.utc).isoformat()
        result = subprocess.run(command, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (logs/f'{name}.stdout').write_bytes(result.stdout)
        (logs/f'{name}.stderr').write_bytes(result.stderr)
        record = dict(name=name, utc=begin, command=command, cwd=str(cwd), sha=sha,
                      exit=result.returncode, stdout=f'{name}.stdout', stderr=f'{name}.stderr')
        with (logs/'commands.jsonl').open('a') as f:
            f.write(json.dumps(record)+'\n')
        print(f'{name}: exit {result.returncode}', flush=True)
        if negative:
            # Compiler process must reach an actual type/access diagnostic. Missing
            # packages, syntax errors and missing SDK are not successful negatives.
            text = (result.stdout+result.stderr).decode(errors='replace')
            environmental = ['can not find the following dependencies', 'failed to update', 'get registry', 'command not found', 'expected a member name', 'unclosed delimiter']
            if result.returncode == 0 or 'error' not in text.lower() or any(x in text for x in environmental):
                raise RuntimeError(f'invalid compile-negative result: {name}; inspect raw evidence')
        elif result.returncode != 0:
            sys.stdout.buffer.write(result.stdout)
            sys.stderr.buffer.write(result.stderr)
            raise SystemExit(result.returncode)
    positive = ['values'] if options.mode == 'values' else ['integration'] if options.mode == 'integration' else ['values','integration']
    for group in positive:
        run(f'{group}-build', ['cjpm','build'], HERE/group)
        run(f'{group}-run', [str(HERE/group/'target/release/bin/main')], HERE/group)
    if options.mode in ['all','negative']:
        scratch = HERE/'.negative-run'
        scratch.mkdir(exist_ok=True)
        for fixture in sorted((HERE/'negative').glob('*.cj.txt')):
            project = scratch/fixture.stem.replace('.cj','')
            (project/'src').mkdir(parents=True,exist_ok=True)
            (project/'src/main.cj').write_bytes(fixture.read_bytes())
            manifest = (HERE/'integration/cjpm.toml').read_text().replace('theme_integration_contract','theme_negative').replace('../../..','../../../..')
            (project/'cjpm.toml').write_text(manifest)
            config = HERE/'integration/cangjie-repo.toml'
            if config.exists(): shutil.copy2(config,project/config.name)
            run(f'negative-{project.name}', ['cjpm','build'], project, negative=True)
    print('PASS selected TASK085 theme contracts',flush=True)

if __name__ == '__main__':
    main()
