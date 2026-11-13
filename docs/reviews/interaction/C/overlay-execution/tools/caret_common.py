"""Checks projected directly from frozen native_caret_pty.py/fixture, one vector."""
import re
ROWS={'base':['ABCDEFGH','ijklmnop','QRSTUVWX'],'covered':['ABCDEFGH','ij   nop','QRSTUVWX'],'restored':['ABCDEFGH','ijklmnop','QRSTUVWX']}
def fields(text):
    result=dict(line.split('=',1) for line in text.splitlines() if '=' in line)
    if len(result)!=9:raise ValueError('incomplete state file')
    return result
def judge_state(stage,state,status=None):
    hidden=stage=='covered';assert state['stage']==stage
    assert state['focusBase']=='true' and state['logicalVisible']==str(not hidden).lower()
    assert [state['owner'],state['x'],state['y']]==(['None','0','0'] if hidden else ['base','3','1'])
    assert state['handleOpen']==str(hidden).lower()
    if status:assert state['cursorStatus']==state['savedCursorStatus']==status
def judge_wire(output,status):
    assert output.count(b'\x1b[?25$p')==1
    modes=re.findall(rb'\x1b\[\?25([hlsr])',output)
    if status.startswith('unknown-'):assert not modes;return 'logical occlusion PASS; native physical hide unsupported/insufficient under Unknown; zero25h/l/s/r'
    assert status in ['original-visible','original-hidden'];assert modes[-1:]==([b'h'] if status=='original-visible' else [b'l'])
    assert b'\x1b[2;4H' in output and b'l' in modes and b'h' in modes
    return 'logical occlusion + real-host known mode hide/show/CUP and original mode restore PASS'
