from pathlib import Path
import hashlib,json,subprocess,datetime
b=Path(__file__).resolve().parent.parent;raw=b/'raw';s=b/'source';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();root=Path('/workspace/work/editing-implementation/raw');proof={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'roots':{},'cases':[]};input_hashes={}
for name,indexroot,casebase,want in [('accepted-K',root/'19-baseline-fault-set',root/'19-baseline-fault-set/artifacts','52f061e6466c2cb9b44864e11f3374012238774def39638f302642b867151963'),('current-E',root/'regressions',root/'regressions/session-extensions/artifacts','948a047cf1cbd072fa6267fa3a9f562ff660ff7cbaa3586f5b7fb7105a3d3d5e')]:
 index=indexroot/'SHA256SUMS';assert sha(index)==want
 table={line.split('  ',1)[1].removeprefix('./'):line.split('  ',1)[0] for line in index.read_text().splitlines()}
 dirs=sorted(casebase.glob('*fault-set*-0*'));assert len(dirs)==4
 proof['roots'][name]={'index':str(index),'index_sha256':sha(index),'index_receipt_sha256':sha(indexroot/'SHA256SUMS.sha256')}
 for p in [index,indexroot/'SHA256SUMS.sha256']:input_hashes[str(p)]=sha(p)
 for d in dirs:
  for p in d.iterdir():
   if p.is_file():
    rel=str(p.relative_to(indexroot));assert sha(p)==table[rel],str(p);input_hashes[str(p)]=sha(p)
  events=[line.split('\t') for line in (d/'native.tsv').read_text().splitlines()];firstclose=next(i for i,e in enumerate(events) if e[0]=='close');pre=events[:firstclose];allwire=(d/'all-wire.bin').read_bytes();cursor=0;packets={}
  for e in pre:
   if e[0]=='write':
    n=int(e[2]);packets.setdefault(e[1],b'');packets[e[1]]+=allwire[cursor:cursor+n];cursor+=n
  assert [int(e[1]) for e in pre if e[0]=='sequence']==[1,2,3,4]
  assert packets['4']==bytes.fromhex('1b5b3f323030346c');assert len(packets['4'])==8
  assert (d/'session.raw').read_bytes().startswith(bytes.fromhex('1b5b3f3230303468'));assert (d/'before').read_bytes()==(d/'after').read_bytes()
  proof['cases'].append({'group':name,'directory':str(d),'route':json.loads((d/'launch.json').read_text())['config']['route'],'preclose_packets_hex':{k:v.hex() for k,v in packets.items()},'preclose_wire_bytes':cursor,'first_close':pre[-1] if False else events[firstclose],'init_enable_observed':True,'tty_restored':True})
 for extra in ['source-commit','binary.sha256','stdout','stderr','exit']:
  p=indexroot/extra
  if not p.exists() and name=='current-E':p=root/'regressions/session-extensions'/extra
  if p.exists():input_hashes[str(p)]=sha(p)
 if name=='current-E':
  for extra in ['product-input.sha256','product-post-check','binaries.sha256']:
   p=indexroot/extra;input_hashes[str(p)]=sha(p)
assert (root/'19-baseline-fault-set/source-commit').read_text().strip()=='f38c72784f440ff96a118233ad0237e1a1b57504'
proof['manual_protocol']={'enable_hex':'1b5b3f3230303468','disable_hex':'1b5b3f323030346c','mode25_query_hex':'1b5b3f32352470','enable_disable_bytes':8,'mode25_query_bytes':7,'allowed_preclose':'routeWrapped(save)+routeWrapped(pop)+exact bare mode2004disable, and no other write','basis':'K004 requested2004 finally restoration; S007 owned title scope cleanup; S008 zero-byte failure remains synchronized, partial failure silent'}
proof['input_sha256']=input_hashes
(raw/'proof.json').write_text(json.dumps(proof,indent=2)+'\n')
print('PROOF PASS8 original cases: acceptedK/currentE same exact2004l after pop before close; original indexes/files unchanged')
