// Literal grids were written from the fixed geometry, not captured from main.
import {readFileSync} from 'node:fs';
export const smokeGoldens=JSON.parse(readFileSync(new URL('./goldens.json',import.meta.url)));
export const ptyGoldens=JSON.parse(readFileSync(new URL('./pty-goldens.json',import.meta.url)));
export const modalGoldens=JSON.parse(readFileSync(new URL('./pty-modal-goldens.json',import.meta.url)));
export const retainedGoldens=JSON.parse(readFileSync(new URL('./retained-goldens.json',import.meta.url)));
export const presets=Object.freeze(['Classic','Dark','Light','High contrast']);
export const palette=Object.freeze({
  Classic:{fg:'default',bg:'default',accent:'named:36'},
  Dark:{fg:'rgb:232,237,242',bg:'rgb:16,24,32',accent:'rgb:102,204,255'},
  Light:{fg:'rgb:24,32,40',bg:'rgb:255,255,255',accent:'rgb:0,90,156'},
  'High contrast':{fg:'named:97',bg:'named:40',accent:'named:93'}
});
export const f7='\x1b[18~';
export const frame=(goldens,name,width,height,state='startup')=>{
  const found=goldens.find(x=>x.name===name&&x.width===width&&x.height===height&&x.state===state);
  if(!found)throw Error(`missing literal ${name} ${width}x${height} ${state}`);
  return found.rows;
};
