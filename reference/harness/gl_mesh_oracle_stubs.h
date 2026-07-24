#ifndef MINIQUAKE_GL_MESH_ORACLE_STUBS_H
#define MINIQUAKE_GL_MESH_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
typedef unsigned __int64 size_t;
typedef struct _iobuf FILE;

#ifndef NULL
#define NULL ((void *)0)
#endif

#define MAX_QPATH 64
#define MAX_OSPATH 128
#define MAXALIASVERTS 1024
#define MAXALIASFRAMES 256
#define MAXALIASTRIS 2048

typedef struct
{
    int onseam;
    int s;
    int t;
} stvert_t;

typedef struct mtriangle_s
{
    int facesfront;
    int vertindex[3];
} mtriangle_t;

typedef struct
{
    byte v[3];
    byte lightnormalindex;
} trivertx_t;

typedef struct
{
    int unused;
} maliasgroup_t;

typedef struct
{
    int ident;
    int version;
    float scale[3];
    float scale_origin[3];
    float boundingradius;
    float eyeposition[3];
    int numskins;
    int skinwidth;
    int skinheight;
    int numverts;
    int numtris;
    int numframes;
    int synctype;
    int flags;
    float size;
    int numposes;
    int poseverts;
    int posedata;
    int commands;
} aliashdr_t;

typedef struct model_s
{
    char name[MAX_QPATH];
} model_t;

void *memset(void *destination, int value, size_t count);
void *memcpy(void *destination, const void *source, size_t count);
size_t strlen(const char *text);
char *strcpy(char *destination, const char *source);
char *strcat(char *destination, const char *source);
int sprintf(char *buffer, const char *format, ...);
FILE *fopen(const char *path, const char *mode);
int fclose(FILE *file);
size_t fread(void *buffer, size_t size, size_t count, FILE *file);
size_t fwrite(const void *buffer, size_t size, size_t count, FILE *file);

extern aliashdr_t *pheader;
extern stvert_t stverts[MAXALIASVERTS];
extern mtriangle_t triangles[MAXALIASTRIS];
extern trivertx_t *poseverts[MAXALIASFRAMES];
extern char com_gamedir[MAX_OSPATH];

void Con_DPrintf(char *format, ...);
void Con_Printf(char *format, ...);
void COM_StripExtension(char *input, char *output);
int COM_FOpenFile(char *path, FILE **file);
void *Hunk_Alloc(int size);

int StripLength(int starttri, int startv);
int FanLength(int starttri, int startv);
void BuildTris(void);
void GL_MakeAliasModelDisplayLists(model_t *model, aliashdr_t *header);

#endif
