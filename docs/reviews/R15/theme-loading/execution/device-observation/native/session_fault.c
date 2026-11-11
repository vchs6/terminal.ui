/* Test-only native boundary: real product writer/open/close and real PTY remain.
 * Arm only after the first frame. Fail one selected real sequence at a precise
 * cumulative byte boundary, never replace Application or its result encoder. */
#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
extern ssize_t __real_write(int, const void *, size_t);
extern int __real_cjt_buffer_write(void);
extern int __real_cjt_buffer_add(int);
extern int __real_cjt_open(void);
extern int __real_cjt_close(void);
extern int __real_poll(struct pollfd *, nfds_t, int);
static int sequence_extension;
static int armed, fault_mode, target, sequence, in_writer, injected, failed;
static int64_t limit_bytes, written;
static const int signals[3] = {SIGWINCH, SIGINT, SIGTERM};
static struct sigaction before_signals[3];
static void event(const char *name, int64_t a, int64_t b) {
    const char *path = getenv("CJTUI_SESSION_NATIVE");
    if (!path) return;
    FILE *f = fopen(path, "a");
    if (!f) abort();
    fprintf(f, "%s\t%lld\t%lld\n", name, (long long)a, (long long)b);
    fclose(f);
}
static void capture(const char *name, const void *p, size_t n) {
    const char *path = getenv(name);
    if (!path) return;
    int fd = open(path, O_WRONLY | O_CREAT | O_APPEND, 0600);
    if (fd < 0) abort();
    if (__real_write(fd, p, n) != (ssize_t)n) abort();
    close(fd);
}
void cjt_test_arm(int mode, int64_t offset, int which) {
    armed = 1; fault_mode = mode; limit_bytes = offset; target = which;
    sequence = 0; written = 0; injected = 0; failed = 0;
    event("arm", mode, offset);
}
int __wrap_cjt_open(void) {
    for (int i = 0; i < 3; i++) if (sigaction(signals[i], NULL, &before_signals[i])) abort();
    int result = __real_cjt_open(); event("open", result, armed); return result;
}
int __wrap_cjt_close(void) {
    int result = __real_cjt_close();
    for (int i = 0; i < 3; i++) {
        struct sigaction after;
        if (sigaction(signals[i], NULL, &after)) abort();
        int equal = after.sa_handler == before_signals[i].sa_handler;
        for (int sig = 1; sig < 64; sig++) if (sigismember(&after.sa_mask, sig) != sigismember(&before_signals[i].sa_mask, sig)) equal = 0;
        event("signal-restored", signals[i], equal);
    }
    const char *setting = getenv("CJTUI_SESSION_CLOSE_FAIL");
    int inject = setting && !strcmp(setting, "1");
    event("close", result, inject); return result ? result : inject ? -1 : 0;
}
int __wrap_poll(struct pollfd *fds, nfds_t n, int timeout) {
    if (armed && failed) event("poll-after-fault", timeout, 0);
    return __real_poll(fds, n, timeout);
}
int __wrap_cjt_buffer_add(int byte) {
    if (armed && fault_mode == 5 && sequence + 1 == target && !injected) {
        injected = 1; event("allocation", 0, 0); return -1;
    }
    return __real_cjt_buffer_add(byte);
}
int __wrap_cjt_buffer_write(void) {
    if (armed) { sequence++; written = 0; sequence_extension = -1; event("sequence", sequence, 0); }
    in_writer = 1;
    int result = __real_cjt_buffer_write();
    in_writer = 0;
    if (armed) event("sequence-result", result, written);
    return result;
}
ssize_t __wrap_write(int fd, const void *p, size_t n) {
    if (!armed || fd != STDOUT_FILENO) return __real_write(fd, p, n);
    if (in_writer && sequence_extension == -1) {
        const unsigned char *b = p;
        sequence_extension = n >= 4 && b[0] == 27 && ((b[1] == ']' && (b[2] == '2' || (b[2] == '5' && b[3] == '2'))) || (n >= 7 && b[1] == '[' && b[2] == '2' && (b[3] == '2' || b[3] == '3') && b[4] == ';' && b[5] == '2' && b[6] == 't') || (b[1] == 'P' && (b[2] == 27 || (n >= 7 && !memcmp(b + 2, "tmux;", 5)))));
    }
    int selected = in_writer && sequence == target;
    if (selected && fault_mode && fault_mode != 5) {
        if (fault_mode == 2 && !injected) {
            injected = 1; event("eintr", 0, 0); errno = EINTR; return -1;
        }
        if (fault_mode != 2 && fault_mode != 6 && written >= limit_bytes) {
            injected = 1; failed = 1; event("fault", sequence, written);
            if (fault_mode == 4) return 0;
            errno = fault_mode == 3 ? EAGAIN : EIO; return -1;
        }
        if (fault_mode != 2 && fault_mode != 6 && n > (size_t)(limit_bytes - written)) n = (size_t)(limit_bytes - written);
        /* mode 6: successful positive short writes, eventually complete. */
        if (fault_mode == 6 && n > 1) n = 1;
    }
    ssize_t result = __real_write(fd, p, n);
    if (result > 0) { capture("CJTUI_SESSION_ALL_WIRE", p, (size_t)result); if (in_writer && sequence_extension) capture("CJTUI_SESSION_WIRE", p, (size_t)result); written += result; event("write", sequence, result); }
    if (result <= 0) failed = 1;
    return result;
}
