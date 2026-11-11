#define _POSIX_C_SOURCE 200809L
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
// Test-only link seam: -Wl,--wrap=cjt_monotonic_ms. No public/product setter.
// Constant mode rereads one atomic control file. Script mode reads one line per
// invocation, repeating the last line; only fixture code owns the call index.
static unsigned long clock_calls;
int64_t __wrap_cjt_monotonic_ms(void) {
    const char *script = getenv("CJTUI_A_CLOCK_SCRIPT");
    const char *path = script != NULL ? script : getenv("CJTUI_A_CLOCK_FILE");
    int64_t result = -1;
    if (path != NULL) {
        FILE *input = fopen(path,"r");
        if (input != NULL) {
            char value[64], selected[64] = "";
            unsigned long index = 0;
            while (fgets(value,sizeof value,input) != NULL) {
                (void)snprintf(selected,sizeof selected,"%s",value);
                if (script == NULL || index++ >= clock_calls) break;
            }
            (void)fclose(input);
            errno = 0;
            char *end = NULL;
            long long parsed = strtoll(selected,&end,10);
            if (errno == 0 && end != selected && (*end == '\n' || *end == '\0') && parsed >= 0) result = (int64_t)parsed;
        }
    }
    ++clock_calls;
    const char *trace = getenv("CJTUI_A_CLOCK_TRACE");
    if (trace != NULL) {
        FILE *out = fopen(trace,"a");
        if (out != NULL) { (void)fprintf(out,"%lld\n",(long long)result); (void)fclose(out); }
    }
    return result;
}
