/*
Deterministic platform/dependency fixture for the pinned WinQuake/r_part.c.
All particle functions under test are linked from the original translation
unit; this file only owns command-line, file, message, random and GL edges.
*/

#include "mq_r_part_fixture.h"

#define MQ_CAPACITY 2048
#define NUMVERTEXNORMALS 162

client_state_t cl;
server_t sv;
vec3_t vec3_origin;
vec3_t vup = {0, 0, 1};
vec3_t vright = {0, -1, 0};
vec3_t vpn = {1, 0, 0};
vec3_t r_origin;
unsigned int d_8to24table[256];
int particletexture = 77;
cvar_t sv_gravity = {"sv_gravity", "800", false, false, 800};
float r_avertexnormals[NUMVERTEXNORMALS][3];

int com_argc;
char **com_argv;

extern particle_t *active_particles, *free_particles, *particles;
extern int r_numparticles;
extern vec3_t avelocities[NUMVERTEXNORMALS];

void R_InitParticles (void);
void R_EntityParticles (entity_t *entity);
void R_ClearParticles (void);
void R_ReadPointFile_f (void);
void R_ParseParticleEffect (void);
void R_ParticleExplosion (vec3_t origin);
void R_ParticleExplosion2 (vec3_t origin, int color_start, int color_length);
void R_BlobExplosion (vec3_t origin);
void R_LavaSplash (vec3_t origin);
void R_TeleportSplash (vec3_t origin);
void R_RocketTrail (vec3_t start, vec3_t end, int type);
void R_DrawParticles (void);

static particle_t mq_pool[MQ_CAPACITY];
static unsigned long mq_seed;
static int mq_rand_calls;
static int mq_gl_calls;
static int mq_vertices;
static float mq_message_coords[3];
static int mq_message_chars[3];
static int mq_message_bytes[2];
static int mq_coord_index, mq_char_index, mq_byte_index;

static void MQ_ResetRandom (void)
{
	mq_seed = 1;
	mq_rand_calls = 0;
}

int MQ_Rand (void)
{
	mq_seed = mq_seed * 214013UL + 2531011UL;
	mq_rand_calls++;
	return (int)((mq_seed >> 16) & 0x7fff);
}

static void MQ_ResetPool (int capacity)
{
	int index;
	if (capacity > MQ_CAPACITY)
		capacity = MQ_CAPACITY;
	memset (mq_pool, 0, sizeof(mq_pool));
	particles = mq_pool;
	r_numparticles = capacity;
	active_particles = NULL;
	free_particles = mq_pool;
	for (index = 0; index < capacity - 1; index++)
		mq_pool[index].next = &mq_pool[index + 1];
	mq_pool[capacity - 1].next = NULL;
	MQ_ResetRandom ();
	cl.time = 2;
	cl.oldtime = 1.9f;
}

static int MQ_Count (particle_t *head)
{
	int count = 0;
	while (head)
	{
		count++;
		head = head->next;
	}
	return count;
}

static particle_t *MQ_Tail (particle_t *head)
{
	if (!head)
		return NULL;
	while (head->next)
		head = head->next;
	return head;
}

static void MQ_Emit (const char *scene, const char *function_name,
	double a, double b)
{
	particle_t *head = active_particles;
	particle_t *tail = MQ_Tail (active_particles);
	double head_color = head ? head->color : -1;
	double head_type = head ? head->type : -1;
	double tail_color = tail ? tail->color : -1;
	double tail_type = tail ? tail->type : -1;
	double tail_die = tail ? tail->die : -1;
	double tail_x = tail ? tail->org[0] : 0;
	double tail_y = tail ? tail->org[1] : 0;
	double tail_z = tail ? tail->org[2] : 0;
	double tail_vx = tail ? tail->vel[0] : 0;
	double tail_vy = tail ? tail->vel[1] : 0;
	double tail_vz = tail ? tail->vel[2] : 0;
	printf (
		"{\"schema\":\"miniquake.r_part.v1\",\"scene\":\"%s\","
		"\"function\":\"%s\",\"seq\":0,\"op\":\"state\","
		"\"args\":[%d,%d,%d,%d,%d,%.12g,%.12g,%.12g,%.12g,"
		"%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,"
		"%.12g,%.12g]}\n",
		scene, function_name, MQ_Count(active_particles),
		MQ_Count(free_particles), mq_rand_calls, mq_gl_calls, mq_vertices,
		head_color, head_type, tail_color, tail_type, tail_die,
		tail_x, tail_y, tail_z, tail_vx, tail_vy, tail_vz, a, b);
}

int COM_CheckParm (char *parameter)
{
	int index;
	for (index = 1; index < com_argc; index++)
		if (!strcmp (parameter, com_argv[index]))
			return index;
	return 0;
}

int Q_atoi (char *text)
{
	return atoi (text);
}

void *Hunk_AllocName (int size, char *name)
{
	(void)size; (void)name;
	memset (mq_pool, 0, sizeof(mq_pool));
	return mq_pool;
}

int COM_FOpenFile (char *name, FILE **file)
{
	(void)name;
	*file = tmpfile ();
	if (!*file)
		return -1;
	fputs ("1 2 3\n-4.5 6 7\n", *file);
	rewind (*file);
	return 2;
}

void Con_Printf (char *format, ...)
{
	(void)format;
}

float MSG_ReadCoord (void)
{
	return mq_message_coords[mq_coord_index++];
}

int MSG_ReadChar (void)
{
	return mq_message_chars[mq_char_index++];
}

int MSG_ReadByte (void)
{
	return mq_message_bytes[mq_byte_index++];
}

vec_t VectorNormalize (vec3_t vector)
{
	float length = (float)sqrt (
		vector[0] * vector[0] + vector[1] * vector[1] + vector[2] * vector[2]);
	if (length)
	{
		vector[0] /= length;
		vector[1] /= length;
		vector[2] /= length;
	}
	return length;
}

void GL_Bind (int texture) { mq_gl_calls++; (void)texture; }
void MQ_glEnable (GLenum value) { mq_gl_calls++; (void)value; }
void MQ_glDisable (GLenum value) { mq_gl_calls++; (void)value; }
void MQ_glTexEnvf (GLenum a, GLenum b, float c)
{ mq_gl_calls++; (void)a; (void)b; (void)c; }
void MQ_glBegin (GLenum value) { mq_gl_calls++; (void)value; }
void MQ_glEnd (void) { mq_gl_calls++; }
void MQ_glColor3ubv (const byte *color) { mq_gl_calls++; (void)color; }
void MQ_glTexCoord2f (float s, float t)
{ mq_gl_calls++; (void)s; (void)t; }
void MQ_glVertex3fv (const float *vertex)
{ mq_gl_calls++; mq_vertices++; (void)vertex; }
void MQ_glVertex3f (float x, float y, float z)
{ mq_gl_calls++; mq_vertices++; (void)x; (void)y; (void)z; }

static void MQ_ResetGl (void)
{
	mq_gl_calls = 0;
	mq_vertices = 0;
}

static void MQ_TraceInit (void)
{
	char *arguments[] = {"quake", "-particles", "128"};
	com_argc = 3;
	com_argv = arguments;
	MQ_ResetRandom ();
	MQ_ResetGl ();
	R_InitParticles ();
	MQ_Emit ("rpart_init", "R_InitParticles", r_numparticles, particles == mq_pool);
}

static void MQ_TraceEntity (void)
{
	entity_t entity;
	int index;
	MQ_ResetPool (2048);
	memset (avelocities, 0, sizeof(vec3_t) * NUMVERTEXNORMALS);
	memset (&entity, 0, sizeof(entity));
	entity.origin[0] = 1; entity.origin[1] = 2; entity.origin[2] = 3;
	for (index = 0; index < NUMVERTEXNORMALS; index++)
		r_avertexnormals[index][index % 3] = 1;
	MQ_ResetGl ();
	R_EntityParticles (&entity);
	MQ_Emit ("rpart_entity", "R_EntityParticles", 0, 0);
}

static void MQ_TraceClear (void)
{
	vec3_t origin = {0, 0, 0};
	vec3_t direction = {1, 0, 0};
	MQ_ResetPool (2048);
	R_RunParticleEffect (origin, direction, 40, 2);
	MQ_ResetRandom ();
	MQ_ResetGl ();
	R_ClearParticles ();
	MQ_Emit ("rpart_clear", "R_ClearParticles", 0, 0);
}

static void MQ_TracePointFile (void)
{
	MQ_ResetPool (2048);
	strcpy (sv.name, "fixture");
	MQ_ResetGl ();
	R_ReadPointFile_f ();
	MQ_Emit ("rpart_point_file", "R_ReadPointFile_f", 0, 0);
}

static void MQ_TraceParse (void)
{
	MQ_ResetPool (2048);
	mq_message_coords[0] = 1; mq_message_coords[1] = 2; mq_message_coords[2] = 3;
	mq_message_chars[0] = 16; mq_message_chars[1] = -16; mq_message_chars[2] = 0;
	mq_message_bytes[0] = 4; mq_message_bytes[1] = 40;
	mq_coord_index = mq_char_index = mq_byte_index = 0;
	MQ_ResetGl ();
	R_ParseParticleEffect ();
	MQ_Emit ("rpart_parse", "R_ParseParticleEffect", mq_coord_index, mq_byte_index);
}

static void MQ_TraceExplosion (void)
{
	vec3_t origin = {0, 0, 0};
	MQ_ResetPool (2048);
	MQ_ResetGl ();
	R_ParticleExplosion (origin);
	MQ_Emit ("rpart_explosion", "R_ParticleExplosion", 0, 0);
}

static void MQ_TraceExplosion2 (void)
{
	vec3_t origin = {0, 0, 0};
	MQ_ResetPool (2048);
	MQ_ResetGl ();
	R_ParticleExplosion2 (origin, 120, 3);
	MQ_Emit ("rpart_explosion2", "R_ParticleExplosion2", 0, 0);
}

static void MQ_TraceBlob (void)
{
	vec3_t origin = {0, 0, 0};
	MQ_ResetPool (2048);
	MQ_ResetGl ();
	R_BlobExplosion (origin);
	MQ_Emit ("rpart_blob", "R_BlobExplosion", 0, 0);
}

static void MQ_TraceRunEffect (void)
{
	vec3_t origin = {1, 2, 3};
	vec3_t direction = {1, -1, 0};
	MQ_ResetPool (2048);
	MQ_ResetGl ();
	R_RunParticleEffect (origin, direction, 40, 4);
	MQ_Emit ("rpart_run_effect", "R_RunParticleEffect", 0, 0);
}

static void MQ_TraceLava (void)
{
	vec3_t origin = {10, 20, 30};
	MQ_ResetPool (2048);
	MQ_ResetGl ();
	R_LavaSplash (origin);
	MQ_Emit ("rpart_lava", "R_LavaSplash", 0, 0);
}

static void MQ_TraceTeleport (void)
{
	vec3_t origin = {0, 0, 0};
	MQ_ResetPool (2048);
	MQ_ResetGl ();
	R_TeleportSplash (origin);
	MQ_Emit ("rpart_teleport", "R_TeleportSplash", 0, 0);
}

static void MQ_TraceRocket (void)
{
	vec3_t start = {0, 0, 0};
	vec3_t end = {10, 0, 0};
	MQ_ResetPool (2048);
	MQ_ResetGl ();
	R_RocketTrail (start, end, 0);
	MQ_Emit ("rpart_rocket", "R_RocketTrail", start[0], start[1]);
}

static void MQ_TraceDraw (void)
{
	particle_t *expired;
	particle_t *alive;
	MQ_ResetPool (2048);
	expired = &mq_pool[0];
	alive = &mq_pool[1];
	expired->die = 0;
	expired->next = alive;
	alive->org[0] = 100;
	alive->vel[2] = 10;
	alive->die = 10;
	alive->color = 5;
	alive->type = pt_blob2;
	alive->next = NULL;
	active_particles = expired;
	free_particles = &mq_pool[2];
	cl.time = 1;
	cl.oldtime = 0.9f;
	MQ_ResetRandom ();
	MQ_ResetGl ();
	R_DrawParticles ();
	MQ_Emit ("rpart_draw", "R_DrawParticles", alive->org[2], alive->vel[2]);
}

int main (void)
{
	int index;
	for (index = 0; index < 256; index++)
		d_8to24table[index] = (unsigned int)index;
	MQ_TraceInit ();
	MQ_TraceEntity ();
	MQ_TraceClear ();
	MQ_TracePointFile ();
	MQ_TraceParse ();
	MQ_TraceExplosion ();
	MQ_TraceExplosion2 ();
	MQ_TraceBlob ();
	MQ_TraceRunEffect ();
	MQ_TraceLava ();
	MQ_TraceTeleport ();
	MQ_TraceRocket ();
	MQ_TraceDraw ();
	return 0;
}
