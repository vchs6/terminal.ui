#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#ifdef __linux__
#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <sys/ioctl.h>
#include <linux/kd.h>
#include <linux/vt.h>
#endif

/* status: 0 known, 1 not tty, 2 not concrete, 3 query, 4 not text,
   5 allocation, 6 map query, 7 invalid, 8 unsupported. */
void cjt_glyph_probe(uint8_t *bitmap, int64_t *result) {
    memset(bitmap, 0, 8192);
    result[0] = 8; result[1] = 0; result[2] = 0;
#ifdef __linux__
    struct stat st;
    struct vt_mode vt;
    int mode;
    if (!isatty(STDOUT_FILENO)) { result[0] = 1; return; }
    if (fstat(STDOUT_FILENO, &st) < 0) { result[0] = 3; result[1] = errno; return; }
    if (!S_ISCHR(st.st_mode) || major(st.st_rdev) != 4 || minor(st.st_rdev) < 1 || minor(st.st_rdev) > 63) {
        result[0] = 2; return;
    }
    if (ioctl(STDOUT_FILENO, VT_GETMODE, &vt) < 0 || ioctl(STDOUT_FILENO, KDGETMODE, &mode) < 0) {
        result[0] = 3; result[1] = errno; return;
    }
    if (mode != KD_TEXT) { result[0] = 4; return; }
    struct unipair *pairs = malloc(65535u * sizeof(*pairs));
    if (!pairs) { result[0] = 5; return; }
    struct unimapdesc map = { .entry_ct = 65535, .entries = pairs };
    if (ioctl(STDOUT_FILENO, GIO_UNIMAP, &map) < 0) {
        result[0] = 6; result[1] = errno; free(pairs); return;
    }
    if (map.entries != pairs) { result[0] = 7; free(pairs); return; }
    for (unsigned int i = 0; i < map.entry_ct; ++i) {
        unsigned int c = pairs[i].unicode;
        bitmap[c / 8] |= (uint8_t)(1u << (c % 8));
    }
    result[0] = 0; result[2] = map.entry_ct;
    free(pairs);
#endif
}
