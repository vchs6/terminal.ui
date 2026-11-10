"""Local ncurses cross-check for the terminfo no_color_video numeric mask."""
import curses
import subprocess

entry = subprocess.check_output(
    ["infocmp", "-L", "-1", "linux"], text=True, stderr=subprocess.STDOUT
)
ncv_line = next(line.strip() for line in entry.splitlines()
                if line.strip().startswith("no_color_video#"))
ncv = int(ncv_line.split("#", 1)[1].rstrip(","), 0)

# ncurses' chtype attributes are shifted left from the terminfo ncv bitmask.
shift = curses.A_STANDOUT.bit_length() - 1
names = ("A_STANDOUT", "A_UNDERLINE", "A_REVERSE", "A_BLINK", "A_DIM",
         "A_BOLD", "A_INVIS", "A_PROTECT", "A_ALTCHARSET")
print(f"terminfo.{ncv_line}")
print(f"curses.attr_shift={shift}")
for name in names:
    raw = getattr(curses, name)
    bit = raw >> shift
    print(f"{name}.raw={raw} ncv_bit={bit} set={'yes' if ncv & bit else 'no'}")
print("decode=" + ",".join(name for name in names if ncv & (getattr(curses, name) >> shift)))
