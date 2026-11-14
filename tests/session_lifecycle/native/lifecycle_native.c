/* Test-only observations composed with unchanged accepted Session152 helper.
 * Product native functions remain the only terminal/buffer implementation. */
#define __wrap_cjt_open session_base_open
#define __wrap_cjt_close session_base_close
#define __wrap_cjt_buffer_add session_base_add
#define __wrap_poll session_base_poll
#include "../../session_extensions/native/session_fault.c"
#undef __wrap_cjt_open
#undef __wrap_cjt_close
#undef __wrap_cjt_buffer_add
#undef __wrap_poll
#include <termios.h>
#include <sys/stat.h>
extern void *__real_realloc(void *, size_t);
extern void __real_free(void *);
extern ssize_t __real_read(int, void *, size_t);
static int tracking, observations_ready, pipe_input = -1;
static void *owned_buffer;
static int allocations, frees;
static struct sigaction full_before[3];
static int observed_run;
/* Observe every defined Linux termios field on fd0 itself. Do not reset it. */
static void termios_snapshot(const char *phase) {
    int caller_errno = errno;
    struct termios value;
    int result = tcgetattr(STDIN_FILENO, &value);
    int termios_errno = result < 0 ? errno : 0;
    struct stat endpoint;
    if (fstat(STDIN_FILENO, &endpoint)) abort();
    const char *directory = getenv("CJTUI_020_OUTPUT");
    if (!directory) abort();
    char path[4096];
    int length = snprintf(path, sizeof(path), "%s/native-termios-%s-%d.json", directory, phase, observed_run);
    if (length < 0 || (size_t)length >= sizeof(path)) abort();
    FILE *file = fopen(path, "w"); if (!file) abort();
    fprintf(file, "{\"run\":%d,\"phase\":\"%s\",\"endpoint\":{\"fd\":0,\"dev\":%llu,\"ino\":%llu,\"rdev\":%llu},\"rc\":%d,\"errno\":",
        observed_run, phase, (unsigned long long)endpoint.st_dev,
        (unsigned long long)endpoint.st_ino, (unsigned long long)endpoint.st_rdev, result);
    if (result < 0) fprintf(file, "%d,\"fields\":null}\n", termios_errno);
    else {
        fprintf(file, "null,\"fields\":{\"iflag\":%llu,\"oflag\":%llu,\"cflag\":%llu,\"lflag\":%llu,\"line\":%u,\"cc\":[",
            (unsigned long long)value.c_iflag, (unsigned long long)value.c_oflag,
            (unsigned long long)value.c_cflag, (unsigned long long)value.c_lflag, (unsigned)value.c_line);
        for (int i = 0; i < NCCS; i++) fprintf(file, "%s%u", i ? "," : "", (unsigned)value.c_cc[i]);
        fprintf(file, "],\"ispeed\":%llu,\"ospeed\":%llu}}\n",
            (unsigned long long)value.c_ispeed, (unsigned long long)value.c_ospeed);
    }
    if (fclose(file)) abort();
    errno = caller_errno;
}
static void original_handler(int sig) { (void)sig; }
void *__wrap_realloc(void *ptr, size_t size) {
    void *result = __real_realloc(ptr, size);
    if (tracking && result) { owned_buffer = result; allocations++; }
    return result;
}
void __wrap_free(void *ptr) {
    if (ptr && ptr == owned_buffer) { frees++; owned_buffer = NULL; event("buffer-free", frees, 0); }
    __real_free(ptr);
}
int __wrap_cjt_buffer_add(int byte) {
    tracking = 1; int result = session_base_add(byte); tracking = 0; return result;
}
int __wrap_cjt_open(void) {
    observed_run++; termios_snapshot("before");
    if (!observations_ready) {
        struct sigaction custom = {0};
        custom.sa_handler = original_handler; custom.sa_flags = SA_RESTART | SA_NODEFER;
        sigemptyset(&custom.sa_mask); sigaddset(&custom.sa_mask, SIGUSR1);
        for (int i = 0; i < 3; i++) if (sigaction(signals[i], &custom, NULL)) abort();
        observations_ready = 1;
    }
    for (int i = 0; i < 3; i++) if (sigaction(signals[i], NULL, &full_before[i])) abort();
    int result = session_base_open();
    if (!result) {
        struct termios raw; if (tcgetattr(0, &raw)) abort();
        int correct = !(raw.c_iflag & (BRKINT | ICRNL | INPCK | ISTRIP | IXON)) &&
            !(raw.c_oflag & OPOST) && !(raw.c_lflag & (ECHO | ICANON | IEXTEN | ISIG)) &&
            (raw.c_cflag & CSIZE) == CS8 && raw.c_cc[VMIN] == 0 && raw.c_cc[VTIME] == 0;
        event("raw-active", correct, 0);
    }
    return result;
}
int cjt_lifecycle_owner(void) {
    int result = __real_cjt_open(); event("competing-open", result, 0); return result;
}
/* An actual OS pipe is routed only at read/poll, after a real TTY run started.
 * tcgetattr/tcsetattr/isatty/output keep their real original TTY endpoints.
 * This is transport evidence, not a natural terminal-host HUP claim. */
int cjt_lifecycle_eof(int buffered) {
    int fds[2]; if (pipe(fds)) return -1;
    pipe_input = fds[0];
    if (buffered) {
        const char data[] = "z\033[";
        if (__real_write(fds[1], data, sizeof(data)-1) != sizeof(data)-1) abort();
    }
    close(fds[1]); event("pipe-start", buffered, 0); return 0;
}
ssize_t __wrap_read(int fd, void *buf, size_t n) {
    int target_fd = fd == 0 && pipe_input >= 0 ? pipe_input : fd;
    ssize_t result = __real_read(target_fd, buf, n);
    int read_errno = errno;
    if (target_fd == fd && fd == 0 && result <= 0) event("tty-read", result, result < 0 ? read_errno : 0);
    if (target_fd != fd) event("pipe-read", result, result > 0 ? *(unsigned char *)buf : 0);
    errno = read_errno;
    return result;
}
int __wrap_poll(struct pollfd *fds, nfds_t n, int timeout) {
    if (n == 1 && fds[0].fd == 0 && pipe_input >= 0) {
        struct pollfd actual = fds[0]; actual.fd = pipe_input;
        int result = __real_poll(&actual, 1, timeout); int poll_errno = errno;
        fds[0].revents = actual.revents;
        event("pipe-poll", result, actual.revents); errno = poll_errno; return result;
    }
    return session_base_poll(fds,n,timeout);
}
int __wrap_cjt_close(void) {
    int result = session_base_close();
    /* Explicit negative-control only: create a real wrong child post-state.
     * Never repair/reset that endpoint to make the observation pass. */
    const char *negative = getenv("CJTUI_020_NEGATIVE_CHILD_DRIFT");
    if (negative && !strcmp(negative, "1") && observed_run == 1) {
        struct termios drift;
        if (tcgetattr(STDIN_FILENO, &drift)) abort();
        drift.c_lflag ^= ECHO;
        if (tcsetattr(STDIN_FILENO, TCSANOW, &drift)) abort();
        event("negative-child-drift", 1, 0);
    }
    termios_snapshot("after");
    for (int i = 0; i < 3; i++) {
        struct sigaction after; if (sigaction(signals[i], NULL, &after)) abort();
        event("signal-flags", signals[i], after.sa_flags == full_before[i].sa_flags);
    }
    event("buffer-released", owned_buffer == NULL, allocations);
    if (pipe_input >= 0) { close(pipe_input); pipe_input = -1; }
    return result;
}

extern int __real_cjt_read(int);
extern int64_t __real_cjt_size_snapshot(void);
int __wrap_cjt_read(int timeout) {
    int result = __real_cjt_read(timeout);
    if (result == -2 || result == -3 || result == -4) event("native-read", result, 0);
    return result;
}
int64_t __wrap_cjt_size_snapshot(void) {
    int64_t result = __real_cjt_size_snapshot();
    if (result < 0) event("size-result", result, errno);
    return result;
}
