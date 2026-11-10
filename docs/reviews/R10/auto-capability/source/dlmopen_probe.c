/* Isolated glibc-only experiment: separate libtinfo namespaces and cur_term. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <link.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct term TERMINAL;
typedef int (*setupterm_fn)(const char *, int, int *);
typedef int (*tigetnum_fn)(const char *);
typedef TERMINAL *(*set_curterm_fn)(TERMINAL *);
typedef void (*del_curterm_fn)(TERMINAL *);

typedef struct {
  void *handle;
  setupterm_fn setupterm;
  tigetnum_fn tigetnum;
  set_curterm_fn set_curterm;
  del_curterm_fn del_curterm;
  TERMINAL **cur_term;
} Api;

static pthread_mutex_t private_mutex = PTHREAD_MUTEX_INITIALIZER;

static int bind_api(Api *api, void *handle) {
  *api = (Api){.handle = handle};
  api->setupterm = (setupterm_fn)dlsym(handle, "setupterm");
  api->tigetnum = (tigetnum_fn)dlsym(handle, "tigetnum");
  api->set_curterm = (set_curterm_fn)dlsym(handle, "set_curterm");
  api->del_curterm = (del_curterm_fn)dlsym(handle, "del_curterm");
  api->cur_term = (TERMINAL **)dlsym(handle, "cur_term");
  return api->setupterm && api->tigetnum && api->set_curterm &&
      api->del_curterm && api->cur_term;
}

/* Query then restore the namespace-local current terminal. */
static int query_restore(Api *api, const char *term, int *colors) {
  TERMINAL *saved = *api->cur_term;
  int errret = 999;
  if (api->setupterm(term, 1, &errret) != 0) return 1;
  TERMINAL *created = *api->cur_term;
  *colors = api->tigetnum("colors");
  api->set_curterm(saved);
  api->del_curterm(created);
  return *api->cur_term == saved ? 0 : 2;
}

typedef struct { Api *api; const char *term; int errors; int use_mutex; } Loop;

static void *loop_queries(void *arg) {
  Loop *loop = (Loop *)arg;
  for (int i = 0; i < 500; ++i) {
    int colors = 0, rc;
    if (loop->use_mutex) pthread_mutex_lock(&private_mutex);
    rc = query_restore(loop->api, loop->term, &colors);
    if (loop->use_mutex) pthread_mutex_unlock(&private_mutex);
    if (rc != 0) ++loop->errors;
  }
  return NULL;
}

int main(void) {
#ifndef LM_ID_NEWLM
  puts("dlmopen=UNAVAILABLE LM_ID_NEWLM missing");
  return 20;
#else
  Api base, priv;
  void *base_handle = dlopen("libtinfo.so.6", RTLD_NOW | RTLD_LOCAL);
  if (!base_handle) { printf("base.dlopen=FAIL %s\n", dlerror()); return 10; }
  if (!bind_api(&base, base_handle)) { puts("base.bind=FAIL"); return 11; }

  int base_errret = 999;
  if (base.setupterm("dumb", 1, &base_errret) != 0) {
    printf("base.setup=FAIL errret=%d\n", base_errret); return 12;
  }
  TERMINAL *base_created = *base.cur_term;
  int base_before_colors = base.tigetnum("colors");

  void *private_handle = dlmopen(LM_ID_NEWLM, "libtinfo.so.6", RTLD_NOW | RTLD_LOCAL);
  if (!private_handle) { printf("dlmopen=FAIL %s\n", dlerror()); return 13; }
  if (!bind_api(&priv, private_handle)) { puts("private.bind=FAIL"); return 14; }
  struct link_map *base_map = NULL;
  struct link_map *private_map = NULL;
  int base_map_rc = dlinfo(base_handle, RTLD_DI_LINKMAP, &base_map);
  int private_map_rc = dlinfo(private_handle, RTLD_DI_LINKMAP, &private_map);
  if (base_map_rc != 0 || private_map_rc != 0) {
    printf("linkmap=FAIL base_rc=%d private_rc=%d\n", base_map_rc, private_map_rc);
    return 15;
  }
  printf("linkmap.base.addr=%#lx private.addr=%#lx distinct=%s base.name=%s private.name=%s\n",
      (unsigned long)base_map->l_addr, (unsigned long)private_map->l_addr,
      base_map->l_addr != private_map->l_addr ? "yes" : "no",
      base_map->l_name, private_map->l_name);
  printf("handles.base=%p private=%p cur_term.address.base=%p private=%p distinct=%s\n",
      base.handle, priv.handle, (void *)base.cur_term, (void *)priv.cur_term,
      base.cur_term != priv.cur_term ? "yes" : "no");
  printf("initial.base.current=%p private.current=%p base.colors=%d\n",
      (void *)*base.cur_term, (void *)*priv.cur_term, base_before_colors);

  int private_colors = 0;
  int query_rc = query_restore(&priv, "xterm-256color", &private_colors);
  int base_after_colors = base.tigetnum("colors");
  printf("private.query.rc=%d private.colors=%d private.current=%p\n",
      query_rc, private_colors, (void *)*priv.cur_term);
  printf("base.after_private.current=%p unchanged=%s colors=%d unchanged_colors=%s\n",
      (void *)*base.cur_term, *base.cur_term == base_created ? "yes" : "no",
      base_after_colors, base_after_colors == base_before_colors ? "yes" : "no");

  Loop private_reuse = {.api = &priv, .term = "xterm-256color", .errors = 0, .use_mutex = 1};
  loop_queries(&private_reuse);
  printf("private.reuse.iterations=500 mutex=yes errors=%d current=%p\n",
      private_reuse.errors, (void *)*priv.cur_term);

  Loop base_loop = {.api = &base, .term = "linux", .errors = 0, .use_mutex = 0};
  Loop private_loop = {.api = &priv, .term = "xterm-256color", .errors = 0, .use_mutex = 1};
  pthread_t base_thread, private_thread;
  int create_a = pthread_create(&base_thread, NULL, loop_queries, &base_loop);
  int create_b = pthread_create(&private_thread, NULL, loop_queries, &private_loop);
  if (create_a == 0) pthread_join(base_thread, NULL);
  if (create_b == 0) pthread_join(private_thread, NULL);
  printf("parallel.base_create=%d private_create=%d base_errors=%d private_errors=%d base_current_unchanged=%s private_current=%p\n",
      create_a, create_b, base_loop.errors, private_loop.errors,
      *base.cur_term == base_created ? "yes" : "no", (void *)*priv.cur_term);

  base.set_curterm(NULL);
  base.del_curterm(base_created);
  dlclose(private_handle);
  dlclose(base_handle);
  return query_rc || private_reuse.errors || create_a || create_b ||
      base_loop.errors || private_loop.errors ? 16 : 0;
#endif
}
