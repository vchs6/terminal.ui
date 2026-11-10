#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
int64_t __wrap_cjt_monotonic_ms(void);
int main(int argc, char **argv) {
    int count = argc > 1 ? atoi(argv[1]) : 1;
    for (int i=0;i<count;++i) printf("%lld\n",(long long)__wrap_cjt_monotonic_ms());
    return 0;
}
