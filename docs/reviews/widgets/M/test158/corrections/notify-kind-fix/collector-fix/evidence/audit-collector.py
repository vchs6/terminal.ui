from pathlib import Path
import hashlib,json,re,subprocess
root=Path('/workspace/work/widgets-composite-tests/notify-kind-fix/collector-fix')
source=root/'source'
files=sorted(p for folder in ['src','device/src','prerequisite/src'] for p in (source/'tests/widgets_composite'/folder).glob('*.cj'))
constructors={'Column','Row','StatusBar','SplitPane','ScrollView'}
def mask(text):
    return re.sub(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"',lambda m:''.join('\n' if c=='\n' else ' ' for c in m.group()),text,flags=re.S)
def closing(text,index,opener,closer):
    depth=0
    for j in range(index,len(text)):
        if text[j]==opener:depth+=1
        elif text[j]==closer:
            depth-=1
            if depth==0:return j
    raise AssertionError('unclosed block')
def inspect(text):
    hidden=mask(text);blocks=[]
    for m in re.finditer(r'\b(?:Column|Row|StatusBar|SplitPane|ScrollView)\b',hidden):
        j=m.end()
        while j<len(hidden) and hidden[j].isspace():j+=1
        if j<len(hidden) and hidden[j]=='(':
            j=closing(hidden,j,'(',')')+1
            while j<len(hidden) and hidden[j].isspace():j+=1
        if j>=len(hidden) or hidden[j]!='{':continue
        end=closing(hidden,j,'{','}')
        body=hidden[j+1:end]
        bare=[]
        for n in re.finditer(r'(?:^|[;\n])\s*([A-Za-z_]\w*)\s*(?=$|[;\n])',body):
            prefix=body[:n.start(1)]
            if prefix.count('{')==prefix.count('}'):
                bare.append({'name':n.group(1),'line':text.count('\n',0,j+1+n.start(1))+1})
        blocks.append({'constructor':m.group(),'line':text.count('\n',0,m.start())+1,'bare_top_level_identifiers':bare})
    return blocks
rows=[]; old_issues=[]
for path in files:
    rel=str(path.relative_to(source))
    before=subprocess.check_output(['git','show','c940315729615824fcf1a051b0d4265f98b177ce:'+rel],cwd=source,text=True)
    old,new=inspect(before),inspect(path.read_text())
    for block in old:
        if block['bare_top_level_identifiers']:old_issues.append({'file':rel,**block})
    assert not any(b['bare_top_level_identifiers'] for b in new),(rel,new)
    rows.append({'file':rel,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'before_blocks':old,'after_blocks':new})
result={'scope':'Exactly the 11 formal headless/device/prerequisite CJ files; collector bare preconstructed-value expressions only','result':'PASS','old_affected_collector_blocks':old_issues,'old_affected_block_count':len(old_issues),'new_bare_preconstructed_value_expressions':0,'files':rows,'manual_checks':['Dynamic insertBefore/append and Application/openOverlay passing existing components are supported and intentionally unchanged','SharedPanel.build constructs its three children inside the runtime collector; no preconstructed child expression there','No production or constructor-collector semantic change; let-held optional Component arrays only preserve the original object handles'],'limitations':'Bounded source audit and preservation checks, not a compiler or M runtime pass'}
(root/'evidence/collector-audit.json').write_text(json.dumps(result,indent=2)+'\n')
print('COLLECTOR_AUDIT_PASS',len(files),'files;',len(old_issues),'old affected collector blocks; remaining bare values=0')
