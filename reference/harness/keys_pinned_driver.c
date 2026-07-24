#include "keys_oracle_stubs.h"

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
__declspec(dllimport) void *__cdecl memset(void *, int, unsigned __int64);

extern char key_lines[32][256];
extern int key_linepos;
extern int shift_down;
extern int key_lastpress;
extern int edit_line;
extern int history_line;
extern keydest_t key_dest;
extern int key_count;
extern char *keybindings[256];
extern qboolean consolekeys[256];
extern qboolean menubound[256];
extern int keyshift[256];
extern int key_repeats[256];
extern qboolean keydown[256];
extern char chat_buffer[32];

int _fltused = 0;
client_static_t cls;
viddef_t vid = {640, 480};
qboolean con_forcedup;
int con_backscroll;
int con_totallines = 100;

static char command_buffer[8192];
static int command_length;
static char file_buffer[8192];
static int file_length;
static byte zone_storage[65536];
static int zone_used;
static int command_argc;
static char *command_argv[4];
static int registered_commands;
static int menu_keys;
static int menu_toggles;

static int text_length(const char *text)
{
    int count = 0;
    while (text[count])
        count++;
    return count;
}

static void append_text(char *destination, int *length, const char *text)
{
    while (*text && *length + 1 < 8192)
        destination[(*length)++] = *text++;
    destination[*length] = 0;
}

static int text_equal(const char *left, const char *right)
{
    while (*left && *right && *left == *right)
    {
        left++;
        right++;
    }
    return *left == *right;
}

static void reset_command_buffer(void)
{
    command_length = 0;
    command_buffer[0] = 0;
}

void Cbuf_AddText(char *text)
{
    append_text(command_buffer, &command_length, text);
}

void Con_Printf(char *format, ...)
{
    (void)format;
}

char *Cmd_CompleteCommand(char *partial)
{
    (void)partial;
    return NULL;
}

char *Cvar_CompleteVariable(char *partial)
{
    (void)partial;
    return NULL;
}

char *Q_strcpy(char *destination, char *source)
{
    char *result = destination;
    while ((*destination++ = *source++) != 0)
    {
    }
    return result;
}

int Q_strlen(char *text)
{
    return text_length(text);
}

static int lower_ascii(int value)
{
    if (value >= 'A' && value <= 'Z')
        return value + ('a' - 'A');
    return value;
}

int Q_strcasecmp(char *left, char *right)
{
    while (*left || *right)
    {
        int a = lower_ascii((unsigned char)*left++);
        int b = lower_ascii((unsigned char)*right++);
        if (a != b)
            return a - b;
    }
    return 0;
}

void SCR_UpdateScreen(void)
{
}

void Z_Free(void *pointer)
{
    (void)pointer;
}

void *Z_Malloc(int size)
{
    void *result;
    int index;
    size = (size + 7) & ~7;
    result = &zone_storage[zone_used];
    for (index = 0; index < size; index++)
        zone_storage[zone_used + index] = 0;
    zone_used += size;
    return result;
}

int Cmd_Argc(void)
{
    return command_argc;
}

char *Cmd_Argv(int index)
{
    if (index < 0 || index >= command_argc)
        return "";
    return command_argv[index];
}

void Cmd_AddCommand(char *name, xcommand_t function)
{
    (void)name;
    (void)function;
    registered_commands++;
}

void M_Keydown(int key)
{
    (void)key;
    menu_keys++;
}

void M_ToggleMenu_f(void)
{
    menu_toggles++;
}

void Sys_Error(char *format, ...)
{
    (void)format;
}

char *keys_oracle_strcat(char *destination, const char *source)
{
    char *cursor = destination;
    while (*cursor)
        cursor++;
    while ((*cursor++ = *source++) != 0)
    {
    }
    return destination;
}

static void append_number(char *destination, int *position, int number)
{
    char digits[16];
    int count = 0;
    if (number == 0)
    {
        destination[(*position)++] = '0';
        return;
    }
    if (number < 0)
    {
        destination[(*position)++] = '-';
        number = -number;
    }
    while (number > 0)
    {
        digits[count++] = (char)('0' + number % 10);
        number /= 10;
    }
    while (count > 0)
        destination[(*position)++] = digits[--count];
}

int keys_oracle_sprintf(
    char *destination, const char *format, char *text, int number)
{
    int position = 0;
    if (format[0] == '-')
        destination[position++] = '-';
    while (*text)
        destination[position++] = *text++;
    destination[position++] = ' ';
    append_number(destination, &position, number);
    destination[position++] = '\n';
    destination[position] = 0;
    return position;
}

int keys_oracle_fprintf(
    FILE *file, const char *format, char *key, char *binding)
{
    int before = file_length;
    (void)file;
    (void)format;
    append_text(file_buffer, &file_length, "bind \"");
    append_text(file_buffer, &file_length, key);
    append_text(file_buffer, &file_length, "\" \"");
    append_text(file_buffer, &file_length, binding);
    append_text(file_buffer, &file_length, "\"\n");
    return file_length - before;
}

static void set_arguments(
    int count, char *first, char *second, char *third)
{
    command_argc = count;
    command_argv[0] = first;
    command_argv[1] = second;
    command_argv[2] = third;
}

static int active_bindings(void)
{
    int index;
    int count = 0;
    for (index = 0; index < 256; index++)
        if (keybindings[index] != NULL && keybindings[index][0] != 0)
            count++;
    return count;
}

__declspec(dllexport) int __cdecl keys_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    char *name;
    int init_registered;
    int init_console_a;
    int init_console_tick;
    int init_shift_a;
    int init_menu_f12;
    int down_seen;
    int release_seen;
    int write_exact;
    (void)capacity;

    memset(keybindings, 0, 256 * sizeof(keybindings[0]));
    zone_used = 0;
    registered_commands = 0;
    menu_keys = 0;
    menu_toggles = 0;
    cls.state = ca_disconnected;
    cls.demoplayback = false;
    con_forcedup = false;
    Key_Init();
    init_registered = registered_commands;
    init_console_a = consolekeys['a'];
    init_console_tick = consolekeys['`'];
    init_shift_a = keyshift['a'];
    init_menu_f12 = menubound[K_F12];
    cursor += sprintf(
        cursor,
        "{\"function\":\"Key_Init\",\"case\":\"tables\","
        "\"registered\":%d,\"console_a\":%d,\"console_tick\":%d,"
        "\"shift_a\":%d,\"menu_f12\":%d,\"linepos\":%d}\n",
        init_registered, init_console_a, init_console_tick,
        init_shift_a, init_menu_f12, key_linepos);

    reset_command_buffer();
    Key_Console('h');
    Key_Console('i');
    Key_Console(K_ENTER);
    cursor += sprintf(
        cursor,
        "{\"function\":\"Key_Console\",\"case\":\"submit\","
        "\"queued\":%d,\"line\":\"%s\",\"edit\":%d,\"linepos\":%d}\n",
        text_equal(command_buffer, "hi\n"), key_lines[0] + 1,
        edit_line, key_linepos);

    reset_command_buffer();
    key_dest = key_message;
    Key_Message('h');
    Key_Message('i');
    Key_Message(K_ENTER);
    cursor += sprintf(
        cursor,
        "{\"function\":\"Key_Message\",\"case\":\"say\","
        "\"queued\":%d,\"destination\":%d,\"empty\":%d}\n",
        text_equal(command_buffer, "say \"hi\"\n"), key_dest,
        chat_buffer[0] == 0);

    cursor += sprintf(
        cursor,
        "{\"function\":\"Key_StringToKeynum\",\"case\":\"names\","
        "\"ascii\":%d,\"arrow\":%d,\"unknown\":%d}\n",
        Key_StringToKeynum("a"), Key_StringToKeynum("UPARROW"),
        Key_StringToKeynum("not-a-key"));

    name = Key_KeynumToString(K_MOUSE2);
    cursor += sprintf(
        cursor,
        "{\"function\":\"Key_KeynumToString\",\"case\":\"names\","
        "\"mouse\":\"%s\",\"missing\":\"%s\",\"ascii\":\"%s\"}\n",
        name, Key_KeynumToString(-1), Key_KeynumToString('A'));

    Key_SetBinding('A', "+attack");
    cursor += sprintf(
        cursor,
        "{\"function\":\"Key_SetBinding\",\"case\":\"replace\","
        "\"binding\":\"%s\"}\n",
        keybindings['A']);

    set_arguments(2, "unbind", "A", "");
    Key_Unbind_f();
    cursor += sprintf(
        cursor,
        "{\"function\":\"Key_Unbind_f\",\"case\":\"bound\","
        "\"empty\":%d}\n",
        keybindings['A'] != NULL && keybindings['A'][0] == 0);

    Key_SetBinding('A', "+attack");
    Key_SetBinding('B', "+use");
    Key_Unbindall_f();
    cursor += sprintf(
        cursor,
        "{\"function\":\"Key_Unbindall_f\",\"case\":\"all\","
        "\"active\":%d}\n",
        active_bindings());

    set_arguments(3, "bind", "MOUSE1", "+attack");
    Key_Bind_f();
    cursor += sprintf(
        cursor,
        "{\"function\":\"Key_Bind_f\",\"case\":\"set\","
        "\"binding\":\"%s\"}\n",
        keybindings[K_MOUSE1]);

    file_length = 0;
    file_buffer[0] = 0;
    Key_WriteBindings((FILE *)1);
    write_exact = text_equal(
        file_buffer, "bind \"MOUSE1\" \"+attack\"\n");
    cursor += sprintf(
        cursor,
        "{\"function\":\"Key_WriteBindings\",\"case\":\"one\","
        "\"exact\":%d,\"length\":%d}\n",
        write_exact, file_length);

    Key_SetBinding('a', "+attack");
    reset_command_buffer();
    key_dest = key_game;
    Key_Event('a', true);
    Key_Event('a', true);
    Key_Event('a', false);
    down_seen = command_length >= 11;
    release_seen = text_equal(
        command_buffer, "+attack 97\n-attack 97\n");
    cursor += sprintf(
        cursor,
        "{\"function\":\"Key_Event\",\"case\":\"button-repeat\","
        "\"down\":%d,\"release\":%d,\"repeat\":%d,\"keydown\":%d,"
        "\"last\":%d}\n",
        down_seen, release_seen, key_repeats['a'], keydown['a'],
        key_lastpress);

    Key_Event(K_SHIFT, true);
    Key_Event('a', true);
    Key_ClearStates();
    cursor += sprintf(
        cursor,
        "{\"function\":\"Key_ClearStates\",\"case\":\"held\","
        "\"shift\":%d,\"repeat\":%d,\"keydown\":%d}\n",
        shift_down, key_repeats['a'], keydown['a']);

    *cursor = 0;
    return (int)(cursor - output);
}
