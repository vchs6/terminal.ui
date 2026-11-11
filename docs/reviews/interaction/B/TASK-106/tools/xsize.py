import ctypes as c
from xtest import X
class Hints(c.Structure):
 _fields_=[('flags',c.c_long)]+[(n,c.c_int) for n in ['x','y','width','height','min_width','min_height','max_width','max_height','width_inc','height_inc','min_ax','min_ay','max_ax','max_ay','base_width','base_height','win_gravity']]
X.XGetWMNormalHints.argtypes=[c.c_void_p,c.c_ulong,c.POINTER(Hints),c.POINTER(c.c_long)];X.XGetWMNormalHints.restype=c.c_int
X.XResizeWindow.argtypes=[c.c_void_p,c.c_ulong,c.c_uint,c.c_uint]
def hints(keyboard,win):
 v=Hints();supported=c.c_long();assert X.XGetWMNormalHints(keyboard.display,int(win,16),c.byref(v),c.byref(supported));return {name:getattr(v,name) for name,_ in v._fields_}
def resize(keyboard,win,w,h,info):
 bw=info['base_width'] if info['flags']&256 else info['min_width'];bh=info['base_height'] if info['flags']&256 else info['min_height'];assert info['width_inc']>0 and info['height_inc']>0
 pixels=[bw+w*info['width_inc'],bh+h*info['height_inc']];X.XResizeWindow(keyboard.display,int(win,16),*pixels);X.XSync(keyboard.display,0);return pixels
