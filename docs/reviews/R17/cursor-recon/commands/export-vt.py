import re,base64,pathlib,struct,subprocess,tarfile,sys
for arg in sys.argv[1:]:
 r=pathlib.Path(arg);s=(r/'vt-serial.log').read_text(errors='replace')
 m=re.search('EVIDENCE_TAR_BASE64_BEGIN\n(.*?)EVIDENCE_TAR_BASE64_END',s,re.S)
 if m:
  (r/'evidence.tar').write_bytes(base64.b64decode(m[1]));(r/'evidence').mkdir(exist_ok=True)
  with tarfile.open(r/'evidence.tar') as t:t.extractall(r/'evidence',filter='data')
 for m in re.finditer(r'GRID seq=(\d+) phase=(\w+) path=/dev/(\w+) n=(-?\d+) hex=([0-9a-f]*)',s):
  seq,phase,dev,n,he=m.groups();blob=bytes.fromhex(he);(r/f'{seq}-{phase}-{dev}.bin').write_bytes(blob)
  if dev=='vcsa1' and len(blob)>4:
   rows,cols,x,y=blob[:4];text='\n'.join(bytes(blob[4+row*cols*2:4+(row+1)*cols*2:2]).decode('cp437') for row in range(rows));(r/f'{seq}-{phase}-{dev}.txt').write_text(text)
  if dev=='vcsu1' and blob:
   vals=struct.unpack('<'+'I'*(len(blob)//4),blob);text='\n'.join(''.join(chr(c) for c in vals[row*80:(row+1)*80]) for row in range(25));(r/f'{seq}-{phase}-{dev}.txt').write_text(text)
 for ppm in r.glob('*.ppm'):subprocess.run(['convert',str(ppm),str(ppm.with_suffix('.png'))],check=True)
 for trace in (r/'evidence').glob('*.strace'):
  output=bytearray();inputs=bytearray()
  for line in trace.read_text().splitlines():
   m=re.search(r'\b(write\(1|read\(0), "((?:\\x[0-9a-f]{2})*)",.*?= (\d+)$',line)
   if m:
    val=bytes.fromhex(m[2].replace('\\x',''))[:int(m[3])]
    (output if m[1]=='write(1' else inputs).extend(val)
  (r/'stdout-raw.ansi').write_bytes(output);(r/'stdin-raw.bin').write_bytes(inputs)
 print(r, 'exported',bool(m))
