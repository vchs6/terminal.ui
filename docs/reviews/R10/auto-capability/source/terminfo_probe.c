/*
 * Isolated POSIX probe for libtinfo.  It intentionally has no product
 * dependency: this is only evidence for whether a future optional loader can
 * query terminfo without permanently replacing the library's current terminal.
 */
#define _XOPEN_SOURCE 700
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct term TERMINAL;
typedef int (*setupterm_fn)(const char *, int, int *);
typedef int (*tigetnum_fn)(const char *);
typedef int (*tigetflag_fn)(const char *);
typedef char *(*tigetstr_fn)(const char *);
typedef TERMINAL *(*set_curterm_fn)(TERMINAL *);
typedef void (*del_curterm_fn)(TERMINAL *);

static void print_num(tigetnum_fn f, const char *name) {
  printf("num.%s=%d\n", name, f(name));
}

static void print_flag(tigetflag_fn f, const char *name) {
  printf("flag.%s=%d\n", name, f(name));
}

static void print_str(tigetstr_fn f, const char *name) {
  char *value = f(name);
  if (value == (char *)-1) {
    printf("str.%s=INVALID_OR_NOT_STRING\n", name);
  } else if (value == NULL) {
    printf("str.%s=ABSENT_OR_CANCELLED\n", name);
  } else {
    printf("str.%s=PRESENT bytes=%zu\n", name, strlen(value));
  }
}

int main(int argc, char **argv) {
  const char *term = argc > 1 ? argv[1] : getenv("TERM");
  const char *library = argc > 2 ? argv[2] : "libtinfo.so.6";
  const char *seed_term = argc > 3 ? argv[3] : NULL;
  void *h = dlopen(library, RTLD_LAZY | RTLD_LOCAL);
  if (!h) { printf("dlopen=FAIL %s\n", dlerror()); return 10; }

  setupterm_fn setupterm = (setupterm_fn)dlsym(h, "setupterm");
  tigetnum_fn tigetnum = (tigetnum_fn)dlsym(h, "tigetnum");
  tigetflag_fn tigetflag = (tigetflag_fn)dlsym(h, "tigetflag");
  tigetstr_fn tigetstr = (tigetstr_fn)dlsym(h, "tigetstr");
  set_curterm_fn set_curterm = (set_curterm_fn)dlsym(h, "set_curterm");
  del_curterm_fn del_curterm = (del_curterm_fn)dlsym(h, "del_curterm");
  TERMINAL **cur_term = (TERMINAL **)dlsym(h, "cur_term");
  printf("dlopen=OK setupterm=%s tigetnum=%s tigetflag=%s tigetstr=%s set_curterm=%s del_curterm=%s cur_term=%s\n",
      setupterm ? "OK" : "MISS", tigetnum ? "OK" : "MISS",
      tigetflag ? "OK" : "MISS", tigetstr ? "OK" : "MISS", set_curterm ? "OK" : "MISS",
      del_curterm ? "OK" : "MISS", cur_term ? "OK" : "MISS");
  if (!term || !setupterm || !tigetnum || !tigetflag || !tigetstr || !set_curterm || !del_curterm || !cur_term) {
    dlclose(h); return 11;
  }

  if (seed_term) {
    int seed_err = 999;
    int seed_rc = setupterm(seed_term, 1, &seed_err);
    printf("seed.term=%s seed.rc=%d seed.errret=%d seed.current=%p\n",
        seed_term, seed_rc, seed_err, (void *)*cur_term);
    if (seed_rc != 0) { dlclose(h); return 13; }
  }
  TERMINAL *saved = *cur_term;
  int err = 999;
  int rc = setupterm(term, 1, &err);
  TERMINAL *created = *cur_term;
  printf("term=%s setupterm.rc=%d errret=%d saved=%p created=%p\n",
      term, rc, err, (void *)saved, (void *)created);
  if (rc != 0) { dlclose(h); return 12; }

  print_num(tigetnum, "colors");
  print_num(tigetnum, "pairs");
  print_num(tigetnum, "ncv");
  print_flag(tigetflag, "ccc");
  print_flag(tigetflag, "Tc");
  print_flag(tigetflag, "RGB");
  print_str(tigetstr, "bold");
  print_str(tigetstr, "dim");
  print_str(tigetstr, "sitm");
  print_str(tigetstr, "smul");
  print_str(tigetstr, "rev");
  print_str(tigetstr, "smxx");

  TERMINAL *returned = set_curterm(saved);
  printf("restore.returned=%p restore.current=%p restore.matches_saved=%s\n",
      (void *)returned, (void *)*cur_term, *cur_term == saved ? "yes" : "no");
  del_curterm(created);
  printf("delete.created=done current_after_delete=%p current_still_saved=%s\n",
      (void *)*cur_term, *cur_term == saved ? "yes" : "no");
  dlclose(h);
  return 0;
}
