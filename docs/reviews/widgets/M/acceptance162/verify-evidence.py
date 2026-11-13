#!/usr/bin/env python3
"""TASK162 read-only acceptance audit of original TASK161 evidence; no product execution."""
import datetime, hashlib, json, pathlib, re, subprocess

OUT = pathlib.Path(__file__).resolve().parent
EX = OUT.parent / 'widgets-composite-execution'
REPO = OUT.parent / 'terminal.ui'
SOURCE = '6e3f26aaaeee9442fde91ce31d720a841eeda473'
TEST = 'ad100b79956de30fe65c6d561f11be67186821d5'
BASE = '9ec836cef9c137b87c928a049aa8452b3a83b301'
receipts = {}
def sha(data): return hashlib.sha256(data).hexdigest()
def read(p):
    p = pathlib.Path(p); data = p.read_bytes()
    receipts[str(p)] = dict(bytes=len(data), sha256=sha(data))
    return data
def obj(p): return json.loads(read(p))
def git(*args): return subprocess.check_output(['git', '-C', str(REPO), *args])
def save(name, value): (OUT/name).write_text(json.dumps(value, ensure_ascii=False, indent=2)+'\n')

assert sha(read(EX/'final-index.json')) == 'b126ef3d726c4b5e01a6d145e70f519d87bae210c26de68f60101c98f8b50d51'
assert sha(read(OUT.parent/'widgets-composite-review/index.json')) == 'da8bf5213acd6c01d3b216b0de3a321abf8eebad6207ba70d11cd6590741482e'
v = obj(EX/'raw/final-verification/verification.json')
assert v['fixed_source'] == SOURCE and v['independent_test_revision'] == TEST
assert git('rev-parse', TEST+':tests/widgets_composite').decode().strip() == 'ff16e53ffe8156950088fd3c7d4654f972c830cc'
changed = git('diff','--name-status',BASE,SOURCE,'--','src','native','cjpm.toml','build.cj','themes').decode().splitlines()
assert len(changed)==8 and all(x.startswith('A\tsrc/') for x in changed), changed
source_bindings = []
for row in changed:
    rel = row.split('\t')[1]; data = read(EX/'source'/rel)
    assert data == git('show', SOURCE+':'+rel)
    source_bindings.append(dict(path=rel, sha256=sha(data)))
for rel in ['src/widget_activation.cj','src/application.cj','src/foreach_group.cj','src/node_ref.cj',
            'src/theme_decoder.cj','docs/product/widgets.md','examples/widgets_composition/src/main.cj',
            'examples/widgets_composition/cjpm.toml','cjpm.toml']:
    p = EX/'source'/rel
    if not p.exists(): continue
    assert read(p) == git('show',SOURCE+':'+rel)
test_bindings=[]
for rel in git('ls-tree','-r','--name-only',TEST,'tests/widgets_composite').decode().splitlines():
    data=read(EX/'source'/rel)
    assert data == git('show',TEST+':'+rel) == read(EX/'clean/cjtui-0.0.0'/rel)
    test_bindings.append(dict(path=rel,sha256=sha(data)))
assert len(test_bindings)==30

contracts=[]
for rel in ['AGENTS.md','openspec/changes/implement-standard-widgets/design.md',
 'openspec/changes/implement-standard-widgets/specs/standard-widgets/spec.md',
 'openspec/changes/implement-standard-widgets/tasks.md',
 'openspec/changes/implement-theme-styles/design.md',
 'openspec/changes/implement-public-interaction/design.md',
 'openspec/changes/implement-layout-decoration/design.md',
 'openspec/changes/implement-reactive-runtime/design.md',
 '.superpowers/sdd/tasks-implement-standard-widgets/theme-inheritance-clarification.md',
 '.superpowers/sdd/tasks-implement-standard-widgets/task-162-brief.md']:
    data=read(REPO/rel); contracts.append(dict(path=rel,sha256=sha(data),location=str(REPO/rel)))

phases=[]
for record in v['new_required_phases']:
    assert record['exit']==0 and record['source_sha']==SOURCE
    phases.append({k:record[k] for k in ['command','cwd','utc_start','utc_end','exit']})
assert len(phases)==12
for phase in ['normal-build','normal-bundle','clean-full-runner','clean-example-build']:
    command=obj(EX/'raw'/phase/'command.json'); assert command['exit']==0
    read(EX/'raw'/phase/'stdout'); read(EX/'raw'/phase/'stderr')
assert b'TASK158_M01_M05_S02_PASS' in read(EX/'raw/clean-full-runner/stdout')
package=obj(EX/'raw/package-audit/manifest.json')
assert package['archive_sha256']=='99da9c9dca77299c1ac90b8076424b505af5e9d2eed096c599ebf0d6294c2e44'
assert len(package['members'])==263 and len(package['external_frozen_inputs'])==30
for item in package['members']:
    rel=pathlib.PurePosixPath(item['path']); assert not rel.is_absolute() and '..' not in rel.parts
    if '/'.join(rel.parts[1:]) in [x['path'] for x in source_bindings]+['examples/widgets_composition/src/main.cj','docs/product/widgets.md']:
        assert sha(read(EX/'clean'/rel))==item['sha256']

focus='a;c;a;c;a;c;a;a;c;p;r;p;r;r;c;p;n;p;c;p;c;p;c;'
expected=dict(calls='4',chosen='h:a;h:a;p:r;p:p;',model='NEW',cleanups='1',resources='0/0/0/0')
def modes(raw): return re.findall(rb'\x1b\[\?([0-9;]*)([hlsr])',raw)
def mode_actions(raw,mode): return [action.decode() for params,action in modes(raw) if mode in [int(x or b'0') for x in params.split(b';')]]
pty=[]
for mode,code in [('normal',0),('callback-failure',21),('getter-failure',22)]:
    d=EX/'raw/clean-full-runner/artifacts'/mode; meta=obj(d/'metadata.json')
    raw=read(d/'stdout.raw'); sent=read(d/'stdin.raw'); summary=read(d/'summary').decode()
    assert meta['exit']==code and meta['before_termios']==meta['after_termios']
    assert meta['summary']['resources']=='0/0/0/0' and meta['summary']['cleanups']=='1'
    assert raw.count(b'\x1b[?25$p')==1 and not mode_actions(raw,25) and not mode_actions(raw,1049)
    assert mode_actions(raw,2004)==['h','l'] and not re.search(rb'\x1b\[\?25;[0-4]\$y',sent)
    assert meta['binary_sha256']==v['binaries']['device']['sha256']
    if mode=='normal':
        assert meta['summary']==expected and read(d/'focus').decode()==focus
    else:
        assert ('M_NATIVE_'+('CALLBACK' if code==21 else 'GETTER')+'_SENTINEL') in read(d/'error').decode()
    pty.append(dict(mode=mode,direct_exit=code,exact_termios=True,cleanup=1,resources='0/0/0/0',mode25='Unknown; zero controls',paste2004=['h','l']))

hosts=[]
for host in ['xterm','vte','vt']:
  for scene in ['normal','example']:
    d=EX/'raw'/('host-'+host+'-'+scene); result=obj(d/'result.json'); launch=obj(d/'launch.json')
    raw=read(d/'output.raw'); incoming=read(d/'input.raw')
    assert launch['fixed_source_sha']==SOURCE and launch['binary_sha256']==v['binaries']['device' if scene=='normal' else 'example']['sha256']
    assert mode_actions(raw,2004)==['h','l'] and not mode_actions(raw,1049)
    if host=='vt':
        assert result['product_exit']==0 and result['termios_equal'] and result['virtual_hardware']
        assert read(d/'evidence/termios-before.bin')==read(d/'evidence/termios-after.bin')
        assert not mode_actions(raw,25) and not re.search(rb'\x1b\[\?25;[0-4]\$y',incoming)
        serial=read(d/'serial.log').decode()
        assert 'EXTERNAL_MODE25 phase=BEFORE query=1 reply_hex= no_mode_force=1' in serial
        assert 'EXTERNAL_MODE25 phase=AFTER query=1 reply_hex= no_mode_force=1' in serial
        assert 'actual=50x10' in serial and 'termios_equal=1' in serial
        fdir=d/'evidence'; state='Unknown; no controls; physical visibility unproved'
    else:
        before=obj(d/'terminal-before.json'); after=obj(d/'terminal-after.json'); identity=obj(d/'host-identity.json')
        assert before['termios']==after['termios'] and after['product_exit']==0 and after['tracer_exit']==0
        assert before['mode25']['status']==after['mode25']['status']==1
        assert mode_actions(raw,25)==['l','h'] and b'\x1b[?25;1$y' in incoming
        assert any(e.get('resize_cells')==[50,10] for e in result['events'])
        fdir=d; state='Known visible 1 -> 1; hide/show pair'
    if scene=='normal':
        assert result['summary']==expected
        assert read(fdir/'focus').decode()==focus
        assert read(fdir/'chosen').decode()==expected['chosen']
        assert read(fdir/'reason').decode()=='Requested'
        read(fdir/'summary')
    hosts.append(dict(host=host,scene=scene,product_exit=0,exact_termios=True,mode25=state,source=SOURCE,binary_sha256=launch['binary_sha256'],capture_utc=launch['utc'],resize='60x12 -> 50x10',transport=launch['connection']))

selected={
 'host-xterm-normal/chosen-popup-still-open.png':'P/X/R remains visible after choice; R cyan/underlined, B/X visibly dim; counts require raw chosen/focus.',
 'host-vte-normal/nested-modal.png':'N cyan/underlined overlays the parent middle entry; parent P/R remain visible.',
 'host-vte-normal/nested-escape-parent-retained.png':'N disappears, disabled X returns, parent P regains focus styling; raw trace confirms p.',
 'host-vt-normal/resized.png':'Settled 50x10 normal scene shows NEW twice, C focused; no popup residue.',
 'host-vt-example/resized.png':'Settled 50x10 example keeps Options focus and Selected: close on last row.',
 'host-xterm-example/popup-close-entry.png':'Documented example shows focused Close overlay and Selected: open base status.'
}
screens=[]
for rel,observation in selected.items():
    p=EX/'raw'/rel; data=read(p)
    screens.append(dict(path=str(p),sha256=sha(data),observation=observation,original=True,viewed_with='view_image',limits='Pixels establish visible settled state only; no cleanup/callback-count inference.'))
for host_scene in ['host-vt-normal','host-vt-example']:
    d=EX/'raw'/host_scene
    for label in ['resize-transition','resized']:
        b=read(d/(label+'-vcsa.bin')); rows,cols=b[0],b[1];assert (rows,cols)==(10,50)
        lines=[b[4+2*cols*y:4+2*cols*(y+1):2].decode('latin1') for y in range(rows)]
        if label=='resized':
            assert ('NEW' in lines[2] and 'NEW' in lines[3]) if host_scene.endswith('normal') else ('Selected: close' in lines[-1])
        screens.append(dict(path=str(d/(label+'-vcsa.bin')),sha256=sha(b),rows=rows,columns=cols,visible_rows=lines,observation='Original VT cells; transition is not used as settled output.' if label=='resize-transition' else 'Settled original VT cells agree with viewed PNG.'))

save('source-test-contract-receipts.json',dict(source=SOURCE,test_revision=TEST,test_tree='ff16e53ffe8156950088fd3c7d4654f972c830cc',source_additions=source_bindings,test_inputs=test_bindings,contracts=contracts,baseline=BASE,unchanged_scope='Existing S/Runtime/layout/native/theme/keyboard and package configuration unchanged; reuse remains confined to captured original environment/configuration.'))
save('selected-original-receipts.json',screens)
save('verification.json',dict(task=162,utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),status='PASS_ORIGINAL_EVIDENCE_AUDIT',product_reexecution=False,phases=phases,pty=pty,hosts=hosts,package=dict(members=263,frozen_inputs=30,archive_sha256=package['archive_sha256'],audit='Root full hash/safe-source equality audit reused; selected M delivered files and all frozen consumer bytes rechecked.'),reuse='Root verified22indices/294raw/24top/65PNG/4binaries after environment resume; this audit checks selective receipt bindings and exact observations, not a new host run.',receipts=receipts))
print('TASK162_ORIGINAL_EVIDENCE_AUDIT_PASS: anchors/source/test/strictPTY/6hosts/settledVT/selectedoriginals; no product execution')
