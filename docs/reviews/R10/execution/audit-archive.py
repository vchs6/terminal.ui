import tarfile,pathlib,hashlib,json,tomllib,sys
archive=pathlib.Path(sys.argv[1]); repo=pathlib.Path(sys.argv[2]); entries=[]; declarations={}
with tarfile.open(archive) as tar:
 for member in tar.getmembers():
  if not member.isfile(): continue
  data=tar.extractfile(member).read(); rel='/'.join(member.name.split('/')[1:]); sha=hashlib.sha256(data).hexdigest()
  source=repo/rel
  entries.append({'entry':member.name,'size':len(data),'sha256':sha,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest() if source.is_file() else None})
  if rel.endswith('cjpm.toml'):
   doc=tomllib.loads(data.decode()); declarations[rel]={k:doc[k] for k in ['dependencies','test-dependencies','script-dependencies','ffi'] if k in doc}
print(json.dumps({'archive':str(archive),'archive_sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'file_count':len(entries),'entries':entries,'declarations':declarations},indent=2))
