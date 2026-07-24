#ifndef MINIQUAKE_GL_RLIGHT_FIXTURE_H
#define MINIQUAKE_GL_RLIGHT_FIXTURE_H

#include <math.h>

#define MAX_LIGHTSTYLES 64
#define MAX_DLIGHTS 32
#define MAXLIGHTMAPS 4
#define SURF_DRAWTILED 0x10
#define GL_TRIANGLE_FAN 0x0006
#define GL_TEXTURE_2D 0x0DE1
#define GL_SMOOTH 0x1D01
#define GL_BLEND 0x0BE2
#define GL_ONE 1
#define GL_SRC_ALPHA 0x0302
#define GL_ONE_MINUS_SRC_ALPHA 0x0303
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

typedef unsigned char byte;
typedef float vec3_t[3];

typedef struct
{
	float value;
} cvar_t;

typedef struct
{
	int length;
	char map[64];
} lightstyle_t;

typedef struct
{
	vec3_t origin;
	float radius;
	float die;
	float decay;
	float minlight;
	int key;
} dlight_t;

typedef struct mplane_s
{
	vec3_t normal;
	float dist;
	byte type;
	byte signbits;
	byte pad[2];
} mplane_t;

typedef struct mtexinfo_s
{
	float vecs[2][4];
} mtexinfo_t;

typedef struct msurface_s
{
	int flags;
	mtexinfo_t *texinfo;
	short texturemins[2];
	short extents[2];
	byte *samples;
	byte styles[MAXLIGHTMAPS];
	int dlightframe;
	int dlightbits;
} msurface_t;

typedef struct mnode_s
{
	int contents;
	mplane_t *plane;
	struct mnode_s *children[2];
	unsigned short firstsurface;
	unsigned short numsurfaces;
} mnode_t;

typedef struct model_s
{
	msurface_t *surfaces;
	mnode_t *nodes;
	byte *lightdata;
} model_t;

typedef struct
{
	double time;
	model_t *worldmodel;
} client_state_t;

#define VectorSubtract(a,b,c) ((c)[0]=(a)[0]-(b)[0],(c)[1]=(a)[1]-(b)[1],(c)[2]=(a)[2]-(b)[2])
#define VectorCopy(a,b) ((b)[0]=(a)[0],(b)[1]=(a)[1],(b)[2]=(a)[2])
#define DotProduct(a,b) ((a)[0]*(b)[0]+(a)[1]*(b)[1]+(a)[2]*(b)[2])

static __inline float Length (const vec3_t value)
{
	return (float)sqrt (DotProduct (value, value));
}

extern client_state_t cl;
extern lightstyle_t cl_lightstyle[MAX_LIGHTSTYLES];
extern int d_lightstylevalue[MAX_LIGHTSTYLES];
extern float v_blend[4];
extern dlight_t cl_dlights[MAX_DLIGHTS];
extern cvar_t gl_flashblend;
extern int r_framecount;
extern vec3_t r_origin;
extern vec3_t vpn;
extern vec3_t vright;
extern vec3_t vup;

void glBegin (unsigned int mode);
void glEnd (void);
void glColor3f (float red, float green, float blue);
void glVertex3fv (const float *vertex);
void glDepthMask (unsigned char enabled);
void glDisable (unsigned int capability);
void glShadeModel (unsigned int mode);
void glEnable (unsigned int capability);
void glBlendFunc (unsigned int source, unsigned int destination);

void R_AnimateLight (void);
void AddLightBlend (float red, float green, float blue, float alpha);
void R_RenderDlight (dlight_t *light);
void R_RenderDlights (void);
void R_MarkLights (dlight_t *light, int bit, mnode_t *node);
void R_PushDlights (void);
int RecursiveLightPoint (mnode_t *node, vec3_t start, vec3_t end);
int R_LightPoint (vec3_t point);

#endif
