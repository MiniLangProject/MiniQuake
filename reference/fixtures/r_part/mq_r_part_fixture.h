#ifndef MINIQUAKE_R_PART_FIXTURE_H
#define MINIQUAKE_R_PART_FIXTURE_H

#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned char byte;
typedef int qboolean;
typedef float vec_t;
typedef float vec3_t[3];
typedef unsigned int GLenum;

#ifndef true
#define true 1
#define false 0
#endif

#define MAX_OSPATH 128
#define GL_BLEND 0x0BE2
#define GL_TEXTURE_ENV 0x2300
#define GL_TEXTURE_ENV_MODE 0x2200
#define GL_MODULATE 0x2100
#define GL_REPLACE 0x1E01
#define GL_TRIANGLES 0x0004

typedef enum
{
	pt_static, pt_grav, pt_slowgrav, pt_fire,
	pt_explode, pt_explode2, pt_blob, pt_blob2
} ptype_t;

typedef struct particle_s
{
	vec3_t org;
	float color;
	struct particle_s *next;
	vec3_t vel;
	float ramp;
	float die;
	ptype_t type;
} particle_t;

typedef struct { vec3_t origin; } entity_t;
typedef struct { float time, oldtime; } client_state_t;
typedef struct { char name[64]; } server_t;
typedef struct
{
	const char *name;
	const char *string;
	qboolean archive;
	qboolean server;
	float value;
} cvar_t;

extern int com_argc;
extern char **com_argv;
extern client_state_t cl;
extern server_t sv;
extern vec3_t vec3_origin;
extern vec3_t vup, vright, vpn, r_origin;
extern unsigned int d_8to24table[256];
extern int particletexture;

int COM_CheckParm (char *parameter);
int Q_atoi (char *text);
void *Hunk_AllocName (int size, char *name);
int COM_FOpenFile (char *name, FILE **file);
void Con_Printf (char *format, ...);
float MSG_ReadCoord (void);
int MSG_ReadChar (void);
int MSG_ReadByte (void);
vec_t VectorNormalize (vec3_t vector);
int MQ_Rand (void);
void R_RunParticleEffect (vec3_t origin, vec3_t direction, int color, int count);

void GL_Bind (int texture);
void MQ_glEnable (GLenum capability);
void MQ_glDisable (GLenum capability);
void MQ_glTexEnvf (GLenum target, GLenum name, float value);
void MQ_glBegin (GLenum mode);
void MQ_glEnd (void);
void MQ_glColor3ubv (const byte *color);
void MQ_glTexCoord2f (float s, float t);
void MQ_glVertex3fv (const float *vertex);
void MQ_glVertex3f (float x, float y, float z);

#define rand MQ_Rand
#define glEnable MQ_glEnable
#define glDisable MQ_glDisable
#define glTexEnvf MQ_glTexEnvf
#define glBegin MQ_glBegin
#define glEnd MQ_glEnd
#define glColor3ubv MQ_glColor3ubv
#define glTexCoord2f MQ_glTexCoord2f
#define glVertex3fv MQ_glVertex3fv
#define glVertex3f MQ_glVertex3f

#define VectorCopy(a,b) ((b)[0]=(a)[0],(b)[1]=(a)[1],(b)[2]=(a)[2])
#define VectorSubtract(a,b,c) ((c)[0]=(a)[0]-(b)[0],(c)[1]=(a)[1]-(b)[1],(c)[2]=(a)[2]-(b)[2])
#define VectorAdd(a,b,c) ((c)[0]=(a)[0]+(b)[0],(c)[1]=(a)[1]+(b)[1],(c)[2]=(a)[2]+(b)[2])
#define VectorScale(a,s,b) ((b)[0]=(a)[0]*(s),(b)[1]=(a)[1]*(s),(b)[2]=(a)[2]*(s))

#endif
