import fs from 'node:fs';
import zlib from 'node:zlib';
import crypto from 'node:crypto';
import {fail,safe,digest,checkInline} from './core.mjs';

// Parse the decompressed stream without materializing file contents or extracting paths.
class Reader {
  constructor(stream) { this.it=stream[Symbol.asyncIterator](); this.q=[]; this.n=0; }
  async take(n, consume) {
    while (n) {
      if (!this.n) { const v=await this.it.next(); if(v.done) fail('truncated tar'); this.q.push(v.value); this.n+=v.value.length; }
      const c=this.q[0], k=Math.min(n,c.length); await consume(c.subarray(0,k)); n-=k; this.n-=k; if(k===c.length)this.q.shift(); else this.q[0]=c.subarray(k);
    }
  }
  async buffer(n) { const a=[]; await this.take(n,c=>a.push(c)); return Buffer.concat(a,n); }
  async finish() { for(const c of this.q) if(c.some(x=>x!==0)) fail('nonzero data after tar end'); for(;;) { const v=await this.it.next(); if(v.done) break; if(v.value.some(x=>x!==0)) fail('nonzero data after tar end'); } }
}
const str = b => b.toString('utf8').replace(/\0.*$/s,'');
function number(b) { const s=str(b).trim(); if (!/^[0-7]*$/.test(s)) fail('invalid tar number'); return parseInt(s||'0',8); }
function pax(b) { let i=0, result={}; while(i<b.length) { const j=b.indexOf(32,i); if(j<0) fail('invalid pax'); const n=Number(b.subarray(i,j).toString()); if(!Number.isSafeInteger(n)||n<=j-i+2||i+n>b.length||b[i+n-1]!==10) fail('invalid pax'); const v=b.subarray(j+1,i+n-1).toString(); const eq=v.indexOf('='); if(eq<1) fail('invalid pax'); result[v.slice(0,eq)]=v.slice(eq+1); i+=n; } return result; }
export async function verifyShard(root, shard, records, target, output, stagedFile) {
  const file=stagedFile ?? safe(root,shard.path); if ((await digest(file)).sha256!==shard.sha256) fail(`shard SHA mismatch: ${shard.path}`);
  const expected=new Map(records.map(r=>[r.member,r])), seen=new Set();
  const stream=fs.createReadStream(file).pipe(zlib.createGunzip()), reader=new Reader(stream); let longName, attrs={}, zeros=0;
  while(true) {
    const header=await reader.buffer(512);
    if(header.every(x=>x===0)) { if(++zeros===2) break; continue; } if(zeros) fail('invalid tar ending');
    let sum=0; for(let i=0;i<512;i++) sum+=i>=148&&i<156?32:header[i]; if(sum!==number(header.subarray(148,156))) fail('tar checksum mismatch');
    const size=number(header.subarray(124,136)), mode=number(header.subarray(100,108)), type=String.fromCharCode(header[156]||48);
    if (!Number.isSafeInteger(size)) fail('invalid tar size');
    let name=str(header.subarray(0,100)); const prefix=header.subarray(257,263).equals(Buffer.from('ustar\0')) ? str(header.subarray(345,500)) : ''; if(prefix) name=prefix+'/'+name;
    if (type==='L'||type==='x') { if(size>1024*1024) fail('oversized tar extension'); const b=await reader.buffer(size); if(type==='L') longName=str(b); else attrs=pax(b); }
    else {
      name=attrs.path ?? longName ?? name; if(attrs.size!==undefined && Number(attrs.size)!==size) fail('pax size mismatch'); attrs={}; longName=undefined;
      const r=expected.get(name); if(type!=='0'||!r||seen.has(name)||mode!==r.mode||size!==r.size) fail(`unexpected tar member: ${name}`);
      seen.add(name); const hash=crypto.createHash('sha256');
      await reader.take(size, async c=>{ hash.update(c); if(name===target && output && !output.write(c)) await new Promise((resolve,reject)=>{output.once('drain',resolve);output.once('error',reject);}); });
      if(hash.digest('hex')!==r.sha256) fail(`member SHA mismatch: ${name}`);
    }
    if(size%512) await reader.take(512-size%512,()=>{});
  }
  // Consume trailing bytes so gzip CRC/truncation errors are observed.
  await reader.finish();
  if(seen.size!==expected.size || longName || Object.keys(attrs).length) fail('missing tar members');
  for (const r of records) if(r.inline) await checkInline(root,r);
}
