from pathlib import Path
import os,json,hashlib,subprocess as s,re,datetime
B=Path('/workspace/work/viewport-execution');R=B/'product';raw=B/'raw';H=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();js=lambda p,v:p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
# Fresh verification of actual completed records, never synthesize exits.
mandatory=['b-review9','b-normal','b-device','b-resource-gnutime','node-reference','theme-canvas','affected-a-headless','affected-runtime','affected-themes','affected-async8','bundle','package-check','clean-library','clean-b','clean-nr','clean-theme-canvas','clean-example-build','clean-example-smoke','kernel-fenced-collection','gui-vte-final-collection']
commands={p.parent.name:json.loads(p.read_text()) for p in raw.glob('*/command.json')}
assert all(commands[n]['exit']==0 for n in mandatory)
sourcechecks={p.parent.name:json.loads(p.read_text())==json.loads((p.parent/'post-source.json').read_text()) for p in raw.glob('*/pre-source.json') if (p.parent/'post-source.json').exists()};assert all(sourcechecks.values())
assert s.check_output(['git','status','--porcelain','--untracked-files=no'],cwd=R,text=True)==''
sha=s.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip();assert sha=='62039552a26da295dcd710d7cfc40cb9e43ca5fd'
js(raw/'identity/completed-commands.json',{'utc':now(),'mandatory_exit0':mandatory,'all_completed_commands':commands,'source_pre_post_equal':sourcechecks})
# Input and cache identity, post execution.
deps={}
for name,base in [('dependency-source-hashes.json',Path('/workspace/work/linux-build-recon/cache')),('stdx-hashes.json',Path('/workspace/work/linux-build-recon/stdx-env/linux_x86_64_llvm'))]:
 p=Path('/workspace/work/theme-execution/raw')/name;d=json.loads(p.read_text());pairs=[(x['path'],x['sha256']) for x in d] if isinstance(d,list) else list(d.items());bad=[rel for rel,h in pairs if not(base/rel).is_file() or H(base/rel)!=h];assert not bad;deps[name]={'base':str(base.resolve()),'baseline':str(p),'baseline_sha256':H(p),'checked':len(pairs),'mismatches':bad}
js(raw/'identity/dependencies-post.json',deps)
# Fixed consumers: every tracked byte copied exactly except dependency manifest path.
consumer=[]
for group in ['tests/interaction_b','tests/node_reference_regression','tests/theme_canvas_integration','examples/viewport']:
 for rel in s.check_output(['git','ls-files',group],cwd=R,text=True).splitlines():
  p=B/'clean-consumer'/rel;actual=p.read_bytes();original=(R/rel).read_bytes()
  if p.name=='cjpm.toml':
   depth=len(Path(rel).parent.parts);expected=original.replace(b'path = "../.."',('path = "'+('../'*depth)+'package/cjtui-0.0.0"').encode());assert actual==expected
  else:assert actual==original,rel
  consumer.append({'path':rel,'sha256':H(p),'source_sha256':H(R/rel),'manifest_dependency_path_only':actual!=original})
js(raw/'package/consumer-byte-bindings.json',consumer)
# Old proof reuse is limited to bytes unaffected by B and same actual SDK/host recipes.
old='f8a028b39daf8a341576f304335d262544b9cca5';paths=s.check_output(['git','ls-files','src','native'],cwd=R,text=True).splitlines();reuse=[]
for rel in paths:
 if rel.startswith('native/') or any(x in rel for x in ['input_decoder','caret_probe','ansi_encoding','terminal_','session_capability','glyph','text/unicode']):
  a=s.check_output(['git','show',old+':'+rel],cwd=R);b=(R/rel).read_bytes();assert a==b,rel;reuse.append({'path':rel,'sha256':H(R/rel),'bytes_equal_accepted_A':True})
js(raw/'identity/reuse.json',{'accepted_A':old,'sealed_manifest':'/workspace/work/interaction-execution/manifest.json','sealed_manifest_sha256':H(Path('/workspace/work/interaction-execution/manifest.json')),'content_bindings':reuse,'scope':'Unchanged decoder/native writer/probe clock and capability/glyph policies only. Same SDK1.2/stdx/UCD/native host closure and tool recipes. Does not cover new B layout, owner/session integration, clip, caret, scroll or Unicode damage; those run here. Physical PageUp/PageDown remain unclaimed. Old scope limitations remain.'})
# Host facts captured directly, plus final exact collection mapping.
facts={}
for name,cmd in [('xterm',['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm','-version']),('vte',['xfce4-terminal','--version']),('xorg',['Xorg','-version']),('font',['fc-match','DejaVu Sans Mono']),('vte-library',['pkg-config','--modversion','vte-2.91'])]:
 q=s.run(cmd,capture_output=True,text=True);facts[name]={'argv':cmd,'exit':q.returncode,'stdout':q.stdout,'stderr':q.stderr}
js(raw/'identity/host-versions.json',{'utc':now(),'commands':facts,'tool_hashes_post_collection':{str(p.relative_to(B)):H(p) for p in (B/'tools').glob('*') if p.is_file()},'note':'Helper final hashes are post-collection, not retrospectively asserted pre hashes; command/pre-source and launch artifact hashes are independently captured.'})
collections=[raw/'gui-hosts'/('xterm-'+m) for m in ['pty','caret-resize','same-turn','unicode']]+[raw/'gui-vte-hosts/vte-pty']+[raw/'gui-vte-final'/('vte-'+m) for m in ['caret-resize','same-turn','unicode']]+[raw/'kernel-hosts-fenced'/m for m in ['pty','caret-resize','same-turn']]
hosts=[]
for p in collections:
 stages=json.loads((p/'stages.json').read_text());hosts.append({'path':str(p.relative_to(B)),'stages':stages,'original_pngs':[str(x.relative_to(B)) for x in sorted(p.glob('*.png'))]})
js(raw/'identity/host-index.json',hosts)
cases=json.loads((R/'tests/interaction_b/cases.json').read_text());js(B/'scope.json',{'source':sha,'design_sha256':H(Path('/workspace/work/terminal.ui/openspec/changes/implement-public-interaction/design.md')),'original_case_count':31,'bareCanvas_additional_count':1,'matrix_entry_count':len(cases),'matrix_entries':[{'id':x['id'],'ac':x['ac'],'source':x['source'],'result':'PASS via unchanged full ordinary entry b-normal and clean-b'} for x in cases],'additional':'bareCanvas and nine review cases; review9 isolated and same-process are duplicate observations, not 18 unique cases. Eight public groups retain manual literal goldens. Actual device basic5+three sequences. NR controls/fresh500 and ThemeCanvas finite/control/subtree. Full A headless/runtime/themes and selected eight async admitted only.','hosts':[{'path':h['path'],'stages':len(h['stages']),'pngs':len(h['original_pngs'])} for h in hosts],'resource':{'elapsed_seconds':0.02,'max_rss_KiB':26812,'descriptive_only':True},'requested_role':'independent executor Sol/medium; actual serving configuration not independently certifiable','not_closed':['M01 getter axes onMount initial Off deferred TASK024','wholechecker TASK023 inventory themes/composition/benchmark known gate','full Linux release, M2, full widgets/menu/editing, complete Keyboard117, physical PageUp/PageDown','physical hardware/Android/HarmonyOS']})
js(B/'findings.json',{'source':sha,'product_mustpass_failures':[],'result':'PASS_SCOPED_EXECUTION','deferred':['M01 TASK024 retained'], 'infrastructure_history':[{'raw':'raw/b-resource','exit':127,'cause':'missing default /usr/bin/time; exact fixed runner rerun with official GNU Time absolute path exit0'},{'raw':'raw/gui-collection','exit':1,'cause':'XTerm all4 complete0; VTE logical softwrapped whole range incorrectly treated as physical rows; use native physical per-row getter'},{'raw':'raw/gui-vte-collection','exit':1,'cause':'VTE pty5 complete0; next metadata creation raced JSON parse; atomic publish fix in observer helper'},{'raw':'raw/gui-vte-rest-collection','exit':1,'cause':'VTE exclusive end_col cols-1 clipped last cell at4x1 while full visible/write_contents showed abcd; observer end_col corrected to cols'},{'raw':'raw/kernel-collection;raw/kernel-final-collection','exit':1,'cause':'15s initial controller bound, stale public query and serial flooding full VCS/VCSU on each poll under TCG+full-write strace. Final profile-only poll and stage-native fence with recorded90s bound completed unchanged inputs/oracles.'},{'raw':'raw/vt-pack-callback','exit':1,'cause':'inventory output parent absent; generated initrd not treated as complete proof; final recorded pack0'}, {'raw':'raw/vt-pack-final','exit':None,'cause':'record wrapper invoked before SDK environment sourced; compiler which check aborted before pack; no product result'}]})
print('Verified completed obligations, fixed inputs, consumers, source and deps; cases',len(cases),'host PNGs',sum(len(h['original_pngs']) for h in hosts))
