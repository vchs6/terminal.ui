import fs from 'node:fs';
import {run,root,repo,hash} from './audit.mjs';
const local=repo+'/docs/reviews/R7/evidence/licenses';
fs.mkdirSync(root+'/unicode-official',{recursive:true});
const results=[];
for(const [name,url] of [['unicode-license-v3.txt','https://www.unicode.org/license.txt'],['unicode-terms.html','https://www.unicode.org/terms_of_use.html'],['ucd17-ReadMe.txt','https://www.unicode.org/Public/17.0.0/ucd/ReadMe.txt']]){
 const dest=root+'/unicode-official/'+name;
 const r=run('curl',['-fsSL','--max-time','60','--retry','1','-w','%{http_code} %{url_effective}\n','-o',dest,url]);
 if(r.status)throw Error('official fetch failed '+name);
 const fresh=fs.readFileSync(dest),saved=fs.readFileSync(local+'/'+name);
 results.push({name,url,sha256:hash(fresh),matchesSaved:fresh.equals(saved),fetch:r.stdout.trim()});
 if(!fresh.equals(saved))throw Error('official changed '+name);
}
const ucd='/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip';
const readme=run('unzip',['-p',ucd,'ReadMe.txt']);
if(readme.status||readme.stdout!==fs.readFileSync(root+'/unicode-official/ucd17-ReadMe.txt','utf8'))throw Error('UCD readme mismatch');
run('curl',['-sSL','--max-time','60','-w','%{http_code} %{url_effective}\n','-o',root+'/unicode-official/ucd17-license-response.txt','https://www.unicode.org/Public/17.0.0/ucd/LICENSE.txt']);
run('rg',['-n','Data Files|License v3|/Public/|COPYRIGHT|2026|2025|permission notice','unicode-terms.html','unicode-license-v3.txt','ucd17-ReadMe.txt'],root+'/unicode-official');
fs.writeFileSync(root+'/unicode-official-results.json',JSON.stringify(results,null,2)+'\n');
console.log('Three official documents independently fetched and byte-identical; archived UCD ReadMe matches fixed official version.');
