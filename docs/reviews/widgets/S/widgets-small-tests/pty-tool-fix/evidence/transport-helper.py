import os,sys
assert os.isatty(0) and os.isatty(1)
os.write(1,b"TOOL_ONLY_READY\n")
line=sys.stdin.buffer.readline()
assert line==b"transport-control\n"
os.write(1,b"TOOL_ONLY_ACK:"+line)
