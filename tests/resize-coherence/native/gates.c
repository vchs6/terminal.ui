#define _GNU_SOURCE
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <time.h>
#include <unistd.h>

extern int __real_ioctl(int, unsigned long, ...);
extern ssize_t __real_write(int, const void *, size_t);
static unsigned queries;
static int query_gated, write_gated;
static int marker(const char *name) {
    const char *dir = getenv("CJTUI_RESIZE_HANDSHAKE");
    char path[2048];
    if (!dir) return 0;
    snprintf(path, sizeof(path), "%s/%s", dir, name);
    return access(path, F_OK) == 0;
}
static void hold(const char *name, unsigned cols, unsigned rows) {
    char path[2048];
    const char *dir = getenv("CJTUI_RESIZE_HANDSHAKE");
    snprintf(path, sizeof(path), "%s/%s", dir, name);
    FILE *file = fopen(path, "w");
    if (file) { fprintf(file, "%u %u\n", cols, rows); fclose(file); }
    struct timespec start, now, pause = {0, 1000000};
    clock_gettime(CLOCK_MONOTONIC, &start);
    while (!marker("release")) {
        nanosleep(&pause, NULL);
        clock_gettime(CLOCK_MONOTONIC, &now);
        if (now.tv_sec - start.tv_sec > 20) break;
    }
}
int __wrap_ioctl(int fd, unsigned long request, ...) {
    va_list args; va_start(args, request); void *argument = va_arg(args, void *); va_end(args);
    int result = __real_ioctl(fd, request, argument);
    const char *mode = getenv("CJTUI_RESIZE_MODE");
    const char *dir = getenv("CJTUI_RESIZE_HANDSHAKE");
    if (result == 0 && fd == 1 && request == TIOCGWINSZ && dir) {
        struct winsize *size = argument; unsigned sequence = ++queries;
        char path[2048]; snprintf(path, sizeof(path), "%s/queries.log", dir);
        FILE *file = fopen(path, "a");
        if (file) { fprintf(file, "%u %u %u\n", sequence, size->ws_col, size->ws_row); fclose(file); }
        if (mode && strcmp(mode, "coherence") == 0 && !query_gated && sequence % 2 == 1 && marker("arm")) {
            query_gated = 1; hold("query-held", size->ws_col, size->ws_row);
        }
    }
    return result;
}
ssize_t __wrap_write(int fd, const void *data, size_t length) {
    const char *mode = getenv("CJTUI_RESIZE_MODE");
    if (fd == 1 && mode && strcmp(mode, "inflight") == 0 && !write_gated &&
        memmem(data, length, "\033[1;1H", 6)) {
        write_gated = 1; hold("write-held", 24, 5);
    }
    return __real_write(fd, data, length);
}
