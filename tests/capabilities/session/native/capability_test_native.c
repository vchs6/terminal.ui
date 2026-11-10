#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdint.h>
#include <stdlib.h>

/* Test-only seam: ordinary consumers do not link this archive or --wrap. */
void *__real_dlmopen(long lmid, const char *file, int mode);

void *__wrap_dlmopen(long lmid, const char *file, int mode) {
    if (getenv("CJTUI_CAP_TEST_DLMOPEN_FAIL") != NULL) {
        return NULL;
    }
    return __real_dlmopen(lmid, file, mode);
}

typedef int (*setupterm_fn)(const char *, int, int *);
typedef int (*tigetnum_fn)(const char *);

static void *base_tinfo(void) {
    return dlopen("libtinfo.so.6", RTLD_NOW | RTLD_LOCAL);
}

int64_t cjt_test_base_seed(void) {
    void *library = base_tinfo();
    setupterm_fn setupterm = library == NULL ? NULL : (setupterm_fn)dlsym(library, "setupterm");
    tigetnum_fn tigetnum = library == NULL ? NULL : (tigetnum_fn)dlsym(library, "tigetnum");
    int error = 0;
    if (setupterm == NULL || tigetnum == NULL || setupterm("cap-16", 1, &error) != 0) {
        return -1;
    }
    return tigetnum("colors");
}

int64_t cjt_test_base_colors(void) {
    void *library = base_tinfo();
    tigetnum_fn tigetnum = library == NULL ? NULL : (tigetnum_fn)dlsym(library, "tigetnum");
    return tigetnum == NULL ? -1 : tigetnum("colors");
}
