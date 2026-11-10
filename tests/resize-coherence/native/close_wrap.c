/* Test-only link boundary. Always perform the product's actual close first. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int __real_cjt_close(void);
int __wrap_cjt_close(void) {
    const int real_result = __real_cjt_close();
    const char *setting = getenv("CJTUI_TEST_CLOSE_FAIL");
    const int inject = setting != NULL && strcmp(setting, "1") == 0;
    const char *path = getenv("CJTUI_TEST_CLOSE_RECORD");
    if (path != NULL) {
        FILE *record = fopen(path, "a");
        if (record != NULL) {
            fprintf(record, "real_result=%d injected=%d\n", real_result, inject);
            fclose(record);
        }
    }
    return real_result != 0 ? real_result : (inject ? -1 : 0);
}
