#!/bin/sh
set -eu
BASE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
export LD_LIBRARY_PATH="$BASE/hosts/debian/usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$BASE/hosts/debian/usr/bin/qemu-system-x86_64" \
 -accel tcg -machine pc -m 192 -smp 1 -no-reboot -nic none \
 -L "$BASE/hosts/debian/usr/share/qemu" \
 -bios "$BASE/hosts/debian/usr/share/seabios/bios-256k.bin" \
 -device VGA,romfile="$BASE/hosts/debian/usr/share/seabios/vgabios-stdvga.bin" -vga none \
 -display none -serial file:"$BASE/raw/vt-serial.log" \
 -qmp unix:"$BASE/raw/vt-qmp.sock",server=on,wait=off \
 -kernel "$BASE/packages/linux" -initrd "$BASE/packages/vt-initramfs.cpio.gz" \
 -append 'console=tty0 console=ttyS0,115200 rdinit=/init nomodeset vga=normal loglevel=4'
