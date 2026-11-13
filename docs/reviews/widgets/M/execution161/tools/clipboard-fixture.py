import gi,sys,pathlib
# External GUI fixture only; no product clipboard command/query.
gi.require_version('Gtk','3.0');from gi.repository import Gtk,Gdk,GLib
text=pathlib.Path(sys.argv[1]).read_text()
for atom in [Gdk.SELECTION_PRIMARY,Gdk.SELECTION_CLIPBOARD]:Gtk.Clipboard.get(atom).set_text(text,-1)
pathlib.Path(sys.argv[2]).write_text('external fixture owns known literal\n')
GLib.timeout_add_seconds(45,lambda:(Gtk.main_quit(),False)[1]);Gtk.main()
