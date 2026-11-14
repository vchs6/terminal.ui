#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {pack,remove} from './review-archive/pack.mjs';
async function main(){const a=process.argv.slice(2);if(a.length!==7||a[0]!=='--root'||a[2]!=='--group'||a[4]!=='--keep'||!['pack','remove'].includes(a[6]))throw Error('usage: --root ROOT --group GROUP --keep KEEP.json pack|remove');const root=fs.realpathSync(path.resolve(a[1]));await (a[6]==='pack'?pack:remove)(root,a[3],path.resolve(a[5]));}
main().catch(e=>{console.error(`review-archive-pack: ${e.message}`);process.exitCode=1;});
