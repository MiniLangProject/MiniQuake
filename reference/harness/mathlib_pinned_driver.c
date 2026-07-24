#include "mathlib_oracle_stubs.h"

int _fltused = 0;
static int sys_error_calls;

void Sys_Error(char *error, ...)
{
    (void)error;
    sys_error_calls++;
}

void mathlib_reset_sys_error(void)
{
    sys_error_calls = 0;
}

int mathlib_sys_error_calls(void)
{
    return sys_error_calls;
}
