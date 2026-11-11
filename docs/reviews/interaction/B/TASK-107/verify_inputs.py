"""TASK107 read-only original-evidence checks. Never invokes product or collectors."""
import hashlib, io, json, pathlib, re, subprocess, tarfile, gzip, importlib.util
from datetime import datetime, timezone
E=pathlib.Path('/workspace/work/viewport-execution')
A=pathlib.Path('/workspace/work/viewport-acceptance')
G=pathlib.Path('/workspace/work/terminal.ui')
SOURCE='62039552a26da295dcd710d7cfc40cb9e43ca5fd'
def sha(b): return hashlib.sha256(b).hexdigest()
def rd(p):
    p=pathlib.Path(p)
    assert 'viewport-implementation' not in str(p)
    return p.read_bytes()
def js(p):return json.loads(rd(p))
checks={}; errors=[]
def check(k,v):
    checks[k]=v
    if not v: errors.append(k)
manifest=js(E/'manifest.json')
check('stable_execution_manifest',sha(rd(E/'manifest.json'))=='a4cbad039dd8aa8ccb37afe21dbf9077dae5591f80c59c821a6f88ca802073d5')
check('stable_execution_index',sha(rd(E/'artifacts.sha256'))=='36378247cfda85ed182ce70cd83c2bcf387742437b495426fdc708608168fb2f')
for entry in manifest['original_files']:
    b=rd(E/entry['path']);check('original:'+entry['path'],len(b)==entry['bytes'] and sha(b)==entry['sha256'])
for line in rd(E/'artifacts.sha256').decode().splitlines():
    h,p=line.split('  ',1);check('index:'+p,sha(rd(E/p))==h)
for line in rd('/workspace/work/viewport-review/round2/artifacts.sha256').decode().splitlines():
    h,p=line.split(None,1);check('review2:'+p,sha(rd(pathlib.Path('/workspace/work/viewport-review/round2')/p))==h)
check('canonical_design',sha(rd(G/'openspec/changes/implement-public-interaction/design.md'))=='3aa214946949afbaa79ab08a214bd2fb6bc6f9b3b2173f11d64225bc52b16ebd')
with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(['git','archive',SOURCE],cwd=G))) as t:
    git={m.name:t.extractfile(m).read() for m in t if m.isfile()}
prepost=[]
for p in sorted(E.glob('raw/*/pre-source.json')):
    a=js(p);q=p.with_name('post-source.json')
    if not q.exists():continue
    b=js(q);check('source_prepost:'+p.parent.name,a==b)
    for f,h in a.items():check('source:'+p.parent.name+':'+f,f in git and sha(git[f])==h)
    prepost.append({'command':p.parent.name,'entries':len(a)})
for f in ['src','native','build.cj','cjpm.toml','examples/viewport','tests/interaction_b','tests/node_reference_regression','tests/theme_canvas_integration']:
    for p,b in git.items():
        if p==f or p.startswith(f+'/'):check('current_source:'+p,rd(E/'product'/p)==b)
with tarfile.open(E/'product/target/cjtui-0.0.0.cjp','r:gz') as t:
    members={m.name:t.extractfile(m).read() for m in t if m.isfile()}
inventory=js(E/'raw/package/member-inventory.json')
check('cjp_member_count',len(members)==len(inventory)==208)
for m in inventory:
    b=members[m['member']];g=git[m['git_path']]
    check('cjp:'+m['git_path'],b==g and sha(b)==m['sha256'] and rd(E/'clean-consumer/package/cjtui-0.0.0'/m['git_path'])==b)
for m in js(E/'raw/package/consumer-byte-bindings.json'):
    p=m['path'];b=rd(E/'clean-consumer'/p);g=git[p]
    expected=g.replace(b'path = "../.."',('path = "'+('../'*len(pathlib.Path(p).parent.parts))+'package/cjtui-0.0.0"').encode()) if p.endswith('cjpm.toml') else g
    check('clean_consumer:'+p,b==expected and sha(b)==m['sha256'] and sha(g)==m['source_sha256'])
external=js(E/'omitted-artifacts.json')['external_artifacts']
for m in external:
    b=rd(E/m['path']);check('external:'+m['path'],len(b)==m['bytes'] and sha(b)==m['sha256'])
deps=js(E/'raw/identity/dependencies-post.json')
for name,d in deps.items():
    check('dependency_baseline:'+name,sha(rd(d['baseline']))==d['baseline_sha256'])
    a=js(d['baseline']);pairs=[(r['path'],r['sha256']) for r in a] if isinstance(a,list) else a.items()
    for p,h in pairs:check('dependency:'+name+':'+p,sha(rd(pathlib.Path(d['base'])/p))==h)
hostfacts=js(E/'raw/host-facts/stdout')
for p,d in hostfacts['binaries'].items():check('host_binary:'+p,sha(rd(p))==d['sha256'])
env=js(E/'raw/b-normal/pre-environment.json')
for p,h in env['hashes'].items():check('sdk_env:'+p,sha(rd(p))==h)
check('ucd',sha(rd(env['UCD']))==env['UCD_sha256'])
reuse=js(E/'raw/identity/reuse.json')
check('accepted_A_manifest',sha(rd(reuse['sealed_manifest']))==reuse['sealed_manifest_sha256'])
for d in reuse['content_bindings']:
    old=subprocess.check_output(['git','show',reuse['accepted_A']+':'+d['path']],cwd=G)
    check('accepted_A_unchanged:'+d['path'],old==git[d['path']] and sha(old)==d['sha256'])
cpio=gzip.decompress(rd(E/'packages/vt-viewport.cpio.gz'));pos=0;guest={}
while pos+110<=len(cpio):
    header=cpio[pos:pos+110];assert header[:6] in [b'070701',b'070702']
    fields=[int(header[i:i+8],16) for i in range(6,110,8)]
    size=fields[6];namesize=fields[11];name=cpio[pos+110:pos+110+namesize-1].decode();pos=(pos+110+namesize+3)&~3
    guest[name.lstrip('./')]=cpio[pos:pos+size];pos=(pos+size+3)&~3
    if name=='TRAILER!!!':break
for d in js(E/'raw/staging/vt-initrd-members.json')['members']:
    b=guest[d['guest']];check('guest_member:'+d['guest'],len(b)==d['bytes'] and sha(b)==d['sha256'])
check('guest_same_product',guest['apps/viewport-b']==rd(E/'product/tests/interaction_b/target/release/bin/main'))
spec=importlib.util.spec_from_file_location('trace',E/'tools/trace_bytes.py');trace=importlib.util.module_from_spec(spec);spec.loader.exec_module(trace)
gui=['gui-hosts/xterm-'+m for m in ['pty','caret-resize','same-turn','unicode']]+['gui-vte-hosts/vte-pty']+['gui-vte-final/vte-'+m for m in ['caret-resize','same-turn','unicode']]
hosts=[];pngs=[]
binary_sha='229eb7a6189fb0d916bfec1dba992a15e01471e410d8bff2b6e98363dc621062'
def expected(mode,name):
    if mode=='pty':
        w,h,offset={'initial':(80,24,0),'tail':(80,24,76),'smaller':(40,10,76),'smaller-tail':(40,10,90),'restored':(80,24,76)}[name]
        return w,h,[f'r{i}' for i in range(offset,offset+h)]
    if mode=='unicode':return 40,8,[{'initial':'#A !','offset1':'#界!','offset2':'# B!','shortened':'#B !'}[name]]
    w,line={'initial':(4,'abcd'),'old-caret':(4,'jkl '),'natural-resize':(2,'l '),'new-caret-resize':(2,'bc'),'manual-zero':(2,'ab')}[name]
    return w,1,[line]
def expected_state(mode,name):
    if mode=='pty':
        w,h,lines=expected(mode,name);return [str(w),str(h),'100',lines[0][1:]]
    if mode=='unicode':return {'initial':'2/1/4/1/0/0/0/false','offset1':'2/1/4/1/1/0/0/false','offset2':'2/1/4/1/2/0/0/false','shortened':'2/1/2/1/0/0/0/false'}[name].split('/')
    return {'initial':'4/1/13/1/0/0/0/true','old-caret':'4/1/13/1/9/0/3/true','natural-resize':'2/1/13/1/11/0/1/true','new-caret-resize':'2/1/13/1/1/0/1/true','manual-zero':'2/1/13/1/0/0/0/false'}[name].split('/')
for rel in gui:
    p=E/'raw'/rel;mode=rel.split('/',1)[1].split('-',1)[1];stages=js(p/'stages.json');before=js(p/'terminal-before.json');after=js(p/'terminal-after.json')
    check('host_exit_termios:'+rel,after['exit']==0 and before['before']==after['after'])
    check('host_original_mode:'+rel,before['original_query']['reply_hex']==after['restored_query']['reply_hex'] and rd(p/'original-host-reply.bin')==rd(p/'restored-host-reply.bin'))
    check('host_elf:'+rel,js(p/'launch.json')['binary_sha256']==binary_sha)
    wire,stats=trace.extract(rd(p/'product.strace').decode());check('host_wire:'+rel,wire==rd(p/'product-stdout.raw') and wire.count(b'\x1b[?25$p')==1 and not stats['pending'] and not stats['unparsedTarget'])
    for i,s in enumerate(stages):
        name=s['name'];w,h,want=expected(mode,name)
        target=expected_state(mode,name);check('public_literal:'+rel+':'+name,s['public_state'].strip().split('/')[:len(target)]==target)
        if 'xterm' in rel:
            lines=re.sub(r'\x1b(?:\[[0-?]*[ -/]*[@-~]|#[0-9])','',rd(p/f'native-{i}.ansi').decode()).splitlines()
        else:
            meta=js(p/f'native-{i}-meta.json');check('physical_size:'+rel+':'+name,meta['cols']==w and meta['rows']==h)
            lines=[rd(p/f'native-{i}-row-{r}.txt').decode().rstrip('\n') for r in range(h)]
        check('native_rows:'+rel+':'+name,[r.rstrip() for r in lines[:len(want)]]==[r.rstrip() for r in want])
        check('native_remaining_blank:'+rel+':'+name,all(not r.strip() for r in lines[len(want):]))
        check('public_state:'+rel+':'+name,rd(p/(name+'-state.txt')).decode().strip()==s['public_state'].strip())
    events=js(p/'events.json')
    if mode=='pty':check('gui_keys:'+rel,[x['count'] for x in events if x.get('key')=='Down']==[100,14])
    check('gui_resize_readback:'+rel,all(x['physical_resize']==x['readback'] for x in events if 'physical_resize' in x))
    images=list(p.glob('*.png'));pngs+=images
    hosts.append({'path':str(p),'stages':len(stages),'png':len(images),'product_query_count':1,'trace_parse':stats})
for mode in ['pty','caret-resize','same-turn']:
    rel='kernel-hosts-fenced/'+mode;p=E/'raw'/rel;stages=js(p/'stages.json');serial=rd(p/'vt-serial.log').decode(errors='replace').replace('\r\n','\n');result=js(p/'result.json')
    check('vt_exit:'+mode,result['qemuExit']==0 and result['productExit']==0 and 'termios_equal=1' in serial and 'PRODUCT_ID uid=1000 euid=1000' in serial and 'VT_GETSTATE_rc=0 active=1' in serial)
    check('vt_kernel:'+mode,sha(rd('/workspace/work/linux-console-hosts/packages/linux'))==result['kernelSha256'])
    check('vt_initrd:'+mode,sha(rd(E/'packages/vt-viewport.cpio.gz'))==result['initrdSha256'])
    wire,stats=trace.extract(rd(p/'evidence'/f'{mode}.strace').decode())
    check('vt_unknown_wire:'+mode,wire.count(b'\x1b[?25$p')==1 and not any(b'\x1b[?25'+x in wire for x in [b'h',b'l',b's',b'r']) and not stats['pending'] and not stats['unparsedTarget'])
    for s in stages:
        name=s['name'];native=js(p/(name+'-native.json'));w,h,lines=expected(mode,name);raw=bytes.fromhex(native['vcsa_hex'])
        target=expected_state(mode,name);check('vt_public_literal:'+mode+':'+name,s['public_state'].strip().split('/')[:len(target)]==target)
        if mode!='pty':check('vt_caret:'+mode+':'+name,native['cursor']==[{'initial':0,'old-caret':3,'natural-resize':1,'new-caret-resize':1,'manual-zero':1}[name],0])
        check('vt_cells:'+mode+':'+name,raw[:2]==bytes([h,w]) and raw[4::2]==b''.join(x.encode().ljust(w,b' ') for x in lines) and len(raw)==4+2*w*h)
        check('vt_native_origin:'+mode+':'+name,'GRID seq='+native['sequence']+' phase=RUNNING path=/dev/vcsa1 n='+str(len(raw))+' hex='+raw.hex() in serial and 'PROFILE seq='+s['grid_sequence']+' BEGIN\n'+s['public_state'] in serial)
    images=list(p.glob('*.png'));pngs+=images;hosts.append({'path':str(p),'stages':len(stages),'png':len(images),'product_query_count':1,'trace_parse':stats})
    if mode=='pty':
        qmp=[json.loads(x) for x in rd(p/'qmp.jsonl').decode().splitlines()]
        keydowns=[e for x in qmp for e in x.get('send',{}).get('arguments',{}).get('events',[]) if e.get('type')=='key' and e['data'].get('down') and e['data']['key']['data']=='down']
        check('vt_down_114',len(keydowns)==114)
check('successful_original_png_count',len(pngs)==91)
for p in pngs:check('original_png:'+str(p.relative_to(E)),rd(p).startswith(b'\x89PNG\r\n\x1a\n'))
for p in E.glob('raw/b-device/detail/sequences/*/capture.json'):
    d=js(p);check('pty:'+p.parent.name,d['exit']==0 and not d['forced'] and d['before']==d['after'] and d['binary_sha256']==binary_sha)
d=js(E/'raw/b-device/detail/basic/metadata.json');check('pty_basic',d['exit']==0 and d['termios_before']==d['termios_after'] and len(d['public_states'])==5)
commands={p.parent.name:js(p) for p in E.glob('raw/*/command.json')}
required=['b-normal','b-review9','b-device','b-resource-gnutime','node-reference','theme-canvas','affected-a-headless','affected-runtime','affected-themes','affected-async8','bundle','clean-library','clean-b','clean-nr','clean-theme-canvas','clean-example-build','clean-example-smoke','gui-vte-final-collection','kernel-fenced-collection']
for name in required:check('command_exit:'+name,commands[name]['exit']==0)
for name in ['b-normal','clean-b']:check('full_entry_sentinel:'+name,b'PASS: executed interaction B public viewport assertions' in rd(E/'raw'/name/'stdout'))
result={'utc':datetime.now(timezone.utc).isoformat(),'scope':'Read-only hashes, original byte/oracle assertions; no product execution','source':SOURCE,'execution_manifest_sha256':sha(rd(E/'manifest.json')),'execution_index_sha256':sha(rd(E/'artifacts.sha256')),'original_count':len(manifest['original_files']),'check_count':len(checks),'failed':errors,'source_prepost':prepost,'external_count':len(external),'package_members':len(members),'clean_consumer_bindings':len(js(E/'raw/package/consumer-byte-bindings.json')),'hosts':hosts,'successful_png_count':len(pngs),'command_exits':{n:d.get('exit') for n,d in commands.items()},'check_categories':{prefix:sum(k==prefix or k.startswith(prefix+':') for k in checks) for prefix in sorted(set(k.split(':',1)[0] for k in checks))},'acceptance_helper_history':['Initial script SyntaxError fixed before checks; first completed hash/oracle pass had 12 VT origin string mismatches because raw CRLF was compared to LF-normalized state files; fixed comparison normalizes CRLF only. Cpio inventory includes its empty TRAILER!!! entry, now parsed explicitly after an initial helper KeyError. Original bytes and all product results unchanged.']}
(A/'verification.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k not in ['checks','hosts','command_exits','source_prepost']},indent=2))
raise SystemExit(bool(errors))
