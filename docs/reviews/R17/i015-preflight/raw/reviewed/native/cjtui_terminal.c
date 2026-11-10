#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <stdatomic.h>
#include <stdint.h>
#include <poll.h>
#include <signal.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <sys/ioctl.h>

static struct termios saved;
static struct sigaction old_winch, old_int, old_term;
static volatile sig_atomic_t interrupted;
static atomic_int active;
static unsigned char *buffer;
static size_t length, capacity;
static void handle_signal(int sig) { if (sig == SIGINT || sig == SIGTERM) interrupted = sig; }
int cjt_open(void) {
    struct sigaction action = {0};
    struct termios raw;
    int expected = 0;
    if (!atomic_compare_exchange_strong(&active, &expected, 1)) return -1;
    if (!isatty(STDIN_FILENO) || !isatty(STDOUT_FILENO)) goto fail;
    if (tcgetattr(STDIN_FILENO, &saved) < 0) goto fail;
    interrupted = 0;
    action.sa_handler = handle_signal; sigemptyset(&action.sa_mask);
    if (sigaction(SIGWINCH, &action, &old_winch) < 0) goto fail;
    if (sigaction(SIGINT, &action, &old_int) < 0) { sigaction(SIGWINCH, &old_winch, 0); goto fail; }
    if (sigaction(SIGTERM, &action, &old_term) < 0) { sigaction(SIGINT, &old_int, 0); sigaction(SIGWINCH, &old_winch, 0); goto fail; }
    raw = saved;
    raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
    raw.c_oflag &= ~(OPOST);
    raw.c_cflag |= CS8;
    raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
    raw.c_cc[VMIN] = 0; raw.c_cc[VTIME] = 0;
    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) < 0) {
        sigaction(SIGTERM, &old_term, 0); sigaction(SIGINT, &old_int, 0); sigaction(SIGWINCH, &old_winch, 0); goto fail;
    }
    return 0;
fail:
    atomic_store(&active, 0);
    return -1;
}
int cjt_close(void) {
    int result = 0;
    if (!active) return 0;
    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &saved) < 0) result = -1;
    if (sigaction(SIGTERM, &old_term, 0) < 0) result = -1;
    if (sigaction(SIGINT, &old_int, 0) < 0) result = -1;
    if (sigaction(SIGWINCH, &old_winch, 0) < 0) result = -1;
    free(buffer); buffer = 0; length = capacity = 0;
    atomic_store(&active, 0);
    return result;
}
int64_t cjt_size_snapshot(void) {
    struct winsize ws;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) < 0) return -1;
    return (int64_t)(((uint64_t)ws.ws_col << 32) | (uint64_t)ws.ws_row);
}
int cjt_size(int axis) {
    int64_t size = cjt_size_snapshot();
    if (size < 0) return -1;
    return axis ? (int)((uint64_t)size & UINT64_C(0xffffffff)) : (int)((uint64_t)size >> 32);
}
int cjt_read(int timeout) {
    struct pollfd pfd = { STDIN_FILENO, POLLIN, 0 };
    unsigned char ch;
    if (interrupted) return -2;
    int p = poll(&pfd, 1, timeout);
    if (p < 0) return errno == EINTR ? (interrupted ? -2 : -1) : -3;
    if (!p) return -1;
    if (pfd.revents & (POLLERR | POLLHUP | POLLNVAL)) return -3;
    ssize_t n = read(STDIN_FILENO, &ch, 1);
    if (n == 1) return ch;
    if (n < 0 && (errno == EINTR || errno == EAGAIN)) return -1;
    return -3;
}
void cjt_buffer_clear(void) { length = 0; }
int cjt_buffer_add(int byte) {
    if (length == capacity) {
        size_t next = capacity ? capacity * 2 : 1024;
        if (next < capacity) return -1;
        void *p = realloc(buffer, next); if (!p) return -1;
        buffer = p; capacity = next;
    }
    buffer[length++] = (unsigned char)byte; return 0;
}
int cjt_buffer_write(void) {
    size_t at = 0;
    while (at < length) {
        ssize_t n = write(STDOUT_FILENO, buffer + at, length - at);
        if (n > 0) { at += (size_t)n; continue; }
        if (n < 0 && errno == EINTR && !interrupted) continue;
        return -1;
    }
    return 0;
}
