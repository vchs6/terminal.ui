#!/usr/bin/env python3
"""Verify finite M archive bytes/context only; never build or execute product."""
from pathlib import Path
import hashlib,json,subprocess
M=Path(__file__).resolve().parents[1]
R=M.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
d=json.loads((M/'source-copy-index.json').read_text())
for v in d['copied']+d['already_public_unchanged']:
 assert sha(R/v['proposed_archive'])==v['sha256'],v['proposed_archive']
 assert sha(Path(v['original']))==v['sha256'],v['original']
ctx=json.loads((M/'git-context-index.json').read_text())
for v in ctx:
 data=subprocess.check_output(['git','-C',str(R),'cat-file','blob',v['git_blob']])
 assert hashlib.sha256(data).hexdigest()==v.get('sha256',v.get('actual_git_sha256')),v
 if 'archive' in v:assert (R/v['archive']).read_bytes()==data,v
png=json.loads((M/'execution161/raw/final-verification/original-png-catalogue.json').read_text())
for v in png['all_original_PNGs']:
 p=M/'execution161/raw'/v['relative_to_raw'];assert sha(p)==v['sha256'],p
assert len(png['all_original_PNGs'])==65
assert len(list((M/'execution161/raw').glob('*/phase-index.json')))==22
local=json.loads((M/'index.json').read_text())
for v in local['files']:
 p=M/v['path'];assert p.stat().st_size==v['bytes'] and sha(p)==v['sha256'],p
print(json.dumps({'original_copy_bindings':len(d['copied'])+len(d['already_public_unchanged']),'Git_context_rows':len(ctx),'original_PNGs':65,'phase_indices':22,'archive_files':len(local['files']),'result':'PASS byte/context verification only'}))
