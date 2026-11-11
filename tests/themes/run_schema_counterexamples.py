#!/usr/bin/env python3
"""Run exact official public assertion sources in an isolated ordinary consumer."""
import argparse,datetime,hashlib,json,shutil,subprocess,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
SOURCES=['checks.cj','schema_counterexample_checks.cj','schema_source_types.cj','schema_printable_name.cj','schema_source_order.cj']

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--logs',type=Path,required=True)
    options=parser.parse_args();logs=options.logs.resolve();logs.mkdir(parents=True,exist_ok=True)
    project=HERE/'.negative-run/schema-public'
    (project/'src').mkdir(parents=True,exist_ok=True)
    manifest=(HERE/'values/cjpm.toml').read_text().replace('../../..','../../../..')
    (project/'cjpm.toml').write_text(manifest)
    for name in SOURCES: shutil.copy2(HERE/'values/src'/name,project/'src'/name)
    shutil.copy2(HERE/'schema_counterexample_main.cj.txt',project/'src/main.cj')
    config=HERE/'values/cangjie-repo.toml'
    if config.exists():shutil.copy2(config,project/config.name)
    hashes={str(p.relative_to(HERE)):hashlib.sha256(p.read_bytes()).hexdigest() for p in
            [HERE/'values/src'/name for name in SOURCES]+[HERE/'schema_counterexample_main.cj.txt',HERE/'run_schema_counterexamples.py',HERE/'values/cjpm.toml']}
    (logs/'source-hashes.json').write_text(json.dumps(hashes,indent=2)+'\n')
    sha=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
    def run(name,command,cwd):
        utc=datetime.datetime.now(datetime.timezone.utc).isoformat()
        result=subprocess.run(command,cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        (logs/(name+'.stdout')).write_bytes(result.stdout);(logs/(name+'.stderr')).write_bytes(result.stderr)
        with (logs/'commands.jsonl').open('a') as stream:stream.write(json.dumps(dict(name=name,utc=utc,command=command,cwd=str(cwd),sha=sha,exit=result.returncode))+'\n')
        print(name+': exit '+str(result.returncode),flush=True)
        return result.returncode
    built=run('public-build',['cjpm','build'],project)
    if built:return built
    binary=str(project/'target/release/bin/main')
    positive=run('public-positive',[binary,'positive'],project)
    if positive:return positive
    exits=[run(group,[binary,group],project) for group in ['source-types','printable-name','source-order']]
    return 1 if any(exits) else 0
if __name__=='__main__':raise SystemExit(main())
