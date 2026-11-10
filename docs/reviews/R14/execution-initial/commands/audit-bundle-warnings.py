from pathlib import Path
import re,json,collections
b=Path('/workspace/work/rich-text-execution');raw=(b/'evidence/bundle/stdout').read_text();clean=re.sub(r'\x1b\[[0-9;]*m','',raw)
rows=[]
for line in clean.splitlines():
 m=re.match(r'(.+?):(\d+):(\d+): warning: ([A-Z.0-9]+): (.*)',line)
 if m:rows.append(dict(file=m[1].replace(str(b/'source')+'/',''),line=int(m[2]),column=int(m[3]),rule=m[4],message=m[5]))
assert rows and 'cjpm bundle success' in clean
report=dict(bundle_exit=0,lint_enabled=True,warning_count=len(rows),by_rule=dict(collections.Counter(x['rule'] for x in rows)),by_file=dict(collections.Counter(x['file'] for x in rows)),warnings=rows,assessment='Actual advisory CJPM lint diagnostics retained. Includes package-directory heuristics, API exception comments, length/scope/style and usage advice; project conventions do not promote these advisory heuristics into new gates. Not a claim of lint-clean source. No warnings suppressed or product fixes made by executor.')
(b/'evidence/bundle-warning-audit.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:report[k] for k in ['bundle_exit','lint_enabled','warning_count','by_rule']}))
