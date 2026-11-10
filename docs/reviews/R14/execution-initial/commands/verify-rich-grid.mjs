import {readFileSync,writeFileSync} from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const base='/workspace/work/rich-text-execution/evidence/gui-rich';
const seg=new Intl.Segmenter('en',{granularity:'grapheme'});
const clusters=s=>[...seg.segment(s)].map(x=>x.segment);
const width=g=>['界','👩‍💻'].includes(g)?2:1;
const emptyStyle=()=>({fg:'default',bg:'default',bold:false,dim:false,italic:false,underline:false,inverse:false,strikethrough:false});
const cell=(g=' ',w=1,style=emptyStyle())=>({grapheme:g,width:w,style:{...style}});
const blank=(w,h)=>Array.from({length:h},()=>Array.from({length:w},()=>cell()));
const sha=b=>createHash('sha256').update(b).digest('hex');
const title='Rich text — t: toggle style, q: quit';
const body='ANSI styles remain structured';
// Independent literal hand-golden. Spans cover one whole cluster at the first scalar style.
// R10 policy: XTerm TERM=xterm terminfo colors=8 -> nearest RGB White; XFCE truecolor preserves RGB.
const expected=(w,h,green,profile)=>{
 const g=blank(w,h);
 function put(row,text,style,start=0){let x=start;for(const t of clusters(text)){const n=width(t);g[row][x]=cell(t,n,style);if(n===2)g[row][x+1]=cell('',0,style);x+=n;}return x;}
 put(0,title,emptyStyle());
 put(1,'ANSI styles',{...emptyStyle(),fg:profile==='xterm-default'?'named7':'rgb:80,180,255',bold:true});
 put(1,' remain structured',emptyStyle(),11);
 put(2,'é',{...emptyStyle(),fg:green?'named2':'named1'});
 put(2,' and 界 👩‍💻',{...emptyStyle(),italic:true},1);
 put(3,'ANSI styles',{...emptyStyle(),fg:'named3',bold:true});
 put(3,' remain structured',{...emptyStyle(),fg:'named3'},11);
 return g;
};
const results=[];
for(const profile of ['xterm-default','xfce-vte']){
 const d=`${base}/${profile}/q`;let grid=blank(100,28),r=0,c=0,style=emptyStyle();const stages=[];
 for(const [name,w,h,green] of [['initial',100,28,false],['green',100,28,true],['red',100,28,false],['resized',120,34,false],['resized-green',120,34,true]]){
  const previous=structuredClone(grid); if(grid.length!==h||grid[0].length!==w){grid=blank(w,h);for(let y=0;y<Math.min(h,previous.length);y++)for(let x=0;x<Math.min(w,previous[0].length);x++)grid[y][x]=previous[y][x];}
  const raw=readFileSync(`${d}/example-${name}.raw`),data=raw.toString('utf8');let i=0;
  while(i<data.length){
   if(data[i]==='\x1b'){
    const m=/^\x1b\[([0-?]*)([ -/]*)([@-~])/.exec(data.slice(i));assert(m,`${profile}/${name}: unknown escape`);
    const p=m[1],cmd=m[3],ns=p.split(';').map(x=>Number(x||0));
    if(cmd==='H'||cmd==='f'){r=(ns[0]||1)-1;c=(ns[1]||1)-1;}
    else if(cmd==='J'&&ns[0]===2)grid=blank(w,h);
    else if(cmd==='K'){for(let x=c;x<w;x++)grid[r][x]=cell(' ',1,style);}
    else if(cmd==='m'){
     for(let k=0;k<ns.length;k++){
      const n=ns[k];if(n===0)style=emptyStyle();
      else if([1,2,3,4,7,9].includes(n))style[({1:'bold',2:'dim',3:'italic',4:'underline',7:'inverse',9:'strikethrough'})[n]]=true;
      else if(n===22){style.bold=false;style.dim=false;}
      else if([23,24,27,29].includes(n))style[({23:'italic',24:'underline',27:'inverse',29:'strikethrough'})[n]]=false;
      else if(n===39||n===49)style[n===39?'fg':'bg']='default';
      else if(n>=30&&n<=37)style.fg=`named${n-30}`;
      else if(n>=90&&n<=97)style.fg=`named${n-90+8}`;
      else if(n>=40&&n<=47)style.bg=`named${n-40}`;
      else if(n>=100&&n<=107)style.bg=`named${n-100+8}`;
      else if(n===38||n===48){let key=n===38?'fg':'bg';if(ns[k+1]===2){style[key]=`rgb:${ns.slice(k+2,k+5).join(',')}`;k+=4;}else {assert.equal(ns[k+1],5);style[key]=`indexed${ns[k+2]}`;k+=2;}}
      else assert.fail(`Unexpected SGR ${n}`);
     }
    }else assert(['h','l'].includes(cmd),`Unexpected CSI ${m[0]}`);
    i+=m[0].length;continue;
   }
   if(data[i]==='\r'){c=0;i++;continue;}if(data[i]==='\n'){r++;i++;continue;}
   const end=data.indexOf('\x1b',i);const text=data.slice(i,end<0?undefined:end);let used=0;
   for(const g of clusters(text)){if(g==='\r'||g==='\n')break;const n=width(g);if(r>=0&&r<h&&c>=0&&c<w){grid[r][c]=cell(g,n,style);if(n===2&&c+1<w)grid[r][c+1]=cell('',0,style);}c+=n;used+=g.length;}
   assert(used>0,`Unhandled character ${JSON.stringify(data[i])}`);i+=used;
  }
  const want=expected(w,h,green,profile);
  writeFileSync(`${d}/example-${name}-actual-full-grid.json`,JSON.stringify(grid)+'\n');
  writeFileSync(`${d}/example-${name}-expected-full-grid.json`,JSON.stringify(want)+'\n');
  writeFileSync(`${d}/example-${name}-actual-full-grid.txt`,grid.map(row=>row.map(x=>x.grapheme).join('')).join('\n')+'\n');
  assert.deepEqual(grid,want,`${profile}/${name}: full text/cell/style grid`);
  if(name==='green'||name==='red'||name==='resized-green')for(let y=0;y<h;y++)if(y!==2)assert.deepEqual(grid[y],previous[y],`untouched row${y}`);
  stages.push({name,width:w,height:h,raw_sha256:sha(raw),full_grid_equal:true,untouched_rows_verified:name==='green'||name==='red'||name==='resized-green'});
 }
 for(const which of ['inner','outer']){const fields=Object.fromEntries(readFileSync(`${d}/${which}-tty.txt`,'utf8').trim().split('\n').map(l=>l.split('=')));assert.equal(fields.ready_termios,fields.exit_termios);assert.equal(fields.exit_status,'0');assert.equal(fields.ready_size,'28 100');assert.equal(fields.exit_size,'34 120');}
 const result={profile,stages,restoration_exact:true,q_exit:0,cluster_policy:'Intl.Segmenter grapheme segmentation, width2 only known literal CJK and emoji; no scalar-cell expansion'};
 writeFileSync(`${d}/rich-state-verification.json`,JSON.stringify(result,null,2)+'\n');results.push(result);
}
console.log(JSON.stringify(results,null,2));
