#include "cvar_oracle_stubs.h"

extern cvar_t *cvar_vars;

int _fltused = 0;
server_t sv;
static char arena[4096];
static int arena_position;
static int broadcast_calls;
static int console_calls;
static int command_argc;
static char *command_argv[2];
static char archive_text[512];
static int archive_length;
static FILE archive_file;

static cvar_t foo;
static cvar_t bar;
static cvar_t alpha;

int Q_strcmp(const char *first, const char *second)
{
    while (*first && *first == *second)
    {
        first++;
        second++;
    }
    return (unsigned char)*first - (unsigned char)*second;
}

int Q_strncmp(const char *first, const char *second, int count)
{
    while (count > 0)
    {
        int difference = (unsigned char)*first - (unsigned char)*second;
        if (difference || !*first)
            return difference;
        first++;
        second++;
        count--;
    }
    return 0;
}

int Q_strlen(const char *text)
{
    int length = 0;
    while (text[length])
        length++;
    return length;
}

void Q_strcpy(char *destination, const char *source)
{
    while ((*destination++ = *source++) != 0)
    {
    }
}

float Q_atof(const char *text)
{
    float value = 0.0f;
    float scale = 0.1f;
    int negative = 0;
    if (*text == '-')
    {
        negative = 1;
        text++;
    }
    while (*text >= '0' && *text <= '9')
    {
        value = value * 10.0f + (float)(*text - '0');
        text++;
    }
    if (*text == '.')
    {
        text++;
        while (*text >= '0' && *text <= '9')
        {
            value += (float)(*text - '0') * scale;
            scale *= 0.1f;
            text++;
        }
    }
    return negative ? -value : value;
}

void *Z_Malloc(int size)
{
    void *result = arena + arena_position;
    arena_position += (size + 7) & ~7;
    return result;
}

void Z_Free(void *memory)
{
    (void)memory;
}

qboolean Cmd_Exists(char *name)
{
    (void)name;
    return false;
}

int Cmd_Argc(void)
{
    return command_argc;
}

char *Cmd_Argv(int index)
{
    return index >= 0 && index < command_argc ? command_argv[index] : "";
}

void Con_Printf(char *format, ...)
{
    (void)format;
    console_calls++;
}

void SV_BroadcastPrintf(char *format, ...)
{
    (void)format;
    broadcast_calls++;
}

int mq_fprintf(FILE *file, const char *format, char *name, char *value)
{
    int index;
    (void)file;
    (void)format;
    for (index = 0; name[index]; index++)
        archive_text[archive_length++] = name[index];
    archive_text[archive_length++] = ' ';
    archive_text[archive_length++] = '"';
    for (index = 0; value[index]; index++)
        archive_text[archive_length++] = value[index];
    archive_text[archive_length++] = '"';
    archive_text[archive_length++] = '\n';
    archive_text[archive_length] = 0;
    return archive_length;
}

void cvar_fixture_register(void)
{
    cvar_vars = NULL;
    arena_position = 0;
    broadcast_calls = 0;
    console_calls = 0;
    sv.active = true;
    foo.name = "foo";
    foo.string = "1.25";
    foo.archive = true;
    foo.server = false;
    foo.value = 0.0f;
    foo.next = NULL;
    bar.name = "bar";
    bar.string = "7";
    bar.archive = false;
    bar.server = true;
    bar.value = 0.0f;
    bar.next = NULL;
    alpha.name = "alpha";
    alpha.string = "4";
    alpha.archive = false;
    alpha.server = false;
    alpha.value = 0.0f;
    alpha.next = NULL;
    Cvar_RegisterVariable(&foo);
    Cvar_RegisterVariable(&bar);
    Cvar_RegisterVariable(&alpha);
}

void cvar_set_command(int argc, char *first, char *second)
{
    command_argc = argc;
    command_argv[0] = first;
    command_argv[1] = second;
}

int cvar_broadcast_calls(void)
{
    return broadcast_calls;
}

int cvar_console_calls(void)
{
    return console_calls;
}

char *cvar_archive(void)
{
    archive_length = 0;
    archive_text[0] = 0;
    Cvar_WriteVariables(&archive_file);
    return archive_text;
}
