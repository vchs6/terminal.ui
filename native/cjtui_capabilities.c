#define _GNU_SOURCE
#include <ctype.h>
#include <dlfcn.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>

enum {
    CJT_REASON_NONE,
    CJT_REASON_TERM_UNSET,
    CJT_REASON_TERM_DUMB,
    CJT_REASON_TERM_INVALID,
    CJT_REASON_PLATFORM,
    CJT_REASON_LIBRARY,
    CJT_REASON_SYMBOL,
    CJT_REASON_ENTRY,
    CJT_REASON_DATABASE
};

enum {
    CJT_MODE_UNKNOWN,
    CJT_MODE_MONOCHROME,
    CJT_MODE_BASIC8,
    CJT_MODE_BASIC16,
    CJT_MODE_INDEXED256,
    CJT_MODE_TRUECOLOR
};

/* Packed ABI layout is documented in design D031–D033. */
enum {
    CJT_BOLD_BIT = 3, CJT_DIM_BIT = 4, CJT_ITALIC_BIT = 5,
    CJT_UNDERLINE_BIT = 6, CJT_INVERSE_BIT = 7, CJT_STRIKE_BIT = 8,
    CJT_TERMINFO_BIT = 9, CJT_COLORTERM_BIT = 10,
    CJT_REASON_SHIFT = 11, CJT_NCV_SHIFT = 16, CJT_NCV_PRESENT_BIT = 48
};

typedef int (*setupterm_fn)(char *, int, int *);
typedef int (*tigetnum_fn)(const char *);
typedef int (*tigetflag_fn)(const char *);
typedef char *(*tigetstr_fn)(const char *);
typedef void *(*set_curterm_fn)(void *);
typedef int (*del_curterm_fn)(void *);

struct cjt_tinfo {
    void *handle;
    setupterm_fn setupterm;
    tigetnum_fn tigetnum;
    tigetflag_fn tigetflag;
    tigetstr_fn tigetstr;
    set_curterm_fn set_curterm;
    del_curterm_fn del_curterm;
    void **cur_term;
};

static pthread_mutex_t cjt_tinfo_lock = PTHREAD_MUTEX_INITIALIZER;
static struct cjt_tinfo cjt_tinfo;
static int cjt_tinfo_state;

static int64_t cjt_pack(int mode, int reason) {
    return (int64_t)mode | ((int64_t)reason << CJT_REASON_SHIFT);
}

static int cjt_valid_term(const char *term) {
    size_t length;
    if (!term || !term[0]) return 0;
    length = strlen(term);
    if (length > 128) return -1;
    for (size_t i = 0; i < length; i++) {
        unsigned char ch = (unsigned char)term[i];
        if (!((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') ||
              (ch >= '0' && ch <= '9') || ch == '_' || ch == '+' || ch == '.' || ch == '-')) return -1;
    }
    return 1;
}

static int cjt_color_term(void) {
    const char *color = getenv("COLORTERM");
    return color && (!strcasecmp(color, "truecolor") || !strcasecmp(color, "24bit"));
}

static int cjt_matches_sgr(const char *value, const char *sgr) {
    size_t at = strlen(sgr);
    if (!value || value == (char *)-1 || strncmp(value, sgr, at)) return 0;
    value += at;
    while (*value) {
        if (value[0] != '$' || value[1] != '<') return 0;
        value += 2;
        if (!isdigit((unsigned char)*value)) return 0;
        while (isdigit((unsigned char)*value)) value++;
        if (*value == '.') {
            value++;
            if (!isdigit((unsigned char)*value)) return 0;
            while (isdigit((unsigned char)*value)) value++;
        }
        if (*value == '*') value++;
        if (*value == '/') value++;
        if (*value != '>') return 0;
        value++;
    }
    return 1;
}

static int cjt_load_tinfo(void) {
#if defined(__linux__) && defined(__GLIBC__)
    if (cjt_tinfo_state) return cjt_tinfo_state == 1;
    cjt_tinfo.handle = dlmopen(LM_ID_NEWLM, "libtinfo.so.6", RTLD_NOW | RTLD_LOCAL);
    if (!cjt_tinfo.handle) {
        cjt_tinfo_state = -1;
        return 0;
    }
    cjt_tinfo.setupterm = (setupterm_fn)dlsym(cjt_tinfo.handle, "setupterm");
    cjt_tinfo.tigetnum = (tigetnum_fn)dlsym(cjt_tinfo.handle, "tigetnum");
    cjt_tinfo.tigetflag = (tigetflag_fn)dlsym(cjt_tinfo.handle, "tigetflag");
    cjt_tinfo.tigetstr = (tigetstr_fn)dlsym(cjt_tinfo.handle, "tigetstr");
    cjt_tinfo.set_curterm = (set_curterm_fn)dlsym(cjt_tinfo.handle, "set_curterm");
    cjt_tinfo.del_curterm = (del_curterm_fn)dlsym(cjt_tinfo.handle, "del_curterm");
    cjt_tinfo.cur_term = (void **)dlsym(cjt_tinfo.handle, "cur_term");
    if (!cjt_tinfo.setupterm || !cjt_tinfo.tigetnum || !cjt_tinfo.tigetflag || !cjt_tinfo.tigetstr ||
        !cjt_tinfo.set_curterm || !cjt_tinfo.del_curterm || !cjt_tinfo.cur_term) {
        dlclose(cjt_tinfo.handle);
        memset(&cjt_tinfo, 0, sizeof(cjt_tinfo));
        cjt_tinfo_state = -2;
        return 0;
    }
    cjt_tinfo_state = 1;
    return 1;
#else
    cjt_tinfo_state = -3;
    return 0;
#endif
}

int64_t cjt_capabilities_detect(void) {
    const char *term = getenv("TERM");
    int valid = cjt_valid_term(term);
    int color_term;
    int error = 0;
    int level = CJT_MODE_UNKNOWN;
    int colors;
    int ncv;
    int flags = 0;
    int reason = CJT_REASON_NONE;
    int64_t result;
    void *saved;
    void *created;

    if (valid <= 0) return cjt_pack(CJT_MODE_UNKNOWN, valid == 0 ? CJT_REASON_TERM_UNSET : CJT_REASON_TERM_INVALID);
    if (!strcmp(term, "dumb")) return cjt_pack(CJT_MODE_UNKNOWN, CJT_REASON_TERM_DUMB);
    color_term = cjt_color_term();

    pthread_mutex_lock(&cjt_tinfo_lock);
    if (!cjt_load_tinfo()) {
        reason = cjt_tinfo_state == -2 ? CJT_REASON_SYMBOL :
            (cjt_tinfo_state == -3 ? CJT_REASON_PLATFORM : CJT_REASON_LIBRARY);
        pthread_mutex_unlock(&cjt_tinfo_lock);
        result = cjt_pack(color_term ? CJT_MODE_TRUECOLOR : CJT_MODE_UNKNOWN, reason);
        return color_term ? result | ((int64_t)1 << CJT_COLORTERM_BIT) : result;
    }
    saved = *cjt_tinfo.cur_term;
    if (cjt_tinfo.setupterm((char *)term, STDOUT_FILENO, &error) != 0) {
        created = *cjt_tinfo.cur_term;
        cjt_tinfo.set_curterm(saved);
        if (created && created != saved) cjt_tinfo.del_curterm(created);
        pthread_mutex_unlock(&cjt_tinfo_lock);
        reason = error == -1 ? CJT_REASON_DATABASE : CJT_REASON_ENTRY;
        result = cjt_pack(color_term ? CJT_MODE_TRUECOLOR : CJT_MODE_UNKNOWN, reason);
        return color_term ? result | ((int64_t)1 << CJT_COLORTERM_BIT) : result;
    }
    created = *cjt_tinfo.cur_term;
    colors = cjt_tinfo.tigetnum("colors");
    if (colors >= 16777216 || cjt_tinfo.tigetflag("RGB") == 1 || cjt_tinfo.tigetflag("Tc") == 1) {
        level = CJT_MODE_TRUECOLOR;
    } else if (colors >= 256) {
        level = CJT_MODE_INDEXED256;
    } else if (colors >= 16) {
        level = CJT_MODE_BASIC16;
    } else if (colors >= 8) {
        level = CJT_MODE_BASIC8;
    } else {
        level = CJT_MODE_MONOCHROME;
    }
    if (color_term) level = CJT_MODE_TRUECOLOR;
    if (cjt_matches_sgr(cjt_tinfo.tigetstr("bold"), "\033[1m")) flags |= 1 << CJT_BOLD_BIT;
    if (cjt_matches_sgr(cjt_tinfo.tigetstr("dim"), "\033[2m")) flags |= 1 << CJT_DIM_BIT;
    if (cjt_matches_sgr(cjt_tinfo.tigetstr("sitm"), "\033[3m")) flags |= 1 << CJT_ITALIC_BIT;
    if (cjt_matches_sgr(cjt_tinfo.tigetstr("smul"), "\033[4m")) flags |= 1 << CJT_UNDERLINE_BIT;
    if (cjt_matches_sgr(cjt_tinfo.tigetstr("rev"), "\033[7m")) flags |= 1 << CJT_INVERSE_BIT;
    if (cjt_matches_sgr(cjt_tinfo.tigetstr("smxx"), "\033[9m")) flags |= 1 << CJT_STRIKE_BIT;
    ncv = cjt_tinfo.tigetnum("ncv");
    cjt_tinfo.set_curterm(saved);
    cjt_tinfo.del_curterm(created);
    pthread_mutex_unlock(&cjt_tinfo_lock);

    result = cjt_pack(level, CJT_REASON_NONE) | ((int64_t)1 << CJT_TERMINFO_BIT) | flags;
    if (color_term) result |= (int64_t)1 << CJT_COLORTERM_BIT;
    if (ncv >= 0) result |= ((int64_t)(uint32_t)ncv << CJT_NCV_SHIFT) | ((int64_t)1 << CJT_NCV_PRESENT_BIT);
    return result;
}
