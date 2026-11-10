#!/usr/bin/env python3
import pathlib,json,re,hashlib,datetime
r=pathlib.Path('/workspace/work/terminal-width-recon')
hosts={}
for host in ['xterm-default','xfce-vte']:
 d=r/'raw'/host;rows=[json.loads(line) for line in (d/'dsr.jsonl').read_text().splitlines()]
 assert len(rows)==58 and all(x['matched_full_csi'] for x in rows)
 inp=(d/'input.bin').read_bytes();out=(d/'output.bin').read_bytes();off=0
 for x in rows:
  b=bytes.fromhex(x['raw_hex']);assert re.fullmatch(rb'\x1b\[[0-9]+;[0-9]+R',b)
  assert inp[off:x['input_end_offset']]==b;off=x['input_end_offset']
  assert out[x['output_end_offset']-4:x['output_end_offset']]==b'\x1b[6n'
 assert off==len(inp)
 mapping={x['name']:x for x in rows if x['name']!='before'}
 for n in ['original-0-green','original-0-red','original-1-green','original-1-red','remove_zwj_only-0-green','remove_zwj_only-0-red']:
  assert (mapping[n]['row'],mapping[n]['col'])==(4,3)
 for n in ['padding_minus2-0-green','padding_minus2-0-red','replace_zwj_cjk-0-green','replace_zwj_cjk-0-red']:
  assert (mapping[n]['row'],mapping[n]['col'])==(3,100)
 assert (mapping['delta-after-zwj']['row'],mapping['delta-after-zwj']['col'])==(3,14)
 ev=(d/'events.txt').read_text().splitlines();ready=ev[0].split(' utc=')[0].split('termios=')[1];restored=ev[-1].split(' utc=')[0].split('termios=')[1];assert ready==restored
 meta=json.loads((d/'metadata.json').read_text());assert meta['host_exit']==0 and (d/'exit.txt').read_text()=='0\n'
 assert len(list(d.glob('*.png')))==17
 hosts[host]={'complete_dsr_count':len(rows),'raw_input_bytes':len(inp),'raw_output_bytes':len(out),'ordinary_keys_read':0,'termios_restored':True,'native_exit':0,'host_exit':0,'png_count':17,'by_name':{k:{'row':v['row'],'col':v['col']} for k,v in mapping.items()}}
product={}
for line in (r/'raw/product-width.tsv').read_text().splitlines():
 f=line.split('\t')
 if f[0]!='cell':product[f[0]]={'width':int(f[1]),'graphemes':int(f[2])}
table=['| Input | Product displayWidth | XTerm398 DSR advance | VTE0.80.1 DSR advance |','|---|---:|---:|---:|']
for n,v in product.items():table.append(f"| {n} | {v['width']} | {hosts['xterm-default']['by_name'][n]['col']-1} | {hosts['xfce-vte']['by_name'][n]['col']-1} |")
(r/'width-table.md').write_text('\n'.join(table)+'\n')
finding={'id':'TASK083-WIDTH-ROOT-CAUSE','status':'confirmed_root_cause_no_fix','fixed_product_sha':'91c22f82adcd2412d9509b9872ff63450ba81af9','finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'fact':'Both actual hosts advance woman-ZWJ-laptop by4; product displayWidth and Frame reserve2. Delta writes13 physical cells plus89 spaces=102 from CUP3,1, wrapping two spaces onto row4 columns1-2 and leaving cursor4,3.','mismatch_layer':'using unicodewidth canonical string width as an unverified host physical-advance invariant; Frame and ANSI encoder agree with each other but not tested terminal behavior','hosts':hosts,'product_widths':product,'causal_controls':{'replace_whole_cluster_with_cjk':'only glyph sequence changes; fourth row preserved, final3;100','remove_only_zwj':'two emoji scalars still advance4; same corruption4;3','padding_minus2':'original Unicode preserved; 87 blanks prevent overflow and fourth row preserved3;100; proves causal padding boundary, not a product fix'},'bounded_options':[{'option':'session-specific physical occupancy through existing Unicode/layout/Frame/renderer pipeline','impact':'must replace width-from-unicodewidth-only invariant for terminal sessions; preserve canonical logical/offline widths and grapheme editing; actual sequence advance and fit need measured or positively supported policies'},{'option':'retain canonical two-cell grid and automatically project only incompatible sequences to measured bounded substitutes','impact':'visible terminal glyph can differ from full logical Unicode; original text and offline files retained; fallback and diagnostics require contract decision; never blanket-disable emoji'}],'unresolved':['User choice of terminal physical occupancy versus bounded visual projection semantics','No capability protocol implemented or proven by this investigation','One ZWJ probe cannot establish VS16, flags, modifiers, fonts, Unicode versions, contextual or all-sequence behavior','Unknown/no-DSR terminals, multiplexers and input-event routing need lifecycle evidence before product changes','Same-session terminal measurement must not introduce second Unicode kernel/ANSI parser/terminal emulator'],'prohibited_shortcuts':['example modification','programmer host branching','blind global emoji width4','blind terminal mode change','full-redraw-only masking','terminal capture or model as product runtime dependency'],'product_edits':False,'formal_test_edits':False,'commits':False}
(r/'findings.json').write_text(json.dumps(finding,ensure_ascii=False,indent=2)+'\n')
(r/'raw/integrity-verification.json').write_text(json.dumps({'all_full_csi_responses_matched':True,'input_output_offsets_verified':True,'host_DSR_count':116,'all_expected_replay_controls_verified':True,'native_and_host_exits_zero':True,'full_termios_restored':True,'primary_pngs':34},indent=2)+'\n')
print(json.dumps({'status':'verified','hosts':list(hosts),'dsr':116,'pngs':34}))
