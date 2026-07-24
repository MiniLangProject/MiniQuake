#ifndef MINIQUAKE_PR_EXEC_ORACLE_STUBS_H
#define MINIQUAKE_PR_EXEC_ORACLE_STUBS_H
typedef unsigned char byte;
typedef int qboolean;
typedef int func_t;
typedef float vec3_t[3];
typedef char *va_list;
#define va_start(value,last) ((value)=(char *)0)
#define va_end(value) ((void)(value))

typedef struct {
    unsigned short op;
    short a;
    short b;
    short c;
} dstatement_t;
typedef struct {
    int first_statement;
    int parm_start;
    int locals;
    int profile;
    int s_name;
    int s_file;
    int numparms;
    byte parm_size[8];
} dfunction_t;
typedef struct {
    int numfunctions;
} dprograms_t;
typedef union {
    int _int;
    float _float;
    int string;
    int function;
    int edict;
    vec3_t vector;
} eval_t;
typedef struct {
    float nextthink;
    float frame;
    int think;
} entvars_t;
typedef struct edict_s {
    entvars_t v;
} edict_t;
typedef struct {
    edict_t *edicts;
    int state;
} server_t;
typedef struct {
    int self;
    float time;
} globalvars_t;

extern dprograms_t *progs;
extern dfunction_t *pr_functions;
extern dstatement_t *pr_statements;
extern float *pr_globals;
extern char *pr_strings;
extern globalvars_t *pr_global_struct;
extern server_t sv;
extern void (*pr_builtins[])(void);
extern int pr_numbuiltins;

#define false 0
#define true 1
#define NULL ((void *)0)
#define ss_active 2
#define OFS_RETURN 1
#define OFS_PARM0 4
#define OP_DONE 0
#define OP_MUL_F 1
#define OP_MUL_V 2
#define OP_MUL_FV 3
#define OP_MUL_VF 4
#define OP_DIV_F 5
#define OP_ADD_F 6
#define OP_ADD_V 7
#define OP_SUB_F 8
#define OP_SUB_V 9
#define OP_EQ_F 10
#define OP_EQ_V 11
#define OP_EQ_S 12
#define OP_EQ_E 13
#define OP_EQ_FNC 14
#define OP_NE_F 15
#define OP_NE_V 16
#define OP_NE_S 17
#define OP_NE_E 18
#define OP_NE_FNC 19
#define OP_LE 20
#define OP_GE 21
#define OP_LT 22
#define OP_GT 23
#define OP_LOAD_F 24
#define OP_LOAD_V 25
#define OP_LOAD_S 26
#define OP_LOAD_ENT 27
#define OP_LOAD_FLD 28
#define OP_LOAD_FNC 29
#define OP_ADDRESS 30
#define OP_STORE_F 31
#define OP_STORE_V 32
#define OP_STORE_S 33
#define OP_STORE_ENT 34
#define OP_STORE_FLD 35
#define OP_STORE_FNC 36
#define OP_STOREP_F 37
#define OP_STOREP_V 38
#define OP_STOREP_S 39
#define OP_STOREP_ENT 40
#define OP_STOREP_FLD 41
#define OP_STOREP_FNC 42
#define OP_RETURN 43
#define OP_NOT_F 44
#define OP_NOT_V 45
#define OP_NOT_S 46
#define OP_NOT_ENT 47
#define OP_NOT_FNC 48
#define OP_IF 49
#define OP_IFNOT 50
#define OP_CALL0 51
#define OP_CALL1 52
#define OP_CALL2 53
#define OP_CALL3 54
#define OP_CALL4 55
#define OP_CALL5 56
#define OP_CALL6 57
#define OP_CALL7 58
#define OP_CALL8 59
#define OP_STATE 60
#define OP_GOTO 61
#define OP_AND 62
#define OP_OR 63
#define OP_BITAND 64
#define OP_BITOR 65
#define PROG_TO_EDICT(value) (&sv.edicts[(int)(value)])

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
__declspec(dllimport) void * __cdecl memset(void *, int, unsigned __int64);
int mq_strlen(const char *);
int mq_strcmp(const char *, const char *);
int mq_vsprintf(char *, const char *, va_list);
#define strlen mq_strlen
#define strcmp mq_strcmp
#define vsprintf mq_vsprintf
void Con_Printf(char *format, ...);
void Host_Error(char *format, ...);
void Sys_Error(char *format, ...);
void ED_Print(edict_t *entity);
char *PR_GlobalString(int offset);
char *PR_GlobalStringNoContents(int offset);

#endif
