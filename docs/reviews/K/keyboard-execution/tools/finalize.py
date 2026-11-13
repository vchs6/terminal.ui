import pathlib,json,hashlib,datetime,os
B=pathlib.Path('/workspace/work/keyboard-execution');source='c3c4642d84df57bbd9550d222ed22f602acd13ef';overlay='daf99aa1f323929d09907d558623b3bb6a74cbbb'
required=['main-build','keyboard-suite','native-session','application-lifecycle','runtime-session','integration-profile-fixed','mandatory-bundle','package-audit-command-r2','clean-keyboard-build','clean-keyboard-run','clean-dispatch-build','clean-dispatch-run','clean-example-build','clean-example-run','real-gui-hosts','real-vt-host-r3']
for name in required:assert json.loads((B/'raw'/name/'manifest.json').read_text())['exit']==0,name
for name in ['integration','real-vt-host','package-audit-command']:assert json.loads((B/'raw'/name/'manifest.json').read_text())['exit']==1,name
lines=[
'TASK116 finite execution PASS; product '+source+'; acceptance TASK117 remains separate.',
'Test-only overlay '+overlay+': exact one-file explicit Unicode fixture profile; product unchanged.',
'SDK/cjpm1.2.0; ordinary own build/config/outputs, shared readonly SDK/stdx/dependency inputs; no author assessment/contact.',
'Normal main build0; current frozen keyboard dispatcher0 once: original7 device modes, formal27 native vectors, API negatives, all6 review selectors.',
'Native-session0; application-lifecycle0; runtime-session0; direct binary verdicts retained rather than cjpm run.',
'Original integration1 preserved: default Auto PTY correctly used conservative ??; independent diagnosis/root qualification recorded.',
'Authorized fixed integration0, all11 modes; fixture SHA1f7f815c93a4a29d49901436259917fab01a62766cb62fa0c05aa35d5b1a3f12; original grid oracle unchanged.',
'Normal mandatory cjpm bundle0, no skip; CJP SHAe3196fccc18ff3fe3889245ad46d789abf52af5f2384fe7b36444f685f8e00f9.',
'Finite package audit0: all229 members safe and byte-equal to fixed source; current public keyboard-input.md included.',
'First own audit1 required obsolete keyboard.md; failed script/raw retained, corrected only own audit path, no rebundle.',
'Clean external KeyboardDecoder and dispatch builds/direct runs0; exact frozen source, only dependency manifest paths changed.',
'Bundled keyboard example build/direct PTY0; actual input/output, requested2004 cleanup and exact termios restoration retained.',
'Actual XTerm398 and XFCE1.1.4/VTE0.80.1: keys, one real clipboard-fixture paste, physical50x10 resize, direct0, termios/resources restored.',
'Actual QEMU10.0.13 kernelVT: keys/keymap, native VT_RESIZE50x10, settled original PNG, direct0, termios/resources restored; VM is not physical hardware.',
'Limits: XTerm Alt+z emitted UTF8 ú; VT ShiftTab→tab and ShiftInsert→insert. No unsupported modifier/backtab/console-paste capability claimed.',
'Live callback summaries record code/text; modifier bits separately covered by frozen decoder tests. Natural host EOF unexercised; real pipe/TTY EOF covered.',
'Unknown cursor/display capability stays Unknown; cleanup claims are requested2004 bytes plus exact termios/resources, not every host display mode.',
'VT collector framing attempt1 failed before keys; original raw preserved; r2 transition and r3 settled captures separately retained.',
'All1119 original input files checked: only authorized fixture differs; unchanged internal facts reused narrowly per AGENTS11.1 via raw/reuse-scope.json.',
'Per-phase immutable manifests/host indices under raw; 17 original actual-host PNGs cataloged in raw/png-catalog.json; 15 binary hashes in raw/binary-bindings.json.',
'Original RED, copied API temp originals, diagnosis, test overlay and collector/audit failures remain separately indexed; no original receipt overwritten.',
'T087-G01 stale whole-product checker not invoked/passed; TASK023/whole Linux acceptance and physical hardware remain unclaimed.',
'Overall immutable index: stablemanifest.json; source/test verification: raw/final-verification.json; remaining free bytes recorded there.'
]
assert len(lines)<=25
report=B/'report.md';assert not report.exists();report.write_text('\n'.join(lines)+'\n');report.chmod(0o444)
files={}
def add(p,category):
 if p.is_file() and not p.is_symlink():files[str(p.relative_to(B))]=dict(size=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest(),category=category)
for folder in ['raw','tools','artifacts','prepare']:
 for p in sorted((B/folder).rglob('*')):add(p,folder)
for name in ['report.md','READY.md','env.sh','cangjie-repo.toml','ACTUALGO']:add(B/name,'entry')
original=json.loads((B/'raw/source-manifest.json').read_text())
for rel in original['files']:add(B/'source'/rel,'fixed-source-or-authorized-test-overlay')
for x in json.loads((B/'raw/binary-bindings.json').read_text())['direct_binaries']:add(B/x['path'],'actual-direct-binary')
# Also bind the clean source package without indexing rebuildable intermediate targets.
for p in (B/'clean-unpacked/cjtui-0.0.0').rglob('*'):
 if p.is_file() and not any(a in {'target','.cjtui-build','build-script-cache'} for a in p.relative_to(B/'clean-unpacked/cjtui-0.0.0').parts):add(p,'clean-unpacked-input')
for p in (B/'clean-consumers').rglob('*'):
 if p.is_file() and 'target' not in p.relative_to(B/'clean-consumers').parts:add(p,'clean-public-consumer-input')
record=dict(task='TASK116',result='PASS_SCOPED_EXECUTION_WITH_RECORDED_QUALIFICATIONS',utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),product_source=source,independent_test_overlay=overlay,source_method='Own git archive fixed product, one authorized independent test fixture bytecopy; no product/spec/main mutation',required_zero_exit_phases=required,preserved_failed_phases={'integration':'original virtual Unicode fixture/default Auto mismatch; independent diagnosis+authorized test-only overlay','real-vt-host':'own collector accepted unterminated serial line; framing fixed, new r2/r3 phases','package-audit-command':'own obsolete required doc filename; actual approved keyboard-input.md present; new audit phase'},selected_real_host_indices=['raw/host-xterm/phase-index.json','raw/host-vte/phase-index.json','raw/host-vt-r3/phase-index.json'],scope_limits='Finite K001-K004 execution only; host keymap/capability limits in raw/host-qualification.json; no whole Linux/physical hardware acceptance or stale whole-product checker PASS',original_files=[dict(path=k,**v) for k,v in sorted(files.items())])
p=B/'stablemanifest.json';assert not p.exists();p.write_text(json.dumps(record,indent=2)+'\n');p.chmod(0o444)
print(json.dumps(dict(report_lines=len(lines),index_files=len(files),stablemanifest_sha256=hashlib.sha256(p.read_bytes()).hexdigest(),report_sha256=hashlib.sha256(report.read_bytes()).hexdigest(),actual_PNGs=17,actual_binaries=15)))
