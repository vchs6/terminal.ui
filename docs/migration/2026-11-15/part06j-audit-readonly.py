import os,stat,json,zlib,struct,hashlib,tarfile,gzip,pathlib
folder='/workspace/work/migration-part06j/'
sha=lambda b:hashlib.sha256(b).hexdigest()
def read(p):
 s=os.lstat(p);assert stat.S_ISREG(s.st_mode)
 return open(p,'rb').read()
m=json.loads(read(folder+'manifest.json'));d=json.loads(read(folder+'delivery.json'))
q=json.loads(read('/workspace/work/migration-small-closure/queue.json'))
old=json.loads(read(q['index_binding']['path']))
assert sha(read(q['index_binding']['path']))==q['index_binding']['sha256']
assert len(m['files'])==len(q['files'])==5
qb={f['path']:f for f in q['files']};by={f['archive_path']:f for f in m['files']}
assert len(qb)==len(by)==5
rows=[];duplicates=[]
for f in m['files']:
 contract=qb[f['path']]
 for k in ('archive_path','bytes','sha256','mode','kind'):assert f[k]==contract[k]
 assert f['archive_path']==f['path'].removeprefix('/workspace/')
 b=read(f['path']);s=os.stat(f['path'])
 assert len(b)==s.st_size==f['bytes'] and sha(b)==f['sha256'] and stat.S_IMODE(s.st_mode)==f['mode']
 row={'path':f['path'],'bytes':len(b),'sha256':sha(b),'mode':stat.S_IMODE(s.st_mode),'source_regular_file':True}
 if f['path'].endswith('.gz'):
  indexrow=old['files'][contract['old_index_files_row']]
  assert indexrow['path']==f['path'].rsplit('/',1)[1] and indexrow['bytes']==len(b) and indexrow['sha256']==sha(b) and int(indexrow['mode'],8)==f['mode']
  de=zlib.decompressobj(31);decoded=de.decompress(b)+de.flush()
  assert de.eof and not de.unused_data and not de.unconsumed_tail
  assert struct.unpack('<II',b[-8:])==(zlib.crc32(decoded)&0xffffffff,len(decoded)&0xffffffff)
  assert len(decoded)==contract['decoded_JSON_bytes']==10934020 and not decoded.startswith(b'\x7fELF')
  data=json.loads(decoded);assert isinstance(data,list) and len(data)==contract['metadata_rows']==30303
  keys=set();forbidden=set();nested=0
  for record in data:
   assert isinstance(record,dict)
   keys.update(record)
   for k,val in record.items():
    if any(term in k.lower().replace('-','_') for term in ('content','env','token','password','private_key','privatekey','secret')):forbidden.add(k)
    assert isinstance(val,(str,int,float,bool,type(None)))
   assert 'path' in record and 'type' in record
  assert not forbidden and keys==set(contract['metadata_keys'])
  row.update({'metadata_only_not_ELF':True,'old_index_files_row':contract['old_index_files_row'],'old_index_exact_binding':True,'decoded_JSON_bytes':len(decoded),'decoded_rows':len(data),'metadata_keys':sorted(keys),'gzip_crc32':f'{zlib.crc32(decoded)&0xffffffff:08x}','gzip_single_stream_CRC_EOF':True,'forbidden_field_count':0,'listed_target_paths_opened':0})
 else:
  prior=json.loads(read(contract['prior_manifest']))
  hits=[p for p in prior['files'] if p['path']==f['path']]
  assert len(hits)==1
  for k in ('archive_path','bytes','sha256','mode'):assert hits[0][k]==f[k]
  duplicates.append(f['path']);row['exact_intentional_repeat_of_06i']=True
  if contract['old_index_files_row'] is not None:
   rr=old['files'][contract['old_index_files_row']]
   assert rr['path']==f['path'].rsplit('/',1)[1] and rr['bytes']==f['bytes'] and rr['sha256']==f['sha256'] and int(rr['mode'],8)==f['mode']
 rows.append(row)
assert rows[0]['sha256']==rows[1]['sha256'] and len(duplicates)==3
p=d['archive_path'];assert p.startswith('/dev/shm/terminal-ui-migration-20261115-host/')
b=read(p);assert len(b)==d['bytes']==2103699
assert sha(b)==d['sha256']=='08873ae2298cd363dfc44d6008d0941cb578b3a75088bfca2f5f0e06d7260df2'
blob=hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest();assert blob==d['git_blob']
seen=set();control='migration-part06j/manifest.json';members=[]
with tarfile.open(p,'r|gz') as t:
 for mem in t:
  name=mem.name
  assert name and not name.startswith('/') and '..' not in pathlib.PurePosixPath(name).parts and '\\' not in name
  assert name not in seen and mem.isfile() and not mem.linkname
  seen.add(name);body=t.extractfile(mem).read();assert len(body)==mem.size
  if name==control:
   src=folder+'manifest.json';assert body==read(src)
  else:
   assert name in by;f=by[name];src=f['path']
   assert mem.size==f['bytes'] and sha(body)==f['sha256']
   assert body==read(src)
  s=os.stat(src)
  assert mem.mode==stat.S_IMODE(s.st_mode) and mem.uid==s.st_uid and mem.gid==s.st_gid and abs(mem.mtime-s.st_mtime)<0.000001
  members.append({'name':name,'bytes':len(body),'sha256':sha(body),'mode':mem.mode,'source_uid_gid_mtime_match':True})
assert seen==set(by)|{control} and len(seen)==d['tar_members']==6 and d['payload_files']==5
de=zlib.decompressobj(31);crc=0;n=0
for j in range(0,len(b),65536):
 out=de.decompress(b[j:j+65536]);n+=len(out);crc=zlib.crc32(out,crc)
out=de.flush();n+=len(out);crc=zlib.crc32(out,crc)
assert de.eof and not de.unused_data and not de.unconsumed_tail and struct.unpack('<II',b[-8:])==(crc&0xffffffff,n&0xffffffff)
result={'status':'PASS','scope':'Only final frozen five-payload 06j migration package. No conclusion on completion of group 6, group 7, or Linux acceptance.','archive':{'bytes':len(b),'sha256':sha(b),'git_blob':blob,'payload_files':5,'tar_members':6,'safe_regular_unique_exact_members':True,'control_manifest_exact_bytes_and_source_metadata':True,'outer_gzip_single_stream_CRC_EOF':True},'payloads':rows,'tar_members':members,'two_metadata_gzip_path_originals_one_unique_byte_identity':True,'intentional_06i_context_duplicates':duplicates,'errors':[],'boundaries':'Read only five named source payloads, local contract/manifests, and dedicated RAM archive; parsed gzip JSON only in memory. Did not read any inventory-listed target path, print metadata values, execute payloads, restore decompressed payloads to disk, build, use VM/network/upload, or evaluate packed_target author claims outside this five-file verification scope.'}
with open(folder+'findings.json','w') as fd:json.dump(result,fd,indent=2);fd.write('\n')
report='''# Independent verification: frozen part06j

PASS — five payloads and one control manifest; archive 2,103,699 bytes, SHA-256 08873ae2298cd363dfc44d6008d0941cb578b3a75088bfca2f5f0e06d7260df2. Git blob matches delivery.

All five physical source files are regular files and match full SHA-256, size and mode. Tar members are safe, regular, unique, exactly cover the five payloads plus the unchanged control manifest, and match all bytes and source mode/uid/gid/mtime. Outer gzip CRC and single-stream EOF pass.

The two same-byte metadata JSON.gz originals retain both original path labels. Historical index rows 40 (before) and 39 (after) match SHA-256, size and mode. Each gzip passes CRC/EOF and decodes in memory to 10,934,020 JSON bytes and 30,303 metadata records. Only the contract's scalar metadata keys occur; no content/environment/token/password/private-key/secret fields. They are not ELF. No listed target paths were opened and no metadata values were printed.

The other three files exactly match their deliberately repeated 06i context records. No payload was executed, built or decompressed to disk. Scope is this frozen five-file 06j package only; no completion claim for group 6, group 7, or Linux acceptance.
'''
with open(folder+'report.md','w') as fd:fd.write(report)
assert os.path.getsize(folder+'findings.json')+os.path.getsize(folder+'report.md')<80000
print('06j PASS: 5 payloads, 6 regular unique tar members; two metadata gzip inventories each 30303 rows; three exact intentional 06i context duplicates.')
