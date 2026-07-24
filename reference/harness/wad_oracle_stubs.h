#ifndef MINIQUAKE_WAD_ORACLE_STUBS_H
#define MINIQUAKE_WAD_ORACLE_STUBS_H

typedef unsigned char byte;

typedef struct
{
    int width;
    int height;
    byte data[4];
} qpic_t;

typedef struct
{
    int filepos;
    int disksize;
    int size;
    char type;
    char compression;
    char pad1;
    char pad2;
    char name[16];
} lumpinfo_t;

typedef struct
{
    char identification[4];
    int numlumps;
    int infotableofs;
} wadinfo_t;

#ifndef NULL
#define NULL ((void *)0)
#endif

#define TYP_QPIC 66
#define LittleLong(value) (value)

byte *COM_LoadHunkFile(char *filename);
void Sys_Error(char *error, ...);
int mq_strcmp(const char *first, const char *second);
#define strcmp mq_strcmp

#endif
