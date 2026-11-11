from pathlib import Path
import hashlib,json,datetime,subprocess
root=Path(__file__).resolve().parent
repo=Path('/workspace/work/terminal.ui')
up=Path('/workspace/work/linux-build-recon/cache/repository/source/default/cangjie_toml-0.2.3')
out=root/'source-evidence';out.mkdir(exist_ok=True)
paths=[repo/'.superpowers/sdd/tasks-implement-theme-styles/t009-key-budget-candidate.md',repo/'openspec/changes/implement-theme-styles/design.md',repo/'openspec/changes/implement-theme-styles/proposal.md',repo/'tests/themes/values/src/capacity_boundaries.cj',repo/'tests/themes/generate_inputs.py',up/'cjpm.toml',up/'src/cangjie_toml/lexer/token.cj',up/'src/cangjie_toml/lexer/lexer.cj',up/'src/cangjie_toml/lexer/state.cj',up/'src/cangjie_toml/parser/parser.cj',up/'src/cangjie_toml/parser/key.cj',up/'src/cangjie_toml/util/escape.cj',up/'src/cangjie_toml/from_toml.cj']
records=[dict(path=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in paths]
(root/'input-hashes.json').write_text(json.dumps(dict(captured_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),repo_commit=subprocess.check_output(['git','-C',str(repo),'rev-parse','HEAD'],text=True).strip(),files=records),indent=2)+'\n')
# Preserve narrow source evidence, not a dependency checkout or binaries.
for label,p,ranges in [
 ('formal-design',paths[1],[(135,140),(406,408),(432,434)]),
 ('original085-capacity',paths[3],[(1,1000)]),('original085-inputs',paths[4],[(1,57)]),
 ('upstream-token',paths[6],[(1,1000)]),('upstream-lexer',paths[7],[(1,117)]),
 ('upstream-state',paths[8],[(275,365)]),('upstream-parser',paths[9],[(1,40),(95,126),(323,337),(653,731)]),
 ('upstream-key',paths[10],[(1,1000)]),('upstream-escape',paths[11],[(1,1000)]),
 ('upstream-fromtoml',paths[12],[(100,135)])]:
    lines=p.read_text().splitlines()
    text='Source: '+str(p)+'\nSHA256: '+hashlib.sha256(p.read_bytes()).hexdigest()+'\n'
    for lo,hi in ranges:
        text+=''.join(f'{i}: {lines[i-1]}\n' for i in range(lo,min(hi,len(lines))+1))
    (out/(label+'.txt')).write_text(text)
(root/'candidate.md').write_bytes(paths[0].read_bytes())
public=[]
for p in sorted((up/'src/cangjie_toml').rglob('*.cj')):
    for n,l in enumerate(p.read_text().splitlines(),1):
        if 'public ' in l: public.append(f'{p.relative_to(up)}:{n}:{l}')
(out/'public-api-inventory.txt').write_text('\n'.join(public)+'\n')
# Verify the copied normal dependency sources are identical to configured originals.
copy=root/'cache/repository/source/default/cangjie_toml-0.2.3'
checks=[]
for p in sorted(up.rglob('*.cj')):
    q=copy/p.relative_to(up)
    checks.append(dict(file=str(p.relative_to(up)),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),identical=q.read_bytes()==p.read_bytes()))
(root/'dependency-source-identity.json').write_text(json.dumps(checks,indent=2)+'\n')
assert all(x['identical'] for x in checks)
