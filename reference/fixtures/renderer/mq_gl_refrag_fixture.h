#ifndef MINIQUAKE_GL_REFRAG_FIXTURE_H
#define MINIQUAKE_GL_REFRAG_FIXTURE_H

#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CONTENTS_SOLID -2
#define MAX_VISEDICTS 256
#define mod_brush 0
#define mod_sprite 1
#define mod_alias 2

typedef int qboolean;
typedef float vec3_t[3];

typedef struct mplane_s
{
	vec3_t normal;
	float dist;
	unsigned char type;
	unsigned char signbits;
	unsigned char pad[2];
} mplane_t;

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

struct entity_s;
typedef struct efrag_s
{
	struct mleaf_s *leaf;
	struct efrag_s *leafnext;
	struct entity_s *entity;
	struct efrag_s *entnext;
} efrag_t;

typedef struct mleaf_s
{
	int contents;
	int visframe;
	float minmaxs[6];
	mnode_t *parent;
	unsigned char *compressed_vis;
	efrag_t *efrags;
	void *firstmarksurface;
	int nummarksurfaces;
	int key;
	unsigned char ambient_sound_level[4];
} mleaf_t;

typedef struct model_s
{
	int type;
	vec3_t mins;
	vec3_t maxs;
	mnode_t *nodes;
} model_t;

typedef struct entity_s
{
	qboolean forcelink;
	int update_type;
	void *baseline;
	double msgtime;
	vec3_t msg_origins[2];
	vec3_t origin;
	vec3_t msg_angles[2];
	vec3_t angles;
	model_t *model;
	efrag_t *efrag;
	int frame;
	float syncbase;
	unsigned char *colormap;
	int effects;
	int skinnum;
	int visframe;
	int dlightframe;
	int dlightbits;
	int trivial_accept;
	mnode_t *topnode;
} entity_t;

typedef struct
{
	efrag_t *free_efrags;
	model_t *worldmodel;
} client_state_t;

extern client_state_t cl;
extern int r_framecount;
extern int cl_numvisedicts;
extern entity_t *cl_visedicts[MAX_VISEDICTS];

int MQ_BoxOnPlaneSide (const vec3_t mins, const vec3_t maxs,
	const mplane_t *plane);
#define BOX_ON_PLANE_SIDE(mins,maxs,plane) \
	MQ_BoxOnPlaneSide((mins),(maxs),(plane))

void Con_Printf (const char *format, ...);
void Sys_Error (const char *format, ...);

#endif
