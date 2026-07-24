#ifndef MINIQUAKE_GL_RMISC_FIXTURE_H
#define MINIQUAKE_GL_RMISC_FIXTURE_H

#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_CLIENTS 16
#define MAX_MODELS 256
#define MAX_SKINS 32
#define MAX_LIGHTSTYLES 256
#define TOP_RANGE 16
#define BOTTOM_RANGE 96
#define mod_alias 2

#define GL_FRONT 0x0404
#define GL_BACK 0x0405
#define GL_TEXTURE_2D 0x0DE1
#define GL_RGBA 0x1908
#define GL_UNSIGNED_BYTE 0x1401
#define GL_TEXTURE_ENV 0x2300
#define GL_TEXTURE_ENV_MODE 0x2200
#define GL_MODULATE 0x2100
#define GL_TEXTURE_MIN_FILTER 0x2801
#define GL_TEXTURE_MAG_FILTER 0x2800
#define GL_LINEAR 0x2601

typedef unsigned char byte;
typedef int qboolean;
typedef unsigned int GLenum;
typedef float vec3_t[3];

#ifndef true
#define true 1
#define false 0
#endif

typedef struct
{
	const char *name;
	const char *string;
	qboolean archive;
	qboolean server;
	float value;
} cvar_t;

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
	void *efrags;
} mleaf_t;

typedef struct model_s
{
	int type;
	int numleafs;
	mleaf_t *leafs;
	int numtextures;
	texture_t **textures;
	void *extradata;
} model_t;

typedef struct
{
	model_t *model;
	int skinnum;
} entity_t;

typedef struct
{
	int colors;
} scoreboard_t;

typedef struct
{
	scoreboard_t scores[MAX_CLIENTS];
	model_t *worldmodel;
} client_state_t;

typedef struct
{
	int x;
	int y;
	int width;
	int height;
} vrect_t;

typedef struct
{
	vrect_t vrect;
	vec3_t viewangles;
} refdef_t;

typedef struct
{
	int skinwidth;
	int skinheight;
	int numskins;
	int texels[MAX_SKINS];
} aliashdr_t;

extern texture_t *r_notexture_mip;
extern int particletexture;
extern int texture_extension_number;
extern int gl_alpha_format;
extern int gl_solid_format;
extern int playertextures;
extern qboolean envmap;
extern refdef_t r_refdef;
extern int glx, gly, glwidth, glheight;
extern client_state_t cl;
extern entity_t cl_entities[MAX_CLIENTS + 1];
extern entity_t *currententity;
extern unsigned int d_8to24table[256];
extern int d_lightstylevalue[MAX_LIGHTSTYLES];
extern entity_t r_worldentity;
extern mleaf_t *r_viewleaf;
extern int skytexturenum;
extern int mirrortexturenum;
extern qboolean gl_mtexable;

extern cvar_t gl_finish;
extern cvar_t r_norefresh, r_lightmap, r_fullbright, r_drawentities;
extern cvar_t r_drawviewmodel, r_shadows, r_mirroralpha, r_wateralpha;
extern cvar_t r_dynamic, r_novis, r_speeds, gl_clear, gl_texsort;
extern cvar_t gl_cull, gl_smoothmodels, gl_affinemodels, gl_polyblend;
extern cvar_t gl_flashblend, gl_playermip, gl_nocolors;
extern cvar_t gl_keeptjunctions, gl_reporttjunctions, gl_doubleeyes;
extern cvar_t gl_max_size;

void *Hunk_AllocName (int size, const char *name);
void GL_DisableMultitexture (void);
void GL_Bind (int texture);
void glTexImage2D (GLenum target, int level, int internal_format,
	int width, int height, int border, GLenum format, GLenum type,
	const void *pixels);
void glTexEnvf (GLenum target, GLenum name, float value);
void glTexParameterf (GLenum target, GLenum name, float value);
void glDrawBuffer (GLenum mode);
void glReadBuffer (GLenum mode);
void glReadPixels (int x, int y, int width, int height,
	GLenum format, GLenum type, void *pixels);
void glFinish (void);
void GL_BeginRendering (int *x, int *y, int *width, int *height);
void GL_EndRendering (void);
void R_RenderView (void);
void COM_WriteFile (const char *name, const void *data, int length);
void Cmd_AddCommand (const char *name, void (*function)(void));
void Cvar_RegisterVariable (cvar_t *variable);
void Cvar_SetValue (const char *name, float value);
void R_InitParticles (void);
void R_ClearParticles (void);
void GL_BuildLightmaps (void);
void *Mod_Extradata (model_t *model);
qboolean VID_Is8bit (void);
void GL_Upload8_EXT (byte *data, int width, int height,
	qboolean mipmap, qboolean alpha);
double Sys_FloatTime (void);
void Con_Printf (const char *format, ...);
void Sys_Error (const char *format, ...);

#define Q_strncmp strncmp

void R_TimeRefresh_f (void);
void R_Envmap_f (void);
void R_ReadPointFile_f (void);

#endif
