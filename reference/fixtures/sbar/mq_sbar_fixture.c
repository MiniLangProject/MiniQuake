/*
 * Synthetic, redistributable execution harness for the unchanged pinned
 * WinQuake/sbar.c. No Quake game data is embedded here.
 */
#include "quakedef.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void Sbar_ShowScores(void);
void Sbar_DontShowScores(void);
void Sbar_Changed(void);
void Sbar_Init(void);
void Sbar_DrawPic(int, int, qpic_t *);
void Sbar_DrawTransPic(int, int, qpic_t *);
void Sbar_DrawCharacter(int, int, int);
void Sbar_DrawString(int, int, char *);
int Sbar_itoa(int, char *);
void Sbar_DrawNum(int, int, int, int, int);
void Sbar_SortFrags(void);
int Sbar_ColorForMap(int);
void Sbar_UpdateScoreboard(void);
void Sbar_SoloScoreboard(void);
void Sbar_DrawScoreboard(void);
void Sbar_DrawInventory(void);
void Sbar_DrawFrags(void);
void Sbar_DrawFace(void);
void Sbar_Draw(void);
void Sbar_IntermissionNumber(int, int, int, int, int);
void Sbar_DeathmatchOverlay(void);
void Sbar_MiniDeathmatchOverlay(void);
void Sbar_IntermissionOverlay(void);
void Sbar_FinaleOverlay(void);

extern int sb_updates, sb_lines, scoreboardlines;
extern qboolean sb_showscores;
extern int fragsort[MAX_SCOREBOARD];
extern char scoreboardtext[MAX_SCOREBOARD][20];
extern int scoreboardtop[MAX_SCOREBOARD], scoreboardbottom[MAX_SCOREBOARD];

client_state_t cl;
viddef_t vid;
qboolean hipnotic, rogue, standard_quake = true;
cvar_t teamplay = {"teamplay", "0", false, false, 0};
float scr_con_current;
int scr_copyeverything, scr_fullupdate;

typedef struct {
    int width;
    int height;
    byte data[4];
} fixture_pic_t;

typedef struct {
    fixture_pic_t pic;
    char name[64];
} named_pic_t;

static named_pic_t pictures[512];
static int picture_count;
static int load_count, command_count;
static unsigned load_hash;
static int op_calls;
static unsigned op_hash;

static void HashByte(unsigned *hash, unsigned value)
{
    *hash ^= value & 255u;
    *hash *= 16777619u;
}

static void HashInt(unsigned *hash, int value)
{
    int i;
    for (i = 0; i < 4; ++i)
        HashByte(hash, (unsigned)value >> (i * 8));
}

static void HashString(unsigned *hash, const char *text)
{
    while (*text) HashByte(hash, (unsigned char)*text++);
    HashByte(hash, 0);
}

static named_pic_t *Named(qpic_t *pic)
{
    int i;
    for (i = 0; i < picture_count; ++i)
        if ((qpic_t *)&pictures[i].pic == pic) return &pictures[i];
    return NULL;
}

static qpic_t *Picture(const char *name)
{
    named_pic_t *entry;
    int width = 24, height = 24;
    if (!strcmp(name, "gfx/ranking.lmp")) width = 160;
    if (!strcmp(name, "gfx/complete.lmp")) width = 192;
    if (!strcmp(name, "gfx/inter.lmp")) width = 320;
    if (!strcmp(name, "gfx/finale.lmp")) width = 128;
    entry = &pictures[picture_count++];
    memset(entry, 0, sizeof(*entry));
    entry->pic.width = width;
    entry->pic.height = height;
    strcpy(entry->name, name);
    return (qpic_t *)&entry->pic;
}

static const char *PicName(qpic_t *pic)
{
    named_pic_t *entry = Named(pic);
    return entry ? entry->name : "<unknown>";
}

static void ResetOps(void)
{
    op_calls = 0;
    op_hash = 2166136261u;
}

static void OpHead(const char *kind)
{
    ++op_calls;
    HashString(&op_hash, kind);
}

static void OpPic(const char *kind, int x, int y, qpic_t *pic)
{
    OpHead(kind);
    HashString(&op_hash, PicName(pic));
    HashInt(&op_hash, x);
    HashInt(&op_hash, y);
}

static void EmitOps(const char *function, const char *scene)
{
    printf("{\"function\":\"%s\",\"scene\":\"%s\",\"calls\":%d,\"hash\":%u}\n",
           function, scene, op_calls, op_hash);
}

static void ResetClient(void)
{
    static scoreboard_t scores[MAX_SCOREBOARD];
    memset(&cl, 0, sizeof(cl));
    memset(scores, 0, sizeof(scores));
    cl.scores = scores;
    cl.maxclients = 5;
    cl.gametype = GAME_COOP;
    cl.viewentity = 2;
    cl.time = 12.75;
    cl.completed_time = 185.0;
    strcpy(cl.levelname, "The Slipgate Complex");
    strcpy(scores[0].name, "alpha");
    scores[0].frags = -2; scores[0].colors = 0x4d;
    strcpy(scores[1].name, "bravo");
    scores[1].frags = 1234; scores[1].colors = 0x00;
    strcpy(scores[2].name, "charlie");
    scores[2].frags = 17; scores[2].colors = 0xb3;
    strcpy(scores[3].name, "delta");
    scores[3].frags = 17; scores[3].colors = 0x6f;
    cl.stats[STAT_HEALTH] = 75;
    cl.stats[STAT_ARMOR] = 42;
    cl.stats[STAT_AMMO] = 9;
    cl.stats[STAT_SHELLS] = 5;
    cl.stats[STAT_NAILS] = 67;
    cl.stats[STAT_ROCKETS] = 1234;
    cl.stats[STAT_CELLS] = 0;
    cl.stats[STAT_ACTIVEWEAPON] = IT_NAILGUN;
    cl.stats[STAT_SECRETS] = 2;
    cl.stats[STAT_TOTALSECRETS] = 7;
    cl.stats[STAT_MONSTERS] = 11;
    cl.stats[STAT_TOTALMONSTERS] = 30;
    cl.items = IT_SHOTGUN | IT_NAILGUN | IT_ARMOR2 | IT_NAILS |
               IT_KEY1 | IT_INVISIBILITY | IT_SIGIL1;
    cl.item_gettime[0] = 0;
    cl.item_gettime[2] = 12.25;
    cl.item_gettime[17] = 12.0;
    vid.width = 640;
    vid.height = 480;
    vid.numpages = 3;
    sb_lines = 48;
    sb_updates = 0;
    sb_showscores = false;
    scr_con_current = 0;
    scr_copyeverything = 0;
    scr_fullupdate = 9;
    teamplay.value = 0;
}

qpic_t *Draw_PicFromWad(char *name)
{
    ++load_count;
    HashString(&load_hash, name);
    return Picture(name);
}

qpic_t *Draw_CachePic(char *path) { return Picture(path); }

void Draw_Pic(int x, int y, qpic_t *pic) { OpPic("pic", x, y, pic); }
void Draw_TransPic(int x, int y, qpic_t *pic) { OpPic("transpic", x, y, pic); }
void Draw_Character(int x, int y, int num)
{
    OpHead("char"); HashInt(&op_hash, num); HashInt(&op_hash, x); HashInt(&op_hash, y);
}
void Draw_String(int x, int y, char *text)
{
    OpHead("string"); HashString(&op_hash, text); HashInt(&op_hash, x); HashInt(&op_hash, y);
}
void Draw_Fill(int x, int y, int width, int height, int color)
{
    OpHead("fill"); HashInt(&op_hash, x); HashInt(&op_hash, y);
    HashInt(&op_hash, width); HashInt(&op_hash, height); HashInt(&op_hash, color);
}
void Draw_TileClear(int x, int y, int width, int height)
{
    OpHead("tileclear"); HashInt(&op_hash, x); HashInt(&op_hash, y);
    HashInt(&op_hash, width); HashInt(&op_hash, height);
}
void M_DrawPic(int x, int y, qpic_t *pic)
{
    Draw_Pic(x + ((vid.width - 320) >> 1), y, pic);
}

void Cmd_AddCommand(char *name, xcommand_t command)
{
    (void)name; (void)command; ++command_count;
}

char *va(char *format, ...)
{
    static char buffers[4][1024];
    static int index;
    va_list args;
    char *result = buffers[index++ & 3];
    va_start(args, format);
    vsprintf(result, format, args);
    va_end(args);
    return result;
}

qpic_t *draw_disc;

static void InitPictures(void)
{
    int base_count, hip_count, rogue_count;
    unsigned base_hash, hip_hash, rogue_hash;
    picture_count = load_count = command_count = 0;
    load_hash = 2166136261u;
    hipnotic = rogue = false; Sbar_Init();
    base_count = load_count; base_hash = load_hash;
    load_count = 0; load_hash = 2166136261u;
    hipnotic = true; rogue = false; Sbar_Init();
    hip_count = load_count; hip_hash = load_hash;
    load_count = 0; load_hash = 2166136261u;
    hipnotic = false; rogue = true; Sbar_Init();
    rogue_count = load_count; rogue_hash = load_hash;
    draw_disc = Picture("disc");
    printf("{\"function\":\"Sbar_Init\",\"scene\":\"base-hipnotic-rogue-loads\","
           "\"counts\":[%d,%d,%d],\"hashes\":[%u,%u,%u],\"commands\":%d}\n",
           base_count, hip_count, rogue_count, base_hash, hip_hash, rogue_hash,
           command_count);
}

int main(void)
{
    char text[32];
    int length;

    ResetClient();
    sb_showscores = false; sb_updates = 5; Sbar_ShowScores(); Sbar_ShowScores();
    printf("{\"function\":\"Sbar_ShowScores\",\"scene\":\"show-idempotent\",\"shown\":%d,\"updates\":%d}\n", sb_showscores, sb_updates);
    sb_updates = 5; Sbar_DontShowScores();
    printf("{\"function\":\"Sbar_DontShowScores\",\"scene\":\"hide\",\"shown\":%d,\"updates\":%d}\n", sb_showscores, sb_updates);
    sb_updates = 9; Sbar_Changed();
    printf("{\"function\":\"Sbar_Changed\",\"scene\":\"invalidate\",\"updates\":%d}\n", sb_updates);

    InitPictures();
    ResetClient();

    ResetOps(); cl.gametype = GAME_COOP; Sbar_DrawPic(3, -4, Picture("probe")); cl.gametype = GAME_DEATHMATCH; Sbar_DrawPic(3, -4, Picture("probe"));
    EmitOps("Sbar_DrawPic", "coop-deathmatch-offsets");
    ResetOps(); cl.gametype = GAME_COOP; Sbar_DrawTransPic(5, -6, Picture("probe")); cl.gametype = GAME_DEATHMATCH; Sbar_DrawTransPic(5, -6, Picture("probe"));
    EmitOps("Sbar_DrawTransPic", "coop-deathmatch-offsets");
    ResetOps(); cl.gametype = GAME_COOP; Sbar_DrawCharacter(7, -8, 65); cl.gametype = GAME_DEATHMATCH; Sbar_DrawCharacter(7, -8, 65);
    EmitOps("Sbar_DrawCharacter", "coop-deathmatch-offsets");
    ResetOps(); cl.gametype = GAME_COOP; Sbar_DrawString(9, -10, "quake"); cl.gametype = GAME_DEATHMATCH; Sbar_DrawString(9, -10, "quake");
    EmitOps("Sbar_DrawString", "coop-deathmatch-offsets");

    length = Sbar_itoa(-1234, text);
    printf("{\"function\":\"Sbar_itoa\",\"scene\":\"signed-decimal\",\"negative\":\"%s\",\"length\":%d,", text, length);
    Sbar_itoa(0, text); printf("\"zero\":\"%s\",", text);
    Sbar_itoa(9876, text); printf("\"positive\":\"%s\"}\n", text);

    ResetOps(); cl.gametype = GAME_COOP; Sbar_DrawNum(10, -2, -1234, 3, 1);
    EmitOps("Sbar_DrawNum", "crop-align-color");

    Sbar_SortFrags();
    printf("{\"function\":\"Sbar_SortFrags\",\"scene\":\"stable-descending\",\"order\":[%d,%d,%d,%d],\"lines\":%d}\n",
           fragsort[0], fragsort[1], fragsort[2], fragsort[3], scoreboardlines);
    printf("{\"function\":\"Sbar_ColorForMap\",\"scene\":\"palette-offset\",\"values\":[%d,%d,%d]}\n",
           Sbar_ColorForMap(0), Sbar_ColorForMap(112), Sbar_ColorForMap(240));
    Sbar_UpdateScoreboard();
    printf("{\"function\":\"Sbar_UpdateScoreboard\",\"scene\":\"text-and-colors\",\"first\":\"%s\",\"top\":%d,\"bottom\":%d}\n",
           &scoreboardtext[0][1], scoreboardtop[0], scoreboardbottom[0]);

    ResetOps(); cl.gametype = GAME_COOP; Sbar_SoloScoreboard();
    EmitOps("Sbar_SoloScoreboard", "stats-time-level");
    ResetOps(); cl.gametype = GAME_DEATHMATCH; Sbar_DrawScoreboard();
    EmitOps("Sbar_DrawScoreboard", "solo-plus-deathmatch");

    ResetClient(); hipnotic = rogue = false; ResetOps(); Sbar_DrawInventory();
    EmitOps("Sbar_DrawInventory", "base-inventory");
    hipnotic = true; cl.items |= HIT_LASER_CANNON | HIT_PROXIMITY_GUN | IT_GRENADE_LAUNCHER | HIT_WETSUIT; cl.item_gettime[HIT_LASER_CANNON_BIT] = 12.25; ResetOps(); Sbar_DrawInventory();
    EmitOps("Sbar_DrawInventory", "hipnotic-inventory");
    hipnotic = false; rogue = true; cl.items |= RIT_SHIELD; cl.stats[STAT_ACTIVEWEAPON] = RIT_MULTI_GRENADE; ResetOps(); Sbar_DrawInventory();
    EmitOps("Sbar_DrawInventory", "rogue-inventory");

    ResetClient(); hipnotic = rogue = false; ResetOps(); Sbar_DrawFrags();
    EmitOps("Sbar_DrawFrags", "top-four-colors-markers");

    ResetClient(); ResetOps(); cl.items = IT_INVISIBILITY | IT_INVULNERABILITY; Sbar_DrawFace();
    cl.items = 0; cl.stats[STAT_HEALTH] = 20; cl.faceanimtime = cl.time; Sbar_DrawFace();
    rogue = true; teamplay.value = 4; cl.gametype = GAME_DEATHMATCH; cl.scores[cl.viewentity - 1].colors = 0; Sbar_DrawFace();
    EmitOps("Sbar_DrawFace", "power-health-animation-team");

    ResetClient(); hipnotic = rogue = false; ResetOps(); Sbar_Draw();
    EmitOps("Sbar_Draw", "normal-wide-order");
    sb_showscores = true; sb_updates = 0; cl.gametype = GAME_DEATHMATCH; ResetOps(); Sbar_Draw();
    EmitOps("Sbar_Draw", "score-deathmatch-order");
    sb_showscores = false; sb_updates = 0; sb_lines = 0; cl.gametype = GAME_COOP; ResetOps(); Sbar_Draw();
    EmitOps("Sbar_Draw", "zero-lines-no-main-bar");
    sb_lines = 48;

    ResetOps(); Sbar_IntermissionNumber(10, 20, -1234, 3, 1);
    EmitOps("Sbar_IntermissionNumber", "absolute-crop-align");
    ResetClient(); cl.gametype = GAME_DEATHMATCH; ResetOps(); Sbar_DeathmatchOverlay();
    EmitOps("Sbar_DeathmatchOverlay", "ranked-scoreboard");
    ResetClient(); cl.gametype = GAME_DEATHMATCH; ResetOps(); Sbar_MiniDeathmatchOverlay();
    EmitOps("Sbar_MiniDeathmatchOverlay", "centered-player-window");
    ResetClient(); cl.gametype = GAME_COOP; ResetOps(); Sbar_IntermissionOverlay();
    EmitOps("Sbar_IntermissionOverlay", "completion-stats");
    ResetClient(); ResetOps(); Sbar_FinaleOverlay();
    EmitOps("Sbar_FinaleOverlay", "centered-finale");
    return 0;
}
