/* Independent compile-only feasibility witness, never product implementation. */
#define _POSIX_C_SOURCE 200809L
#include <stdint.h>
#include <inttypes.h>
#include <time.h>
#include "monotonic_abi.h"
_Static_assert(sizeof(int64_t) == 8, "64-bit ABI");
_Static_assert(INT64_MAX / 1000 == INT64_C(9223372036854775), "whole second limit");
_Static_assert(INT64_MAX % 1000 == 807, "last valid millisecond remainder");
_Static_assert(INT64_MAX - 600 == INT64_C(9223372036854775207), "deadline addition guard");
int64_t cjt_monotonic_ms(void) {
    struct timespec value;
    if (clock_gettime(CLOCK_MONOTONIC, &value) != 0) return -1;
    if (value.tv_sec < 0 || value.tv_nsec < 0 || value.tv_nsec >= 1000000000L) return -1;
    const uintmax_t seconds = (uintmax_t)value.tv_sec;
    const uintmax_t millis = (uintmax_t)value.tv_nsec / 1000000U;
    if (seconds > ((uintmax_t)INT64_MAX - millis) / 1000U) return -1;
    return (int64_t)(seconds * 1000U + millis);
}
