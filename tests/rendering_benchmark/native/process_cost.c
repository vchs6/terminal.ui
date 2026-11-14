#define _DEFAULT_SOURCE
#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/resource.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

/* Test-side whole-process observer. Never linked to the product/benchmark. */
static int64_t micros(struct timeval value) {
    return (int64_t)value.tv_sec * 1000000 + value.tv_usec;
}
static void csv_text(FILE *out, const char *value) {
    fputc('"', out);
    for (; *value; ++value) {
        if (*value == '"') fputc('"', out);
        fputc(*value, out);
    }
    fputc('"', out);
}
int main(int argc, char **argv) {
    if (argc < 4) {
        fputs("usage: process_cost RUN_ID NEW_REPORT.csv COMMAND [ARG...]\n", stderr);
        return 2;
    }
    FILE *out = fopen(argv[2], "wx");
    if (!out) { perror("new process report"); return 2; }
    struct timespec begin, end;
    if (clock_gettime(CLOCK_MONOTONIC, &begin) != 0) {
        perror("monotonic clock"); fclose(out); return 2;
    }
    const pid_t child = fork();
    if (child < 0) { perror("fork"); fclose(out); return 2; }
    if (child == 0) {
        fclose(out);
        execvp(argv[3], argv + 3);
        perror("execvp"); _exit(127);
    }
    int status = 0;
    struct rusage usage;
    pid_t waited;
    do { waited = wait4(child, &status, 0, &usage); } while (waited < 0 && errno == EINTR);
    if (waited != child || clock_gettime(CLOCK_MONOTONIC, &end) != 0) {
        perror("process measurement"); fclose(out); return 2;
    }
    const int code = WIFEXITED(status) ? WEXITSTATUS(status) :
        WIFSIGNALED(status) ? 128 + WTERMSIG(status) : 125;
    const int64_t wall = ((int64_t)end.tv_sec - begin.tv_sec) * 1000000 +
        ((int64_t)end.tv_nsec - begin.tv_nsec) / 1000;
    fputs("run_id,process_pid,executable,scope,instrumentation,cpu_user_us,cpu_system_us,wall_us,peak_rss_kib,exit_code,limitations\n", out);
    csv_text(out, argv[1]);
    fprintf(out, ",%ld,", (long)child);
    csv_text(out, argv[3]);
    fprintf(out, ",whole_process,none,%lld,%lld,%lld,%ld,%d,none\n",
        (long long)micros(usage.ru_utime), (long long)micros(usage.ru_stime),
        (long long)wall, usage.ru_maxrss, code);
    const int failed = ferror(out);
    if (fclose(out) != 0 || failed) { perror("write process report"); return 2; }
    return code;
}
