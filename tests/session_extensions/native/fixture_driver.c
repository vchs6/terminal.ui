/* Fixture selfcheck only: exercise syscall faults against the real existing
 * native writer, without substituting any cjtui session implementation. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
extern void cjt_test_arm(int, int64_t, int);
extern int cjt_buffer_add(int);
extern int cjt_buffer_write(void);
extern void cjt_buffer_clear(void);
int main(int argc, char **argv) {
    if (argc != 3 && argc != 5 && argc != 6) return 2;
    cjt_test_arm(atoi(argv[1]), atoll(argv[2]), argc >= 5 ? atoi(argv[4]) : 1);
    const unsigned char frame[] = "\033]52;c;Zg==\007";
    const unsigned char screen[] = "\033[HFRAME";
    const unsigned char *bytes = argc == 6 ? screen : frame;
    unsigned length = argc == 6 ? sizeof(screen) - 1 : sizeof(frame) - 1;
    for (int count = 0; count < (argc >= 5 ? atoi(argv[3]) : 1); count++) {
    cjt_buffer_clear();
    for (unsigned i = 0; i < length; i++) {
        if (cjt_buffer_add(bytes[i]) != 0) { fputs("allocation-failed\n", stderr); return 3; }
    }
    int result = cjt_buffer_write();
    fprintf(stderr, "writer=%d\n", result);
    if (result != 0) return 4;
    }
    return 0;
}
