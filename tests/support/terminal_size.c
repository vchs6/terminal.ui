#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <unistd.h>

int main(int argc, char **argv) {
    if (argc != 4) { fprintf(stderr, "usage: terminal-size own-tty cols rows\n"); return 2; }
    char *end;
    errno = 0; unsigned long cols = strtoul(argv[2], &end, 10);
    if (errno || *end || cols > 65535) return 2;
    errno = 0; unsigned long rows = strtoul(argv[3], &end, 10);
    if (errno || *end || rows > 65535) return 2;
    int fd = open(argv[1], O_RDWR | O_NOCTTY);
    if (fd < 0) { perror("open own tty"); return 1; }
    struct winsize size = { .ws_row = (unsigned short)rows, .ws_col = (unsigned short)cols };
    /* Exactly one SET carries both dimensions. The following GET verifies it. */
    int result;
    result = ioctl(fd, TIOCSWINSZ, &size);
    if (result < 0) { perror("TIOCSWINSZ"); close(fd); return 1; }
    do { result = ioctl(fd, TIOCGWINSZ, &size); } while (result < 0 && errno == EINTR);
    if (result < 0) { perror("TIOCGWINSZ"); close(fd); return 1; }
    close(fd);
    printf("%u %u\n", size.ws_col, size.ws_row);
    return size.ws_col == cols && size.ws_row == rows ? 0 : 1;
}
