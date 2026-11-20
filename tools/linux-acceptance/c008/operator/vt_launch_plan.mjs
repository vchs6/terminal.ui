import assert from 'node:assert/strict';
import {dirname,join,resolve} from 'node:path';
export function launchPlan(binary,dir,env,launcherText=null){
 const target=resolve(binary),showcase=resolve(env.C008_VT_SHOWCASE_ELF??'/missing'),composition=resolve(env.C008_VT_COMPOSITION_ELF??'/missing');
 if(target===showcase)return {scene:'showcase',elf:showcase};if(target===composition)return {scene:'composition',elf:composition};
 const owner=dirname(resolve(dir)),launcher=join(owner,'launch.sh'),selected=join(owner,'selected.toml');
 assert.equal(target,launcher,'unadmitted VT launcher path');
 assert.equal(launcherText,`#!/bin/sh\nexec "${showcase}" --theme-file "${selected}"\n`,'only exact frozen public --theme-file launcher is admitted');
 return {scene:'showcase-file',elf:showcase,fixture:selected,guestFixture:'/evidence/selected.toml',publicArgs:['--theme-file','/evidence/selected.toml']};
}
