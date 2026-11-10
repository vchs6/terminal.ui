/* Linked only, not executed. Signature/header/linkage check. */
#include "monotonic_abi.h"
static int64_t (*const abi_signature)(void) = &cjt_monotonic_ms;
int main(void) { return abi_signature() < 0; }
