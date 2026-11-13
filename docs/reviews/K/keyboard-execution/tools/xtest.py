#!/usr/bin/python3
"""XTEST on caller's exclusively owned DISPLAY; no clipboard access."""
import ctypes as c, os, time
X=c.CDLL('libX11.so.6'); T=c.CDLL('libXtst.so.6')
X.XOpenDisplay.argtypes=[c.c_char_p]; X.XOpenDisplay.restype=c.c_void_p
X.XStringToKeysym.argtypes=[c.c_char_p]; X.XStringToKeysym.restype=c.c_ulong
X.XKeysymToKeycode.argtypes=[c.c_void_p,c.c_ulong];X.XKeysymToKeycode.restype=c.c_uint
X.XSetInputFocus.argtypes=[c.c_void_p,c.c_ulong,c.c_int,c.c_ulong]
X.XSync.argtypes=[c.c_void_p,c.c_int]
X.XInternAtom.argtypes=[c.c_void_p,c.c_char_p,c.c_int];X.XInternAtom.restype=c.c_ulong
X.XGetSelectionOwner.argtypes=[c.c_void_p,c.c_ulong];X.XGetSelectionOwner.restype=c.c_ulong
T.XTestFakeKeyEvent.argtypes=[c.c_void_p,c.c_uint,c.c_int,c.c_ulong]
T.XTestFakeMotionEvent.argtypes=[c.c_void_p,c.c_int,c.c_int,c.c_int,c.c_ulong]
T.XTestFakeButtonEvent.argtypes=[c.c_void_p,c.c_uint,c.c_int,c.c_ulong]
class Keyboard:
    def __init__(self):
        self.display=X.XOpenDisplay(os.environ['DISPLAY'].encode())
        assert self.display,'private display unavailable'
    def key(self,name,pressed):
        code=X.XKeysymToKeycode(self.display,X.XStringToKeysym(name.encode()))
        assert code,name
        assert T.XTestFakeKeyEvent(self.display,code,int(pressed),0)
    def chord(self,*keys):
        for key in keys:self.key(key,True)
        for key in reversed(keys):self.key(key,False)
        X.XSync(self.display,0);time.sleep(.10)
    def focus(self,window):
        X.XSetInputFocus(self.display,int(window,16),1,0);X.XSync(self.display,0)
    def clipboard_owner(self):
        # Metadata on this newly created private X server; no clipboard conversion/read.
        return X.XGetSelectionOwner(self.display,X.XInternAtom(self.display,b'CLIPBOARD',0))
    def click(self,x,y):
        assert T.XTestFakeMotionEvent(self.display,-1,x,y,0)
        assert T.XTestFakeButtonEvent(self.display,1,1,0)
        assert T.XTestFakeButtonEvent(self.display,1,0,0)
        X.XSync(self.display,0);time.sleep(.15)
    def text(self,text):
        names={'/':'slash','.':'period','-':'minus','_':'underscore'}
        for char in text:
            shifted=char=='_' or char.isupper()
            if shifted:self.key('Shift_L',True)
            self.chord(names.get(char,char.lower()))
            if shifted:self.key('Shift_L',False)
