/*
 * Synthetic, redistributable execution harness for the unchanged pinned
 * WinQuake/gl_model.c.  No Quake game data is embedded here.
 */
#include "quakedef.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern model_t *loadmodel;
extern char loadname[32];
extern byte mod_novis[MAX_MAP_LEAFS / 8];
extern model_t mod_known[512];
extern int mod_numknown;
extern byte *mod_base;
extern aliashdr_t *pheader;
extern int posenum;

void Mod_Init(void);
void *Mod_Extradata(model_t *mod);
mleaf_t *Mod_PointInLeaf(vec3_t point, model_t *model);
byte *Mod_DecompressVis(byte *input, model_t *model);
byte *Mod_LeafPVS(mleaf_t *leaf, model_t *model);
void Mod_ClearAll(void);
model_t *Mod_FindName(char *name);
void Mod_TouchModel(char *name);
model_t *Mod_LoadModel(model_t *mod, qboolean crash);
model_t *Mod_ForName(char *name, qboolean crash);
void Mod_LoadTextures(lump_t *l);
void Mod_LoadLighting(lump_t *l);
void Mod_LoadVisibility(lump_t *l);
void Mod_LoadEntities(lump_t *l);
void Mod_LoadVertexes(lump_t *l);
void Mod_LoadSubmodels(lump_t *l);
void Mod_LoadEdges(lump_t *l);
void Mod_LoadTexinfo(lump_t *l);
void CalcSurfaceExtents(msurface_t *surface);
void Mod_LoadFaces(lump_t *l);
void Mod_SetParent(mnode_t *node, mnode_t *parent);
void Mod_LoadNodes(lump_t *l);
void Mod_LoadLeafs(lump_t *l);
void Mod_LoadClipnodes(lump_t *l);
void Mod_MakeHull0(void);
void Mod_LoadMarksurfaces(lump_t *l);
void Mod_LoadSurfedges(lump_t *l);
void Mod_LoadPlanes(lump_t *l);
float RadiusFromBounds(vec3_t mins, vec3_t maxs);
void Mod_LoadBrushModel(model_t *mod, void *buffer);
void *Mod_LoadAliasFrame(void *pin, maliasframedesc_t *frame);
void *Mod_LoadAliasGroup(void *pin, maliasframedesc_t *frame);
void Mod_FloodFillSkin(byte *skin, int skinwidth, int skinheight);
void *Mod_LoadAllSkins(int numskins, daliasskintype_t *pskintype);
void Mod_LoadAliasModel(model_t *mod, void *buffer);
void *Mod_LoadSpriteFrame(void *pin, mspriteframe_t **frame, int framenum);
void *Mod_LoadSpriteGroup(void *pin, mspriteframe_t **frame, int framenum);
void Mod_LoadSpriteModel(model_t *mod, void *buffer);
void Mod_Print(void);
void GL_SubdivideSurface(msurface_t *surface);
void GL_MakeAliasModelDisplayLists(model_t *model, aliashdr_t *header);

qboolean bigendien = false;

static short IdentityShort(short value) { return value; }
static int IdentityLong(int value) { return value; }
static float IdentityFloat(float value) { return value; }

short (*BigShort)(short value) = IdentityShort;
short (*LittleShort)(short value) = IdentityShort;
int (*BigLong)(int value) = IdentityLong;
int (*LittleLong)(int value) = IdentityLong;
float (*BigFloat)(float value) = IdentityFloat;
float (*LittleFloat)(float value) = IdentityFloat;

static byte hunk_memory[16 * 1024 * 1024];
static int hunk_used;
static int cvar_registers;
static int texture_uploads;
static int cache_checks;
static int console_prints;
static int next_texture = 100;
static byte bsp_file[8192];
static int bsp_size;
static byte mdl_file[2048];
static int mdl_size;
static byte spr_file[1024];
static int spr_size;
static byte load_copy[8192];
static texture_t fallback_texture;

unsigned d_8to24table[256];
int texture_mode = GL_LINEAR;
texture_t *r_notexture_mip = &fallback_texture;

vec_t Length(vec3_t value)
{
    return (vec_t)sqrt(
        value[0] * value[0] +
        value[1] * value[1] +
        value[2] * value[2]);
}

void Q_memset(void *dest, int fill, int count) { memset(dest, fill, (size_t)count); }
void Q_memcpy(void *dest, void *src, int count) { memcpy(dest, src, (size_t)count); }
int Q_memcmp(void *left, void *right, int count) { return memcmp(left, right, (size_t)count); }
void Q_strcpy(char *dest, char *src) { strcpy(dest, src); }
void Q_strncpy(char *dest, char *src, int count) { strncpy(dest, src, (size_t)count); }
int Q_strlen(char *text) { return (int)strlen(text); }
char *Q_strrchr(char *text, char value) { return strrchr(text, value); }
void Q_strcat(char *dest, char *src) { strcat(dest, src); }
int Q_strcmp(char *left, char *right) { return strcmp(left, right); }
int Q_strncmp(char *left, char *right, int count) { return strncmp(left, right, (size_t)count); }
int Q_strcasecmp(char *left, char *right) { return _stricmp(left, right); }
int Q_strncasecmp(char *left, char *right, int count) { return _strnicmp(left, right, (size_t)count); }

void Sys_Error(char *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    vfprintf(stderr, format, arguments);
    fputc('\n', stderr);
    va_end(arguments);
    fflush(stderr);
    exit(86);
}

void Con_Printf(char *format, ...)
{
    (void)format;
    console_prints++;
}

void Cvar_RegisterVariable(cvar_t *variable)
{
    (void)variable;
    cvar_registers++;
}

void *Hunk_AllocName(int size, char *name)
{
    int aligned = (size + 15) & ~15;
    void *result;
    (void)name;
    if (size < 0 || hunk_used + aligned > (int)sizeof(hunk_memory))
        Sys_Error("fixture hunk overflow");
    result = hunk_memory + hunk_used;
    memset(result, 0, (size_t)aligned);
    hunk_used += aligned;
    return result;
}

int Hunk_LowMark(void) { return hunk_used; }

void Hunk_FreeToLowMark(int mark)
{
    if (mark < 0 || mark > hunk_used)
        Sys_Error("fixture bad hunk mark");
    hunk_used = mark;
}

void *Cache_Check(cache_user_t *cache)
{
    cache_checks++;
    return cache->data;
}

void *Cache_Alloc(cache_user_t *cache, int size, char *name)
{
    (void)name;
    cache->data = malloc((size_t)size);
    if (cache->data)
        memset(cache->data, 0, (size_t)size);
    return cache->data;
}

void COM_FileBase(char *path, char *dest)
{
    char *start = path;
    char *end = path + strlen(path);
    char *scan;
    for (scan = path; *scan; ++scan)
        if (*scan == '/' || *scan == '\\')
            start = scan + 1;
    for (scan = start; *scan; ++scan)
        if (*scan == '.')
            end = scan;
    if (end <= start)
    {
        strcpy(dest, "?model?");
        return;
    }
    memcpy(dest, start, (size_t)(end - start));
    dest[end - start] = 0;
}

byte *COM_LoadStackFile(char *path, void *buffer, int buffer_size)
{
    byte *source = NULL;
    int size = 0;
    if (!strcmp(path, "maps/fixture.bsp"))
    {
        source = bsp_file;
        size = bsp_size;
    }
    else if (!strcmp(path, "progs/fixture.mdl"))
    {
        source = mdl_file;
        size = mdl_size;
    }
    else if (!strcmp(path, "progs/fixture.spr"))
    {
        source = spr_file;
        size = spr_size;
    }
    if (!source)
        return NULL;
    if (size <= buffer_size)
    {
        memcpy(buffer, source, (size_t)size);
        return (byte *)buffer;
    }
    memcpy(load_copy, source, (size_t)size);
    return load_copy;
}

int GL_LoadTexture(char *identifier, int width, int height, byte *data, qboolean mipmap, qboolean alpha)
{
    (void)identifier;
    (void)width;
    (void)height;
    (void)data;
    (void)mipmap;
    (void)alpha;
    texture_uploads++;
    return next_texture++;
}

void R_InitSky(texture_t *texture) { (void)texture; }
void GL_SubdivideSurface(msurface_t *surface) { (void)surface; }
void GL_MakeAliasModelDisplayLists(model_t *model, aliashdr_t *header)
{
    (void)model;
    header->poseverts = header->numverts;
}

static int Append(byte *destination, int cursor, const void *source, int size)
{
    memcpy(destination + cursor, source, (size_t)size);
    return cursor + size;
}

static void AddLump(dheader_t *header, int lump_number, int offset, int length)
{
    header->lumps[lump_number].fileofs = offset;
    header->lumps[lump_number].filelen = length;
}

static int BuildTextureLump(byte *output)
{
    static const char *names[4] = {
        "+0fixture", "+1fixture", "+Afixture", "+Bfixture"
    };
    dmiptexlump_t *table = (dmiptexlump_t *)output;
    int cursor = 4 + 4 * 4;
    int index;
    memset(output, 0, 2048);
    table->nummiptex = 4;
    for (index = 0; index < 4; ++index)
    {
        miptex_t *texture;
        int pixel;
        table->dataofs[index] = cursor;
        texture = (miptex_t *)(output + cursor);
        strncpy(texture->name, names[index], sizeof(texture->name));
        texture->width = 16;
        texture->height = 16;
        texture->offsets[0] = 40;
        texture->offsets[1] = 296;
        texture->offsets[2] = 360;
        texture->offsets[3] = 376;
        for (pixel = 0; pixel < 340; ++pixel)
            output[cursor + 40 + pixel] = (byte)(index + 1);
        cursor += 40 + 340;
    }
    return cursor;
}

static void BuildBsp(void)
{
    dheader_t *header = (dheader_t *)bsp_file;
    byte texture_lump[2048];
    int texture_size;
    int cursor = (int)sizeof(dheader_t);
    char entities[] = "{\n\"classname\" \"worldspawn\"\n}\n";
    dplane_t plane;
    dvertex_t vertices[2];
    byte visibility[2] = {1, 0};
    dnode_t node;
    texinfo_t texinfo;
    dface_t face;
    byte lighting[3] = {9, 8, 7};
    dclipnode_t clipnode;
    dleaf_t leaf;
    unsigned short marksurface = 0;
    dedge_t edge;
    int surfedge = 0;
    dmodel_t model;

    memset(bsp_file, 0, sizeof(bsp_file));
    header->version = BSPVERSION;

    AddLump(header, LUMP_ENTITIES, cursor, (int)sizeof(entities));
    cursor = Append(bsp_file, cursor, entities, (int)sizeof(entities));

    memset(&plane, 0, sizeof(plane));
    plane.normal[2] = -1.0f;
    plane.dist = 2.0f;
    plane.type = PLANE_Z;
    AddLump(header, LUMP_PLANES, cursor, (int)sizeof(plane));
    cursor = Append(bsp_file, cursor, &plane, (int)sizeof(plane));

    texture_size = BuildTextureLump(texture_lump);
    AddLump(header, LUMP_TEXTURES, cursor, texture_size);
    cursor = Append(bsp_file, cursor, texture_lump, texture_size);

    memset(vertices, 0, sizeof(vertices));
    vertices[0].point[0] = 17.0f;
    vertices[0].point[1] = -2.0f;
    vertices[0].point[2] = 3.0f;
    vertices[1].point[0] = 33.0f;
    vertices[1].point[1] = 14.0f;
    vertices[1].point[2] = 3.0f;
    AddLump(header, LUMP_VERTEXES, cursor, (int)sizeof(vertices));
    cursor = Append(bsp_file, cursor, vertices, (int)sizeof(vertices));

    AddLump(header, LUMP_VISIBILITY, cursor, (int)sizeof(visibility));
    cursor = Append(bsp_file, cursor, visibility, (int)sizeof(visibility));

    memset(&node, 0, sizeof(node));
    node.children[0] = -1;
    node.children[1] = -1;
    node.mins[0] = -8;
    node.mins[1] = -9;
    node.mins[2] = -10;
    node.maxs[0] = 8;
    node.maxs[1] = 9;
    node.maxs[2] = 10;
    node.numfaces = 1;
    AddLump(header, LUMP_NODES, cursor, (int)sizeof(node));
    cursor = Append(bsp_file, cursor, &node, (int)sizeof(node));

    memset(&texinfo, 0, sizeof(texinfo));
    texinfo.vecs[0][0] = 1.0f;
    texinfo.vecs[1][1] = 1.0f;
    texinfo.miptex = 0;
    texinfo.flags = 5;
    AddLump(header, LUMP_TEXINFO, cursor, (int)sizeof(texinfo));
    cursor = Append(bsp_file, cursor, &texinfo, (int)sizeof(texinfo));

    memset(&face, 0, sizeof(face));
    face.numedges = 1;
    face.styles[0] = 3;
    face.styles[1] = 255;
    face.styles[2] = 255;
    face.styles[3] = 255;
    face.lightofs = 0;
    AddLump(header, LUMP_FACES, cursor, (int)sizeof(face));
    cursor = Append(bsp_file, cursor, &face, (int)sizeof(face));

    AddLump(header, LUMP_LIGHTING, cursor, (int)sizeof(lighting));
    cursor = Append(bsp_file, cursor, lighting, (int)sizeof(lighting));

    memset(&clipnode, 0, sizeof(clipnode));
    clipnode.children[0] = CONTENTS_EMPTY;
    clipnode.children[1] = CONTENTS_SOLID;
    AddLump(header, LUMP_CLIPNODES, cursor, (int)sizeof(clipnode));
    cursor = Append(bsp_file, cursor, &clipnode, (int)sizeof(clipnode));

    memset(&leaf, 0, sizeof(leaf));
    leaf.contents = CONTENTS_SOLID;
    leaf.visofs = 0;
    leaf.firstmarksurface = 0;
    leaf.nummarksurfaces = 1;
    leaf.ambient_level[0] = 11;
    leaf.ambient_level[1] = 12;
    leaf.ambient_level[2] = 13;
    leaf.ambient_level[3] = 14;
    AddLump(header, LUMP_LEAFS, cursor, (int)sizeof(leaf));
    cursor = Append(bsp_file, cursor, &leaf, (int)sizeof(leaf));

    AddLump(header, LUMP_MARKSURFACES, cursor, (int)sizeof(marksurface));
    cursor = Append(bsp_file, cursor, &marksurface, (int)sizeof(marksurface));

    memset(&edge, 0, sizeof(edge));
    edge.v[0] = 0;
    edge.v[1] = 1;
    AddLump(header, LUMP_EDGES, cursor, (int)sizeof(edge));
    cursor = Append(bsp_file, cursor, &edge, (int)sizeof(edge));

    AddLump(header, LUMP_SURFEDGES, cursor, (int)sizeof(surfedge));
    cursor = Append(bsp_file, cursor, &surfedge, (int)sizeof(surfedge));

    memset(&model, 0, sizeof(model));
    model.mins[0] = -3.0f;
    model.mins[1] = -4.0f;
    model.mins[2] = 0.0f;
    model.maxs[0] = 2.0f;
    model.maxs[1] = 1.0f;
    model.maxs[2] = 12.0f;
    model.visleafs = 9;
    model.numfaces = 1;
    AddLump(header, LUMP_MODELS, cursor, (int)sizeof(model));
    cursor = Append(bsp_file, cursor, &model, (int)sizeof(model));
    bsp_size = cursor;
}

static void FillAliasFrame(byte **cursor, const char *name, byte base)
{
    daliasframe_t frame;
    trivertx_t vertices[3];
    int index;
    memset(&frame, 0, sizeof(frame));
    frame.bboxmin.v[0] = base;
    frame.bboxmax.v[0] = (byte)(base + 10);
    strncpy(frame.name, name, sizeof(frame.name));
    *cursor += Append(*cursor, 0, &frame, (int)sizeof(frame));
    for (index = 0; index < 3; ++index)
    {
        memset(&vertices[index], 0, sizeof(vertices[index]));
        vertices[index].v[0] = (byte)(base + index);
        vertices[index].v[1] = (byte)(base + index + 1);
        vertices[index].v[2] = (byte)(base + index + 2);
        vertices[index].lightnormalindex = (byte)index;
    }
    *cursor += Append(*cursor, 0, vertices, (int)sizeof(vertices));
}

static void BuildMdl(void)
{
    mdl_t header;
    byte *cursor = mdl_file;
    int value;
    float interval;
    byte skins[8] = {1, 1, 1, 1, 2, 2, 2, 2};
    stvert_t texcoords[3];
    dtriangle_t triangle;
    daliasgroup_t group;

    memset(mdl_file, 0, sizeof(mdl_file));
    memset(&header, 0, sizeof(header));
    header.ident = IDPOLYHEADER;
    header.version = ALIAS_VERSION;
    header.scale[0] = 1.0f;
    header.scale[1] = 2.0f;
    header.scale[2] = 3.0f;
    header.scale_origin[0] = 4.0f;
    header.boundingradius = 20.0f;
    header.eyeposition[2] = 7.0f;
    header.numskins = 1;
    header.skinwidth = 2;
    header.skinheight = 2;
    header.numverts = 3;
    header.numtris = 1;
    header.numframes = 1;
    header.synctype = ST_RAND;
    header.flags = 9;
    header.size = 11.0f;
    cursor += Append(cursor, 0, &header, (int)sizeof(header));

    value = ALIAS_SKIN_GROUP;
    cursor += Append(cursor, 0, &value, 4);
    value = 2;
    cursor += Append(cursor, 0, &value, 4);
    interval = 0.1f;
    cursor += Append(cursor, 0, &interval, 4);
    interval = 0.2f;
    cursor += Append(cursor, 0, &interval, 4);
    cursor += Append(cursor, 0, skins, (int)sizeof(skins));

    memset(texcoords, 0, sizeof(texcoords));
    texcoords[1].s = 8;
    texcoords[2].t = 12;
    cursor += Append(cursor, 0, texcoords, (int)sizeof(texcoords));

    memset(&triangle, 0, sizeof(triangle));
    triangle.facesfront = 1;
    triangle.vertindex[0] = 0;
    triangle.vertindex[1] = 1;
    triangle.vertindex[2] = 2;
    cursor += Append(cursor, 0, &triangle, (int)sizeof(triangle));

    value = ALIAS_GROUP;
    cursor += Append(cursor, 0, &value, 4);
    memset(&group, 0, sizeof(group));
    group.numframes = 2;
    group.bboxmin.v[0] = 3;
    group.bboxmax.v[0] = 33;
    cursor += Append(cursor, 0, &group, (int)sizeof(group));
    interval = 0.15f;
    cursor += Append(cursor, 0, &interval, 4);
    interval = 0.30f;
    cursor += Append(cursor, 0, &interval, 4);
    FillAliasFrame(&cursor, "pose0", 5);
    FillAliasFrame(&cursor, "pose1", 9);
    mdl_size = (int)(cursor - mdl_file);
}

static void FillSpriteFrame(byte **cursor, int x, int y, byte base)
{
    dspriteframe_t frame;
    byte pixels[4];
    memset(&frame, 0, sizeof(frame));
    frame.origin[0] = x;
    frame.origin[1] = y;
    frame.width = 2;
    frame.height = 2;
    pixels[0] = base;
    pixels[1] = (byte)(base + 1);
    pixels[2] = (byte)(base + 2);
    pixels[3] = (byte)(base + 3);
    *cursor += Append(*cursor, 0, &frame, (int)sizeof(frame));
    *cursor += Append(*cursor, 0, pixels, (int)sizeof(pixels));
}

static void BuildSprite(void)
{
    dsprite_t header;
    byte *cursor = spr_file;
    int value;
    float interval;
    memset(spr_file, 0, sizeof(spr_file));
    memset(&header, 0, sizeof(header));
    header.ident = IDSPRITEHEADER;
    header.version = SPRITE_VERSION;
    header.type = SPR_ORIENTED;
    header.boundingradius = 8.0f;
    header.width = 2;
    header.height = 2;
    header.numframes = 1;
    header.beamlength = 3.5f;
    header.synctype = ST_RAND;
    cursor += Append(cursor, 0, &header, (int)sizeof(header));
    value = SPR_GROUP;
    cursor += Append(cursor, 0, &value, 4);
    value = 2;
    cursor += Append(cursor, 0, &value, 4);
    interval = 0.1f;
    cursor += Append(cursor, 0, &interval, 4);
    interval = 0.25f;
    cursor += Append(cursor, 0, &interval, 4);
    FillSpriteFrame(&cursor, -2, 3, 10);
    FillSpriteFrame(&cursor, 4, 5, 20);
    spr_size = (int)(cursor - spr_file);
}

static void ResetFixture(void)
{
    int index;
    hunk_used = 0;
    cvar_registers = 0;
    texture_uploads = 0;
    cache_checks = 0;
    console_prints = 0;
    next_texture = 100;
    mod_numknown = 0;
    memset(mod_known, 0, sizeof(model_t) * 512);
    memset(d_8to24table, 0, sizeof(d_8to24table));
    d_8to24table[0] = 255;
    memset(&fallback_texture, 0, sizeof(fallback_texture));
    strcpy(fallback_texture.name, "notexture");
    for (index = 0; index < (int)sizeof(mod_novis); ++index)
        mod_novis[index] = 0;
}

static void Emit(char *function, char *scene, char *format, ...)
{
    va_list arguments;
    printf("{\"function\":\"%s\",\"scene\":\"%s\"", function, scene);
    if (format && *format)
    {
        putchar(',');
        va_start(arguments, format);
        vprintf(format, arguments);
        va_end(arguments);
    }
    puts("}");
}

static int FatalMode(char *mode)
{
    model_t model;
    if (!strcmp(mode, "bsp-version"))
    {
        BuildBsp();
        ((dheader_t *)bsp_file)->version = 30;
        memset(&model, 0, sizeof(model));
        strcpy(model.name, "bad.bsp");
        loadmodel = &model;
        Mod_LoadBrushModel(&model, bsp_file);
        return 0;
    }
    if (!strcmp(mode, "mdl-vertices"))
    {
        BuildMdl();
        ((mdl_t *)mdl_file)->numverts = 0;
        memset(&model, 0, sizeof(model));
        strcpy(model.name, "bad.mdl");
        loadmodel = &model;
        Mod_LoadAliasModel(&model, mdl_file);
        return 0;
    }
    if (!strcmp(mode, "sprite-interval"))
    {
        BuildSprite();
        *(float *)(spr_file + sizeof(dsprite_t) + 8) = 0.0f;
        memset(&model, 0, sizeof(model));
        strcpy(model.name, "bad.spr");
        loadmodel = &model;
        Mod_LoadSpriteModel(&model, spr_file);
        return 0;
    }
    if (!strcmp(mode, "lump-size"))
    {
        lump_t lump;
        byte data[1] = {0};
        memset(&model, 0, sizeof(model));
        strcpy(model.name, "bad.bsp");
        loadmodel = &model;
        mod_base = data;
        lump.fileofs = 0;
        lump.filelen = 1;
        Mod_LoadVertexes(&lump);
        return 0;
    }
    return 2;
}

int main(int argc, char **argv)
{
    model_t *brush;
    model_t *alias;
    model_t *sprite;
    model_t *missing;
    model_t *upper;
    model_t *lower;
    aliashdr_t *alias_header;
    msprite_t *sprite_header;
    mspritegroup_t *sprite_group;
    byte vis_stream[3] = {1, 0, 1};
    model_t vis_model;
    mleaf_t vis_leafs[2];
    byte *decompressed;
    byte *pvs;
    vec3_t point = {0.0f, 0.0f, 4.0f};
    vec3_t mins = {-3.0f, -4.0f, 0.0f};
    vec3_t maxs = {2.0f, 1.0f, 12.0f};
    byte skin[4] = {1, 1, 2, 1};
    int before_checks;
    int before_prints;
    maliasframedesc_t frame_desc;
    aliashdr_t direct_header;
    byte direct_frame[sizeof(daliasframe_t) + sizeof(trivertx_t)];
    byte direct_group[sizeof(daliasgroup_t) + 8 + 2 * (sizeof(daliasframe_t) + 3 * sizeof(trivertx_t))];
    byte *cursor;
    int interval_offset;

    ResetFixture();
    BuildBsp();
    BuildMdl();
    BuildSprite();
    if (argc == 3 && !strcmp(argv[1], "--fatal"))
        return FatalMode(argv[2]);

    Mod_Init();
    Emit("Mod_Init", "init", "\"cvars\":%d,\"novis\":[%u,%u]", cvar_registers, mod_novis[0], mod_novis[1023]);

    brush = Mod_ForName("maps/fixture.bsp", true);
    alias = Mod_ForName("progs/fixture.mdl", true);
    sprite = Mod_FindName("progs/fixture.spr");
    sprite = Mod_LoadModel(sprite, true);
    missing = Mod_ForName("missing.bin", false);
    Emit("Mod_ForName", "registry-dispatch", "\"brush\":%d,\"alias\":%d,\"missing\":%d", brush->type, alias->type, missing == NULL);
    Emit("Mod_LoadModel", "registry-dispatch", "\"sprite\":%d,\"needload\":%d", sprite->type, sprite->needload);

    upper = Mod_FindName("PROGS/PLAYER.MDL");
    lower = Mod_FindName("progs/player.mdl");
    Emit("Mod_FindName", "registry-case", "\"different\":%d,\"count\":%d", upper != lower, mod_numknown);

    before_checks = cache_checks;
    Mod_TouchModel("progs/fixture.mdl");
    Emit("Mod_TouchModel", "cache-touch", "\"checks\":%d", cache_checks - before_checks);
    alias_header = (aliashdr_t *)Mod_Extradata(alias);
    Emit("Mod_Extradata", "cache-touch", "\"frames\":%d,\"poses\":%d", alias_header->numframes, alias_header->numposes);

    Emit("Mod_LoadTextures", "bsp29", "\"count\":%d,\"anim\":[%d,%d,%d,%d]", brush->numtextures, brush->textures[0]->anim_total, brush->textures[0]->anim_next == brush->textures[1], brush->textures[0]->alternate_anims == brush->textures[2], texture_uploads >= 4);
    Emit("Mod_LoadLighting", "bsp29", "\"bytes\":[%u,%u,%u]", brush->lightdata[0], brush->lightdata[1], brush->lightdata[2]);
    Emit("Mod_LoadVisibility", "bsp29", "\"bytes\":[%u,%u]", brush->visdata[0], brush->visdata[1]);
    Emit("Mod_LoadEntities", "bsp29", "\"first\":%u,\"worldspawn\":%d", (unsigned char)brush->entities[0], strstr(brush->entities, "worldspawn") != NULL);
    Emit("Mod_LoadVertexes", "bsp29", "\"count\":%d,\"first\":[%.6f,%.6f,%.6f]", brush->numvertexes, brush->vertexes[0].position[0], brush->vertexes[0].position[1], brush->vertexes[0].position[2]);
    Emit("Mod_LoadSubmodels", "bsp29", "\"count\":%d,\"bounds\":[%.6f,%.6f]", brush->numsubmodels, brush->submodels[0].mins[0], brush->submodels[0].maxs[2]);
    Emit("Mod_LoadEdges", "bsp29", "\"count\":%d,\"edge\":[%u,%u]", brush->numedges, brush->edges[0].v[0], brush->edges[0].v[1]);
    Emit("Mod_LoadTexinfo", "bsp29", "\"count\":%d,\"mipadjust\":%.6f,\"flags\":%d", brush->numtexinfo, brush->texinfo[0].mipadjust, brush->texinfo[0].flags);
    Emit("CalcSurfaceExtents", "bsp29", "\"mins\":[%d,%d],\"extents\":[%d,%d]", brush->surfaces[0].texturemins[0], brush->surfaces[0].texturemins[1], brush->surfaces[0].extents[0], brush->surfaces[0].extents[1]);
    Emit("Mod_LoadFaces", "bsp29", "\"count\":%d,\"style\":%u,\"sample\":%u,\"underwater\":%d", brush->numsurfaces, brush->surfaces[0].styles[0], brush->surfaces[0].samples[0], (brush->surfaces[0].flags & SURF_UNDERWATER) != 0);
    Emit("Mod_SetParent", "bsp29", "\"root\":%d,\"leaf\":%d", brush->nodes[0].parent == NULL, brush->leafs[0].parent == &brush->nodes[0]);
    Emit("Mod_LoadNodes", "bsp29", "\"count\":%d,\"faces\":%u,\"childcontent\":%d", brush->numnodes, brush->nodes[0].numsurfaces, brush->nodes[0].children[0]->contents);
    Emit("Mod_LoadLeafs", "bsp29", "\"count\":%d,\"contents\":%d,\"ambient\":[%u,%u,%u,%u]", ((dheader_t *)bsp_file)->lumps[LUMP_LEAFS].filelen / (int)sizeof(dleaf_t), brush->leafs[0].contents, brush->leafs[0].ambient_sound_level[0], brush->leafs[0].ambient_sound_level[1], brush->leafs[0].ambient_sound_level[2], brush->leafs[0].ambient_sound_level[3]);
    Emit("Mod_LoadClipnodes", "bsp29", "\"count\":%d,\"children\":[%d,%d],\"last\":%d", brush->numclipnodes, brush->clipnodes[0].children[0], brush->clipnodes[0].children[1], brush->hulls[1].lastclipnode);
    Emit("Mod_MakeHull0", "bsp29", "\"planenum\":%d,\"children\":[%d,%d]", brush->hulls[0].clipnodes[0].planenum, brush->hulls[0].clipnodes[0].children[0], brush->hulls[0].clipnodes[0].children[1]);
    Emit("Mod_LoadMarksurfaces", "bsp29", "\"count\":%d,\"first\":%d", brush->nummarksurfaces, brush->marksurfaces[0] == &brush->surfaces[0]);
    Emit("Mod_LoadSurfedges", "bsp29", "\"count\":%d,\"first\":%d", brush->numsurfedges, brush->surfedges[0]);
    Emit("Mod_LoadPlanes", "bsp29", "\"count\":%d,\"normalz\":%.6f,\"signbits\":%d", brush->numplanes, brush->planes[0].normal[2], brush->planes[0].signbits);
    Emit("RadiusFromBounds", "bounds", "\"radius\":%.6f", RadiusFromBounds(mins, maxs));
    Emit("Mod_LoadBrushModel", "bsp29", "\"type\":%d,\"frames\":%d,\"radius\":%.6f,\"leafs\":%d", brush->type, brush->numframes, brush->radius, brush->numleafs);

    memset(&vis_model, 0, sizeof(vis_model));
    memset(vis_leafs, 0, sizeof(vis_leafs));
    vis_model.numleafs = 9;
    vis_model.leafs = vis_leafs;
    vis_leafs[1].compressed_vis = vis_stream;
    decompressed = Mod_DecompressVis(vis_stream, &vis_model);
    Emit("Mod_DecompressVis", "vis-rle", "\"bytes\":[%u,%u]", decompressed[0], decompressed[1]);
    pvs = Mod_LeafPVS(&vis_leafs[0], &vis_model);
    decompressed = Mod_LeafPVS(&vis_leafs[1], &vis_model);
    Emit("Mod_LeafPVS", "vis-rle", "\"novis\":%u,\"compressed\":[%u,%u]", pvs[0], decompressed[0], decompressed[1]);
    Emit("Mod_PointInLeaf", "bsp29", "\"contents\":%d", Mod_PointInLeaf(point, brush)->contents);

    memset(&direct_header, 0, sizeof(direct_header));
    direct_header.numverts = 1;
    pheader = &direct_header;
    posenum = 0;
    memset(&frame_desc, 0, sizeof(frame_desc));
    memset(direct_frame, 0, sizeof(direct_frame));
    ((daliasframe_t *)direct_frame)->bboxmin.v[0] = 4;
    ((daliasframe_t *)direct_frame)->bboxmax.v[0] = 14;
    strcpy(((daliasframe_t *)direct_frame)->name, "single");
    Mod_LoadAliasFrame(direct_frame, &frame_desc);
    Emit("Mod_LoadAliasFrame", "mdl6-frame", "\"firstpose\":%d,\"poses\":%d,\"name\":\"%s\"", frame_desc.firstpose, frame_desc.numposes, frame_desc.name);

    memset(&frame_desc, 0, sizeof(frame_desc));
    memset(direct_group, 0, sizeof(direct_group));
    ((daliasgroup_t *)direct_group)->numframes = 2;
    interval_offset = (int)sizeof(daliasgroup_t);
    *(float *)(direct_group + interval_offset) = 0.125f;
    *(float *)(direct_group + interval_offset + 4) = 0.25f;
    cursor = direct_group + interval_offset + 8;
    FillAliasFrame(&cursor, "g0", 1);
    FillAliasFrame(&cursor, "g1", 2);
    direct_header.numverts = 3;
    posenum = 0;
    Mod_LoadAliasGroup(direct_group, &frame_desc);
    Emit("Mod_LoadAliasGroup", "mdl6-group", "\"firstpose\":%d,\"poses\":%d,\"interval\":%.6f", frame_desc.firstpose, frame_desc.numposes, frame_desc.interval);

    Mod_FloodFillSkin(skin, 2, 2);
    Emit("Mod_FloodFillSkin", "mdl6-skin", "\"pixels\":[%u,%u,%u,%u]", skin[0], skin[1], skin[2], skin[3]);
    Emit("Mod_LoadAllSkins", "mdl6", "\"skins\":%d,\"uploads\":%d,\"texels\":%d", alias_header->numskins, alias_header->gl_texturenum[0][0] != 0, alias_header->texels[0] != 0);
    Emit("Mod_LoadAliasModel", "mdl6", "\"type\":%d,\"frames\":%d,\"poses\":%d,\"verts\":%d,\"tris\":%d,\"size\":%.6f", alias->type, alias_header->numframes, alias_header->numposes, alias_header->numverts, alias_header->numtris, alias_header->size);

    sprite_header = (msprite_t *)sprite->cache.data;
    sprite_group = (mspritegroup_t *)sprite_header->frames[0].frameptr;
    Emit("Mod_LoadSpriteFrame", "spr1-group", "\"width\":%d,\"height\":%d,\"bounds\":[%.6f,%.6f,%.6f,%.6f]", sprite_group->frames[0]->width, sprite_group->frames[0]->height, sprite_group->frames[0]->up, sprite_group->frames[0]->down, sprite_group->frames[0]->left, sprite_group->frames[0]->right);
    Emit("Mod_LoadSpriteGroup", "spr1-group", "\"count\":%d,\"intervals\":[%.6f,%.6f]", sprite_group->numframes, sprite_group->intervals[0], sprite_group->intervals[1]);
    Emit("Mod_LoadSpriteModel", "spr1", "\"type\":%d,\"frames\":%d,\"spriteType\":%d,\"bounds\":[%.6f,%.6f]", sprite->type, sprite_header->numframes, sprite_header->type, sprite->mins[0], sprite->maxs[2]);

    Mod_ClearAll();
    Emit("Mod_ClearAll", "registry-cache", "\"brush\":%d,\"alias\":%d,\"sprite\":%d", brush->needload, alias->needload, sprite->needload);
    before_prints = console_prints;
    Mod_Print();
    Emit("Mod_Print", "registry-print", "\"lines\":%d,\"models\":%d", console_prints - before_prints, mod_numknown);
    return 0;
}
