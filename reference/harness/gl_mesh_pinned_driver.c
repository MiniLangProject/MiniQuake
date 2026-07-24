#include "gl_mesh_oracle_stubs.h"

extern int commands[8192];
extern int numcommands;
extern int vertexorder[8192];
extern int numorder;
extern int stripverts[128];
extern int striptris[128];
extern int stripcount;
extern int allverts;
extern int alltris;

int _fltused = 0;
aliashdr_t header_state;
aliashdr_t *pheader = &header_state;
stvert_t stverts[MAXALIASVERTS];
mtriangle_t triangles[MAXALIASTRIS];
trivertx_t *poseverts[MAXALIASFRAMES];
char com_gamedir[MAX_OSPATH] = "Z:/miniquake-does-not-exist";

static model_t model_state;
static trivertx_t pose_state[16];
static byte hunk_storage[65536];
static int hunk_used;

void __chkstk(void)
{
}

FILE *fopen(const char *path, const char *mode)
{
    (void)path;
    (void)mode;
    return NULL;
}

int fclose(FILE *file)
{
    (void)file;
    return 0;
}

size_t fread(void *buffer, size_t size, size_t count, FILE *file)
{
    (void)buffer;
    (void)size;
    (void)count;
    (void)file;
    return 0;
}

size_t fwrite(const void *buffer, size_t size, size_t count, FILE *file)
{
    (void)buffer;
    (void)size;
    (void)file;
    return count;
}

void Con_DPrintf(char *format, ...)
{
    (void)format;
}

void Con_Printf(char *format, ...)
{
    (void)format;
}

void COM_StripExtension(char *input, char *output)
{
    char *dot = NULL;
    while (*input)
    {
        if (*input == '.')
            dot = output;
        *output++ = *input++;
    }
    if (dot != NULL)
        output = dot;
    *output = 0;
}

int COM_FOpenFile(char *path, FILE **file)
{
    (void)path;
    *file = NULL;
    return -1;
}

void *Hunk_Alloc(int size)
{
    void *result;
    int index;
    size = (size + 15) & ~15;
    result = &hunk_storage[hunk_used];
    for (index = 0; index < size; index++)
        hunk_storage[hunk_used + index] = 0;
    hunk_used += size;
    return result;
}

static void clear_fixture(void)
{
    int index;
    byte *header_bytes = (byte *)&header_state;
    byte *model_bytes = (byte *)&model_state;
    for (index = 0; index < (int)sizeof(header_state); index++)
        header_bytes[index] = 0;
    for (index = 0; index < (int)sizeof(model_state); index++)
        model_bytes[index] = 0;
    for (index = 0; index < MAXALIASTRIS; index++)
    {
        triangles[index].facesfront = 0;
        triangles[index].vertindex[0] = 0;
        triangles[index].vertindex[1] = 0;
        triangles[index].vertindex[2] = 0;
    }
    for (index = 0; index < MAXALIASVERTS; index++)
    {
        stverts[index].onseam = 0;
        stverts[index].s = 0;
        stverts[index].t = 0;
    }
    for (index = 0; index < MAXALIASFRAMES; index++)
        poseverts[index] = NULL;
    header_state.skinwidth = 64;
    header_state.skinheight = 32;
    header_state.numverts = 6;
    header_state.numposes = 1;
    poseverts[0] = pose_state;
    for (index = 0; index < 6; index++)
    {
        stverts[index].onseam = index & 1;
        stverts[index].s = index * 5;
        stverts[index].t = index * 3;
        pose_state[index].v[0] = (byte)(index + 1);
        pose_state[index].v[1] = (byte)(index + 11);
        pose_state[index].v[2] = (byte)(index + 21);
        pose_state[index].lightnormalindex = (byte)(index + 31);
    }
    strcpy(model_state.name, "progs/fixture.mdl");
    hunk_used = 0;
    pheader = &header_state;
}

void mesh_setup_strip(void)
{
    clear_fixture();
    header_state.numtris = 4;
    triangles[0].vertindex[0] = 0;
    triangles[0].vertindex[1] = 1;
    triangles[0].vertindex[2] = 2;
    triangles[1].vertindex[0] = 2;
    triangles[1].vertindex[1] = 1;
    triangles[1].vertindex[2] = 3;
    triangles[2].vertindex[0] = 2;
    triangles[2].vertindex[1] = 3;
    triangles[2].vertindex[2] = 4;
    triangles[3].vertindex[0] = 4;
    triangles[3].vertindex[1] = 3;
    triangles[3].vertindex[2] = 5;
}

void mesh_setup_fan(void)
{
    clear_fixture();
    header_state.numtris = 3;
    triangles[0].vertindex[0] = 0;
    triangles[0].vertindex[1] = 1;
    triangles[0].vertindex[2] = 2;
    triangles[1].vertindex[0] = 0;
    triangles[1].vertindex[1] = 2;
    triangles[1].vertindex[2] = 3;
    triangles[2].vertindex[0] = 0;
    triangles[2].vertindex[1] = 3;
    triangles[2].vertindex[2] = 4;
}

void mesh_make_display_lists(void)
{
    GL_MakeAliasModelDisplayLists(&model_state, &header_state);
}

int mesh_strip_vertex(int index)
{
    return stripverts[index];
}

int mesh_strip_triangle(int index)
{
    return striptris[index];
}

int mesh_num_commands(void)
{
    return numcommands;
}

int mesh_num_order(void)
{
    return numorder;
}

int mesh_command_int(int index)
{
    return commands[index];
}

float mesh_command_float(int index)
{
    return *(float *)&commands[index];
}

int mesh_order(int index)
{
    return vertexorder[index];
}

int mesh_header_poseverts(void)
{
    return header_state.poseverts;
}

int mesh_header_commands_nonzero(void)
{
    return header_state.commands != 0;
}

int mesh_header_posedata_nonzero(void)
{
    return header_state.posedata != 0;
}
