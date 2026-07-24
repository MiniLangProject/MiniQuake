#include "wad_oracle_stubs.h"

static byte *fixture_data;
static int sys_error_calls;

void wad_set_fixture_data(byte *data)
{
    fixture_data = data;
}

byte *COM_LoadHunkFile(char *filename)
{
    (void)filename;
    return fixture_data;
}

void Sys_Error(char *error, ...)
{
    (void)error;
    sys_error_calls++;
}

void wad_reset_sys_error(void)
{
    sys_error_calls = 0;
}

int wad_sys_error_calls(void)
{
    return sys_error_calls;
}

int mq_strcmp(const char *first, const char *second)
{
    while (*first && *first == *second)
    {
        first++;
        second++;
    }
    return (unsigned char)*first - (unsigned char)*second;
}
