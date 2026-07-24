/*
 * Synthetic, redistributable execution harness for the unchanged pinned
 * WinQuake/gl_draw.c. No Quake game data is embedded here.
 */
#include "quakedef.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { int texnum; float sl, tl, sh, th; } fixture_glpic_t;
typedef struct { int width, height; byte data[70000]; } fixture_qpic_t;

void GL_Bind(int);
int Scrap_AllocBlock(int, int, int *, int *);
void Scrap_Upload(void);
qpic_t *Draw_PicFromWad(char *);
qpic_t *Draw_CachePic(char *);
void Draw_CharToConback(int, byte *);
void Draw_TextureMode_f(void);
void Draw_Init(void);
void Draw_Character(int, int, int);
void Draw_String(int, int, char *);
void Draw_DebugChar(char);
void Draw_AlphaPic(int, int, qpic_t *, float);
void Draw_Pic(int, int, qpic_t *);
void Draw_TransPic(int, int, qpic_t *);
void Draw_TransPicTranslate(int, int, qpic_t *, byte *);
void Draw_ConsoleBackground(int);
void Draw_TileClear(int, int, int, int);
void Draw_Fill(int, int, int, int, int);
void Draw_FadeScreen(void);
void Draw_BeginDisc(void);
void Draw_EndDisc(void);
void GL_Set2D(void);
int GL_FindTexture(char *);
void GL_ResampleTexture(unsigned *, int, int, unsigned *, int, int);
void GL_Resample8BitTexture(byte *, int, int, byte *, int, int);
void GL_MipMap(byte *, int, int);
void GL_MipMap8Bit(byte *, int, int);
void GL_Upload32(unsigned *, int, int, qboolean, qboolean);
void GL_Upload8_EXT(byte *, int, int, qboolean, qboolean);
void GL_Upload8(byte *, int, int, qboolean, qboolean);
int GL_LoadTexture(char *, int, int, byte *, qboolean, qboolean);
int GL_LoadPicTexture(qpic_t *);
void GL_SelectTexture(GLenum);

extern cvar_t gl_nobind, gl_max_size, gl_picmip;
extern int char_texture, translate_texture, currenttexture;
extern int gl_filter_min, gl_filter_max, texels, numgltextures;
extern int scrap_allocated[2][256], scrap_uploads, scrap_texnum;
extern byte scrap_texels[2][256 * 256 * 4];
extern qboolean scrap_dirty;
extern int pic_count, pic_texels, menu_numcachepics;
extern byte *draw_chars, menuplyr_pixels[4096];
extern qpic_t *draw_disc, *draw_backtile, *conback;

qboolean bigendien = false;
static short IdentityShort(short v) { return v; }
static int IdentityLong(int v) { return v; }
static float IdentityFloat(float v) { return v; }
short (*BigShort)(short) = IdentityShort;
short (*LittleShort)(short) = IdentityShort;
int (*BigLong)(int) = IdentityLong;
int (*LittleLong)(int) = IdentityLong;
float (*BigFloat)(float) = IdentityFloat;
float (*LittleFloat)(float) = IdentityFloat;

viddef_t vid;
byte palette_bytes[768];
byte *host_basepal = palette_bytes;
unsigned d_8to24table[256];
unsigned char d_15to8table[65536];
int texture_extension_number = 1;
int texture_mode = GL_LINEAR;
int glx = 3, gly = 4, glwidth = 640, glheight = 480;
int currenttexture = -1;
int cnttextures[2] = {-1, -1};
const char *gl_renderer = "fixture";
qboolean gl_mtexable = false;

static fixture_qpic_t disc_pic, backtile_pic, conback_pic, menu_pic;
static byte conchars[16384];
static byte hunk[1024];
static int hunk_used;
static int cvar_registers, command_registers, cvar_sets, sbar_changes;
static int cmd_argc = 1;
static char *cmd_argv[2] = {"gl_texturemode", ""};
static qboolean fixture_is8bit;

typedef struct {
    int binds, begins, ends, texcoords, vertices, colors;
    int enables, disables, texparams, teximages, drawbuffers;
    int viewports, matrixmodes, identities, orthos, selects;
    int last_bind, last_level, last_internal, last_width, last_height;
    unsigned upload_hash, upload_chain_hash;
    unsigned upload_level_hash[16];
} gl_stats_t;
static gl_stats_t gs;

static unsigned HashBytes(const byte *data, int count)
{
    unsigned hash = 2166136261u;
    int i;
    for (i = 0; i < count; ++i) {
        hash ^= data[i];
        hash *= 16777619u;
    }
    return hash;
}

static void ResetGL(void)
{
    memset(&gs, 0, sizeof(gs));
    gs.upload_hash = 2166136261u;
    gs.upload_chain_hash = 2166136261u;
}

static void Emit(const char *function, const char *scene, const char *format, ...)
{
    va_list arguments;
    printf("{\"function\":\"%s\",\"scene\":\"%s\"", function, scene);
    if (format && *format) {
        putchar(',');
        va_start(arguments, format);
        vprintf(format, arguments);
        va_end(arguments);
    }
    puts("}");
}

void Sys_Error(char *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    vfprintf(stderr, format, arguments);
    fputc('\n', stderr);
    va_end(arguments);
    exit(86);
}

void Con_Printf(char *format, ...) { (void)format; }
void Cvar_RegisterVariable(cvar_t *variable) { (void)variable; ++cvar_registers; }
void Cvar_Set(char *name, char *value)
{
    ++cvar_sets;
    if (!strcmp(name, "gl_max_size")) {
        gl_max_size.string = value;
        gl_max_size.value = (float)atof(value);
    }
}
void Cmd_AddCommand(char *name, xcommand_t command)
{ (void)name; (void)command; ++command_registers; }
int Cmd_Argc(void) { return cmd_argc; }
char *Cmd_Argv(int index) { return index >= 0 && index < cmd_argc ? cmd_argv[index] : ""; }

int Q_strcasecmp(char *a, char *b) { return _stricmp(a, b); }
int Q_strncasecmp(char *a, char *b, int n) { return _strnicmp(a, b, (size_t)n); }
void Q_memcpy(void *d, void *s, int n) { memcpy(d, s, (size_t)n); }
void Q_memset(void *d, int c, int n) { memset(d, c, (size_t)n); }
int Q_memcmp(void *a, void *b, int n) { return memcmp(a, b, (size_t)n); }
void Q_strcpy(char *d, char *s) { strcpy(d, s); }
void Q_strncpy(char *d, char *s, int n) { strncpy(d, s, (size_t)n); }
int Q_strlen(char *s) { return (int)strlen(s); }
char *Q_strrchr(char *s, char c) { return strrchr(s, c); }
void Q_strcat(char *d, char *s) { strcat(d, s); }
int Q_strcmp(char *a, char *b) { return strcmp(a, b); }
int Q_strncmp(char *a, char *b, int n) { return strncmp(a, b, (size_t)n); }

int Hunk_LowMark(void) { return hunk_used; }
void Hunk_FreeToLowMark(int mark) { hunk_used = mark; }
void *Hunk_AllocName(int size, char *name)
{
    void *result = hunk + hunk_used;
    (void)name;
    hunk_used += (size + 15) & ~15;
    return result;
}

void SwapPic(qpic_t *pic)
{
    pic->width = LittleLong(pic->width);
    pic->height = LittleLong(pic->height);
}

static void FillPic(fixture_qpic_t *pic, int width, int height, int seed)
{
    int i;
    pic->width = width;
    pic->height = height;
    for (i = 0; i < width * height; ++i)
        pic->data[i] = (byte)((seed + i * 3) & 255);
}

void *W_GetLumpName(char *name)
{
    if (!strcmp(name, "conchars")) return conchars;
    if (!strcmp(name, "disc")) return &disc_pic;
    if (!strcmp(name, "backtile")) return &backtile_pic;
    Sys_Error("missing fixture lump %s", name);
    return NULL;
}

byte *COM_LoadTempFile(char *path)
{
    if (!strcmp(path, "gfx/conback.lmp")) return (byte *)&conback_pic;
    if (!strcmp(path, "gfx/menuplyr.lmp")) return (byte *)&menu_pic;
    if (!strcmp(path, "gfx/menu.lmp")) return (byte *)&menu_pic;
    return NULL;
}

qboolean VID_Is8bit(void) { return fixture_is8bit; }
void Sbar_Changed(void) { ++sbar_changes; }

static void APIENTRY FixtureBind(GLenum target, GLuint texture)
{
    (void)target;
    ++gs.binds;
    gs.last_bind = (int)texture;
}
BINDTEXFUNCPTR bindTexFunc = FixtureBind;

static void APIENTRY FixtureSelect(GLenum target)
{ ++gs.selects; gs.last_bind = (int)target; }
lpSelTexFUNC qglSelectTextureSGIS = FixtureSelect;

void APIENTRY glBegin(GLenum mode) { (void)mode; ++gs.begins; }
void APIENTRY glEnd(void) { ++gs.ends; }
void APIENTRY glTexCoord2f(GLfloat s, GLfloat t) { (void)s; (void)t; ++gs.texcoords; }
void APIENTRY glVertex2f(GLfloat x, GLfloat y) { (void)x; (void)y; ++gs.vertices; }
void APIENTRY glColor3f(GLfloat r, GLfloat g, GLfloat b) { (void)r; (void)g; (void)b; ++gs.colors; }
void APIENTRY glColor4f(GLfloat r, GLfloat g, GLfloat b, GLfloat a) { (void)r; (void)g; (void)b; (void)a; ++gs.colors; }
void APIENTRY glEnable(GLenum cap) { (void)cap; ++gs.enables; }
void APIENTRY glDisable(GLenum cap) { (void)cap; ++gs.disables; }
void APIENTRY glTexParameterf(GLenum target, GLenum name, GLfloat value)
{ (void)target; (void)name; (void)value; ++gs.texparams; }
void APIENTRY glDrawBuffer(GLenum mode) { (void)mode; ++gs.drawbuffers; }
void APIENTRY glViewport(GLint x, GLint y, GLsizei w, GLsizei h)
{ (void)x; (void)y; (void)w; (void)h; ++gs.viewports; }
void APIENTRY glMatrixMode(GLenum mode) { (void)mode; ++gs.matrixmodes; }
void APIENTRY glLoadIdentity(void) { ++gs.identities; }
void APIENTRY glOrtho(GLdouble l, GLdouble r, GLdouble b, GLdouble t, GLdouble n, GLdouble f)
{ (void)l; (void)r; (void)b; (void)t; (void)n; (void)f; ++gs.orthos; }
void APIENTRY glTexImage2D(GLenum target, GLint level, GLint internal,
    GLsizei width, GLsizei height, GLint border, GLenum format,
    GLenum type, const GLvoid *pixels)
{
    int bytes_per_pixel = format == GL_RGBA ? 4 : 1;
    (void)target; (void)border; (void)type;
    ++gs.teximages;
    gs.last_level = level;
    gs.last_internal = internal;
    gs.last_width = width;
    gs.last_height = height;
    gs.upload_hash = HashBytes((const byte *)pixels, width * height * bytes_per_pixel);
    if (level >= 0 && level < 16)
        gs.upload_level_hash[level] = gs.upload_hash;
    {
        const byte *source = (const byte *)pixels;
        int count = width * height * bytes_per_pixel;
        int i;
        for (i = 0; i < count; ++i) {
            gs.upload_chain_hash ^= source[i];
            gs.upload_chain_hash *= 16777619u;
        }
    }
}

static void ResetFixture(void)
{
    int i, r, g, b, best, best_distance, p, dr, dg, db, distance;
    memset(conchars, 255, sizeof(conchars));
    for (i = 0; i < (int)sizeof(conchars); i += 97) conchars[i] = (byte)(i & 95);
    FillPic(&disc_pic, 16, 16, 3);
    FillPic(&backtile_pic, 64, 64, 7);
    FillPic(&menu_pic, 64, 64, 11);
    FillPic(&conback_pic, 320, 200, 13);
    for (i = 0; i < 256; ++i) {
        palette_bytes[i * 3] = (byte)i;
        palette_bytes[i * 3 + 1] = (byte)((i * 3) & 255);
        palette_bytes[i * 3 + 2] = (byte)(255 - i);
        d_8to24table[i] = (255u << 24) | palette_bytes[i * 3] |
            ((unsigned)palette_bytes[i * 3 + 1] << 8) |
            ((unsigned)palette_bytes[i * 3 + 2] << 16);
    }
    d_8to24table[255] &= 0x00ffffffu;
    for (i = 0; i < 32768; ++i) {
        r = ((i & 31) << 3) + 4;
        g = ((i & 0x03e0) >> 2) + 4;
        b = ((i & 0x7c00) >> 7) + 4;
        best = 0; best_distance = 100000000;
        for (p = 0; p < 256; ++p) {
            dr = r - palette_bytes[p * 3];
            dg = g - palette_bytes[p * 3 + 1];
            db = b - palette_bytes[p * 3 + 2];
            distance = dr * dr + dg * dg + db * db;
            if (distance < best_distance) { best = p; best_distance = distance; }
        }
        d_15to8table[i] = (byte)best;
    }
    vid.width = 640; vid.height = 480; vid.conwidth = 640; vid.conheight = 480;
    texture_extension_number = 1;
    currenttexture = -1;
    cnttextures[0] = cnttextures[1] = -1;
    numgltextures = 0;
    menu_numcachepics = 0;
    memset(scrap_allocated, 0, sizeof(scrap_allocated));
    memset(scrap_texels, 0, sizeof(scrap_texels));
    scrap_dirty = false; scrap_uploads = 0; pic_count = pic_texels = 0;
    cvar_registers = command_registers = cvar_sets = sbar_changes = 0;
    gl_nobind.value = 0; gl_max_size.value = 1024; gl_picmip.value = 0;
    gl_filter_min = GL_LINEAR_MIPMAP_NEAREST; gl_filter_max = GL_LINEAR;
    hunk_used = 0; fixture_is8bit = false; gl_mtexable = false;
    ResetGL();
}

static void SetPicGL(fixture_qpic_t *pic, int width, int height, int texture)
{
    fixture_glpic_t *gl;
    pic->width = width; pic->height = height;
    gl = (fixture_glpic_t *)pic->data;
    gl->texnum = texture;
    gl->sl = 0.25f; gl->tl = 0.125f; gl->sh = 0.75f; gl->th = 0.875f;
}

static int FatalMode(const char *mode)
{
    fixture_qpic_t pic;
    unsigned pixel = 0;
    int x, y;
    byte data[4] = {0, 1, 2, 3};
    ResetFixture();
    if (!strcmp(mode, "transpic-coordinates")) {
        SetPicGL(&pic, 16, 8, 55);
        Draw_TransPic(-1, 0, (qpic_t *)&pic);
        return 0;
    }
    if (!strcmp(mode, "scrap-full")) {
        Scrap_AllocBlock(255, 256, &x, &y);
        Scrap_AllocBlock(255, 256, &x, &y);
        Scrap_AllocBlock(255, 256, &x, &y);
        return 0;
    }
    if (!strcmp(mode, "upload-too-big")) {
        GL_Upload32(&pixel, 1024, 1024, false, false);
        return 0;
    }
    if (!strcmp(mode, "upload8-size")) {
        GL_Upload8(data, 3, 1, false, false);
        return 0;
    }
    return 2;
}

int main(int argc, char **argv)
{
    int x, y, first, second, texture, found, before;
    byte indexed[16], indexed_out[32], translation[256], rgba_bytes[64], conback_dest[2560];
    byte alias_indexed[200 * 194];
    unsigned alias_converted[200 * 194];
    unsigned alias_resampled[256 * 256];
    unsigned rgba[16], rgba_out[32];
    fixture_qpic_t pic;
    qpic_t *loaded, *cached;
    int i;

    if (argc == 3 && !strcmp(argv[1], "--fatal"))
        return FatalMode(argv[2]);
    ResetFixture();
    char_texture = 77; currenttexture = -1; ResetGL();
    GL_Bind(9); GL_Bind(9); gl_nobind.value = 1; GL_Bind(12);
    Emit("GL_Bind", "bind-cache-nobind", "\"binds\":%d,\"current\":%d,\"last\":%d", gs.binds, currenttexture, gs.last_bind);

    first = Scrap_AllocBlock(8, 8, &x, &y);
    second = Scrap_AllocBlock(8, 8, &x, &y);
    Emit("Scrap_AllocBlock", "scrap-pack", "\"blocks\":[%d,%d,%d,%d]", first, second, x, y);

    gl_nobind.value = 0; scrap_texnum = 90; scrap_dirty = true; ResetGL();
    Scrap_Upload();
    Emit("Scrap_Upload", "scrap-upload", "\"uploads\":%d,\"dirty\":%d,\"images\":%d,\"binds\":%d", scrap_uploads, scrap_dirty, gs.teximages, gs.binds);

    memset(scrap_allocated, 0, sizeof(scrap_allocated)); pic_count = pic_texels = 0; scrap_texnum = 90;
    FillPic(&disc_pic, 16, 16, 3);
    loaded = Draw_PicFromWad("disc");
    Emit("Draw_PicFromWad", "wad-scrap", "\"size\":[%d,%d],\"texture\":%d,\"count\":%d,\"texels\":%d", loaded->width, loaded->height, ((fixture_glpic_t *)loaded->data)->texnum, pic_count, pic_texels);

    FillPic(&menu_pic, 64, 64, 11); menu_numcachepics = 0; numgltextures = 0; ResetGL();
    cached = Draw_CachePic("gfx/menuplyr.lmp");
    loaded = Draw_CachePic("gfx/menuplyr.lmp");
    Emit("Draw_CachePic", "menu-cache", "\"same\":%d,\"size\":[%d,%d],\"player\":%u,\"images\":%d", cached == loaded, cached->width, cached->height, menuplyr_pixels[17], gs.teximages);

    draw_chars = conchars; memset(conback_dest, 7, sizeof(conback_dest));
    Draw_CharToConback(0, conback_dest);
    Emit("Draw_CharToConback", "conback-glyph", "\"hash\":%u", HashBytes(conback_dest, sizeof(conback_dest)));

    numgltextures = 0; texture_extension_number = 30; currenttexture = -1;
    for (i = 0; i < 16; ++i) indexed[i] = (byte)i;
    GL_LoadTexture("", 4, 4, indexed, true, false);
    cmd_argc = 2; cmd_argv[1] = "GL_NEAREST_MIPMAP_LINEAR"; ResetGL();
    Draw_TextureMode_f();
    Emit("Draw_TextureMode_f", "texture-mode", "\"filters\":[%d,%d],\"params\":%d", gl_filter_min, gl_filter_max, gs.texparams);
    cmd_argc = 1;

    ResetFixture(); ResetGL(); Draw_Init();
    Emit("Draw_Init", "draw-init", "\"cvars\":%d,\"commands\":%d,\"textures\":[%d,%d,%d],\"next\":%d,\"pics\":[%d,%d]", cvar_registers, command_registers, char_texture, translate_texture, scrap_texnum, texture_extension_number, draw_disc != NULL, draw_backtile != NULL);

    SetPicGL(&pic, 16, 8, 55); currenttexture = -1; ResetGL(); Draw_Character(10, 20, 'A');
    Emit("Draw_Character", "ui-character", "\"gl\":[%d,%d,%d,%d,%d]", gs.binds, gs.begins, gs.texcoords, gs.vertices, gs.ends);
    ResetGL(); currenttexture = -1; Draw_String(10, 20, "A B");
    Emit("Draw_String", "ui-string", "\"quads\":%d,\"vertices\":%d", gs.begins, gs.vertices);
    ResetGL(); Draw_DebugChar('X');
    Emit("Draw_DebugChar", "ui-debug", "\"calls\":%d", gs.begins + gs.vertices);
    scrap_dirty = false; ResetGL(); currenttexture = -1; Draw_AlphaPic(2, 3, (qpic_t *)&pic, 0.375f);
    Emit("Draw_AlphaPic", "ui-alpha-pic", "\"gl\":[%d,%d,%d,%d,%d]", gs.disables, gs.enables, gs.colors, gs.begins, gs.vertices);
    ResetGL(); currenttexture = -1; Draw_Pic(4, 5, (qpic_t *)&pic);
    Emit("Draw_Pic", "ui-pic", "\"gl\":[%d,%d,%d,%d]", gs.binds, gs.colors, gs.begins, gs.vertices);
    ResetGL(); currenttexture = -1; Draw_TransPic(6, 7, (qpic_t *)&pic);
    Emit("Draw_TransPic", "ui-trans-pic", "\"gl\":[%d,%d,%d]", gs.binds, gs.begins, gs.vertices);
    for (i = 0; i < 256; ++i) translation[i] = (byte)(255 - i);
    memcpy(menuplyr_pixels, menu_pic.data, 4096); menuplyr_pixels[0] = 255;
    translate_texture = 88; ResetGL(); currenttexture = -1;
    Draw_TransPicTranslate(8, 9, (qpic_t *)&pic, translation);
    Emit("Draw_TransPicTranslate", "ui-translate", "\"upload\":[%d,%d,%d,%u],\"quad\":%d", gs.last_width, gs.last_height, gs.last_internal, gs.upload_hash, gs.vertices);
    conback = (qpic_t *)&pic; vid.height = 200; ResetGL(); currenttexture = -1; Draw_ConsoleBackground(100);
    Emit("Draw_ConsoleBackground", "ui-console", "\"alphaPath\":[%d,%d,%d]", gs.disables, gs.enables, gs.vertices);
    draw_backtile = (qpic_t *)&pic; ResetGL(); currenttexture = -1; Draw_TileClear(16, 24, 96, 40);
    Emit("Draw_TileClear", "ui-tile", "\"gl\":[%d,%d,%d,%d]", gs.binds, gs.texcoords, gs.vertices, gs.ends);
    ResetGL(); Draw_Fill(1, 2, 30, 40, 5);
    Emit("Draw_Fill", "ui-fill", "\"gl\":[%d,%d,%d,%d]", gs.disables, gs.colors, gs.vertices, gs.enables);
    ResetGL(); before = sbar_changes; Draw_FadeScreen();
    Emit("Draw_FadeScreen", "ui-fade", "\"gl\":[%d,%d,%d],\"sbar\":%d", gs.enables, gs.disables, gs.vertices, sbar_changes - before);
    draw_disc = (qpic_t *)&pic; vid.width = 640; ResetGL(); currenttexture = -1; Draw_BeginDisc();
    Emit("Draw_BeginDisc", "ui-disc", "\"buffers\":%d,\"vertices\":%d", gs.drawbuffers, gs.vertices);
    ResetGL(); Draw_EndDisc();
    Emit("Draw_EndDisc", "ui-disc-end", "\"calls\":%d", gs.begins + gs.vertices);
    ResetGL(); GL_Set2D();
    Emit("GL_Set2D", "set2d", "\"state\":[%d,%d,%d,%d,%d,%d,%d]", gs.viewports, gs.matrixmodes, gs.identities, gs.orthos, gs.disables, gs.enables, gs.colors);

    ResetFixture(); for (i = 0; i < 16; ++i) indexed[i] = (byte)i;
    texture = GL_LoadTexture("", 4, 4, indexed, false, false);
    found = GL_FindTexture("");
    Emit("GL_FindTexture", "texture-find", "\"found\":%d,\"missing\":%d,\"texture\":%d", found, GL_FindTexture("missing"), texture);

    for (i = 0; i < 16; ++i) rgba[i] = 0xff000000u | (unsigned)(i * 0x010203);
    GL_ResampleTexture(rgba, 4, 4, rgba_out, 8, 4);
    Emit("GL_ResampleTexture", "texture-resample", "\"hash\":%u", HashBytes((byte *)rgba_out, 8 * 4 * 4));
    for (i = 0; i < 16; ++i) indexed[i] = (byte)(i * 7);
    GL_Resample8BitTexture(indexed, 4, 4, indexed_out, 8, 4);
    Emit("GL_Resample8BitTexture", "texture-resample8", "\"hash\":%u", HashBytes(indexed_out, 32));
    memcpy(rgba_bytes, rgba, 64); GL_MipMap(rgba_bytes, 4, 4);
    Emit("GL_MipMap", "texture-mipmap", "\"hash\":%u", HashBytes(rgba_bytes, 16));
    GL_MipMap8Bit(indexed, 4, 4);
    Emit("GL_MipMap8Bit", "texture-mipmap8", "\"hash\":%u", HashBytes(indexed, 4));

    gl_picmip.value = 0; gl_max_size.value = 1024; texels = 0; ResetGL();
    GL_Upload32(rgba, 4, 4, true, true);
    Emit("GL_Upload32", "texture-upload32", "\"upload\":[%d,%d,%d,%d],\"params\":%d,\"texels\":%d", gs.teximages, gs.last_level, gs.last_width, gs.last_height, gs.texparams, texels);
    fixture_is8bit = true; ResetGL(); GL_Upload8_EXT(indexed_out, 8, 4, true, false);
    Emit("GL_Upload8_EXT", "texture-upload8ext", "\"upload\":[%d,%d,%d,%d],\"params\":%d", gs.teximages, gs.last_level, gs.last_width, gs.last_height, gs.texparams);
    fixture_is8bit = false; indexed[0] = 255; ResetGL(); GL_Upload8(indexed, 4, 4, false, true);
    Emit("GL_Upload8", "texture-upload8", "\"upload\":[%d,%d,%d,%u],\"params\":%d", gs.teximages, gs.last_width, gs.last_height, gs.upload_hash, gs.texparams);
    for (i = 0; i < (int)sizeof(alias_indexed); ++i)
    {
        alias_indexed[i] = (byte)((i * 37 + i / 200 * 11 + 17) & 255);
        alias_converted[i] = d_8to24table[alias_indexed[i]];
    }
    GL_ResampleTexture(alias_converted, 200, 194, alias_resampled, 256, 256);
    ResetGL(); GL_Upload8(alias_indexed, 200, 194, true, false);
    Emit("GL_Upload8", "alias-200x194-mip-chain",
        "\"source_hash\":%u,\"converted_hash\":%u,\"resampled_hash\":%u,\"upload\":[%d,%d,%d,%d],\"level_hashes\":[%u,%u,%u,%u,%u,%u,%u,%u,%u],\"chain_hash\":%u",
        HashBytes(alias_indexed, sizeof(alias_indexed)),
        HashBytes((const byte *)alias_converted, sizeof(alias_converted)),
        HashBytes((const byte *)alias_resampled, sizeof(alias_resampled)),
        gs.teximages, gs.last_level, gs.last_width, gs.last_height,
        gs.upload_level_hash[0], gs.upload_level_hash[1],
        gs.upload_level_hash[2], gs.upload_level_hash[3],
        gs.upload_level_hash[4], gs.upload_level_hash[5],
        gs.upload_level_hash[6], gs.upload_level_hash[7],
        gs.upload_level_hash[8],
        gs.upload_chain_hash);

    ResetFixture(); ResetGL();
    first = GL_LoadTexture("named", 4, 4, indexed, false, false);
    second = GL_LoadTexture("named", 4, 4, indexed, false, false);
    Emit("GL_LoadTexture", "texture-load", "\"ids\":[%d,%d],\"count\":%d,\"images\":%d", first, second, numgltextures, gs.teximages);
    SetPicGL(&pic, 4, 4, 0); memcpy(pic.data, indexed, 16); ResetGL();
    texture = GL_LoadPicTexture((qpic_t *)&pic);
    Emit("GL_LoadPicTexture", "texture-load-pic", "\"texture\":%d,\"count\":%d,\"images\":%d", texture, numgltextures, gs.teximages);

    gl_mtexable = true; currenttexture = 41; cnttextures[0] = -1; cnttextures[1] = 72; ResetGL();
    GL_SelectTexture(TEXTURE1_SGIS); GL_SelectTexture(TEXTURE1_SGIS); GL_SelectTexture(TEXTURE0_SGIS);
    Emit("GL_SelectTexture", "texture-select", "\"selects\":%d,\"current\":%d,\"slots\":[%d,%d]", gs.selects, currenttexture, cnttextures[0], cnttextures[1]);
    return 0;
}
