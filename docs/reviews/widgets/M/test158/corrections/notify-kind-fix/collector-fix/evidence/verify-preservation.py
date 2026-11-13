from pathlib import Path
import re,subprocess,json,hashlib,collections
root=Path('/workspace/work/widgets-composite-tests/notify-kind-fix/collector-fix');source=root/'source';e=root/'evidence'
base='83b264db784af638f3c6554bef595316ecdb0e3c'
files=sorted(p for folder in ['src','device/src','prerequisite/src'] for p in (source/'tests/widgets_composite'/folder).glob('*.cj'))
pattern=r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|[A-Za-z_]\w*|\d+|[^\s]'
def tokens(text):return [x for x in re.findall(pattern,text,re.S) if not x.startswith('//') and not x.startswith('/*')]
def named_calls(toks,names):
    result=[]
    for i,t in enumerate(toks[:-1]):
        if t not in names or toks[i+1]!='(':continue
        depth=0
        for j in range(i+1,len(toks)):
            if toks[j]=='(':depth+=1
            elif toks[j]==')':
                depth-=1
                if depth==0:result.append(toks[i:j+1]);break
    return result
rows=[];changed=[]
for p in files:
    rel=str(p.relative_to(source));before=subprocess.check_output(['git','show',base+':'+rel],cwd=source,text=True);after=p.read_text()
    old=tokens(before);new=tokens(after)
    assert collections.Counter(x for x in old if x.startswith('"'))==collections.Counter(x for x in new if x.startswith('"')),rel
    names={'check','equal','focused','focus','expectCode','dispatch','onMount','onKey','onKeyEvent','onKeyCapture'}
    assert named_calls(old,names)==named_calls(new,names),rel
    if before!=after:changed.append(rel)
    rows.append({'path':rel,'base_sha256':hashlib.sha256(before.encode()).hexdigest(),'final_sha256':hashlib.sha256(after.encode()).hexdigest()})
for rel in ['tests/widgets_composite/expected.json','tests/widgets_composite/fixtures/local-theme.toml','tests/widgets_composite/COVERAGE.md','tests/widgets_composite/pty.py']:
    assert subprocess.check_output(['git','show',base+':'+rel],cwd=source)==(source/rel).read_bytes(),rel
(e/'oracle-preservation.json').write_text(json.dumps({'base':base,'scope_files':len(files),'changed_files':changed,'result':'PASS','files':rows,'checks':['Every literal string token retained with identical multiplicity','All check/equal/focused/focus/expectCode/dispatch/onMount/onKey/onKeyEvent/onKeyCapture call token sequences unchanged','expected.json/theme fixture/COVERAGE.md/PTY driver byte-identical'],'limitation':'Source-range preservation only. Token equivalence is not target typing/runtime behavior verification.'},indent=2)+'\n')
print('ASSERTION_AND_ORACLE_PRESERVATION_PASS',len(files),'files;',len(changed),'changed; no runtime claim')
