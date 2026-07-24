#include "console_oracle_stubs.h"

__declspec(dllimport) void *__cdecl memset(void *, int, unsigned __int64);
__declspec(dllimport) void *__cdecl memcpy(
    void *, const void *, unsigned __int64);

extern int con_linewidth;
extern int con_totallines;
extern int con_backscroll;
extern int con_current;
extern int con_x;
extern char *con_text;
extern float con_times[4];
extern int con_vislines;
extern qboolean con_debuglog;
extern qboolean con_initialized;
extern int con_notifylines;
extern qboolean con_forcedup;

int _fltused = 0;
client_static_t cls;
viddef_t vid;
keydest_t key_dest;
qboolean team_message;
int scr_disabled_for_loading;
int clearnotify;
int scr_copytop;
double realtime;
cvar_t developer = {"developer", "0", 0, 0, 0.0f, NULL};
char com_gamedir[1024] = "fixture";
int key_count;
char chat_buffer[32];
char key_lines[32][256];
int edit_line;
int key_linepos;

static byte hunk_storage[32768];
static int registered_commands;
static int registered_cvars;
static int menu_calls;
static int plaque_calls;
static int screen_updates;
static int sound_calls;
static int draw_count;
static int draw_values[512];
static int draw_background;
static char debug_data[4096];
static int debug_length;
static double system_time;

void __chkstk(void)
{
}

unsigned __int64 oracle_strlen(const char *text)
{
    unsigned __int64 count = 0;
    while (text[count])
        count++;
    return count;
}

static void copy_string(char *destination, const char *source)
{
    while ((*destination++ = *source++) != 0)
    {
    }
}

int oracle_vsprintf(char *destination, char *format, va_list arguments)
{
    int written = 0;
    while (*format)
    {
        if (format[0] == '%' && format[1] == 's')
        {
            char *text = va_arg(arguments, char *);
            while (*text)
                destination[written++] = *text++;
            format += 2;
            continue;
        }
        if (format[0] == '%' && format[1] == '%')
        {
            destination[written++] = '%';
            format += 2;
            continue;
        }
        destination[written++] = *format++;
    }
    destination[written] = 0;
    return written;
}

void M_Menu_Main_f(void)
{
    menu_calls++;
}

void SCR_EndLoadingPlaque(void)
{
    plaque_calls++;
}

void *Q_memset(void *destination, int value, int count)
{
    return memset(destination, value, (unsigned __int64)count);
}

void *Q_memcpy(void *destination, const void *source, int count)
{
    return memcpy(destination, source, (unsigned __int64)count);
}

int COM_CheckParm(char *parameter)
{
    (void)parameter;
    return 0;
}

void *Hunk_AllocName(int size, char *name)
{
    (void)name;
    if (size > (int)sizeof(hunk_storage))
        return NULL;
    return hunk_storage;
}

void Cvar_RegisterVariable(cvar_t *variable)
{
    variable->value = 3.0f;
    registered_cvars++;
}

void Cmd_AddCommand(char *name, xcommand_t function)
{
    (void)name;
    (void)function;
    registered_commands++;
}

void S_LocalSound(char *name)
{
    (void)name;
    sound_calls++;
}

void Sys_Printf(char *format, ...)
{
    (void)format;
}

void SCR_UpdateScreen(void)
{
    screen_updates++;
}

char *va(char *format, ...)
{
    (void)format;
    return "fixture/qconsole.log";
}

void Draw_Character(int x, int y, int character)
{
    (void)x;
    (void)y;
    if (draw_count < (int)(sizeof(draw_values) / sizeof(draw_values[0])))
        draw_values[draw_count] = character;
    draw_count++;
}

void Draw_String(int x, int y, char *text)
{
    (void)x;
    (void)y;
    while (*text)
    {
        Draw_Character(0, 0, *text);
        text++;
    }
}

void Draw_ConsoleBackground(int lines)
{
    draw_background = lines;
}

double Sys_FloatTime(void)
{
    system_time += 0.01;
    return system_time;
}

void Sys_SendKeyEvents(void)
{
    key_count++;
}

int unlink(char *path)
{
    (void)path;
    return 0;
}

int open(char *path, int flags, int mode)
{
    (void)path;
    (void)flags;
    (void)mode;
    return 1;
}

int write(int file, char *data, int count)
{
    int index;
    (void)file;
    for (index = 0; index < count && debug_length + 1 < 4096; index++)
        debug_data[debug_length++] = data[index];
    debug_data[debug_length] = 0;
    return count;
}

int close(int file)
{
    (void)file;
    return 0;
}

static int row_text(int logical_line, char *output)
{
    int row = logical_line % con_totallines;
    int count = con_linewidth;
    int index;
    while (count > 0 &&
           (con_text[row * con_linewidth + count - 1] & 127) == ' ')
        count--;
    for (index = 0; index < count; index++)
        output[index] = con_text[row * con_linewidth + index] & 127;
    output[count] = 0;
    return count;
}

static int all_spaces(void)
{
    int index;
    for (index = 0; index < 16384; index++)
        if (con_text[index] != ' ')
            return 0;
    return 1;
}

static int notify_zero(void)
{
    int index;
    for (index = 0; index < 4; index++)
        if (con_times[index] != 0.0f)
            return 0;
    return 1;
}

static void reset_draw(void)
{
    draw_count = 0;
    draw_background = 0;
    memset(draw_values, 0, sizeof(draw_values));
}

__declspec(dllexport) int __cdecl console_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    char previous[128];
    char current[128];
    int menu_before;
    int team_value;
    int cursor_value;
    int rows;
    (void)capacity;

    memset(hunk_storage, 0, sizeof(hunk_storage));
    memset(key_lines, 0, sizeof(key_lines));
    key_lines[0][0] = ']';
    key_linepos = 1;
    edit_line = 0;
    vid.width = 320;
    vid.height = 480;
    cls.state = ca_connected;
    cls.signon = 0;
    registered_commands = 0;
    registered_cvars = 0;
    Con_Init();
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_Init\",\"case\":\"startup\","
        "\"width\":%d,\"total\":%d,\"current\":%d,\"commands\":%d,"
        "\"cvars\":%d,\"initialized\":%d}\n",
        con_linewidth, con_totallines, con_current, registered_commands,
        registered_cvars, con_initialized);

    key_dest = key_console;
    key_lines[0][1] = 'a';
    key_lines[0][2] = 0;
    key_linepos = 2;
    con_times[0] = 1.0f;
    plaque_calls = 0;
    menu_before = menu_calls;
    Con_ToggleConsole_f();
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_ToggleConsole_f\",\"case\":\"connected\","
        "\"game\":%d,\"line_empty\":%d,\"linepos\":%d,\"plaque\":%d,"
        "\"menu\":%d,\"notify_zero\":%d}\n",
        key_dest == key_game, key_lines[0][1] == 0, key_linepos,
        plaque_calls, menu_calls - menu_before, notify_zero());

    con_text[0] = 'X';
    Con_Clear_f();
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_Clear_f\",\"case\":\"buffer\","
        "\"spaces\":%d}\n",
        all_spaces());

    con_times[0] = 1.0f;
    con_times[3] = 2.0f;
    Con_ClearNotify();
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_ClearNotify\",\"case\":\"times\","
        "\"zero\":%d}\n",
        notify_zero());

    team_message = true;
    Con_MessageMode_f();
    team_value = team_message;
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_MessageMode_f\",\"case\":\"public\","
        "\"team\":%d}\n",
        team_value);
    Con_MessageMode2_f();
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_MessageMode2_f\",\"case\":\"team\","
        "\"team\":%d}\n",
        team_message);

    vid.width = 640;
    con_backscroll = 5;
    Con_CheckResize();
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_CheckResize\",\"case\":\"wider\","
        "\"width\":%d,\"total\":%d,\"current\":%d,\"back\":%d,"
        "\"notify_zero\":%d}\n",
        con_linewidth, con_totallines, con_current, con_backscroll,
        notify_zero());

    con_x = 5;
    Con_Linefeed();
    row_text(con_current, current);
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_Linefeed\",\"case\":\"blank\","
        "\"current\":%d,\"x\":%d,\"empty\":%d}\n",
        con_current, con_x, current[0] == 0);

    Con_Clear_f();
    con_current = con_totallines - 1;
    con_x = 0;
    realtime = 2.0;
    Con_Print("hello\nnext");
    row_text(con_current - 1, previous);
    row_text(con_current, current);
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_Print\",\"case\":\"lines\","
        "\"previous\":\"%s\",\"current\":\"%s\",\"x\":%d,"
        "\"time\":%.9g}\n",
        previous, current, con_x, con_times[con_current % 4]);

    debug_length = 0;
    debug_data[0] = 0;
    Con_DebugLog("fixture.log", "%s", "debug");
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_DebugLog\",\"case\":\"append\","
        "\"exact\":%d,\"length\":%d}\n",
        debug_length == 5 &&
            debug_data[0] == 'd' && debug_data[4] == 'g',
        debug_length);

    screen_updates = 0;
    Con_Printf("%s", "printf line\n");
    row_text(con_current, current);
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_Printf\",\"case\":\"visible\","
        "\"line\":\"%s\",\"updates\":%d}\n",
        current, screen_updates);

    developer.value = 1.0f;
    Con_DPrintf("%s", "developer line\n");
    row_text(con_current, current);
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_DPrintf\",\"case\":\"enabled\","
        "\"line\":\"%s\"}\n",
        current);

    screen_updates = 0;
    scr_disabled_for_loading = false;
    Con_SafePrintf("%s", "safe line\n");
    row_text(con_current, current);
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_SafePrintf\",\"case\":\"loading\","
        "\"line\":\"%s\",\"updates\":%d,\"disabled\":%d}\n",
        current, screen_updates, scr_disabled_for_loading);

    memset(key_lines[0], 0, sizeof(key_lines[0]));
    key_lines[0][0] = ']';
    key_lines[0][1] = 'a';
    key_lines[0][2] = 'b';
    key_lines[0][3] = 'c';
    key_linepos = 4;
    key_dest = key_console;
    con_vislines = 200;
    realtime = 0.25;
    reset_draw();
    Con_DrawInput();
    cursor_value = draw_values[4];
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_DrawInput\",\"case\":\"cursor\","
        "\"prefix\":[%d,%d,%d,%d],\"cursor\":%d,\"semantic_length\":5}\n",
        draw_values[0], draw_values[1], draw_values[2], draw_values[3],
        cursor_value);

    Con_Clear_f();
    Con_ClearNotify();
    con_current = con_totallines - 1;
    con_x = 0;
    realtime = 5.0;
    Con_Print("notify");
    realtime = 6.0;
    key_dest = key_game;
    reset_draw();
    con_notifylines = 0;
    Con_DrawNotify();
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_DrawNotify\",\"case\":\"fresh\","
        "\"rows\":%d,\"pixels\":%d,\"first\":%d}\n",
        draw_count / con_linewidth, con_notifylines, draw_values[0] & 127);

    reset_draw();
    Con_DrawConsole(64, false);
    rows = (64 - 16) >> 3;
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_DrawConsole\",\"case\":\"rows\","
        "\"background\":%d,\"rows\":%d,\"visible\":%d}\n",
        draw_background, rows, con_vislines);

    system_time = 0.0;
    Con_NotifyBox("notice\n");
    cursor += sprintf(
        cursor,
        "{\"function\":\"Con_NotifyBox\",\"case\":\"notice\","
        "\"result\":1,\"stored\":1,\"destination\":%d,\"realtime\":%.9g}\n",
        key_dest, realtime);

    *cursor = 0;
    return (int)(cursor - output);
}
