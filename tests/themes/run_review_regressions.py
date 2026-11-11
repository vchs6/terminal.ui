#!/usr/bin/env python3
"""Minimal review-L4 public consumers; never run the old suite or change product."""
import argparse,datetime,hashlib,json,shutil,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--logs',type=Path,required=True)
    logs=parser.parse_args().logs.resolve();logs.mkdir(parents=True,exist_ok=True)
    sha=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
    inputs={};results=[]
    def run(name,argv,cwd):
        utc=datetime.datetime.now(datetime.timezone.utc).isoformat()
        result=subprocess.run(argv,cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        (logs/(name+'.stdout')).write_bytes(result.stdout);(logs/(name+'.stderr')).write_bytes(result.stderr)
        with(logs/'commands.jsonl').open('a') as f:f.write(json.dumps(dict(name=name,argv=argv,cwd=str(cwd),utc=utc,sha=sha,exit=result.returncode))+'\n')
        print(name+': exit '+str(result.returncode),flush=True)
        return result.returncode
    for group,files,dispatch,cases in [
        ('values',['checks.cj','schema_counterexample_checks.cj','schema_review_regressions.cj'],
         'case "positive" => schemaPositiveControl()\ncase "priority" => schemaReviewPriorities()\ncase "variable-order" => schemaReviewVariableOrder()', ['priority','variable-order']),
        ('integration',['checks.cj','rejected_padding_mutation.cj'],
         'case "positive" => let app=Application(Text("X"));app.startHeadless();try { check(app.snapshot(3,3).cellAt(0,0).grapheme=="X","normal Application snapshot positive") } finally { app.dispose() }\ncase "binding" => rejectedPaddingMutations()', ['binding'])]:
        project=HERE/'.negative-run'/('review-'+group);(project/'src').mkdir(parents=True,exist_ok=True)
        (project/'cjpm.toml').write_text((HERE/group/'cjpm.toml').read_text().replace('../../..','../../../..'))
        for name in files:
            source=HERE/group/'src'/name;shutil.copy2(source,project/'src'/name)
            inputs[str(source.relative_to(HERE))]=hashlib.sha256(source.read_bytes()).hexdigest()
        config=HERE/group/'cangjie-repo.toml'
        if config.exists():shutil.copy2(config,project/config.name)
        body='package theme_'+group+'_contract\nimport std.process.Process\n'+('import cjtui.*\n' if group=='integration' else '')+'main():Int64 { try { match(Process.current.arguments[0]) {\n'+dispatch+'\ncase _ => throw Exception("unknown group")\n};return 0 } catch(e:Exception) { println("GROUP FAIL: ${e.message}");return 1 } }\n'
        (project/'src/main.cj').write_text(body);(logs/(group+'-main.cj')).write_text(body)
        (logs/'source-hashes.json').write_text(json.dumps(inputs,indent=2)+'\n')
        built=run(group+'-build',['cjpm','build'],project)
        if built:return built
        binary=str(project/'target/release/bin/main')
        positive=run(group+'-positive',[binary,'positive'],project)
        if positive:return positive
        for case in cases:results.append(run(group+'-'+case,[binary,case],project))
    return 1 if any(results) else 0
if __name__=='__main__':raise SystemExit(main())
