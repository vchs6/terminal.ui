import gi,json,datetime
# Independent GUI observer reads this test host's clipboard; never part of product.
gi.require_version('Gtk','3.0');from gi.repository import Gtk,Gdk
text=Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD).wait_for_text()
print(json.dumps(dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),text=text,scope='external GUI delivery observation; does not upgrade product SentUnconfirmed to Applied')))
