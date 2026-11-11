import hashlib,json,subprocess
from pathlib import Path
B=Path('/workspace/work/theme-execution');R=B/'product';A=Path('/workspace/work/theme-implementation');O=B/'raw/reuse';O.mkdir(exist_ok=True)
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
# Compare pure recorded pre-run source inventory with the final independent checkout.
pre=json.loads((A/'fix-round1-raw/pre-source-tests.json').read_text()); print(type(pre),list(pre)[:4])
# Historical C1 is post-run identity only; explicitly keep that limitation.
c1=json.loads((A/'themes-c1/product-input-hashes.json').read_text());old=c1.get('files',c1)
diff=[];same=[]
for p,v in old.items():
 if p=='cangjie-repo.toml':continue
 q=R/p
 if q.is_file(): (same if h(q)==v else diff).append(p)
 else:diff.append(p)
records=[]
for group in ['themes-c1','themes-c1-resumed']:
 p=A/group/'commands.jsonl'
 for row in map(json.loads,p.read_text().splitlines()):
  n=row['name']
  if n.startswith('negative-') or group.endswith('resumed'):
   name=n.removeprefix('negative-'); fixture=R/'tests/themes/negative'/f'{name}.cj.txt'
   err=A/group/f'{n}.stderr';out=A/group/f'{n}.stdout'
   # resumed names omit negative- prefix
   if not err.exists():err=A/group/f'negative-{n}.stderr'
   if not out.exists():out=A/group/f'negative-{n}.stdout'
   text=err.read_text(errors='replace') if err.exists() else ''
   expected=json.loads((A/'themes-c1/source-hashes.json').read_text()).get(f'negative/{name}.cj.txt')
   records.append({'group':group,'name':name,'exit':row['exit'],'command':row,'fixture_matches':fixture.exists() and h(fixture)==expected,'stderr':str(err),'stderr_sha256':h(err) if err.exists() else None,'diagnostic_tail':text[-1200:]})
result={'temporal_limit':'C1 product-input-hashes captured post-run; no retroactive pre-run identity proof','unchanged_product_files':same,'changed_product_files':diff,'negative_records':records}
(O/'negative-identity.json').write_text(json.dumps(result,indent=2)+'\n')
(O/'round1-pre-source-inventory.json').write_text(json.dumps(pre,indent=2)+'\n')
print('same',len(same),'changed',diff,'negative count',len(records))
