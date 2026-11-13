# Transport-neutral adapter of unchanged independent tests/widgets_composite/pty.py.
# Literal business commands/file expectations are copied from the frozen author oracle.
import time
EXPECTED_FOCUS=['a','c','a','c','a','c','a','a','c','p','r','p','r','r','c','p','n','p','c','p','c','p','c']
EXPECTED_SUMMARY=dict(calls='4',chosen='h:a;h:a;p:r;p:p;',model='NEW',cleanups='1',resources='0/0/0/0')
def normal(key,wait_file,text,capture,paste,altspace,events):
 focus=[];escapes=0
 def fence(want):
  focus.append(want);key('#');expected=';'.join(focus)+';';wait_file('focus',expected)
 def escape():
  nonlocal escapes
  escapes+=1;key('Escape');wait_file('escape_seen',str(escapes))
 fence('a')
 for name,want in [('Right','c'),('Right','a'),('End','c'),('Home','a'),('Left','c'),('Home','a')]:key(name);fence(want)
 capture('horizontal-navigation');key('Return');key('space');wait_file('chosen','h:a;h:a;');altspace();paste();fence('a');assert text('chosen')=='h:a;h:a;'
 key('Tab');fence('c');key('o');fence('p');capture('popup-open');key('Down');fence('r');key('Up');fence('p');key('End');fence('r');key('Return');fence('r');assert text('chosen')=='h:a;h:a;p:r;' and text('open')=='true';capture('chosen-popup-still-open')
 escape();fence('c');assert text('open')=='false' and text('reason')=='Escape';capture('escape-restored')
 key('o');fence('p');key('n');fence('n');capture('nested-modal');escape();fence('p');assert text('open')=='true';capture('nested-escape-parent-retained');escape();fence('c')
 key('u');key('o');fence('p');capture('latest-model-layer');key('c');fence('c');assert text('reason')=='Requested';key('e');fence('p');key('Return');fence('c');assert text('open')=='false' and text('reason')=='Requested';capture('explicit-callback-close');assert focus==EXPECTED_FOCUS;events.append(dict(frozen_focus_trace=focus,escape_count=escapes));return focus

def example(key,capture):
 key('Right');key('Return');capture('menu-save');key('Home');key('space');capture('menu-open');key('Tab');key('Tab');capture('options-focus');key('Return');capture('popup-close-entry');key('Return');capture('callback-close');key('Return');capture('popup-for-escape');key('Escape');capture('escape-close')
