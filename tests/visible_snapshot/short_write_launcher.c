#include <signal.h>
#include <stdio.h>
#include <sys/resource.h>
#include <unistd.h>

/* Test process boundary only; no write interception, SDK or product hooks. */
int main(int argc, char **argv) {
    if (argc != 2) { fputs("usage: short-write-launcher CONSUMER\n", stderr); return 2; }
    struct rlimit limit = {32, 32};
    if (signal(SIGXFSZ, SIG_IGN) == SIG_ERR || setrlimit(RLIMIT_FSIZE, &limit) != 0) {
        perror("short write test infrastructure"); return 2;
    }
    execl(argv[1], argv[1], (char *)NULL);
    perror("exec public consumer"); return 2;
}
