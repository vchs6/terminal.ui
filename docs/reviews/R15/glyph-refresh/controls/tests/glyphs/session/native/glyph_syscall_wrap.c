#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <linux/kd.h>
#include <linux/vt.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <sys/ioctl.h>
#include <unistd.h>

/* Test executable only: link-wrap real libc syscalls. No product hooks/overrides.
 * Unrelated ioctl requests and normal terminal open/read/restore stay real.
 * fd0 is a real PTY; only fd1 receives synthetic concrete-VT metadata. */
int __real_fstat(int, struct stat *);
int __real_isatty(int);
int __real_ioctl(int, unsigned long, ...);
void *__real_malloc(size_t);
void *__real_calloc(size_t, size_t);
void __real_free(void *);
ssize_t __real_write(int, const void *, size_t);
static int stdout_tty_calls;
static int after_text_mode;
static void *pair_allocation;

static const char *scenario(void) {
    const char *value = getenv("CJTUI_GLYPH_TEST_NATIVE");
    return value == NULL ? "real" : value;
}
static int is_case(const char *value) { return strcmp(scenario(), value) == 0; }
static void trace(const char *format, ...) {
    const char *path = getenv("CJTUI_GLYPH_TEST_TRACE");
    if (path == NULL) return;
    int saved = errno;
    int fd = open(path, O_CREAT | O_WRONLY | O_APPEND, 0600);
    if (fd >= 0) {
        char line[200];
        va_list args;
        va_start(args, format);
        int size = vsnprintf(line, sizeof line, format, args);
        va_end(args);
        if (size > 0 && (size_t)size < sizeof line) (void)write(fd, line, (size_t)size);
        (void)close(fd);
    }
    errno = saved;
}
int __wrap_fstat(int fd, struct stat *result) {
    if (is_case("real") || fd != STDOUT_FILENO) return __real_fstat(fd, result);
    trace("fstat fd=%d\n", fd);
    if (is_case("fstat-fail")) { errno = EIO; return -1; }
    int status = __real_fstat(fd, result);
    if (status != 0) return status;
    result->st_mode = (result->st_mode & ~S_IFMT) | S_IFCHR;
    result->st_rdev = makedev(4, 1);
    if (is_case("alias-tty0")) result->st_rdev = makedev(4, 0);
    if (is_case("alias-console")) result->st_rdev = makedev(5, 1);
    if (is_case("alias-tty")) result->st_rdev = makedev(5, 0);
    if (is_case("minor64")) result->st_rdev = makedev(4, 64);
    if (is_case("minor63")) result->st_rdev = makedev(4, 63);
    if (is_case("regular")) result->st_mode = (result->st_mode & ~S_IFMT) | S_IFREG;
    return 0;
}
int __wrap_isatty(int fd) {
    if (fd == STDOUT_FILENO) stdout_tty_calls++;
    // cjt_open must first succeed on the actual PTY; only the later probe fails.
    if (is_case("not-tty") && fd == STDOUT_FILENO && stdout_tty_calls > 1) {
        trace("isatty fd=1 false\n"); errno = ENOTTY; return 0;
    }
    return __real_isatty(fd);
}
static unsigned short mapped_code(unsigned int i) {
    if (i < 95) return (unsigned short)(32 + i);
    static const unsigned short extras[] = {0x00e9, 0x2026, 0x4e2d, 0x6587, 0x0301, 0x200d, 0xfe0f, 0x2708, 0x00e9};
    return extras[i - 95];
}
int __wrap_ioctl(int fd, unsigned long request, ...) {
    va_list args;
    va_start(args, request);
    void *data = va_arg(args, void *);
    va_end(args);
    if (is_case("real") || (request != VT_GETMODE && request != KDGETMODE && request != GIO_UNIMAP))
        return __real_ioctl(fd, request, data);
    trace("ioctl fd=%d request=%lu\n", fd, request);
    if (fd != STDOUT_FILENO) { errno = EBADF; return -1; }
    if (request == VT_GETMODE) {
        if (is_case("vt-fail")) { errno = EACCES; return -1; }
        memset(data, 0, sizeof(struct vt_mode));
        return 0;
    }
    if (request == KDGETMODE) {
        if (is_case("kd-fail")) { errno = EIO; return -1; }
        *(int *)data = is_case("graphics") ? KD_GRAPHICS : KD_TEXT;
        after_text_mode = !is_case("graphics");
        return 0;
    }
    struct unimapdesc *map = data;
    trace("unimap capacity=%u\n", (unsigned)map->entry_ct);
    if (is_case("map-fail")) { errno = EACCES; return -1; }
    unsigned int count = is_case("empty") ? 0 : is_case("max") ? 65535 : 104;
    if (map->entry_ct < count) { errno = ENOMEM; return -1; }
    for (unsigned int i = 0; i < count; i++) {
        unsigned short code = mapped_code(i % 104);
        if (is_case("no-question") && code == '?') code = 'A';
        if (is_case("no-border") && (code == '+' || code == '-' || code == '|')) code = 'A';
        map->entries[i].unicode = code;
        map->entries[i].fontpos = (unsigned short)(i % 256);
    }
    map->entry_ct = (unsigned short)count;
    return 0;
}
static void *allocate_pairs(size_t size, int zeroed, size_t count, size_t item_size) {
    int candidate = after_text_mode && size == 65535u * sizeof(struct unipair);
    if (candidate) {
        trace("allocate bytes=%zu\n", size);
        if (is_case("alloc-fail")) { after_text_mode = 0; errno = ENOMEM; return NULL; }
    }
    void *value = zeroed ? __real_calloc(count, item_size) : __real_malloc(size);
    if (candidate) pair_allocation = value;
    return value;
}
void *__wrap_malloc(size_t size) { return allocate_pairs(size, 0, 0, 0); }
void *__wrap_calloc(size_t count, size_t size) {
    if (size != 0 && count > SIZE_MAX / size) return __real_calloc(count, size);
    return allocate_pairs(count * size, 1, count, size);
}
void __wrap_free(void *value) {
    if (value != NULL && value == pair_allocation) { trace("free pairs\n"); pair_allocation = NULL; }
    __real_free(value);
}
ssize_t __wrap_write(int fd, const void *buffer, size_t size) {
    ssize_t actual = __real_write(fd, buffer, size);
    int saved = errno;
    const char *path = getenv("CJTUI_GLYPH_TEST_CAPTURE");
    if (fd == STDOUT_FILENO && actual > 0 && path != NULL) {
        int capture = open(path, O_CREAT | O_WRONLY | O_APPEND, 0600);
        if (capture >= 0) {
            const unsigned char *bytes = buffer;
            size_t offset = 0;
            while (offset < (size_t)actual) {
                ssize_t n = __real_write(capture, bytes + offset, (size_t)actual - offset);
                if (n > 0) offset += (size_t)n;
                else if (n < 0 && errno == EINTR) continue;
                else break;
            }
            (void)close(capture);
        }
    }
    errno = saved;
    return actual;
}
