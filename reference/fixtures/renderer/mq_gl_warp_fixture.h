#ifndef MINIQUAKE_GL_WARP_FIXTURE_H
#define MINIQUAKE_GL_WARP_FIXTURE_H

#include <math.h>
#include <stddef.h>

#define VERTEXSIZE 7
#define GL_POLYGON 0x0009
#define GL_BLEND 0x0BE2
#define GL_TEXTURE_2D 0x0DE1
#define GL_RGBA 0x1908
#define GL_UNSIGNED_BYTE 0x1401
#define GL_TEXTURE_MIN_FILTER 0x2801
#define GL_TEXTURE_MAG_FILTER 0x2800
#define GL_LINEAR 0x2601
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

typedef unsigned char byte;
typedef float vec3_t[3];

typedef struct cvar_s
{
	float value;
} cvar_t;

typedef struct glpoly_s
{
	struct glpoly_s *next;
	struct glpoly_s *chain;
	int numverts;
	int flags;
	float verts[4][VERTEXSIZE];
} glpoly_t;

typedef struct mvertex_s
{
	vec3_t position;
} mvertex_t;

typedef struct medge_s
{
	unsigned short v[2];
	unsigned int cachededgeoffset;
} medge_t;

typedef struct mtexinfo_s
{
	float vecs[2][4];
} mtexinfo_t;

typedef struct msurface_s
{
	int firstedge;
	int numedges;
	glpoly_t *polys;
	struct msurface_s *texturechain;
	mtexinfo_t *texinfo;
} msurface_t;

typedef struct model_s
{
	int *surfedges;
	mvertex_t *vertexes;
	medge_t *edges;
} model_t;

typedef struct texture_s
{
	char name[16];
	unsigned int width;
	unsigned int height;
	int gl_texturenum;
	struct msurface_s *texturechain;
	int anim_total;
	int anim_min;
	int anim_max;
	struct texture_s *anim_next;
	struct texture_s *alternate_anims;
	unsigned int offsets[4];
} texture_t;

#define VectorCopy(a,b) ((b)[0]=(a)[0],(b)[1]=(a)[1],(b)[2]=(a)[2])
#define VectorSubtract(a,b,c) ((c)[0]=(a)[0]-(b)[0],(c)[1]=(a)[1]-(b)[1],(c)[2]=(a)[2]-(b)[2])
#define DotProduct(a,b) ((a)[0]*(b)[0]+(a)[1]*(b)[1]+(a)[2]*(b)[2])

extern double realtime;
extern vec3_t r_origin;
extern unsigned int d_8to24table[256];
extern int texture_extension_number;
extern int gl_solid_format;
extern int gl_alpha_format;

void *Hunk_Alloc (int size);
void Sys_Error (const char *format, ...);
void GL_Bind (int texture);
void GL_DisableMultitexture (void);
void glBegin (unsigned int mode);
void glEnd (void);
void glTexCoord2f (float s, float t);
void glVertex3fv (const float *vertex);
void glEnable (unsigned int capability);
void glDisable (unsigned int capability);
void glTexImage2D (unsigned int target, int level, int internal_format,
	int width, int height, int border, unsigned int format,
	unsigned int type, const void *pixels);
void glTexParameterf (unsigned int target, unsigned int parameter, float value);

void BoundPoly (int numverts, float *verts, vec3_t mins, vec3_t maxs);
void SubdividePolygon (int numverts, float *verts);
void GL_SubdivideSurface (msurface_t *surface);
void EmitWaterPolys (msurface_t *surface);
void EmitSkyPolys (msurface_t *surface);
void EmitBothSkyLayers (msurface_t *surface);
void R_DrawSkyChain (msurface_t *surface);
void R_InitSky (texture_t *texture);

#endif
