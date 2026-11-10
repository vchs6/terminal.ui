#define _GNU_SOURCE
#include <dlfcn.h>
#include <fcntl.h>
#include <limits.h>
#include <pthread.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <unistd.h>

/* Test-process I/O gate. The product reads real regular TOML files through its
 * normal SDK API. No parser, Theme, worker, or candidate is replaced here.
 * Control FIFOs belong to the test interposer, never to the product input. */
static int (*next_open)(const char *, int, ...);
static int (*next_open64)(const char *, int, ...);
static int (*next_openat)(int, const char *, int, ...);
static int (*next_openat64)(int, const char *, int, ...);
static FILE *(*next_fopen)(const char *, const char *);
static FILE *(*next_fopen64)(const char *, const char *);
static __thread int inside;
static pthread_mutex_t counts_lock = PTHREAD_MUTEX_INITIALIZER;
struct seen_path { char name[256]; unsigned count; };
static struct seen_path seen[128];
static unsigned seen_count;

__attribute__((constructor)) static void setup(void) {
    inside = 1;
    next_open = dlsym(RTLD_NEXT, "open");
    next_open64 = dlsym(RTLD_NEXT, "open64");
    next_openat = dlsym(RTLD_NEXT, "openat");
    next_openat64 = dlsym(RTLD_NEXT, "openat64");
    next_fopen = dlsym(RTLD_NEXT, "fopen");
    next_fopen64 = dlsym(RTLD_NEXT, "fopen64");
    inside = 0;
}
static void fail(const char *why) {
    syscall(SYS_write, 2, why, strlen(why));
    syscall(SYS_exit_group, 93);
}
static void before_open(int dirfd, const char *path, const char *api) {
    if (inside || !path) return;
    const char *root = getenv("THEME_GATE_ROOT");
    const char *control = getenv("THEME_GATE_CONTROL");
    if (!root || !control) return;
    char candidate[PATH_MAX], absolute[PATH_MAX];
    if (path[0] == '/' || dirfd == AT_FDCWD) {
        if (!realpath(path, absolute)) return;
    } else {
        int n = snprintf(candidate, sizeof candidate, "/proc/self/fd/%d/%s", dirfd, path);
        if (n < 0 || n >= (int)sizeof candidate || !realpath(candidate, absolute)) return;
    }
    size_t root_len = strlen(root);
    if (strncmp(root, absolute, root_len) || absolute[root_len] != '/') return;
    const char *base = strrchr(absolute, '/') + 1;
    if (strncmp(base, "gate-", 5)) return;
    struct stat st;
    if (stat(absolute, &st) || !S_ISREG(st.st_mode)) fail("THEME_GATE invalid ordinary-file fixture\n");
    inside = 1;
    pthread_mutex_lock(&counts_lock);
    unsigned index = 0;
    while (index < seen_count && strcmp(seen[index].name, base)) ++index;
    if (index == seen_count) {
        if (seen_count == 128 || strlen(base) >= sizeof seen[index].name) fail("THEME_GATE fixture counter capacity\n");
        strcpy(seen[index].name, base);
        ++seen_count;
    }
    unsigned sequence = ++seen[index].count;
    pthread_mutex_unlock(&counts_lock);
    char event[PATH_MAX + 256];
    int length = snprintf(event, sizeof event, "THEME_GATE ENTER %s %u %s %ld\n", base, sequence, api, syscall(SYS_gettid));
    if (length <= 0 || length >= (int)sizeof event) fail("THEME_GATE event overflow\n");
    syscall(SYS_write, 2, event, (size_t)length);
    char pipe_path[PATH_MAX];
    int n = snprintf(pipe_path, sizeof pipe_path, "%s/%s.%u", control, base, sequence);
    if (n <= 0 || n >= (int)sizeof pipe_path) fail("THEME_GATE control path overflow\n");
    int fd = (int)syscall(SYS_openat, AT_FDCWD, pipe_path, O_RDONLY | O_CLOEXEC, 0);
    if (fd < 0) fail("THEME_GATE control open failed\n");
    char byte = 0;
    ssize_t got = syscall(SYS_read, fd, &byte, 1);
    syscall(SYS_close, fd);
    if (got != 1 || byte != 'R') fail("THEME_GATE invalid release\n");
    length = snprintf(event, sizeof event, "THEME_GATE RELEASED %s %u\n", base, sequence);
    syscall(SYS_write, 2, event, (size_t)length);
    inside = 0;
}
#define MODE(flags, arguments, mode) do { \
    mode = 0; \
    if (((flags) & O_CREAT) || (((flags) & O_TMPFILE) == O_TMPFILE)) { \
        va_start(arguments, flags); mode = (mode_t)va_arg(arguments, int); va_end(arguments); \
    } \
} while (0)
int open(const char *path, int flags, ...) {
    va_list arguments; mode_t mode; MODE(flags, arguments, mode);
    before_open(AT_FDCWD, path, "open");
    return next_open ? next_open(path, flags, mode) : (int)syscall(SYS_openat, AT_FDCWD, path, flags, mode);
}
int open64(const char *path, int flags, ...) {
    va_list arguments; mode_t mode; MODE(flags, arguments, mode);
    before_open(AT_FDCWD, path, "open64");
    return next_open64 ? next_open64(path, flags, mode) : (int)syscall(SYS_openat, AT_FDCWD, path, flags, mode);
}
int openat(int dirfd, const char *path, int flags, ...) {
    va_list arguments; mode_t mode; MODE(flags, arguments, mode);
    before_open(dirfd, path, "openat");
    return next_openat ? next_openat(dirfd, path, flags, mode) : (int)syscall(SYS_openat, dirfd, path, flags, mode);
}
int openat64(int dirfd, const char *path, int flags, ...) {
    va_list arguments; mode_t mode; MODE(flags, arguments, mode);
    before_open(dirfd, path, "openat64");
    return next_openat64 ? next_openat64(dirfd, path, flags, mode) : (int)syscall(SYS_openat, dirfd, path, flags, mode);
}
FILE *fopen(const char *path, const char *mode) {
    before_open(AT_FDCWD, path, "fopen");
    inside = 1; FILE *result = next_fopen(path, mode); inside = 0; return result;
}
FILE *fopen64(const char *path, const char *mode) {
    before_open(AT_FDCWD, path, "fopen64");
    inside = 1; FILE *result = next_fopen64(path, mode); inside = 0; return result;
}
