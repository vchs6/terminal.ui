#!/bin/sh
export PATH=/bin TERM=linux LD_LIBRARY_PATH=/lib/x86_64-linux-gnu LC_ALL=C.UTF-8
mount -t devtmpfs devtmpfs /dev
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mkdir -p /evidence
/bin/busybox chown 1000:1000 /dev/tty1 /evidence
cat /proc/cmdline >/evidence/boot-cmdline.txt
cat /sys/module/vt/parameters/default_utf8 >/evidence/vt-default-utf8.txt 2>/evidence/vt-default-utf8.err
scene=visible
for arg in $(cat /proc/cmdline); do case "$arg" in scene=*) scene=${arg#scene=};; esac; done
export CJTUI_INTERACTION_A_DEVICE=/evidence
setsid sh -c 'exec /vt-product-supervisor '"$scene"' </dev/tty1 >/dev/tty1 2>&1'
echo INIT_CHILD_EXIT=$? >/dev/ttyS0
echo EVIDENCE_TAR_BASE64_BEGIN >/dev/ttyS0
tar -C /evidence -cf - . | base64 >/dev/ttyS0
echo EVIDENCE_TAR_BASE64_END >/dev/ttyS0
sleep 1
poweroff -f
