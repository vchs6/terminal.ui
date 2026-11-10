#include <dlfcn.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

typedef void Display;
typedef unsigned long Window;
typedef unsigned long KeySym;
typedef unsigned long Time;
typedef unsigned int KeyCode;

static void *load_symbol(void *library, const char *name) {
    void *symbol = dlsym(library, name);
    if (symbol == NULL) {
        fprintf(stderr, "missing symbol %s: %s\n", name, dlerror());
        exit(2);
    }
    return symbol;
}

static unsigned long parse_number(const char *value, const char *label) {
    char *end = NULL;
    unsigned long result;
    errno = 0;
    result = strtoul(value, &end, 0);
    if (errno != 0 || end == value || *end != '\0') {
        fprintf(stderr, "invalid %s: %s\n", label, value);
        exit(2);
    }
    return result;
}

int main(int argc, char **argv) {
    void *x11;
    void *xtst;
    Display *(*x_open_display)(const char *) = NULL;
    int (*x_close_display)(Display *) = NULL;
    int (*x_set_input_focus)(Display *, Window, int, Time) = NULL;
    int (*x_resize_window)(Display *, Window, unsigned int, unsigned int) = NULL;
    int (*x_sync)(Display *, int) = NULL;
    KeySym (*x_string_to_keysym)(const char *) = NULL;
    KeyCode (*x_keysym_to_keycode)(Display *, KeySym) = NULL;
    int (*xtest_query_extension)(Display *, int *, int *, int *, int *) = NULL;
    int (*xtest_fake_key_event)(Display *, unsigned int, int, unsigned long) = NULL;
    Display *display;
    Window window;
    KeyCode keycode;
    KeyCode return_keycode;
    int event_base;
    int error_base;
    int major;
    int minor;
    unsigned int width;
    unsigned int height;

    if (argc != 5) {
        fprintf(stderr, "usage: %s WINDOW KEY WIDTH HEIGHT\n", argv[0]);
        return 2;
    }
    window = parse_number(argv[1], "window");
    width = (unsigned int)parse_number(argv[3], "width");
    height = (unsigned int)parse_number(argv[4], "height");
    if ((width == 0) != (height == 0)) {
        fprintf(stderr, "WIDTH and HEIGHT must both be zero or both be positive\n");
        return 2;
    }
    x11 = dlopen("libX11.so.6", RTLD_NOW | RTLD_GLOBAL);
    xtst = dlopen("libXtst.so.6", RTLD_NOW | RTLD_GLOBAL);
    if (x11 == NULL || xtst == NULL) {
        fprintf(stderr, "X11 or XTEST runtime library unavailable\n");
        return 2;
    }
    x_open_display = load_symbol(x11, "XOpenDisplay");
    x_close_display = load_symbol(x11, "XCloseDisplay");
    x_set_input_focus = load_symbol(x11, "XSetInputFocus");
    x_resize_window = load_symbol(x11, "XResizeWindow");
    x_sync = load_symbol(x11, "XSync");
    x_string_to_keysym = load_symbol(x11, "XStringToKeysym");
    x_keysym_to_keycode = load_symbol(x11, "XKeysymToKeycode");
    xtest_query_extension = load_symbol(xtst, "XTestQueryExtension");
    xtest_fake_key_event = load_symbol(xtst, "XTestFakeKeyEvent");
    display = x_open_display(NULL);
    if (display == NULL) {
        fprintf(stderr, "cannot open DISPLAY\n");
        return 2;
    }
    if (!xtest_query_extension(display, &event_base, &error_base, &major, &minor)) {
        fprintf(stderr, "XTEST extension unavailable\n");
        return 3;
    }
    keycode = x_keysym_to_keycode(display, x_string_to_keysym(argv[2]));
    return_keycode = x_keysym_to_keycode(display, x_string_to_keysym("Return"));
    if (keycode == 0 || return_keycode == 0) {
        fprintf(stderr, "could not map injected key or Return\n");
        return 3;
    }
    x_set_input_focus(display, window, 1, 0);
    x_sync(display, 0);
    if (!xtest_fake_key_event(display, keycode, 1, 0) ||
        !xtest_fake_key_event(display, keycode, 0, 0) ||
        !xtest_fake_key_event(display, return_keycode, 1, 0) ||
        !xtest_fake_key_event(display, return_keycode, 0, 0)) {
        fprintf(stderr, "XTEST key injection rejected\n");
        return 3;
    }
    if (width != 0) {
        x_resize_window(display, window, width, height);
    }
    x_sync(display, 0);
    printf("xtest_extension=%d.%d window=0x%lx injected=%s+Return resize=%s\n",
           major, minor, window, argv[2], width == 0 ? "unchanged" : argv[3]);
    x_close_display(display);
    return 0;
}
