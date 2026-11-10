/* Fixture selfcheck only: exercise syscall faults against the real existing
 * native writer, without substituting any cjtui session implementation. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern void cjt_test_arm(int, int64_t, int);
extern int cjt_buffer_add(int);
extern int cjt_buffer_write(void);
extern void cjt_buffer_clear(void);
int main(int argc, char **argv) {
    if (argc == 5 && !strcmp(argv[1], "safe-set")) {
        /* Injector selfcheck: literal input files, real existing native writer.
         * This is not a Session implementation or cleanup result simulator. */
        cjt_test_arm(1, 0, 2);
        for (int i = 2; i < 5; i++) {
            FILE *input = fopen(argv[i], "rb");
            if (!input) return 5;
            cjt_buffer_clear();
            int byte;
            while ((byte = fgetc(input)) != EOF) {
                if (cjt_buffer_add(byte)) { fclose(input); return 3; }
            }
            if (ferror(input)) { fclose(input); return 6; }
            fclose(input);
            int result = cjt_buffer_write();
            fprintf(stderr, "sequence%d-writer=%d\n", i - 1, result);
            if (result != (i == 3 ? -1 : 0)) return 7;
        }
        return 0;
    }
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
