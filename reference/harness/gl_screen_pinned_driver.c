#include "gl_screen_oracle_stubs.h"

extern int glx, gly, glwidth, glheight;
extern int scr_copytop, scr_copyeverything;
extern float scr_con_current, scr_conlines;
extern float oldscreensize, oldfov;
extern cvar_t scr_viewsize, scr_fov, scr_conspeed, scr_centertime;
extern cvar_t scr_showram, scr_showturtle, scr_showpause, scr_printspeed;
extern cvar_t gl_triplebuffer;
extern qboolean scr_initialized;
extern qpic_t *scr_ram, *scr_net, *scr_turtle;
extern int scr_fullupdate, clearconsole, clearnotify, sb_lines;
extern viddef_t vid;
extern vrect_t scr_vrect;
extern qboolean scr_disabled_for_loading, scr_drawloading, block_drawing;
extern float scr_disabled_time;
extern char scr_centerstring[1024];
extern float scr_centertime_start, scr_centertime_off;
extern int scr_center_lines, scr_erase_lines, scr_erase_center;
extern char *scr_notifystring;
extern qboolean scr_drawdialog;

int _fltused = 0;
client_state_t cl;
client_static_t cls;
refdef_t r_refdef;
float host_frametime;
float realtime;
int key_dest;
int key_count;
int key_lastpress;
qboolean r_cache_thrash;
qboolean con_forcedup;
int con_notifylines;
qboolean con_initialized;
byte palette_data[768];
byte *host_basepal = palette_data;
cvar_t crosshair = {"crosshair", "0", false, false, 0.0f, NULL};
char com_gamedir[MAX_OSPATH] = "id1";

static qpic_t wad_ram = {24, 24};
static qpic_t wad_net = {24, 24};
static qpic_t wad_turtle = {24, 24};
static qpic_t pause_pic = {64, 24};
static qpic_t loading_pic = {80, 24};
static int cvar_registers;
static int command_registers;
static int draw_chars;
static int draw_pics;
static int tile_calls;
static int tile_values[16];
static int console_draws;
static int notify_draws;
static int render_begins;
static int render_ends;
static int render_views;
static int set2d_calls;
static int sbar_draws;
static int menu_draws;
static int palette_sets;
static int stop_calls;
static int clear_notify_calls;
static int file_write_size;
static byte file_write_data[64];
static byte allocation[4096];

double sin(double);
double cos(double);
double atan2(double, double);

char *mq_strncpy(char *destination, const char *source, unsigned __int64 count)
{
    unsigned __int64 index = 0;
    while (index < count && source[index])
    {
        destination[index] = source[index];
        index++;
    }
    while (index < count)
        destination[index++] = 0;
    return destination;
}

void *malloc(unsigned __int64 bytes)
{
    (void)bytes;
    return allocation;
}

void free(void *pointer)
{
    (void)pointer;
}

double mq_tan(double value)
{
    return sin(value) / cos(value);
}

double mq_atan(double value)
{
    return atan2(value, 1.0);
}

static int same(const char *left, const char *right)
{
    while (*left && *right && *left == *right)
    {
        left++;
        right++;
    }
    return *left == *right;
}

static float decimal(char *text)
{
    float value = 0.0f;
    float scale = 0.1f;
    int fraction = 0;
    while (*text)
    {
        if (*text == '.')
        {
            fraction = 1;
            text++;
            continue;
        }
        if (*text >= '0' && *text <= '9')
        {
            if (!fraction)
                value = value * 10.0f + (*text - '0');
            else
            {
                value += (*text - '0') * scale;
                scale *= 0.1f;
            }
        }
        text++;
    }
    return value;
}

void Sys_Error(char *format, ...)
{
    (void)format;
}

void Con_Printf(char *format, ...)
{
    (void)format;
}

void Cvar_Set(char *name, char *value)
{
    float number = decimal(value);
    if (same(name, "viewsize"))
        scr_viewsize.value = number;
    else if (same(name, "fov"))
        scr_fov.value = number;
}

void Cvar_SetValue(char *name, float value)
{
    if (same(name, "viewsize"))
        scr_viewsize.value = value;
    else if (same(name, "fov"))
        scr_fov.value = value;
}

void Cvar_RegisterVariable(cvar_t *variable)
{
    variable->value = decimal(variable->string);
    cvar_registers++;
}

void Cmd_AddCommand(char *name, void (*function)(void))
{
    (void)name;
    (void)function;
    command_registers++;
}

void Sbar_Changed(void)
{
}

qpic_t *Draw_PicFromWad(char *name)
{
    if (same(name, "ram"))
        return &wad_ram;
    if (same(name, "net"))
        return &wad_net;
    return &wad_turtle;
}

void Draw_Pic(int x, int y, qpic_t *picture)
{
    (void)x;
    (void)y;
    (void)picture;
    draw_pics++;
}

qpic_t *Draw_CachePic(char *name)
{
    return same(name, "gfx/pause.lmp") ? &pause_pic : &loading_pic;
}

void Draw_Character(int x, int y, int character)
{
    (void)x;
    (void)y;
    (void)character;
    draw_chars++;
}

void Con_CheckResize(void)
{
}

void Con_DrawConsole(float lines, qboolean draw_input)
{
    (void)lines;
    (void)draw_input;
    console_draws++;
}

void Con_DrawNotify(void)
{
    notify_draws++;
}

int Sys_FileTime(char *path)
{
    (void)path;
    return -1;
}

void glReadPixels(
    int x, int y, int width, int height, int format, int type, void *output)
{
    byte *bytes = (byte *)output;
    int index;
    (void)x;
    (void)y;
    (void)format;
    (void)type;
    for (index = 0; index < width * height * 3; index++)
        bytes[index] = (byte)(index + 1);
}

void COM_WriteFile(char *name, void *data, int size)
{
    int index;
    (void)name;
    file_write_size = size;
    for (index = 0; index < size && index < 64; index++)
        file_write_data[index] = ((byte *)data)[index];
}

void S_StopAllSounds(qboolean clear)
{
    (void)clear;
    stop_calls++;
}

void Con_ClearNotify(void)
{
    clear_notify_calls++;
}

void S_ClearBuffer(void)
{
}

void Sys_SendKeyEvents(void)
{
    key_lastpress = 'y';
}

void VID_SetPalette(byte *palette)
{
    (void)palette;
    palette_sets++;
}

void Draw_TileClear(int x, int y, int width, int height)
{
    int base = tile_calls * 4;
    if (base + 3 < 16)
    {
        tile_values[base] = x;
        tile_values[base + 1] = y;
        tile_values[base + 2] = width;
        tile_values[base + 3] = height;
    }
    tile_calls++;
}

void GL_BeginRendering(int *x, int *y, int *width, int *height)
{
    *x = 0;
    *y = 0;
    *width = vid.width;
    *height = vid.height;
    render_begins++;
}

void V_RenderView(void)
{
    render_views++;
}

void GL_Set2D(void)
{
    set2d_calls++;
}

void Sbar_Draw(void)
{
    sbar_draws++;
}

void Draw_FadeScreen(void)
{
}

void Sbar_IntermissionOverlay(void)
{
}

void Sbar_FinaleOverlay(void)
{
}

void M_Draw(void)
{
    menu_draws++;
}

void V_UpdatePalette(void)
{
}

void GL_EndRendering(void)
{
    render_ends++;
}

static void reset_draw_counts(void)
{
    draw_chars = 0;
    draw_pics = 0;
    tile_calls = 0;
    console_draws = 0;
    notify_draws = 0;
}

__declspec(dllexport) int __cdecl gl_screen_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    float fov;
    (void)capacity;
    memset(&cl, 0, sizeof(cl));
    memset(&cls, 0, sizeof(cls));
    memset(&r_refdef, 0, sizeof(r_refdef));
    vid.width = 320;
    vid.height = 200;
    vid.numpages = 3;
    key_dest = key_game;
    host_frametime = 0.05f;
    realtime = 1.0f;

    scr_centertime.value = 2.0f;
    cl.time = 4.0f;
    SCR_CenterPrint("one\ntwo");
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_CenterPrint\",\"case\":\"lines\","
        "\"lines\":%d,\"off\":%.9g,\"start\":%.9g}\n",
        scr_center_lines, scr_centertime_off, scr_centertime_start);

    reset_draw_counts();
    SCR_DrawCenterString();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_DrawCenterString\",\"case\":\"two-lines\","
        "\"characters\":%d,\"erase\":%d}\n",
        draw_chars, scr_erase_center);

    reset_draw_counts();
    scr_erase_lines = 0;
    host_frametime = 0.25f;
    SCR_CheckDrawCenterString();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_CheckDrawCenterString\",\"case\":\"visible\","
        "\"copytop\":%d,\"erase_lines\":%d,\"characters\":%d,"
        "\"remaining\":%.9g}\n",
        scr_copytop, scr_erase_lines, draw_chars, scr_centertime_off);

    fov = CalcFov(90.0f, 320.0f, 200.0f);
    cursor += sprintf(
        cursor,
        "{\"function\":\"CalcFov\",\"case\":\"classic\","
        "\"value\":%.9g}\n",
        fov);

    scr_viewsize.value = 80.0f;
    scr_fov.value = 90.0f;
    cl.intermission = 0;
    SCR_CalcRefdef();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_CalcRefdef\",\"case\":\"windowed\","
        "\"x\":%d,\"y\":%d,\"width\":%d,\"height\":%d,\"sb\":%d,"
        "\"fovx\":%.9g,\"fovy\":%.9g}\n",
        r_refdef.vrect.x, r_refdef.vrect.y, r_refdef.vrect.width,
        r_refdef.vrect.height, sb_lines, r_refdef.fov_x, r_refdef.fov_y);

    SCR_SizeUp_f();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_SizeUp_f\",\"case\":\"increment\","
        "\"viewsize\":%.9g,\"recalc\":%d}\n",
        scr_viewsize.value, vid.recalc_refdef);

    SCR_SizeDown_f();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_SizeDown_f\",\"case\":\"decrement\","
        "\"viewsize\":%.9g,\"recalc\":%d}\n",
        scr_viewsize.value, vid.recalc_refdef);

    cvar_registers = 0;
    command_registers = 0;
    SCR_Init();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_Init\",\"case\":\"register\","
        "\"initialized\":%d,\"cvars\":%d,\"commands\":%d,\"pics\":%d}\n",
        scr_initialized, cvar_registers, command_registers,
        scr_ram != NULL && scr_net != NULL && scr_turtle != NULL);

    reset_draw_counts();
    scr_showram.value = 1.0f;
    r_cache_thrash = true;
    SCR_DrawRam();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_DrawRam\",\"case\":\"thrash\","
        "\"pictures\":%d}\n",
        draw_pics);

    reset_draw_counts();
    scr_showturtle.value = 1.0f;
    host_frametime = 0.2f;
    SCR_DrawTurtle();
    SCR_DrawTurtle();
    SCR_DrawTurtle();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_DrawTurtle\",\"case\":\"three-slow\","
        "\"pictures\":%d}\n",
        draw_pics);

    reset_draw_counts();
    realtime = 1.0f;
    cl.last_received_message = 0.0f;
    cls.demoplayback = false;
    SCR_DrawNet();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_DrawNet\",\"case\":\"stalled\","
        "\"pictures\":%d}\n",
        draw_pics);

    reset_draw_counts();
    scr_showpause.value = 1.0f;
    cl.paused = true;
    SCR_DrawPause();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_DrawPause\",\"case\":\"paused\","
        "\"pictures\":%d}\n",
        draw_pics);

    reset_draw_counts();
    scr_drawloading = true;
    SCR_DrawLoading();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_DrawLoading\",\"case\":\"active\","
        "\"pictures\":%d}\n",
        draw_pics);

    scr_drawloading = false;
    cl.worldmodel = NULL;
    cls.signon = 0;
    scr_con_current = 0.0f;
    host_frametime = 0.05f;
    SCR_SetUpToDrawConsole();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_SetUpToDrawConsole\",\"case\":\"forced\","
        "\"forced\":%d,\"lines\":%.9g,\"current\":%.9g}\n",
        con_forcedup, scr_conlines, scr_con_current);

    console_draws = 0;
    scr_con_current = 50.0f;
    SCR_DrawConsole();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_DrawConsole\",\"case\":\"visible\","
        "\"copy\":%d,\"draws\":%d,\"clear\":%d}\n",
        scr_copyeverything, console_draws, clearconsole);

    glx = 0;
    gly = 0;
    glwidth = 2;
    glheight = 1;
    file_write_size = 0;
    SCR_ScreenShot_f();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_ScreenShot_f\",\"case\":\"tga\","
        "\"size\":%d,\"type\":%d,\"width\":%d,\"height\":%d,"
        "\"pixel\":%d,\"bgr\":[%d,%d,%d]}\n",
        file_write_size, file_write_data[2], file_write_data[12],
        file_write_data[14], file_write_data[16],
        file_write_data[18], file_write_data[19], file_write_data[20]);

    cls.state = ca_connected;
    cls.signon = SIGNONS;
    cl.worldmodel = (void *)1;
    con_initialized = true;
    stop_calls = 0;
    clear_notify_calls = 0;
    realtime = 10.0f;
    SCR_BeginLoadingPlaque();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_BeginLoadingPlaque\",\"case\":\"connected\","
        "\"stops\":%d,\"clears\":%d,\"accepted\":1}\n",
        stop_calls, clear_notify_calls);

    clear_notify_calls = 0;
    SCR_EndLoadingPlaque();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_EndLoadingPlaque\",\"case\":\"end\","
        "\"disabled\":%d,\"full\":%d,\"clears\":%d}\n",
        scr_disabled_for_loading, scr_fullupdate, clear_notify_calls);

    reset_draw_counts();
    scr_notifystring = "OK";
    SCR_DrawNotifyString();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_DrawNotifyString\",\"case\":\"text\","
        "\"characters\":%d}\n",
        draw_chars);

    cls.state = ca_dedicated;
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_ModalMessage\",\"case\":\"dedicated\","
        "\"result\":%d}\n",
        SCR_ModalMessage("Continue?"));

    scr_conlines = 0.0f;
    scr_con_current = 0.0f;
    cl.cshifts[0].percent = 25;
    palette_sets = 0;
    SCR_BringDownConsole();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_BringDownConsole\",\"case\":\"settled\","
        "\"center\":%.9g,\"shift\":%d,\"palettes\":%d}\n",
        scr_centertime_off, cl.cshifts[0].percent, palette_sets);

    r_refdef.vrect.x = 10;
    r_refdef.vrect.y = 5;
    r_refdef.vrect.width = 100;
    r_refdef.vrect.height = 80;
    sb_lines = 48;
    tile_calls = 0;
    SCR_TileClear();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_TileClear\",\"case\":\"border\","
        "\"calls\":%d,\"left\":[%d,%d,%d,%d],"
        "\"right\":[%d,%d,%d,%d]}\n",
        tile_calls, tile_values[0], tile_values[1], tile_values[2],
        tile_values[3], tile_values[4], tile_values[5], tile_values[6],
        tile_values[7]);

    block_drawing = true;
    scr_disabled_for_loading = false;
    scr_drawloading = false;
    scr_drawdialog = false;
    scr_initialized = true;
    con_initialized = true;
    cls.state = ca_connected;
    cls.signon = SIGNONS;
    cls.demoplayback = false;
    cl.worldmodel = (void *)1;
    cl.intermission = 0;
    cl.paused = false;
    key_dest = key_game;
    scr_viewsize.value = 100.0f;
    scr_fov.value = 90.0f;
    scr_showram.value = 0.0f;
    scr_showturtle.value = 0.0f;
    crosshair.value = 0.0f;
    render_begins = render_ends = render_views = set2d_calls = 0;
    sbar_draws = menu_draws = 0;
    SCR_UpdateScreen();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SCR_UpdateScreen\",\"case\":\"blocked\","
        "\"begin\":%d,\"view\":%d,\"set2d\":%d,\"sbar\":%d,"
        "\"menu\":%d,\"end\":%d,\"pages\":%d}\n",
        render_begins, render_views, set2d_calls, sbar_draws,
        menu_draws, render_ends, vid.numpages);

    *cursor = 0;
    return (int)(cursor - output);
}
