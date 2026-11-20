"""Only the exact isolated mux endpoint already supplied to launch-host.sh."""
import json,os,subprocess as S
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1'
kind=os.environ['C008_HOST_KIND'];args=None
if kind=='tmux':args=[os.environ['C008_TMUX'],'-S',os.environ['C008_TMUX_SOCKET'],'kill-server']
if kind=='screen':args=[os.environ['C008_SCREEN'],'-S',os.environ['C008_SCREEN_SESSION'],'-X','quit'];assert os.environ['SCREENDIR']
if args:
 p=S.run(args,capture_output=True,timeout=5);print(json.dumps({'argv':args,'returncode':p.returncode,'scope':'exact owned mux endpoint from original launch; never default/user socket'}))
