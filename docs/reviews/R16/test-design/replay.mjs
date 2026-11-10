import fs from 'node:fs';
import { spawn } from 'node:child_process';
const root='/workspace/work/glyph-tests';
const directory='/workspace/work/glyph-tests-evidence/final';
fs.mkdirSync(directory,{recursive:true});
fs.mkdirSync(directory+'/logical-files',{recursive:true});
const commands=[
 ['environment','cjc --version; cjpm --version; git rev-parse HEAD; git status --short'],
 ['baseline-build','cjpm build'],
 ['api-red','tests/glyphs/run.sh api'],
 ['public-red','tests/glyphs/run.sh public'],
 ['internal-red','tests/glyphs/run.sh internal'],
 ['rich-red','tests/glyphs/run.sh rich'],
 ['session-red','tests/glyphs/run.sh session'],
 ['negative-blocked','tests/glyphs/run.sh negative'],
 ['shell-syntax','bash -n tests/glyphs/run.sh tests/glyphs/negative.sh'],
 ['node-syntax','node --check tests/glyphs/pty.mjs'],
 ['native-compile','gcc -std=c11 -Wall -Wextra -Werror -fPIC -O2 -c tests/glyphs/session/native/glyph_syscall_wrap.c -o /workspace/work/glyph-tests-evidence/final/glyph_syscall_wrap.o'],
 ['diff-check','git diff --cached --check']
];
const metadata=[];
for (const [name,command] of commands) {
 const actual='source /workspace/work/validation/sdk/cangjie/envsetup.sh\n'+command;
 const start=new Date().toISOString();
 const fd=fs.openSync(`${directory}/${name}.log`,'w');
 const child=spawn('bash',['-lc',actual],{cwd:root,env:{...process.env,CJTUI_GLYPH_FILES:directory+'/logical-files'},stdio:['ignore',fd,fd]});
 const result=await new Promise(resolve=>child.on('close',(code,signal)=>resolve({code,signal})));
 fs.closeSync(fd);
 const record={name,cwd:root,argv:['bash','-lc',actual],start,end:new Date().toISOString(),...result};
 metadata.push(record);
 fs.writeFileSync(`${directory}/commands.json`,JSON.stringify(metadata,null,2)+'\n');
 process.stdout.write(`${name}: exit=${result.code} signal=${result.signal}\n`);
}
