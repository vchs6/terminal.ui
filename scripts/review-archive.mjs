#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {once} from 'node:events';
import {logical,load,groupData,fail} from './review-archive/core.mjs';
import {verifyShard} from './review-archive/tar.mjs';

async function main() {
  let args=process.argv.slice(2), root=process.cwd();
  if(args[0]==='--root') { if(!args[1]) fail('missing root'); root=path.resolve(args[1]); args=args.slice(2); }
  root=fs.realpathSync(root); const [command,...rest]=args, catalog=await load(root);
  if(command==='list' && !rest.length) { console.log(JSON.stringify(Object.keys(catalog.groups).sort())); return; }
  if(command==='verify' && rest.length<=1) {
    const groups=rest.length?rest:Object.keys(catalog.groups).sort();
    for(const g of groups) { const data=await groupData(root,catalog,g); for(const shard of data.shards.values()) await verifyShard(root,shard,data.records.filter(r=>r.shard===shard.path)); }
    console.log(JSON.stringify({verified:groups})); return;
  }
  if((command==='resolve'&&rest.length===1)||(command==='restore'&&rest.length===2)) {
    const p=logical(rest[0],root), group=p.split('/')[2], data=await groupData(root,catalog,group), r=data.byPath.get(p); if(!r) fail(`unknown logical path: ${p}`);
    if(command==='resolve') { console.log(JSON.stringify(r)); return; }
    const dest=path.resolve(rest[1]), dir=path.dirname(dest), temp=path.join(dir,`.review-archive-${crypto.randomBytes(12).toString('hex')}.tmp`);
    let stream;
    try {
      // link() publishes atomically and refuses existing files and dangling symlinks.
      stream=fs.createWriteStream(temp,{flags:'wx',mode:0o600}); await once(stream,'open');
      await verifyShard(root,data.shards.get(r.shard),data.records.filter(x=>x.shard===r.shard),r.member,stream);
      stream.end(); await once(stream,'finish'); fs.chmodSync(temp,r.mode); const fd=fs.openSync(temp,'r'); try { fs.fsyncSync(fd); } finally { fs.closeSync(fd); }
      fs.linkSync(temp,dest); fs.unlinkSync(temp); console.log(JSON.stringify({path:r.path,destination:dest}));
    } finally { if(stream&&!stream.destroyed) stream.destroy(); try {fs.unlinkSync(temp);} catch(e){if(e.code!=='ENOENT') throw e;} }
    return;
  }
  fail('usage: review-archive.mjs --root ROOT list | resolve PATH | verify [GROUP] | restore PATH DESTINATION');
}
main().catch(e=>{console.error(`review-archive: ${e.message}`);process.exitCode=1;});
