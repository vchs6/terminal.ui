"""Future public product PTY integration, never run against declaration stubs."""
import argparse,json,pathlib,time
from pty_capture import Capture,QUERY,unknown_wire,restored

def session(binary,out,status):
    cap=Capture([str(pathlib.Path(binary).resolve())],out)
    try:
        cap.wait_bytes(QUERY)
        if status in (1,2): cap.send(b"\x1b[?25;"+str(status).encode()+b"$y")
        else: cap.drain(0.7)
        cap.send(b"s"); state=cap.state(lambda s:s.startswith("original-" if status in (1,2) else "unknown-timeout"))
        assert "\nA\n" in state,state
        assert "text:s|" in state and "25;" not in state,state
        cap.send(b"\t");cap.send(b"s");cap.state(lambda s:"\nB\n" in s)
        cap.send(b"\x1b[");cap.drain(0.01);cap.send(b"Z");cap.send(b"s");cap.state(lambda s:"\nA\n" in s and "backtab:|" in s)
        cap.send(b"\x1bOZ\x1b[1Z");cap.send(b"s");state=cap.state(lambda s:s.count("text:s|")>=4)
        assert "\nA\n" in state,state
        cap.send(b"m");cap.send(b"s");cap.state(lambda s:"text:m|" in s)
        # Wire must contain final CUP to 0-based (2,0), even grid unchanged.
        cap.drain(0.1);assert b"\x1b[1;3H" in cap.raw,bytes(cap.raw)
        cap.send(b"h");cap.drain(0.1)
    finally:
        metadata=cap.finish()
    restored(metadata);assert metadata["exit"]==0
    raw=bytes(cap.raw);assert raw.count(QUERY)==1
    if status==0: unknown_wire(raw)
    else:
        original=b"\x1b[?25h" if status==1 else b"\x1b[?25l"
        assert b"\x1b[?25h" in raw and b"\x1b[?25l" in raw
        assert raw.rfind(original)>raw.rfind(b"BBBB"),"restore must follow product frames"
    assert (pathlib.Path(out)/"closed-cleanup").read_text()=="1"
    assert (pathlib.Path(out)/"cleanup").read_text()=="2"
    expected={0:"unknown-timeout",1:"original-visible",2:"original-hidden"}[status]
    assert (pathlib.Path(out)/"closed-status").read_text()==expected
    return {"case":expected,"exit":metadata["exit"],"raw":str(pathlib.Path(out)/"wire.bin")}
if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("--binary",required=True);p.add_argument("--output",required=True);a=p.parse_args()
    reports=[session(a.binary,pathlib.Path(a.output)/str(s),s) for s in (0,1,2)]
    print(json.dumps({"scope":"PTY protocol, no physical host pixel claim","cases":reports},indent=2))
