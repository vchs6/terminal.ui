"""Only infrastructure assertions run here. Never product PASS."""
import argparse, importlib.util, json, os, pathlib, subprocess, tempfile
from pty_capture import Capture, QUERY, unknown_wire, restored

def expect_rejected(action,label):
    try: action()
    except AssertionError: return label
    raise AssertionError("negative control was accepted: "+label)

def run(output):
    here=pathlib.Path(__file__).resolve().parent.parent
    output=pathlib.Path(output);output.mkdir(parents=True,exist_ok=True)
    compiler=["gcc","-std=c11","-Wall","-Wextra","-Werror","-O2"]
    peer=output/"harness-peer";clock=output/"clock-selftest";fault=output/"write-fault.so"
    subprocess.run(compiler+[str(here/"native/harness_peer.c"),"-o",str(peer)],check=True)
    subprocess.run(compiler+[str(here/"native/clock_wrap.c"),str(here/"native/clock_selftest.c"),"-o",str(clock)],check=True)
    subprocess.run(compiler+["-fPIC","-shared",str(here/"native/write_fault.c"),"-ldl","-o",str(fault)],check=True)
    good=Capture([str(peer)],output/"pty-good");good.wait_bytes(b"FIXTURE-READY");good.send(b"a\t\x1b[Z"); good.wait_bytes(b"a\t\x1b[Z")
    meta=good.finish();unknown_wire(good.raw);restored(meta);assert meta["exit"]==0
    controls=[expect_rejected(lambda:unknown_wire(bytes(good.raw).replace(QUERY,b"")),"missing-query"),
        expect_rejected(lambda:unknown_wire(bytes(good.raw)+QUERY),"duplicate-query")]
    bad=Capture([str(peer),"illegal-mode"],output/"pty-illegal");bad.wait_bytes(b"FIXTURE-READY");bad.finish()
    controls.append(expect_rejected(lambda:unknown_wire(bad.raw),"forbidden-show-in-Unknown"))
    leak=Capture([str(peer),"leak-termios"],output/"pty-leak");leak.wait_bytes(b"FIXTURE-READY");leak_meta=leak.finish()
    controls.append(expect_rejected(lambda:restored(leak_meta),"termios-leak"))
    path=output/"clock.txt";env=os.environ|{"CJTUI_A_CLOCK_FILE":str(path)}
    for literal,want in [("0",0),("1599",1599),("1600",1600),("-1",-1),("9223372036854775807",9223372036854775807),("9223372036854775808",-1),("bad",-1)]:
        path.write_text(literal+"\n");got=int(subprocess.check_output([str(clock)],env=env));assert got==want,(literal,got,want)
    path.unlink();assert int(subprocess.check_output([str(clock)],env=env))==-1
    path.write_text("1000\n1599\n1600\n-1\n")
    scripted=os.environ|{"CJTUI_A_CLOCK_SCRIPT":str(path)}
    assert subprocess.check_output([str(clock),"5"],env=scripted)==b"1000\n1599\n1600\n-1\n-1\n"
    for mode in ("zero","partial"):
        cap=Capture([str(peer)],output/("fault-"+mode),{"LD_PRELOAD":str(fault),"CJTUI_A_WRITE_FAIL_AT":"1","CJTUI_A_WRITE_FAULT":mode,"CJTUI_A_WRITE_TRACE":str(output/(mode+".calls"))})
        if mode=="zero":
            m=cap.finish(send_quit=False); assert m["exit"]==12 and len(cap.raw)==0
        else:
            cap.wait_bytes(b"\x1b");cap.send(b"x");cap.drain(0.05);m=cap.finish();assert m["exit"]==0 and bytes(cap.raw)==b"\x1b"
        restored(m)
    result={"scope":"infrastructure only; no cjtui behavior executed","selftest":"PASS","negative_controls_rejected":controls,"clock_cases":9,"write_faults":["zero","partial"],"real_pty":True}
    (output/"selftest.json").write_text(json.dumps(result,indent=2));print(json.dumps(result))
if __name__=="__main__":
    parser=argparse.ArgumentParser();parser.add_argument("--output",required=True);run(parser.parse_args().output)
