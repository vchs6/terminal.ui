import os,stat,json,hashlib,gzip,zlib,tarfile,io,pathlib,datetime
ROOT='/workspace/work/'
def verify(volume):
 B=ROOT+'migration-part06'+volume+'/'
 manifest_bytes=open(B+'manifest.json','rb').read(); manifest=json.loads(manifest_bytes); delivery=json.load(open(B+'delivery.json'))
 errors=[]
 def check(c,s):
  if not c: errors.append(s)
 def hashes(f):
  h=hashlib.sha256(); n=0
  while True:
   b=f.read(1024*1024)
   if not b: break
   h.update(b); n+=len(b)
  return n,h.hexdigest()
 files=manifest['files']; check(len(files)==delivery['payload_files'],'manifest payload count'); byname={x['archive_path']:x for x in files}; check(len(byname)==len(files),'manifest duplicate names')
 source_results=[]
 for x in files:
  s=os.lstat(x['path'])
  with open(x['path'],'rb') as f: n,h=hashes(f)
  ok=stat.S_ISREG(s.st_mode) and n==x['bytes'] and h==x['sha256'] and stat.S_IMODE(s.st_mode)==x['mode']
  check(ok,'source mismatch '+x['path']); source_results.append({'path':x['archive_path'],'bytes':n,'sha256':h,'mode':stat.S_IMODE(s.st_mode),'pass':ok})
 archive=delivery['archive_path']; n=os.stat(archive).st_size; sha=hashlib.sha256(); blob=hashlib.sha1(('blob '+str(n)+'\0').encode())
 with open(archive,'rb') as f:
  while True:
   b=f.read(1024*1024)
   if not b: break
   sha.update(b); blob.update(b)
 check(n==delivery['bytes'],'archive size'); check(sha.hexdigest()==delivery['sha256'],'archive SHA256'); check(blob.hexdigest()==delivery['git_blob'],'archive git blob identity')
 expected=files+[{'path':B+'manifest.json','archive_path':'migration-part06'+volume+'/manifest.json','bytes':len(manifest_bytes),'sha256':hashlib.sha256(manifest_bytes).hexdigest(),'mode':stat.S_IMODE(os.stat(B+'manifest.json').st_mode)}]
 records={}; decompressed={}; member_results=[]; pax_count=0; seen=set(); raw_header_blocks=0
 # Compare every raw header/control byte with the exact PAX tar encoding of the corresponding source stat.
 with tarfile.open(fileobj=io.BytesIO(),mode='w',format=tarfile.PAX_FORMAT) as template, gzip.open(archive,'rb') as f:
  for x in expected:
   name=x['archive_path']; check(not name.startswith('/') and '..' not in pathlib.PurePosixPath(name).parts and '\\' not in name and not any(ord(c)<32 or ord(c)==127 for c in name),'unsafe name '+name); check(name not in seen,'duplicate '+name); seen.add(name)
   ti=template.gettarinfo(x['path'],arcname=name)
   header=ti.tobuf(tarfile.PAX_FORMAT,'utf-8','surrogateescape'); actual=f.read(len(header)); check(actual==header,'raw header/control metadata mismatch '+name); raw_header_blocks+=len(header)//512
   if len(header)>512: pax_count+=1
   actual_ti=tarfile.TarInfo.frombuf(actual[-512:],'utf-8','surrogateescape')
   check(ti.isreg() and not ti.linkname,'nonregular/link '+name)
   h=hashlib.sha256(); total=0; data=bytearray(); gz='/witness/' in name and name.endswith('.gz')
   if gz: dec=zlib.decompressobj(16+zlib.MAX_WBITS); dh=hashlib.sha256(); dn=0; elfhead=b''
   remaining=x['bytes']
   while remaining:
    b=f.read(min(1024*1024,remaining))
    if not b: raise ValueError('truncated payload '+name)
    remaining-=len(b); total+=len(b); h.update(b)
    if gz:
     out=dec.decompress(b); dh.update(out); dn+=len(out); elfhead=(elfhead+out[:64])[:64]
    else: data.extend(b)
   if gz:
    out=dec.flush(); dh.update(out); dn+=len(out); check(dec.eof and not dec.unused_data and not dec.unconsumed_tail,'gzip complete single stream '+name); decompressed[name]={'bytes':dn,'sha256':dh.hexdigest(),'gzip_sha256':h.hexdigest(),'gzip_bytes':total,'ELF_header_hex':elfhead.hex()}
   else: records[name]=bytes(data)
   padding=f.read((-total)%512); check(padding==b'\0'*((-total)%512),'nonzero payload padding '+name)
   ok=total==x['bytes'] and h.hexdigest()==x['sha256'] and actual_ti.mode==x['mode']; check(ok,'archive payload mismatch '+name)
   member_results.append({'path':name,'bytes':total,'sha256':h.hexdigest(),'mode':actual_ti.mode,'pass':ok})
  tail=f.read(); check(len(tail)>=1024 and not tail.strip(b'\0'),'tar trailing content or missing terminator')
 check(len(member_results)==delivery['tar_members'],'tar regular count'); check(records.get('migration-part06'+volume+'/manifest.json')==manifest_bytes,'manifest exact bytes')
 return locals()
for volume,groups in [('d',[('input-fix-build-headroom-20261114/',12),('input-fix-build-headroom-20261114/round1/',4)]),('e',[('ended-role-build-output-custody-20261115/',18)])]:
 v=verify(volume); errors=v['errors']; records=v['records']; gz=v['decompressed']; checked=set(); rowresults=[]; indexcount=0
 def ck(ok,msg):
  if not ok: errors.append(msg)
 payload={x['archive_path']:x for x in v['files']}
 for group,count in groups:
  prefix='work/validation/'+group; index=json.loads(records[prefix+'index.json']); rows=json.loads(records[prefix+'progress.json']); ck(len(rows)==count,'progress count '+group); ck(index['summary']['migrated_files']==count,'index count '+group)
  for r in index['files']:
   name=prefix+r['path']; x=payload.get(name); ck(x is not None,'index target absent '+name)
   if x: ck(x['bytes']==r['bytes'] and x['sha256']==r['sha256'],'index size/hash binding '+name)
   indexcount+=1
  for number,r in enumerate(rows,1):
   name=r['witness'].removeprefix('/workspace/'); ck(name not in checked,'duplicate progress witness '+name); checked.add(name); d=gz[name]
   good=d['bytes']==r['bytes']==r['verified_before_unlink']['decompressed_bytes'] and d['sha256']==r['sha256']==r['verified_before_unlink']['decompressed_sha256'] and d['gzip_bytes']==r['witness_bytes'] and d['gzip_sha256']==r['witness_sha256'] and d['ELF_header_hex']==r['ELF_header_hex']
   ck(good,'gzip original/ELF/witness binding '+name); ck(r['witness_uri']==r['witness'],'witness URI '+name)
   before=json.loads(records[prefix+str(number)+'-before.json'])['original']; receipt=json.loads(records[prefix+str(number)+'-verified-before-unlink.json'])
   for label,rd in [('before',before),('verified',receipt)]:
    for key,value in rd.items(): ck(key in r and r[key]==value,'receipt '+label+' '+name+' '+key)
   ck(r['physical_original_present'] is False,'historical physical absence '+name)
   rowresults.append({'group':group,'ordinal':number,'witness':name,'original_sha256':r['sha256'],**d,'matches_progress':good})
  summary=index['summary']; own=[gz[r['witness'].removeprefix('/workspace/')] for r in rows]
  ck(sum(d['bytes'] for d in own)==summary['original_bytes'],'summary original total '+group); ck(sum(d['gzip_bytes'] for d in own)==summary['witness_bytes'],'summary witness total '+group)
  physical={prefix+'witness/'+name for name in os.listdir('/workspace/'+prefix+'witness') if os.path.isfile('/workspace/'+prefix+'witness/'+name)}
  ck(physical=={r['witness'].removeprefix('/workspace/') for r in rows},'physical witness exact coverage '+group)
 ck(checked==set(gz),'archive vs progress exact gzip cover')
 ck(len(gz)==(16 if volume=='d' else 18),'volume gzip count')
 status='PASS' if not errors else 'FAIL'; originaltotal=sum(d['bytes'] for d in gz.values()); n=v['n']
 result={'status':status,'scope':'Part06'+volume+' existing custody bytes only; no change to historical provenance or acceptance; no entire-sixth-group completion or Linux acceptance claim.','timestamp_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'archive':{'path':v['archive'],'bytes':n,'sha256':v['sha'].hexdigest(),'git_blob':v['blob'].hexdigest()},'counts':{'source_originals':len(v['files']),'regular_tar_members':len(v['member_results']),'gzip_originals':len(gz),'metadata_originals':len(v['files'])-len(gz),'pax_mtime_control_records':v['pax_count'],'original_decompressed_bytes':originaltotal,'index_file_bindings':indexcount,'receipt_pairs':len(rowresults),'trailing_zero_bytes':len(v['tail'])},'checks':{'originals':'all source regular/size/SHA256/mode checked','archive':'full SHA256/size/Git-blob identity checked','tar_mapping':'exact regular member set and embedded manifest bytes; safe unique names, no links/extras; zero padding/tail','control_metadata':'all raw header and PAX control bytes equal source-derived metadata encoding including uid/gid/names/mtime/mode','gzip':'all streams single-stream CRC/EOF and original SHA/size/ELF-header, witness SHA/size checked against immutable progress','index_and_receipts':'all index file references SHA/size bound to delivered payload; original-before and verified-before-unlink receipt contents bound to progress rows; summary totals match; physical gzip exact coverage','old_indices_and_conclusions':'read only; preserved'},'sources':v['source_results'],'tar_members':v['member_results'],'restored_streams':rowresults,'errors':errors}
 B=v['B']; open(B+'findings.json','w').write(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
 report=f'''# Part06{volume} independent verification\n\nResult: **{status}**, {len(errors)} findings. All {len(v['files'])} original source files matched manifest size, SHA-256 and mode. All {len(v['member_results'])} regular archive members, including the embedded manifest, matched exact bytes and metadata. Every raw tar header and PAX control byte matched source-derived metadata encoding. Member paths are safe and unique; there are no links, unexpected members or nonzero padding/trailing data.\n\nArchive: `{v['archive']}`\n\n- Bytes: {n}\n- SHA-256: `{v['sha'].hexdigest()}`\n- Git blob: `{v['blob'].hexdigest()}`\n- Payload: {len(gz)} gzip originals and {len(v['files'])-len(gz)} metadata originals.\n- Original bytes streamed: {originaltotal}.\n\nThe immutable index.json/progress.json groups ({', '.join(str(count) for group,count in groups)} entries) bind all gzip streams to original ELF SHA-256, size and header, compressed SHA-256/size, and both before/verified-before-unlink receipts. Every indexed file hash/size was checked against delivered bytes, summary byte totals match, and progress covers each physical witness gzip exactly once. Gzip CRC/EOF and single-stream boundaries passed.\n\nThis volume preserves existing bytes and their recorded conclusions. It does not infer new compiler/source identity, change old logical indices, certify Linux acceptance, or close the entire sixth group. Verification used read-only source/archive access with in-memory streaming; no decompressed ELF was written or run, no build/VM/network or subagents were used, and no authentication or environment values were read. Earlier volumes a/b/c were not reverified.\n'''
 if errors: report+='\n'+'\n'.join('- '+e for e in errors)+'\n'
 open(B+'report.md','w').write(report)
 print(json.dumps({'volume':volume,'status':status,'errors':errors,'counts':result['counts'],'report_bytes':os.stat(B+'report.md').st_size,'findings_bytes':os.stat(B+'findings.json').st_size}))
