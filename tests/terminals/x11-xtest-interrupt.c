#include <dlfcn.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
typedef void Display; typedef unsigned long Window, KeySym, Time; typedef unsigned int KeyCode;
static void *sym(void *h, const char *n) { void *p = dlsym(h, n); if (!p) { fprintf(stderr, "missing %s\n", n); exit(2); } return p; }
static Window id(const char *s) { char *e; errno = 0; Window v = strtoul(s, &e, 0); if (errno || e == s || *e) exit(2); return v; }
int main(int n, char **v) {
  if (n != 2) return 2;
  void *x = dlopen("libX11.so.6", RTLD_NOW | RTLD_GLOBAL), *t = dlopen("libXtst.so.6", RTLD_NOW | RTLD_GLOBAL);
  if (!x || !t) return 2;
  Display *(*open)(const char *) = sym(x, "XOpenDisplay");
  int (*close)(Display *) = sym(x, "XCloseDisplay"), (*focus)(Display *, Window, int, Time) = sym(x, "XSetInputFocus"), (*sync)(Display *, int) = sym(x, "XSync"), (*query)(Display *, int *, int *, int *, int *) = sym(t, "XTestQueryExtension"), (*fake)(Display *, unsigned int, int, unsigned long) = sym(t, "XTestFakeKeyEvent");
  KeySym (*keysym)(const char *) = sym(x, "XStringToKeysym"); KeyCode (*keycode)(Display *, KeySym) = sym(x, "XKeysymToKeycode");
  Display *d = open(0); int event, error, major, minor;
  if (!d || !query(d, &event, &error, &major, &minor)) return 3;
  KeyCode ctrl = keycode(d, keysym("Control_L")), key = keycode(d, keysym("c"));
  if (!ctrl || !key) return 3;
  focus(d, id(v[1]), 1, 0); sync(d, 0);
  if (!fake(d, ctrl, 1, 0) || !fake(d, key, 1, 0) || !fake(d, key, 0, 0) || !fake(d, ctrl, 0, 0)) return 3;
  sync(d, 0); printf("xtest_extension=%d.%d injected=Ctrl+c\n", major, minor); return close(d);
}
