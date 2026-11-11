#!/bin/sh
set -eu
BASE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
HOST=/workspace/work/linux-console-hosts
RUN_DIR=${VT_RUN_DIR:?}
mkdir -p "$RUN_DIR"
if test -e "$RUN_DIR/vt-serial.log"; then echo refusing-overwrite >&2; exit 2; fi
export LD_LIBRARY_PATH="$HOST/hosts/debian/usr/lib/x86_64-linux-gnu"
exec "$HOST/hosts/debian/usr/bin/qemu-system-x86_64" \
 -accel tcg -cpu max -machine pc -m 512 -smp 1 -no-reboot -nic none \
 -L "$HOST/hosts/debian/usr/share/qemu" -bios "$HOST/hosts/debian/usr/share/seabios/bios-256k.bin" \
 -device VGA,romfile="$HOST/hosts/debian/usr/share/seabios/vgabios-stdvga.bin" -vga none \
 -display none -serial file:"$RUN_DIR/vt-serial.log" \
 -chardev socket,id=probe,path="$RUN_DIR/control.sock",server=on,wait=off -serial chardev:probe \
 -qmp unix:"$RUN_DIR/vt-qmp.sock",server=on,wait=off \
 -kernel "$HOST/packages/linux" -initrd "${VT_INITRD:-$BASE/packages/vt-initramfs.cpio.gz}" \
 -append "console=tty0 console=ttyS0,115200 rdinit=/init nomodeset vga=normal loglevel=4 scene=${VT_SCENE:-minimal}"
