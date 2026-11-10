from pathlib import Path
import json,re,shutil,hashlib,subprocess
b=Path('/workspace/work/dynamic-execution');s=b/'source';o=b/'evidence/reuse';o.mkdir(exist_ok=True)
r=Path('/workspace/work/runtime-execution/evidence/reused-macro-negatives')
shutil.copytree(r,o/'macro-negative15',dirs_exist_ok=True)
rows=[]
for line in (s/'tests/runtime/macros/negative/cases.tsv').read_text().splitlines():
 name,loc,pattern=line.split('\t');d=r/'artifacts';exit=int((d/f'{name}.exit').read_text());diag=(d/f'{name}.diagnostics').read_text();assert exit!=0 and loc in diag and re.search(pattern,diag,re.I),(name,exit,diag)
 rows.append(dict(name=name,actualexit=exit,diagnostic_sha256=hashlib.sha256(diag.encode()).hexdigest(),diagnostic_valid=True))
(o/'macro-negative-independent-audit.json').write_text(json.dumps(rows,indent=2)+'\n')
# Reuse only direct Frame/color encoding paths. Rendering/layout/RuntimeSession paths are fresh executions.
for path in ['command','exit','start','end','stdout','stderr']:
 p=Path('/workspace/work/runtime-execution/evidence/regressions')/path
 if p.exists():shutil.copy2(p,o/('r12-regressions-'+path))
raw=(o/'r12-regressions-stdout').read_text();assert 'PASS: Color constructor/channel Eq 0/0' in raw
(o/'scope.json').write_text(json.dumps(dict(rule='AGENTS.md 11.1',source_commit='c3d743d2dd5cb125e4ca435b2842d1b10c501281',macro_source_commit=(r/'head').read_text().strip(),macro_negative15='all 15 compiler-negative cases have actual nonzero exit, source location and matching required diagnostic',lower_layer_scope='unchanged Frame/Cell/ANSI/Color/Style/text code; reuse direct Frame/color-only observations, not render(), RuntimeSession or aggregate suite status',r12_aggregate_exit=1,r12_aggregate_failure='later composition fixture requires unavailable independent harness source; retained as historical failure, no aggregate PASS claimed',impact_proof='../fixed-content-proof.json'),indent=2)+'\n')
