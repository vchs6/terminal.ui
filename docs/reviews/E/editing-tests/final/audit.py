import collections, hashlib, json, pathlib, re, shutil, subprocess
root=pathlib.Path('/workspace/work/editing-tests/final'); source=root/'source'
base='da9eaf4044cba917d12f441e041e164deb5eff80'
def git(*args): return subprocess.check_output(['git','-C',str(source),*args],text=True).strip()
def sha(path): return hashlib.sha256(pathlib.Path(path).read_bytes()).hexdigest()
def listed(*paths): return subprocess.check_output(['git','-C',str(source),'ls-files','-z','--',*paths]).decode().split('\0')[:-1]
assert git('status','--porcelain') == '', 'source not clean'
changed=git('diff','--name-only',base,'HEAD').splitlines()
assert changed and all(p.startswith('tests/editing/') for p in changed)
assert git('diff',base,'HEAD','--','src','native','build.cj','cjpm.toml','openspec','AGENTS.md','tests/run-slice.sh') == ''
product={p:sha(source/p) for p in listed('src','native','third_party/licenses','build.cj','cjpm.toml')}
tests={p:sha(source/p) for p in listed('tests/editing')}
inputs={str(p):sha(p) for p in [
 pathlib.Path('/workspace/work/terminal.ui/AGENTS.md'),
 pathlib.Path('/workspace/work/terminal.ui/openspec/changes/implement-linux-input-editing/design.md'),
 pathlib.Path('/workspace/work/terminal.ui/openspec/changes/implement-linux-input-editing/tasks.md'),
 pathlib.Path('/workspace/work/terminal.ui/.superpowers/sdd/tasks-implement-linux-input-editing/task-118-final-brief.md'),
 pathlib.Path('/workspace/work/CangjieSkills/.agents/skills/cangjie-coding/SKILL.md'),
 pathlib.Path('/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip'),
 root/'env.sh',source/'cangjie-repo.toml',source/'tests/editing/cjpm.lock',
 source/'tests/editing/prerequisites/cjpm.lock',source/'tests/editing/missing_api/cjpm.lock'] if p.is_file()}
binaries={str(p.relative_to(root)):sha(p) for p in [source/'tests/editing/prerequisites/target/release/bin/main',
 source/'native/libunicodedata.a',source/'native/libcjtui_terminal.a',source/'native/libcjtui_capabilities.a',
 source/'native/libcjtui_glyphs.a',source/'.cjtui-build/unicode-0.1.0.cjp'] if p.is_file()}
versions={}; tool_hashes={}
for tool,args in [('cjc',['-v']),('cjpm',['-v']),('node',['--version']),('python3',['--version']),('cc',['--version'])]:
 path=shutil.which(tool); r=subprocess.run([path,*args],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
 versions[tool]=dict(path=path,exit=r.returncode,output=r.stdout.strip());tool_hashes[path]=sha(path)
text=re.sub(r'\x1b\[[0-9;]*m','',(root/'raw/12-full-consumer-final-build/stderr').read_text())
counts=collections.Counter(line for line in text.splitlines() if line.startswith('error:'))
assert sum(counts.values()) == 112
allowed={"error: undeclared type name 'TextEditController'","error: undeclared type name 'TextEditIssue'",
 "error: undeclared identifier 'TextSelection'","error: undeclared identifier 'TextEditController'",
 "error: undeclared identifier 'TextEditIssue'","error: undeclared identifier 'TextEditLimits'",
 "error: no matching function for operator '()' function call"}
assert set(counts).issubset(allowed)
for block in re.split(r'(?=^error:)',text,flags=re.M)[1:]:
 if block.startswith('error: no matching'):
  assert any('TextInput(' in line or 'TextArea(' in line for line in block.splitlines()[1:8])
assert (root/'raw/13-final-syntax-and-fixtures/stderr').read_bytes()==b''
for phase,wanted in [('05-missing-editor-red',1),('11-prerequisite-final-build',0),('12-full-consumer-final-build',1),('13-final-syntax-and-fixtures',0),('14-final-positive-binary',0)]:
 assert int((root/'raw'/phase/'exit').read_text())==wanted
data=dict(base=base,test_commit=git('rev-parse','HEAD'),changed_files=changed,product_sha256=product,
 test_sha256=tests,input_sha256=inputs,binary_sha256=binaries,versions=versions,tool_sha256=tool_hashes,
 full_body_diagnostic_counts=dict(counts),full_body_typechecked=False,editor_behavior_executed=False,
 product_pty_executed=False,editor_race_executed=False,Applied_adapter_present=False,
 requested_model='Sol/high; serving not independently introspected',
 skills=['superpowers:test-driven-development','superpowers:verification-before-completion','superpowers:using-git-worktrees','superpowers:systematic-debugging','CangjieSkills:cangjie-coding'])
target=root/'input-bindings.json';target.write_text(json.dumps(data,indent=2,sort_keys=True)+'\n');target.chmod(0o444)
print(json.dumps(dict(commit=data['test_commit'],product_files=len(product),test_files=len(tests),
 product_and_dispatcher_unchanged=True,clean_source=True,input_bindings_sha256=sha(target),
 full_body_errors=dict(counts),binary_sha256=binaries,versions=versions),indent=2))
