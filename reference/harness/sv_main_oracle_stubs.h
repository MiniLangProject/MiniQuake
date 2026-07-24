#ifndef MINIQUAKE_SV_MAIN_ORACLE_STUBS_H
#define MINIQUAKE_SV_MAIN_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
typedef float vec_t;
typedef vec_t vec3_t[3];
typedef struct edict_s edict_t;

typedef struct {
    qboolean allowoverflow;
    qboolean overflowed;
    byte *data;
    int maxsize;
    int cursize;
} sizebuf_t;

typedef struct {
    vec3_t normal;
    float dist;
    unsigned char type;
    unsigned char signbits;
    unsigned char pad[2];
} mplane_t;

typedef struct mnode_s {
    int contents;
    mplane_t *plane;
    struct mnode_s *children[2];
} mnode_t;

typedef struct mleaf_s {
    int contents;
    mplane_t *plane;
    mnode_t *children[2];
    byte *compressed_vis;
} mleaf_t;

typedef struct model_s {
    char *name;
    int numleafs;
    int numsubmodels;
    mnode_t *nodes;
    char *entities;
} model_t;

typedef struct {
    vec3_t origin;
    vec3_t angles;
    int modelindex;
    int frame;
    int colormap;
    int skin;
    int effects;
} entity_state_t;

typedef struct {
    vec3_t origin;
    vec3_t angles;
    vec3_t mins;
    vec3_t maxs;
    vec3_t view_ofs;
    vec3_t punchangle;
    vec3_t velocity;
    float movetype;
    float solid;
    float modelindex;
    int model;
    float frame;
    float colormap;
    float skin;
    float effects;
    float sounds;
    int message;
    float frags;
    float dmg_take;
    float dmg_save;
    int dmg_inflictor;
    float fixangle;
    float idealpitch;
    float items;
    float flags;
    float waterlevel;
    float weaponframe;
    float armorvalue;
    int weaponmodel;
    float health;
    float currentammo;
    float ammo_shells;
    float ammo_nails;
    float ammo_rockets;
    float ammo_cells;
    float weapon;
} entvars_t;

struct edict_s {
    qboolean free;
    int num_leafs;
    short leafnums[16];
    entity_state_t baseline;
    entvars_t v;
};

typedef struct netadr_s {
    int unused;
} netadr_t;

typedef struct qsocket_s {
    char address[64];
    netadr_t addr;
} qsocket_t;

typedef struct client_s {
    qboolean active;
    qboolean spawned;
    qboolean dropasap;
    qboolean sendsignon;
    qboolean privileged;
    char name[32];
    qsocket_t *netconnection;
    edict_t *edict;
    sizebuf_t message;
    byte msgbuf[8192];
    int old_frags;
    double last_message;
    float spawn_parms[16];
} client_t;

typedef struct {
    qboolean active;
    qboolean paused;
    qboolean loadgame;
    int state;
    float time;
    int num_edicts;
    int max_edicts;
    edict_t *edicts;
    sizebuf_t datagram;
    byte datagram_buf[1024];
    sizebuf_t reliable_datagram;
    byte reliable_datagram_buf[1024];
    sizebuf_t signon;
    byte signon_buf[8192];
    char *model_precache[256];
    char *sound_precache[256];
    model_t *models[256];
    model_t *worldmodel;
    char name[64];
    char modelname[128];
} server_t;

typedef struct {
    int maxclients;
    client_t *clients;
    int serverflags;
    qboolean changelevel_issued;
} server_static_t;

typedef struct {
    float serverflags;
    int SetNewParms;
    int SetChangeParms;
    int self;
    float parm1;
    float parm2;
    float parm3;
    float parm4;
    float parm5;
    float parm6;
    float parm7;
    float parm8;
    float parm9;
    float parm10;
    float parm11;
    float parm12;
    float parm13;
    float parm14;
    float parm15;
    float parm16;
    float coop;
    float deathmatch;
    int mapname;
} globalvars_t;

typedef struct {
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    void *next;
} cvar_t;

typedef union {
    float _float;
    int _int;
    vec3_t vector;
} eval_t;

typedef struct {
    int state;
} client_static_t;

typedef struct {
    int entityfields;
} dprograms_t;

extern server_t sv;
extern server_static_t svs;
extern client_t *host_client;
extern globalvars_t *pr_global_struct;
extern client_static_t cls;
extern char pr_strings[4096];
extern int pr_crc;
extern int net_activeconnections;
extern double realtime;
extern int standard_quake;
extern int current_skill;
extern int pr_edict_size;
extern dprograms_t *progs;
extern float host_frametime;
extern float scr_centertime_off;
extern cvar_t coop;
extern cvar_t deathmatch;
extern cvar_t skill;
extern cvar_t hostname;
extern cvar_t sv_maxvelocity;
extern cvar_t sv_gravity;
extern cvar_t sv_nostep;
extern cvar_t sv_friction;
extern cvar_t sv_edgefriction;
extern cvar_t sv_stopspeed;
extern cvar_t sv_maxspeed;
extern cvar_t sv_accelerate;
extern cvar_t sv_idealpitchscale;
extern cvar_t sv_aim;

#define false 0
#define true 1
#define NULL ((void *)0)
#define MAX_MODELS 256
#define MAX_SOUNDS 256
#define MAX_DATAGRAM 1024
#define MAX_MAP_LEAFS 8192
#define MAX_EDICTS 600
#define NUM_SPAWN_PARMS 16
#define NET_MAXMESSAGE 8192
#define VERSION 1.09
#define PROTOCOL_VERSION 15
#define GAME_COOP 0
#define GAME_DEATHMATCH 1
#define DEFAULT_SOUND_PACKET_VOLUME 255
#define DEFAULT_SOUND_PACKET_ATTENUATION 1.0
#define DEFAULT_VIEWHEIGHT 22
#define SND_VOLUME 1
#define SND_ATTENUATION 2
#define CONTENTS_SOLID -2
#define MOVETYPE_STEP 4
#define MOVETYPE_PUSH 7
#define SOLID_BSP 4
#define FL_ONGROUND 512
#define EF_MUZZLEFLASH 2
#define U_MOREBITS 1
#define U_ORIGIN1 2
#define U_ORIGIN2 4
#define U_ORIGIN3 8
#define U_ANGLE2 16
#define U_NOLERP 32
#define U_FRAME 64
#define U_SIGNAL 128
#define U_ANGLE1 256
#define U_ANGLE3 512
#define U_MODEL 1024
#define U_COLORMAP 2048
#define U_SKIN 4096
#define U_EFFECTS 8192
#define U_LONGENTITY 16384
#define SU_VIEWHEIGHT 1
#define SU_IDEALPITCH 2
#define SU_PUNCH1 4
#define SU_VELOCITY1 32
#define SU_ITEMS 512
#define SU_ONGROUND 1024
#define SU_INWATER 2048
#define SU_WEAPONFRAME 4096
#define SU_ARMOR 8192
#define SU_WEAPON 16384
#define svc_nop 1
#define svc_sound 6
#define svc_time 7
#define svc_print 8
#define svc_stufftext 9
#define svc_setangle 10
#define svc_serverinfo 11
#define svc_updatefrags 14
#define svc_clientdata 15
#define svc_particle 18
#define svc_damage 19
#define svc_spawnbaseline 22
#define svc_signonnum 25
#define svc_cdtrack 32
#define svc_setview 5
#define ss_loading 1
#define ss_active 2
#define ca_dedicated 2
#define src_command 1

#define NUM_FOR_EDICT(value) ((int)((value) - sv.edicts))
#define EDICT_NUM(value) (&sv.edicts[(int)(value)])
#define NEXT_EDICT(value) ((value) + 1)
#define EDICT_TO_PROG(value) ((int)((value) - sv.edicts))
#define PROG_TO_EDICT(value) (&sv.edicts[(int)(value)])
#define DotProduct(a,b) \
    ((a)[0]*(b)[0] + (a)[1]*(b)[1] + (a)[2]*(b)[2])
#define VectorCopy(a,out) \
    ((out)[0]=(a)[0], (out)[1]=(a)[1], (out)[2]=(a)[2])
#define VectorAdd(a,b,out) \
    ((out)[0]=(a)[0]+(b)[0], (out)[1]=(a)[1]+(b)[1], \
     (out)[2]=(a)[2]+(b)[2])
#define Q_memset memset

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
int mq_strcmp(const char *, const char *);
#define strcmp mq_strcmp
__declspec(dllimport) char * __cdecl strcpy(char *, const char *);
__declspec(dllimport) void * __cdecl memcpy(
    void *, const void *, unsigned __int64);
__declspec(dllimport) void * __cdecl memset(
    void *, int, unsigned __int64);

void Cvar_RegisterVariable(cvar_t *variable);
void Cvar_Set(char *name, char *value);
void Cvar_SetValue(char *name, float value);
void Sys_Error(char *format, ...);
void Con_Printf(char *format, ...);
void Con_DPrintf(char *format, ...);
void SZ_Clear(sizebuf_t *buffer);
void SZ_Write(sizebuf_t *buffer, void *data, int length);
void MSG_WriteByte(sizebuf_t *buffer, int value);
void MSG_WriteChar(sizebuf_t *buffer, int value);
void MSG_WriteShort(sizebuf_t *buffer, int value);
void MSG_WriteLong(sizebuf_t *buffer, int value);
void MSG_WriteFloat(sizebuf_t *buffer, float value);
void MSG_WriteCoord(sizebuf_t *buffer, float value);
void MSG_WriteAngle(sizebuf_t *buffer, float value);
void MSG_WriteString(sizebuf_t *buffer, char *value);
void PR_ExecuteProgram(int function_index);
qsocket_t *NET_CheckNewConnections(void);
int NET_SendUnreliableMessage(qsocket_t *socket, sizebuf_t *message);
int NET_SendMessage(qsocket_t *socket, sizebuf_t *message);
qboolean NET_CanSendMessage(qsocket_t *socket);
int NET_SendToAll(sizebuf_t *message, double blocktime);
byte *Mod_LeafPVS(mleaf_t *leaf, model_t *model);
void SV_SetIdealPitch(void);
eval_t *GetEdictFieldValue(edict_t *entity, char *field_name);
void SV_DropClient(qboolean crash);
void Cmd_ExecuteString(char *text, int source);
void SV_ClearWorld(void);
void SV_Physics(void);
void ED_LoadFromFile(char *data);
void PR_LoadProgs(void);
void Host_ClearMemory(void);
void *Hunk_AllocName(int size, char *name);
model_t *Mod_ForName(char *name, qboolean crash);

#endif
