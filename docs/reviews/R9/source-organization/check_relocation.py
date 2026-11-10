from pathlib import Path
import re, subprocess, sys
root=Path(sys.argv[1]); baseline='1dcf9693a57e1f77d02f5b9279462495c160dcf2'
starts=re.compile(r'^(?:(?:public|internal|private)\s+)?(?:(enum|struct|class|interface|func|let|var)\s+(\w+)|(foreign)\s*\{)',re.M)
lex=re.compile(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*.*?\*/|\s+|;|.',re.S)
def declarations(files):
 result={}
 for name,text in files:
  text=re.sub(r'^(?:public\s+)?import\s+[^\n]*\n|^package\s+[^\n]*\n','',text,flags=re.M)
  matches=list(starts.finditer(text))
  for i,m in enumerate(matches):
   key=(m.group(1),m.group(2)) if not m.group(3) else ('foreign','terminal')
   fragment=text[m.start():matches[i+1].start() if i+1<len(matches) else len(text)]
   tokens=[x for x in lex.findall(fragment) if not(x.isspace() or x==';' or x.startswith('//') or x.startswith('/*'))]
   if key in result: raise ValueError(f'duplicate declaration: {key}')
   result[key]=tokens
 return result
paths=subprocess.check_output(['git','-C',str(root),'ls-tree','-r','--name-only',baseline,'src']).decode().splitlines()
old=declarations((p,subprocess.check_output(['git','-C',str(root),'show',baseline+':'+p]).decode()) for p in paths if p.endswith('.cj'))
new=declarations((str(p),p.read_text()) for p in (root/'src').rglob('*.cj'))
errors=[]
for key in old.keys()|new.keys():
 if old.get(key)!=new.get(key): errors.append(str(key))
print('DIFFERENT '+', '.join(errors) if errors else f'PASS: all {len(old)} top-level declaration token sequences preserved (except package/import, whitespace/comments and optional semicolons)')
sys.exit(bool(errors))
