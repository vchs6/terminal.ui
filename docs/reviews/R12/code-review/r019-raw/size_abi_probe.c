#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <unistd.h>
extern int64_t cjt_size_snapshot(void);
extern int cjt_size(int);
static unsigned calls;
static unsigned short cols, rows;
static int fail;
int __wrap_ioctl(int fd, unsigned long request, ...) {
    assert(fd == STDOUT_FILENO && request == TIOCGWINSZ);
    va_list args;
    va_start(args, request);
    struct winsize *out = va_arg(args, struct winsize *);
    va_end(args);
    calls++;
    if (fail) return -1;
    out->ws_col = cols;
    out->ws_row = rows;
    cols = 7; rows = 9;
    return 0;
}
int main(void) {
    const unsigned short values[] = {0, 1, 65535};
    for (unsigned x = 0; x < 3; x++) for (unsigned y = 0; y < 3; y++) {
        cols = values[x]; rows = values[y]; calls = 0;
        const int64_t result = cjt_size_snapshot();
        assert(calls == 1 && result >= 0);
        assert((uint64_t)result == (((uint64_t)values[x] << 32) | values[y]));
        assert(result / INT64_C(4294967296) == values[x]);
        assert(result % INT64_C(4294967296) == values[y]);
    }
    for (int axis = -1; axis <= 1; axis++) {
        cols = 65535; rows = 123; calls = 0;
        assert(cjt_size(axis) == (axis ? 123 : 65535));
        assert(calls == 1);
    }
    fail = 1; calls = 0;
    assert(cjt_size_snapshot() == -1 && calls == 1);
    calls = 0; assert(cjt_size(0) == -1 && calls == 1);
    calls = 0; assert(cjt_size(1) == -1 && calls == 1);
    puts("PASS: all 0/1/65535 pairs, single ioctl, packed/divmod decoding, legacy axis, error sentinel");
    return 0;
}
