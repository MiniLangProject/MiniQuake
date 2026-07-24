#ifndef MINIQUAKE_PR_EDICT_ORACLE_STUBS_H
#define MINIQUAKE_PR_EDICT_ORACLE_STUBS_H
typedef unsigned char byte;
typedef int qboolean;
typedef int string_t;
typedef int func_t;
typedef int etype_t;
typedef float vec3_t[3];
typedef struct mq_file_s FILE;

typedef struct {
    int version, crc;
    int ofs_statements, numstatements;
    int ofs_globaldefs, numglobaldefs;
    int ofs_fielddefs, numfielddefs;
    int ofs_functions, numfunctions;
    int ofs_strings, numstrings;
    int ofs_globals, numglobals;
    int entityfields;
} dprograms_t;
typedef struct { unsigned short type, ofs; int s_name; } ddef_t;
typedef struct { unsigned short op; short a,b,c; } dstatement_t;
typedef struct {
    int first_statement, parm_start, locals, profile;
    int s_name, s_file, numparms;
    byte parm_size[8];
} dfunction_t;
typedef union {
    int _int, string, function, edict;
    float _float;
    vec3_t vector;
} eval_t;
typedef struct {
    int model;
    float takedamage, modelindex, colormap, skin, frame;
    vec3_t origin, angles;
    float nextthink, solid, movetype, spawnflags;
    int classname;
    float health;
} entvars_t;
typedef struct edict_s {
    qboolean free;
    float freetime;
    entvars_t v;
} edict_t;
typedef struct {
    edict_t *edicts;
    int num_edicts, max_edicts;
    float time;
} server_t;
typedef struct { int maxclients; } server_static_t;
typedef struct { float time; int self; } globalvars_t;
typedef struct {
    char *name,*string;
    qboolean archive,server;
    float value;
    void *next;
} cvar_t;
struct mq_file_s { int calls; };

extern server_t sv;
extern server_static_t svs;
extern vec3_t vec3_origin;
extern cvar_t deathmatch;
extern int current_skill;
extern char com_token[1024];
extern int com_filesize;

#define false 0
#define true 1
#define NULL ((void *)0)
#define MAX_EDICTS 600
#define MOVETYPE_STEP 4
#define PROG_VERSION 6
#define PROGHEADER_CRC 5927
#define DEF_SAVEGLOBAL 0x8000
#define ev_void 0
#define ev_string 1
#define ev_float 2
#define ev_vector 3
#define ev_entity 4
#define ev_field 5
#define ev_function 6
#define ev_pointer 7
#define SPAWNFLAG_NOT_EASY 256
#define SPAWNFLAG_NOT_MEDIUM 512
#define SPAWNFLAG_NOT_HARD 1024
#define SPAWNFLAG_NOT_DEATHMATCH 2048
#define EDICT_TO_PROG(value) ((int)((byte *)(value)-(byte *)sv.edicts))
#define PROG_TO_EDICT(value) ((edict_t *)((byte *)sv.edicts+(int)(value)))
#define G_INT(value) (((int *)pr_globals)[(value)])
#define VectorCopy(a,b) ((b)[0]=(a)[0],(b)[1]=(a)[1],(b)[2]=(a)[2])

extern dprograms_t *progs;
extern dfunction_t *pr_functions;
extern char *pr_strings;
extern ddef_t *pr_fielddefs,*pr_globaldefs;
extern dstatement_t *pr_statements;
extern globalvars_t *pr_global_struct;
extern float *pr_globals;
extern int pr_edict_size;
extern unsigned short pr_crc;

__declspec(dllimport) int __cdecl sprintf(char *,const char *,...);
__declspec(dllimport) void * __cdecl memset(void *,int,unsigned __int64);
int mq_strlen(const char *);
int mq_strcmp(const char *,const char *);
char *mq_strcpy(char *,const char *);
char *mq_strcat(char *,const char *);
float mq_atof(const char *);
int mq_atoi(const char *);
#define strlen mq_strlen
#define strcmp mq_strcmp
#define strcpy mq_strcpy
#define strcat mq_strcat
#define atof mq_atof
#define atoi mq_atoi
int mq_fprintf(FILE *,char *,...);
#define fprintf mq_fprintf

void Sys_Error(char *,...);
void Host_Error(char *,...);
void Con_Printf(char *,...);
void Con_DPrintf(char *,...);
void SV_UnlinkEdict(edict_t *);
char *COM_Parse(char *);
void *Hunk_Alloc(int);
void *COM_LoadHunkFile(char *);
void CRC_Init(unsigned short *);
void CRC_ProcessByte(unsigned short *,byte);
int LittleLong(int);
short LittleShort(short);
int Q_atoi(char *);
char *Cmd_Argv(int);
void Cmd_AddCommand(char *,void (*)(void));
void Cvar_RegisterVariable(cvar_t *);
void PR_Profile_f(void);
void PR_ExecuteProgram(func_t);

edict_t *EDICT_NUM(int);
int NUM_FOR_EDICT(edict_t *);
#endif
