from pathlib import Path
import json
root=Path(__file__).resolve().parent
cases=[]
def add(name,text,payload,kind,position='key',decoded=None):
    path=root/'inputs'/f'{name}.toml'; path.write_text(text)
    cases.append(dict(name=name,input=str(path.relative_to(root)),payload=payload,token_type=kind,position=position,expected_bytes=len(payload.encode()),decoded_bytes=decoded))
add('bare','alpha=true\n','alpha','Text',decoded=5)
add('basic','"alpha"=true\n','alpha','String',decoded=5)
add('literal',"'alpha'=true\n",'alpha','RawString',decoded=5)
add('empty-basic','""=true\n','','String',decoded=0)
add('escape-u','"\\u0061"=true\n',r'\u0061','StringEsc',decoded=1)
add('escape-U','"\\U0001F600"=true\n',r'\U0001F600','StringEsc',decoded=4)
add('escape-quote','"a\\\"b"=true\n',r'a\"b','StringEsc',decoded=3)
add('escape-backslash','"a\\\\b"=true\n',r'a\\b','StringEsc',decoded=3)
add('literal-backslash',"'\\u0061'=true\n",r'\u0061','RawString',decoded=6)
add('mixed-unicode','"界\\u0061"=true\n','界'+r'\u0061','StringEsc',decoded=4)
for n in [1024,1025]:
    raw='界'*341+'x'*(n-1023)
    add(f'raw-unicode-{n}','"'+raw+'"=true\n',raw,'String',decoded=n)
    add(f'bare-{n}','a'*n+'=true\n','a'*n,'Text',decoded=n)
    add(f'literal-{n}',"'"+'a'*n+"'=true\n",'a'*n,'RawString',decoded=n)
    u=r'\u0061'*170+'a'*(n-1020)
    add(f'escape-u-{n}','"'+u+'"=true\n',u,'StringEsc',decoded=170+n-1020)
    U=r'\U0001F600'*102+'a'*(n-1020)
    add(f'escape-U-{n}','"'+U+'"=true\n',U,'StringEsc',decoded=408+n-1020)
    for label,unit in [('quote',r'\"'),('backslash',r'\\')]:
        s=unit*512+'a'*(n-1024)
        add(f'escape-{label}-{n}','"'+s+'"=true\n',s,'StringEsc',decoded=512+n-1024)
    for label,fmt in [('dotted','root."%s"=true\n'),('table','["%s"]\nv=true\n'),('array-table','[["%s"]]\nv=true\n'),('inline','root={"%s"=true}\n'),('array-inline','root=[{"%s"=true}]\n')]:
        add(f'{label}-{n}',fmt%u,u,'StringEsc',decoded=170+n-1020)
    add(f'value-{n}','name="'+u+'"\n',u,'StringEsc','value',decoded=170+n-1020)
# Explicit semantic-equivalence stress with a schema-valid ASCII variable name.
s=r'\U00000061'*103
add('schema-valid-escaped-1030','schema_version=1\nname="x"\n[variables]\n"'+s+'"={type="bool",value=true}\n',s,'StringEsc',decoded=103)
add('schema-valid-plain-103','schema_version=1\nname="x"\n[variables]\n'+'a'*103+'={type="bool",value=true}\n','a'*103,'Text',decoded=103)
# Quoted punctuation and value/comment strings must never create key segments.
add('quoted-dot-bracket','"a.b[{]"=true\n','a.b[{]','String',decoded=6)
add('value-comment-control','# "'+('x'*1025)+'"\nname="'+('x'*1025)+'"\n','x'*1025,'String','value',decoded=1025)
(root/'cases.json').write_text(json.dumps(cases,ensure_ascii=False,indent=2)+'\n')
print(len(cases))
