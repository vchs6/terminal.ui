#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

typedef void *Pointer;
typedef unsigned int Unsigned;
typedef long Long;

typedef struct {
    unsigned short red;
    unsigned short green;
    unsigned short blue;
} PangoColor;

typedef struct {
    Long row;
    Long column;
    PangoColor fore;
    PangoColor back;
    unsigned int underline : 1;
    unsigned int strikethrough : 1;
    unsigned int columns : 4;
} VteCharAttributes;

typedef struct {
    char *data;
    Unsigned len;
    Unsigned allocated_len;
} GArrayPrefix;

static Pointer load_symbol(Pointer library, const char *name) {
    Pointer symbol = dlsym(library, name);
    if (!symbol) {
        fprintf(stderr, "missing symbol %s: %s\n", name, dlerror());
        exit(2);
    }
    return symbol;
}

int main(int argc, char **argv) {
    Pointer gtk = dlopen("libgtk-3.so.0", RTLD_NOW | RTLD_GLOBAL);
    Pointer vte = dlopen("libvte-2.91.so.0", RTLD_NOW | RTLD_GLOBAL);
    Pointer glib = dlopen("libglib-2.0.so.0", RTLD_NOW | RTLD_GLOBAL);
    void (*gtk_init)(int *, char ***) = NULL;
    Pointer (*gtk_window_new)(int) = NULL;
    void (*gtk_window_set_title)(Pointer, const char *) = NULL;
    void (*gtk_window_set_default_size)(Pointer, int, int) = NULL;
    void (*gtk_container_add)(Pointer, Pointer) = NULL;
    void (*gtk_widget_set_size_request)(Pointer, int, int) = NULL;
    void (*gtk_widget_show_all)(Pointer) = NULL;
    void (*gtk_main)(void) = NULL;
    void (*gtk_main_quit)(void) = NULL;
    Pointer (*vte_terminal_new)(void) = NULL;
    void (*vte_terminal_set_size)(Pointer, Long, Long) = NULL;
    int (*vte_terminal_spawn_sync)(Pointer, int, const char *, char **, char **,
                                   int, Pointer, Pointer, int *, Pointer, Pointer) = NULL;
    char *(*vte_terminal_get_text)(Pointer, Pointer, Pointer, Pointer) = NULL;
    void (*g_free)(Pointer) = NULL;
    Unsigned (*g_timeout_add)(Unsigned, int (*)(Pointer), Pointer) = NULL;
    Pointer window;
    Pointer terminal;
    int child_pid = 0;
    int callback(Pointer data) {
        (void)data;
        char *text = vte_terminal_get_text(terminal, NULL, NULL, NULL);
        FILE *out = fopen("/workspace/work/cross-terminal-recon/raw/vte-testhost-grid.txt", "w");
        if (!out || !text) {
            fprintf(stderr, "could not write VTE grid capture\n");
            gtk_main_quit();
            return 0;
        }
        fputs("text_begin\n", out);
        fputs(text, out);
        fputs("text_end\nattributes_api=unavailable: VTE 0.80 asserts attributes == nullptr for vte_terminal_get_text\n", out);
        fclose(out);
        g_free(text);
        gtk_main_quit();
        return 0;
    }

    if (!gtk || !vte || !glib) {
        fprintf(stderr, "required GTK/VTE/GLib runtime library unavailable\n");
        return 2;
    }
    gtk_init = load_symbol(gtk, "gtk_init");
    gtk_window_new = load_symbol(gtk, "gtk_window_new");
    gtk_window_set_title = load_symbol(gtk, "gtk_window_set_title");
    gtk_window_set_default_size = load_symbol(gtk, "gtk_window_set_default_size");
    gtk_container_add = load_symbol(gtk, "gtk_container_add");
    gtk_widget_set_size_request = load_symbol(gtk, "gtk_widget_set_size_request");
    gtk_widget_show_all = load_symbol(gtk, "gtk_widget_show_all");
    gtk_main = load_symbol(gtk, "gtk_main");
    gtk_main_quit = load_symbol(gtk, "gtk_main_quit");
    vte_terminal_new = load_symbol(vte, "vte_terminal_new");
    vte_terminal_set_size = load_symbol(vte, "vte_terminal_set_size");
    vte_terminal_spawn_sync = load_symbol(vte, "vte_terminal_spawn_sync");
    vte_terminal_get_text = load_symbol(vte, "vte_terminal_get_text");
    g_free = load_symbol(glib, "g_free");
    g_timeout_add = load_symbol(glib, "g_timeout_add");

    gtk_init(&argc, &argv);
    window = gtk_window_new(0);
    terminal = vte_terminal_new();
    gtk_window_set_title(window, "TASK065 explicit VTE testhost");
    gtk_window_set_default_size(window, 1017, 561);
    vte_terminal_set_size(terminal, 100, 28);
    gtk_widget_set_size_request(terminal, 1000, 532);
    gtk_container_add(window, terminal);
    gtk_widget_show_all(window);
    {
        char *child_argv[] = {"/bin/sh", "/workspace/work/cross-terminal-recon/probes/scene-vte-testhost.sh", NULL};
        char *child_env[] = {"TERM=xterm-256color", "COLORTERM=truecolor", NULL};
        if (!vte_terminal_spawn_sync(terminal, 0, NULL, child_argv, child_env,
                                     0, NULL, NULL, &child_pid, NULL, NULL)) {
            fprintf(stderr, "VTE child spawn failed\n");
            return 3;
        }
    }
    g_timeout_add(3500, callback, NULL);
    gtk_main();
    return 0;
}
