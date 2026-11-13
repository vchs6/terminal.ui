import gi,sys
from pathlib import Path
gi.require_version('Gtk','3.0');from gi.repository import Gtk,Gdk,GLib
# Fixture writes only its own known literal; product has no clipboard API calls.
for atom in [Gdk.SELECTION_PRIMARY,Gdk.SELECTION_CLIPBOARD]:Gtk.Clipboard.get(atom).set_text('HOST-PASTE-116',-1)
Path(sys.argv[1]).write_text('literal HOST-PASTE-116 owned by external GTK fixture\n')
GLib.timeout_add_seconds(45,lambda:(Gtk.main_quit(),False)[1]);Gtk.main()
