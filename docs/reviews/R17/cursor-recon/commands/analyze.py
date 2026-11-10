from PIL import Image,ImageChops
import pathlib,json,hashlib,re
b=pathlib.Path(__file__).resolve().parents[1];results=[]
for host in ['xterm','xfce-vte','vt']:
 for state in ['visible','hidden']:
  r=b/'raw'/host/state;refphase='changed' if state=='visible' else 'baseline';ref=Image.open(r/f'{refphase}-0.png').convert('RGB')
  row={'host':host,'initial':state,'pixels':ref.size,'reference':refphase+'-0.png','phases':{}}
  for phase in ['baseline','changed','restored','exited']:
   frames=[]
   for f in sorted(r.glob(phase+'-*.png')):
    a=Image.open(f).convert('RGB');diff=ImageChops.difference(a,ref);bbox=diff.getbbox();count=sum(px!=(0,0,0) for px in diff.getdata());frames.append({'file':f.name,'different_pixels':count,'bbox':bbox,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()})
   row['phases'][phase]=frames
  rawdir=r/'evidence' if host=='vt' else r
  row['responses']={p.name:p.read_bytes().hex() for p in sorted(rawdir.glob('*response.bin'))}
  if host=='vt':
   row['vcsa']={p.name:{'rows':p.read_bytes()[0],'cols':p.read_bytes()[1],'x':p.read_bytes()[2],'y':p.read_bytes()[3],'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in sorted(r.glob('*-vcsa1.bin'))}
   row['vcsa_all_equal']=len(set(p.read_bytes() for p in r.glob('*-vcsa1.bin')))==1
   row['vcsu_all_equal']=len(set(p.read_bytes() for p in r.glob('*-vcsu1.bin')))==1
   row['ppm_png_rgb_equal']=all(Image.open(p).convert('RGB').tobytes()==Image.open(p.with_suffix('.png')).convert('RGB').tobytes() for p in r.glob('*.ppm'))
  results.append(row)
(b/'raw/analysis.json').write_text(json.dumps(results,indent=2)+'\n')
for row in results:
 print(row['host'],row['initial'],row['pixels'],'response',row['responses'])
 for phase,frames in row['phases'].items():print(' ',phase,[x['different_pixels'] for x in frames],list({str(x['bbox']) for x in frames}))
 if row['host']=='vt':print(' vcsa=',row['vcsa'],'all_same=',row['vcsa_all_equal'],row['vcsu_all_equal'],'lossless=',row['ppm_png_rgb_equal'])
