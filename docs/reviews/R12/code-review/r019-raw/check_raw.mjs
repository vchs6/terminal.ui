import assert from 'node:assert/strict';
import fs from 'node:fs';
import { completeFrames, finalGrid } from '../r019-source/tests/support/terminal_frames.mjs';
const paths={oldCoherence:'/workspace/work/runtime-tests/r019-artifacts/cjtui-resize-QLuMDr/coherence',oldInflight:'/workspace/work/runtime-tests/r019-artifacts/cjtui-resize-5ftANm/inflight',newCoherence:'/workspace/work/runtime-implementation/runs/61ce9e5-coherence/cjtui-resize-mZ0l43/coherence',newInflight:'/workspace/work/runtime-implementation/runs/61ce9e5-coherence/cjtui-resize-mZ0l43/inflight'};
for(const [name,dir] of Object.entries(paths)) {
 const read=file=>fs.readFileSync(dir+'/'+file);
 const raw=read('session.raw'), frames=completeFrames(raw);
 assert(finalGrid(raw,['CJTUI_CO','01234567','        ']));
 assert.equal(read('before').toString(),read('after').toString());
 assert.equal(read('close-record.txt').toString(),'real_result=0 injected=0\n');
 const queries=read('queries.log').toString().trim().split('\n').map(s=>s.split(' ').map(Number));
 assert(queries.every(([,w,h])=>(w===24&&h===5)||(w===8&&h===3)));
 const mixed=frames.filter(({width:w,height:h})=>!((w===24&&h===5)||(w===8&&h===3)));
 if(name==='oldCoherence')assert(mixed.some(x=>x.width===24&&x.height===3));else assert.equal(mixed.length,0);
 if(name.endsWith('Inflight'))assert(frames.some(x=>x.width===24&&x.height===5));
 console.log(JSON.stringify({name,pairs:frames.map(f=>[f.width,f.height]),realPairs:queries.map(q=>q.slice(1)),settled:true,restored:true}));
}
