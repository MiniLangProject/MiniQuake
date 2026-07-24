#ifndef MINIQUAKE_GL_RSURF_FIXTURE_H
#define MINIQUAKE_GL_RSURF_FIXTURE_H

#include <math.h>
#include <stddef.h>
#include <string.h>

#define MAX_LIGHTSTYLES 64
#define MAX_DLIGHTS 32
#define MAXLIGHTMAPS 4
#define MAX_MODELS 256
#define MAX_MAP_HULLS 4
#define MAX_QPATH 64
#define VERTEXSIZE 7
#define CONTENTS_SOLID -2
#define PLANE_X 0
#define PLANE_Y 1
#define PLANE_Z 2
#define SURF_PLANEBACK 2
#define SURF_DRAWSKY 4
#define SURF_DRAWTURB 0x10
#define SURF_DRAWTILED 0x20
#define SURF_UNDERWATER 0x80
#define BACKFACE_EPSILON 0.01
#define TEXTURE0_SGIS 0x835E
#define TEXTURE1_SGIS 0x835F
#define GL_TRIANGLE_FAN 0x0006
#define GL_POLYGON 0x0009
#define GL_ZERO 0
#define GL_ONE 1
#define GL_SRC_COLOR 0x0300
#define GL_ONE_MINUS_SRC_COLOR 0x0301
#define GL_SRC_ALPHA 0x0302
#define GL_ONE_MINUS_SRC_ALPHA 0x0303
#define GL_BLEND 0x0BE2
#define GL_TEXTURE_2D 0x0DE1
#define GL_RGBA 0x1908
#define GL_ALPHA 0x1906
#define GL_LUMINANCE 0x1909
#define GL_INTENSITY 0x8049
#define GL_UNSIGNED_BYTE 0x1401
#define GL_TEXTURE_MIN_FILTER 0x2801
#define GL_TEXTURE_MAG_FILTER 0x2800
#define GL_LINEAR 0x2601
#define GL_TEXTURE_ENV 0x2300
#define GL_TEXTURE_ENV_MODE 0x2200
#define GL_REPLACE 0x1E01
#define GL_MODULATE 0x2100
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

typedef unsigned char byte;
typedef int qboolean;
typedef unsigned int GLenum;
typedef float GLfloat;
typedef float vec3_t[3];

#ifndef true
#define true 1
#define false 0
#endif

typedef struct
{
	float value;
} cvar_t;

typedef struct mplane_s
{
	vec3_t normal;
	float dist;
	byte type;
	byte signbits;
	byte pad[2];
} mplane_t;

struct msurface_s;
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

typedef struct
{
	unsigned short v[2];
	unsigned int cachededgeoffset;
} medge_t;

typedef struct
{
	vec3_t position;
} mvertex_t;

typedef struct
{
	float vecs[2][4];
	float mipadjust;
	texture_t *texture;
	int flags;
} mtexinfo_t;

typedef struct glpoly_s
{
	struct glpoly_s *next;
	struct glpoly_s *chain;
	int numverts;
	int flags;
	float verts[4][VERTEXSIZE];
} glpoly_t;

typedef struct msurface_s
{
	int visframe;
	mplane_t *plane;
	int flags;
	int firstedge;
	int numedges;
	short texturemins[2];
	short extents[2];
	int light_s;
	int light_t;
	glpoly_t *polys;
	struct msurface_s *texturechain;
	mtexinfo_t *texinfo;
	int dlightframe;
	int dlightbits;
	int lightmaptexturenum;
	byte styles[MAXLIGHTMAPS];
	int cached_light[MAXLIGHTMAPS];
	qboolean cached_dlight;
	byte *samples;
} msurface_t;

typedef struct mnode_s
{
	int contents;
	int visframe;
	float minmaxs[6];
	struct mnode_s *parent;
	mplane_t *plane;
	struct mnode_s *children[2];
	unsigned short firstsurface;
	unsigned short numsurfaces;
} mnode_t;

typedef struct efrag_s
{
	int unused;
} efrag_t;

typedef struct mleaf_s
{
	int contents;
	int visframe;
	float minmaxs[6];
	mnode_t *parent;
	byte *compressed_vis;
	efrag_t *efrags;
	msurface_t **firstmarksurface;
	int nummarksurfaces;
	int key;
	byte ambient_sound_level[4];
} mleaf_t;

typedef struct
{
	void *clipnodes;
	mplane_t *planes;
	int firstclipnode;
	int lastclipnode;
	vec3_t clip_mins;
	vec3_t clip_maxs;
} hull_t;

typedef struct model_s
{
	char name[MAX_QPATH];
	int needload;
	int type;
	int numframes;
	int synctype;
	int flags;
	vec3_t mins;
	vec3_t maxs;
	float radius;
	int clipbox;
	vec3_t clipmins;
	vec3_t clipmaxs;
	int firstmodelsurface;
	int nummodelsurfaces;
	int numsubmodels;
	void *submodels;
	int numplanes;
	mplane_t *planes;
	int numleafs;
	mleaf_t *leafs;
	int numvertexes;
	mvertex_t *vertexes;
	int numedges;
	medge_t *edges;
	int numnodes;
	mnode_t *nodes;
	int numtexinfo;
	mtexinfo_t *texinfo;
	int numsurfaces;
	msurface_t *surfaces;
	int numsurfedges;
	int *surfedges;
	int numclipnodes;
	void *clipnodes;
	int nummarksurfaces;
	msurface_t **marksurfaces;
	hull_t hulls[MAX_MAP_HULLS];
	int numtextures;
	texture_t **textures;
	byte *visdata;
	byte *lightdata;
	char *entities;
} model_t;

typedef struct
{
	vec3_t origin;
	vec3_t angles;
	int frame;
	model_t *model;
} entity_t;

typedef struct
{
	vec3_t origin;
	float radius;
	float die;
	float decay;
	float minlight;
	int key;
} dlight_t;

typedef struct
{
	double time;
	model_t *worldmodel;
	model_t *model_precache[MAX_MODELS];
} client_state_t;

typedef struct
{
	vec3_t vieworg;
} refdef_t;

typedef void (*lpMTexFUNC) (GLenum, GLfloat, GLfloat);
typedef void (*lpSelTexFUNC) (GLenum);

#define VectorCopy(a,b) ((b)[0]=(a)[0],(b)[1]=(a)[1],(b)[2]=(a)[2])
#define VectorSubtract(a,b,c) ((c)[0]=(a)[0]-(b)[0],(c)[1]=(a)[1]-(b)[1],(c)[2]=(a)[2]-(b)[2])
#define VectorAdd(a,b,c) ((c)[0]=(a)[0]+(b)[0],(c)[1]=(a)[1]+(b)[1],(c)[2]=(a)[2]+(b)[2])
#define DotProduct(a,b) ((a)[0]*(b)[0]+(a)[1]*(b)[1]+(a)[2]*(b)[2])

extern client_state_t cl;
extern dlight_t cl_dlights[MAX_DLIGHTS];
extern int d_lightstylevalue[MAX_LIGHTSTYLES];
extern cvar_t r_fullbright;
extern cvar_t gl_texsort;
extern cvar_t r_lightmap;
extern cvar_t r_dynamic;
extern cvar_t r_wateralpha;
extern cvar_t r_mirroralpha;
extern cvar_t r_novis;
extern cvar_t gl_keeptjunctions;
extern cvar_t gl_flashblend;
extern int gl_lightmap_format;
extern qboolean gl_mtexable;
extern int r_framecount;
extern int r_visframecount;
extern int c_brush_polys;
extern entity_t *currententity;
extern int currenttexture;
extern double realtime;
extern float r_world_matrix[16];
extern qboolean mirror;
extern mplane_t *mirror_plane;
extern int mirrortexturenum;
extern vec3_t modelorg;
extern refdef_t r_refdef;
extern mleaf_t *r_viewleaf;
extern mleaf_t *r_oldviewleaf;
extern int texture_extension_number;
extern qboolean isPermedia;

void *Hunk_Alloc (int size);
void Sys_Error (const char *format, ...);
float VectorNormalize (vec3_t vector);
int COM_CheckParm (const char *parameter);
void GL_Bind (int texture);
void GL_SelectTexture (GLenum target);
void EmitWaterPolys (msurface_t *surface);
void EmitSkyPolys (msurface_t *surface);
void EmitBothSkyLayers (msurface_t *surface);
void R_DrawSkyChain (msurface_t *surface);
void R_ClearSkyBox (void);
void R_DrawSkyBox (void);
void R_MarkLights (dlight_t *light, int bit, mnode_t *node);
qboolean R_CullBox (const float *minimums, const float *maximums);
void R_StoreEfrags (efrag_t **efrags);
void AngleVectors (const vec3_t angles, vec3_t forward, vec3_t right, vec3_t up);
void R_RotateForEntity (entity_t *entity);
byte *Mod_LeafPVS (mleaf_t *leaf, model_t *model);

void glBegin (GLenum mode);
void glEnd (void);
void glTexCoord2f (float s, float t);
void glVertex3fv (const float *vertex);
void glEnable (GLenum capability);
void glDisable (GLenum capability);
void glBlendFunc (GLenum source, GLenum destination);
void glDepthMask (byte enabled);
void glTexEnvf (GLenum target, GLenum name, float value);
void glColor3f (float red, float green, float blue);
void glColor4f (float red, float green, float blue, float alpha);
void glTexSubImage2D (GLenum target, int level, int x, int y,
	int width, int height, GLenum format, GLenum type, const void *pixels);
void glTexParameterf (GLenum target, GLenum name, float value);
void glTexImage2D (GLenum target, int level, int internal_format,
	int width, int height, int border, GLenum format, GLenum type,
	const void *pixels);
void glLoadMatrixf (const float *matrix);
void glPushMatrix (void);
void glPopMatrix (void);

#endif
