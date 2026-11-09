#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <pthread.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>
#include <poll.h>

/* Internal bridge ABI only: link the actual product translation unit separately. */
extern int cjt_open(void), cjt_close(void), cjt_read(int timeout);
static enum { OWNER, SETUP_SIGNAL } scenario;
static struct termios original, device;
static pthread_mutex_t guard = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t progress = PTHREAD_COND_INITIALIZER;
static _Thread_local int role;
static int first_paused, release_first, first_finished;
static int second_in_environment, second_finished, applies;

int __wrap_isatty(int fd) {
    if (scenario == OWNER) {
        pthread_mutex_lock(&guard);
        if (role == 1 && fd == STDOUT_FILENO) {
            first_paused = 1;
            pthread_cond_broadcast(&progress);
            while (!release_first) pthread_cond_wait(&progress, &guard);
        }
        if (role == 2) {
            second_in_environment = 1;
            pthread_cond_broadcast(&progress);
        }
        pthread_mutex_unlock(&guard);
    }
    return 1;
}
int __wrap_tcgetattr(int fd, struct termios *value) {
    (void)fd;
    pthread_mutex_lock(&guard);
    /* A losing opener must never overwrite the owner's original snapshot.
       Delay its device read until the first opener has actually finished. */
    while (scenario == OWNER && role == 2 && !first_finished)
        pthread_cond_wait(&progress, &guard);
    *value = device;
    pthread_mutex_unlock(&guard);
    return 0;
}
int __wrap_tcsetattr(int fd, int action, const struct termios *value) {
    (void)fd; (void)action;
    pthread_mutex_lock(&guard);
    device = *value;
    int inject_signal = scenario == SETUP_SIGNAL && ++applies == 1;
    pthread_mutex_unlock(&guard);
    /* A real signal exercises the product's actual sigaction handler. */
    if (inject_signal && raise(SIGTERM) != 0) abort();
    return 0;
}
int __wrap_poll(struct pollfd *fds, nfds_t count, int timeout) {
    (void)fds; (void)count; (void)timeout;
    return 0; /* No input available; cancellation must not be erased by setup. */
}
static void initialize_device(void) {
    memset(&original, 0, sizeof(original));
    original.c_iflag = BRKINT | ICRNL | IXON;
    original.c_oflag = OPOST;
    original.c_cflag = CS8;
    original.c_lflag = ECHO | ICANON | IEXTEN | ISIG;
    original.c_cc[VMIN] = 1;
    original.c_cc[VTIME] = 0;
    device = original;
}
static struct timespec deadline_ms(long milliseconds) {
    struct timespec deadline;
    if (clock_gettime(CLOCK_REALTIME, &deadline) != 0) abort();
    deadline.tv_sec += milliseconds / 1000;
    deadline.tv_nsec += (milliseconds % 1000) * 1000000L;
    if (deadline.tv_nsec >= 1000000000L) {
        deadline.tv_sec++;
        deadline.tv_nsec -= 1000000000L;
    }
    return deadline;
}
static void *open_thread(void *arg) {
    role = (int)(intptr_t)arg;
    int result = cjt_open();
    pthread_mutex_lock(&guard);
    if (role == 1) first_finished = 1;
    else second_finished = 1;
    pthread_cond_broadcast(&progress);
    pthread_mutex_unlock(&guard);
    return (void *)(intptr_t)result;
}
static int owner_case(void) {
    pthread_t first, second;
    void *first_result, *second_result;
    if (pthread_create(&first, NULL, open_thread, (void *)(intptr_t)1) != 0) return 1;
    pthread_mutex_lock(&guard);
    struct timespec deadline = deadline_ms(3000);
    while (!first_paused) {
        if (pthread_cond_timedwait(&progress, &guard, &deadline) == ETIMEDOUT) {
            fprintf(stderr, "FAIL owner: first opener did not reach the TTY setup gate\n");
            pthread_mutex_unlock(&guard);
            return 1;
        }
    }
    pthread_mutex_unlock(&guard);
    if (pthread_create(&second, NULL, open_thread, (void *)(intptr_t)2) != 0) return 1;
    pthread_mutex_lock(&guard);
    deadline = deadline_ms(250);
    /* Correct atomic rejection may finish before any wrapped syscall.
       Correct serialization may wait outside the wrapped syscalls. Neither
       requires the second thread to reach an internal barrier to release first. */
    while (!second_in_environment && !second_finished) {
        if (pthread_cond_timedwait(&progress, &guard, &deadline) == ETIMEDOUT) break;
    }
    release_first = 1;
    pthread_cond_broadcast(&progress);
    pthread_mutex_unlock(&guard);
    if (pthread_join(first, &first_result) != 0 || pthread_join(second, &second_result) != 0) return 1;
    int first_code = (int)(intptr_t)first_result;
    int second_code = (int)(intptr_t)second_result;
    int successes = (first_code == 0) + (second_code == 0);
    int closed = cjt_close();
    int restored = memcmp(&device, &original, sizeof(device)) == 0;
    printf("owner: open1=%d open2=%d successes=%d close=%d restored=%d original_lflag=%lu restored_lflag=%lu\n",
        first_code, second_code, successes, closed, restored,
        (unsigned long)original.c_lflag, (unsigned long)device.c_lflag);
    if (successes != 1 || closed != 0 || !restored) {
        fprintf(stderr, "FAIL owner: exactly one open may own the terminal, and close must restore its original termios\n");
        return 1;
    }
    puts("PASS owner");
    return 0;
}
static int setup_signal_case(void) {
    int opened = cjt_open();
    int next_read = cjt_read(0);
    int closed = cjt_close();
    int restored = memcmp(&device, &original, sizeof(device)) == 0;
    printf("setup-signal: open=%d read_after_SIGTERM=%d close=%d restored=%d\n", opened, next_read, closed, restored);
    if (opened != 0 || next_read != -2 || closed != 0 || !restored) {
        fprintf(stderr, "FAIL setup-signal: setup must preserve the real SIGTERM for the next read cancellation (-2), then restore termios\n");
        return 1;
    }
    puts("PASS setup-signal");
    return 0;
}
int main(int argc, char **argv) {
    if (argc != 2) { fprintf(stderr, "usage: session owner|setup-signal\n"); return 2; }
    if (strcmp(argv[1], "owner") == 0) scenario = OWNER;
    else if (strcmp(argv[1], "setup-signal") == 0) scenario = SETUP_SIGNAL;
    else { fprintf(stderr, "unknown scenario\n"); return 2; }
    /* A hang is an error; this signal is unrelated to the cancellation under test. */
    alarm(8);
    initialize_device();
    return scenario == OWNER ? owner_case() : setup_signal_case();
}
