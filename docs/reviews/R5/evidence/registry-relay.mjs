// Compatibility adapter for CJPM's network client in this managed environment.
// Public registry bytes remain unchanged; curl uses inherited proxy and CA trust.
import http from 'node:http';
import {spawn} from 'node:child_process';
const port=Number(process.env.PROBE_RELAY_PORT ?? 18768);
http.createServer((req,res)=>{
  if(req.method!=='GET' || !/^\/(index|pkg)\/[A-Za-z0-9_./-]+$/.test(req.url)) {
    res.writeHead(400);res.end('unsupported probe request');return;
  }
  const child=spawn('curl',['-fsSL','--max-time','60','https://pkg.cangjie-lang.cn/registry'+req.url]);
  const chunks=[];
  child.stdout.on('data',chunk=>chunks.push(chunk));
  child.stderr.pipe(process.stderr);
  child.on('close',code=>{
    res.writeHead(code===0?200:502);
    res.end(code===0?Buffer.concat(chunks):'public registry fetch failed');
  });
}).listen(port,'127.0.0.1',()=>console.log('registry relay ready'));
