/* Minimal C helper called once from a Cangjie 1.2 executable. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <link.h>
#include <stddef.h>
#include <stdint.h>

typedef struct term TERMINAL;
typedef int (*setupterm_fn)(const char *, int, int *);
typedef int (*tigetnum_fn)(const char *);
typedef TERMINAL *(*set_curterm_fn)(TERMINAL *);
typedef void (*del_curterm_fn)(TERMINAL *);

typedef struct {
  setupterm_fn setupterm;
  tigetnum_fn tigetnum;
  set_curterm_fn set_curterm;
  del_curterm_fn del_curterm;
  TERMINAL **cur_term;
} Api;

static int bind(Api *api, void *handle) {
  api->setupterm = (setupterm_fn)dlsym(handle, "setupterm");
  api->tigetnum = (tigetnum_fn)dlsym(handle, "tigetnum");
  api->set_curterm = (set_curterm_fn)dlsym(handle, "set_curterm");
  api->del_curterm = (del_curterm_fn)dlsym(handle, "del_curterm");
  api->cur_term = (TERMINAL **)dlsym(handle, "cur_term");
  return api->setupterm && api->tigetnum && api->set_curterm &&
      api->del_curterm && api->cur_term;
}

/* Success packs: bit 32=base unchanged, bit 16=private restored, bits 0..15=colors. */
int64_t cangjie_dlmopen_probe(void) {
#ifndef LM_ID_NEWLM
  return -20;
#else
  void *base_handle = dlopen("libtinfo.so.6", RTLD_NOW | RTLD_LOCAL);
  if (!base_handle) return -10;
  Api base, priv;
  if (!bind(&base, base_handle)) { dlclose(base_handle); return -11; }
  int err = 999;
  if (base.setupterm("dumb", 1, &err) != 0) { dlclose(base_handle); return -12; }
  TERMINAL *base_saved = *base.cur_term;
  int base_colors = base.tigetnum("colors");
  void *private_handle = dlmopen(LM_ID_NEWLM, "libtinfo.so.6", RTLD_NOW | RTLD_LOCAL);
  if (!private_handle) { base.set_curterm(NULL); base.del_curterm(base_saved); dlclose(base_handle); return -13; }
  if (!bind(&priv, private_handle)) { dlclose(private_handle); base.set_curterm(NULL); base.del_curterm(base_saved); dlclose(base_handle); return -14; }
  err = 999;
  if (priv.setupterm("xterm-256color", 1, &err) != 0) { dlclose(private_handle); base.set_curterm(NULL); base.del_curterm(base_saved); dlclose(base_handle); return -15; }
  TERMINAL *private_created = *priv.cur_term;
  int colors = priv.tigetnum("colors");
  priv.set_curterm(NULL);
  priv.del_curterm(private_created);
  int private_restored = *priv.cur_term == NULL;
  int base_unchanged = *base.cur_term == base_saved && base.tigetnum("colors") == base_colors;
  base.set_curterm(NULL);
  base.del_curterm(base_saved);
  dlclose(private_handle);
  dlclose(base_handle);
  return ((int64_t)base_unchanged << 32) | ((int64_t)private_restored << 16) |
      (uint16_t)colors;
#endif
}
