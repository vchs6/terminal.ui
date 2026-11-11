/* Reuse the fixed glyph fixture engine. Only remove one returned mapping.
 * Real PTY, synthetic stdout VT metadata: never an actual-kernel claim. */
#define __wrap_ioctl glyph_fixture_ioctl
#include "../../../glyphs/session/native/glyph_syscall_wrap.c"
#undef __wrap_ioctl
int __wrap_ioctl(int fd, unsigned long request, ...) {
    va_list args;
    va_start(args, request);
    void *data = va_arg(args, void *);
    va_end(args);
    int result = glyph_fixture_ioctl(fd, request, data);
    if (result == 0 && request == GIO_UNIMAP && is_case("no-ellipsis")) {
        struct unimapdesc *map = data;
        unsigned int removed = 0;
        for (unsigned int i = 0; i < map->entry_ct; ++i) {
            if (map->entries[i].unicode == 0x2026) {
                map->entries[i].unicode = 'A';
                ++removed;
            }
        }
        trace("theme-filter ellipsis-removed=%u pairs=%u\n",removed,(unsigned)map->entry_ct);
    }
    return result;
}
