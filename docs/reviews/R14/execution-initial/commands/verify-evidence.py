from pathlib import Path
import hashlib,json,datetime,re
b=Path('/workspace/work/rich-text-execution');e=b/'evidence'
required=['bundle-warning-audit','clean-dependency-check','versions','root-build','root-check','rich-build','rich-direct','dynamic-build','dynamic-direct','core-build','core-direct','runtime-session','macro-positive-build','macro-positive-direct','contract','coordinates','layout','decoration','composition','colors','rich-example-build','rich-example-smoke','bundle','clean-prepare','clean-root-build','clean-root-check','clean-rich-build','clean-rich-direct','clean-example-build','clean-example-smoke','gui-rich-command','gui-grid','gui-finalize','provenance']
results=[]
for name in required:
 d=e/name;status=int((d/'exit').read_text());assert status==0,(name,status)
 results.append(dict(name=name,exit=status,start=(d/'start').read_text().strip(),end=(d/'end').read_text().strip(),cwd=(d/'cwd').read_text().strip(),command=(d/'command').read_text().strip(),stdout_sha256=hashlib.sha256((d/'stdout').read_bytes()).hexdigest(),stderr_sha256=hashlib.sha256((d/'stderr').read_bytes()).hexdigest()))
for name in ['rich-direct','clean-rich-direct']:
 lines=(e/name/'stdout').read_text().splitlines();assert not any(x.startswith('FAIL:') for x in lines)
 assert sum(x.startswith('PASS: CSI UTF8 ') and not x.startswith('PASS: CSI UTF8 immediate first fault,') for x in lines)==98
 assert 'CSI UTF8 first-fault regression failures: 0' in lines
 assert lines[-1]=='PASS: rich text public contract'
results.append(dict(name='whole-archive-boundary',exit=int((e/'whole-archive-boundary/exit').read_text()),classification='known future whole-product scope failure; not TASK083 rich package consumer failure'))
assert results[-1]['exit']==1
assert 'Incomplete product bundle: examples/composition/cjpm.toml' in (e/'whole-archive-boundary/stderr').read_text()
for f in e.rglob('*.json'):json.loads(f.read_text())
inventory=json.loads((e/'source-inventory.json').read_text());assert all(hashlib.sha256((b/'source'/f).read_bytes()).hexdigest()==v for f,v in inventory.items())
for profile in ['xterm-default','xfce-vte']:
 d=e/'gui-rich'/profile/'q';m=json.loads((d/'final-artifacts.json').read_text());assert all(hashlib.sha256((d/f).read_bytes()).hexdigest()==v for f,v in m['artifacts'].items())
finding=json.loads((e/'gui-visible-finding.json').read_text());assert finding['status'].startswith('FAIL')
(e/'execution-summary.json').write_text(json.dumps(dict(verified_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),fresh_results=results,rich_old_groups=11,rich_new_cases=98,rich_failures=0,clean_rich_old_groups=11,clean_rich_new_cases=98,clean_rich_failures=0,macro_negative_reused_cases=15,actual_gui_hosts=2,gui_stages_per_host=5,actual_gui_visible_failed_hosts=2,overall_verdict='FAIL',blocking_finding='R14T083001',raw_model_grid_pass_is_not_actual_host_pass=True,source_unchanged=True,strict_json=True),indent=2)+'\n')
print(json.dumps(dict(fresh_required_commands=len(required),known_boundary_exit=1,rich='11+98 failures0 twice',gui_raw_model='2 hosts x5 logical full grids match, PNG shows visible failure',overall_verdict='FAIL R14T083001',fixed_source_unchanged=True)))
