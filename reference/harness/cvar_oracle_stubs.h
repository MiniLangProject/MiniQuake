#ifndef MINIQUAKE_CVAR_ORACLE_STUBS_H
#define MINIQUAKE_CVAR_ORACLE_STUBS_H

typedef int qboolean;
#define false 0
#define true 1
#ifndef NULL
#define NULL ((void *)0)
#endif

typedef struct cvar_s
{
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    struct cvar_s *next;
} cvar_t;

typedef struct
{
    qboolean active;
} server_t;

typedef struct mq_file_s
{
    int unused;
} FILE;

extern server_t sv;

int Q_strcmp(const char *first, const char *second);
int Q_strncmp(const char *first, const char *second, int count);
int Q_strlen(const char *text);
void Q_strcpy(char *destination, const char *source);
float Q_atof(const char *text);
void *Z_Malloc(int size);
void Z_Free(void *memory);
qboolean Cmd_Exists(char *name);
int Cmd_Argc(void);
char *Cmd_Argv(int index);
void Con_Printf(char *format, ...);
void SV_BroadcastPrintf(char *format, ...);
int sprintf(char *buffer, const char *format, ...);
int mq_fprintf(FILE *file, const char *format, char *name, char *value);
#define fprintf mq_fprintf

cvar_t *Cvar_FindVar(char *var_name);
float Cvar_VariableValue(char *var_name);
char *Cvar_VariableString(char *var_name);
char *Cvar_CompleteVariable(char *partial);
void Cvar_Set(char *var_name, char *value);
void Cvar_SetValue(char *var_name, float value);
void Cvar_RegisterVariable(cvar_t *variable);
qboolean Cvar_Command(void);
void Cvar_WriteVariables(FILE *file);

#endif
