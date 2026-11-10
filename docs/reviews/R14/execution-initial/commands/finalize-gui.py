from pathlib import Path
import subprocess,json,hashlib,datetime
b=Path('/workspace/work/rich-text-execution');g=b/'evidence/gui-rich';p=Path((b/'clean-product-path').read_text().strip());binary=p/'examples/rich-text/target/release/bin/main'
h=lambda x:hashlib.sha256(x.read_bytes()).hexdigest()
def out(*a):return subprocess.check_output(a,stderr=subprocess.STDOUT).decode()
for profile in ['xterm-default','xfce-vte']:
 d=g/profile/'q';m=json.loads((d/'metadata.json').read_text());assert (d/'process-reaping.txt').is_file()
 m['metadata_created_at_utc']=m['captured_at_utc']
 m['captured_at_utc']=(d/'example-initial-captured-at-utc.txt').read_text().strip()
 m['captured_at_utc_semantics']='actual initial screenshot capture start; per-stage times below'
 m['captured_at_utc_by_stage']={n:(d/f'example-{n}-captured-at-utc.txt').read_text().strip() for n in ['initial','green','red','resized','resized-green']}
 m['input_helper_binary']={'path':str(b/'commands/gui-key'),'sha256':h(b/'commands/gui-key'),'role':'external X11 key/resize injection; ELF kept outside curated archive'}
 m['executed_harness_sha256']={str(f.relative_to(b/'commands')):h(f) for f in sorted((b/'commands').glob('*')) if f.is_file() and f.name in ['gui-rich.sh','gui-metadata.py','gui-key.c','verify-rich-grid.mjs','execute-gui.sh']}
 m['binary_abi']=out('file',str(binary));m['ldd']=out('ldd',str(binary));m['host_libraries']=out('ldd','/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm' if profile=='xterm-default' else '/usr/bin/xfce4-terminal')
 m['vte_version']=out('dpkg-query','-W','libvte-2.91-0')
 m['expected_policy']={'source':'formal final7a33ddc + R10 terminal projection policy; hand-literal expected rows in verify-rich-grid.mjs','initial_grid':[100,28],'resized_grid':[120,34],'events':['initial','t:Green','t:Red','resize','t:Green','q'],'logical_rgb':[80,180,255],'projected_rgb':'White (Basic8 nearest palette)' if profile=='xterm-default' else 'Rgb(80,180,255) preserved','component_override':'Yellow foreground per field with existing bold first11 cells retained','unicode':'e+combining one cell; CJK and ZWJ emoji each two cells, first scalar style'}
 m['finalized_at_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['hashes_sampled_after_host_and_xorg_exit']=True
 (d/'metadata.json').write_text(json.dumps(m,indent=2,ensure_ascii=False)+'\n')
 (d/'final-artifacts.json').write_text(json.dumps(dict(final_hash_time_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),artifacts={str(f.relative_to(d)):h(f) for f in sorted(d.rglob('*')) if f.is_file() and f.name!='final-artifacts.json' and 'xdg-cache' not in f.parts}),indent=2)+'\n')
print('2 real GUI host records finalized after process reaping')
