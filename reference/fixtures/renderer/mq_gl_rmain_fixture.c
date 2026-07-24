/*
Deterministic diagnostic sink for all active bodies in the pinned
WinQuake/gl_rmain.c.  This file supplies platform/dependency edges only; the
renderer functions under test are compiled directly from the pinned source.
*/

#include "quakedef.h"

viddef_t vid;
client_state_t cl;
entity_t cl_entities[MAX_EDICTS];
dlight_t cl_dlights[MAX_DLIGHTS];
int cl_numvisedicts;
entity_t *cl_visedicts[MAX_VISEDICTS];
float v_blend[4];
float gldepthmin;
float gldepthmax;
int glx, gly, glwidth, glheight;
cvar_t chase_active = {"chase_active", "0"};
cvar_t gl_ztrick = {"gl_ztrick", "0"};
vec3_t lightspot;

extern entity_t r_worldentity;
extern entity_t *currententity;
extern int r_framecount, c_brush_polys, c_alias_polys;
extern int lastposenum, mirrortexturenum;
extern int playertextures;
extern int currenttexture;
extern int mirror;
extern mplane_t *mirror_plane;
extern mplane_t frustum[4];
extern vec3_t vup, vpn, vright, r_origin, shadevector;
extern float shadelight;
extern refdef_t r_refdef;
extern cvar_t r_drawentities, r_drawviewmodel, r_shadows;
extern cvar_t r_mirroralpha, gl_clear, gl_polyblend, gl_cull;
extern cvar_t gl_smoothmodels, gl_affinemodels, gl_nocolors;

qboolean R_CullBox (vec3_t mins, vec3_t maxs);
void R_RotateForEntity (entity_t *entity);
mspriteframe_t *R_GetSpriteFrame (entity_t *entity);
void R_DrawSpriteModel (entity_t *entity);
void GL_DrawAliasFrame (aliashdr_t *header, int pose);
void GL_DrawAliasShadow (aliashdr_t *header, int pose);
void R_SetupAliasFrame (int frame, aliashdr_t *header);
void R_DrawAliasModel (entity_t *entity);
void R_DrawEntitiesOnList (void);
void R_DrawViewModel (void);
void R_PolyBlend (void);
int SignbitsForPlane (mplane_t *plane);
void R_SetFrustum (void);
void R_SetupFrame (void);
void MYgluPerspective (GLdouble fovy, GLdouble aspect,
	GLdouble near_value, GLdouble far_value);
void R_SetupGL (void);
void R_RenderScene (void);
void R_Clear (void);
void R_Mirror (void);
void R_RenderView (void);

static unsigned long mq_hash;
static int mq_calls;
static double mq_scalar_sum;
static int mq_vertices;
static int mq_binds;
static int mq_last_texture;
static unsigned long mq_clear_mask;
static unsigned long mq_depth_func;
static double mq_depth_min;
static double mq_depth_max;

static void MQ_ResetSink (void)
{
	mq_hash = 0;
	mq_calls = 0;
	mq_scalar_sum = 0;
	mq_vertices = 0;
	mq_binds = 0;
	mq_last_texture = -1;
	mq_clear_mask = 0;
	mq_depth_func = 0;
	mq_depth_min = 0;
	mq_depth_max = 0;
}

static void MQ_Note (int operation, double a, double b, double c, double d)
{
	unsigned __int64 next = (unsigned __int64)mq_hash * 131 + operation;
	mq_hash = (unsigned long)(next % 1000000007);
	mq_calls++;
	mq_scalar_sum += operation + a + b + c + d;
}

static void MQ_Emit (const char *scene, const char *function_name,
	double a, double b, double c, double d, double e, double f)
{
	printf (
		"{\"schema\":\"miniquake.renderer.gl.v1\","
		"\"scene\":\"%s\",\"function\":\"%s\",\"seq\":0,"
		"\"op\":\"state\",\"args\":[%d,%lu,%.12g,%d,%d,%d,%lu,%lu,"
		"%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g]}\n",
		scene, function_name, mq_calls, mq_hash, mq_scalar_sum,
		mq_vertices, mq_binds, mq_last_texture, mq_clear_mask, mq_depth_func,
		mq_depth_min, mq_depth_max, a, b, c, d, e, f);
}

void MQ_glTranslatef (GLfloat x, GLfloat y, GLfloat z)
{
	MQ_Note (1, x, y, z, 0);
}
void MQ_glRotatef (GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
{
	MQ_Note (2, angle, x, y, z);
}
void MQ_glColor3f (GLfloat red, GLfloat green, GLfloat blue)
{
	MQ_Note (3, red, green, blue, 0);
}
void MQ_glColor4f (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
{
	MQ_Note (4, red, green, blue, alpha);
}
void MQ_glColor4fv (const GLfloat *values)
{
	MQ_Note (5, values[0], values[1], values[2], values[3]);
}
void MQ_glEnable (GLenum capability)
{
	MQ_Note (6, capability, 0, 0, 0);
}
void MQ_glDisable (GLenum capability)
{
	MQ_Note (7, capability, 0, 0, 0);
}
void MQ_glBegin (GLenum mode)
{
	MQ_Note (8, mode, 0, 0, 0);
}
void MQ_glEnd (void)
{
	MQ_Note (9, 0, 0, 0, 0);
}
void MQ_glTexCoord2f (GLfloat s, GLfloat t)
{
	MQ_Note (10, s, t, 0, 0);
}
void MQ_glVertex3f (GLfloat x, GLfloat y, GLfloat z)
{
	mq_vertices++;
	MQ_Note (11, x, y, z, 0);
}
void MQ_glVertex3fv (const GLfloat *values)
{
	mq_vertices++;
	MQ_Note (12, values[0], values[1], values[2], 0);
}
void MQ_glPushMatrix (void)
{
	MQ_Note (13, 0, 0, 0, 0);
}
void MQ_glPopMatrix (void)
{
	MQ_Note (14, 0, 0, 0, 0);
}
void MQ_glScalef (GLfloat x, GLfloat y, GLfloat z)
{
	MQ_Note (15, x, y, z, 0);
}
void MQ_glShadeModel (GLenum mode)
{
	MQ_Note (16, mode, 0, 0, 0);
}
void MQ_glTexEnvf (GLenum target, GLenum name, GLfloat value)
{
	MQ_Note (17, target, name, value, 0);
}
void MQ_glHint (GLenum target, GLenum mode)
{
	MQ_Note (18, target, mode, 0, 0);
}
void MQ_glDepthRange (GLclampd minimum, GLclampd maximum)
{
	mq_depth_min = minimum;
	mq_depth_max = maximum;
	MQ_Note (19, minimum, maximum, 0, 0);
}
void MQ_glLoadIdentity (void)
{
	MQ_Note (20, 0, 0, 0, 0);
}
void MQ_glFrustum (GLdouble left, GLdouble right, GLdouble bottom,
	GLdouble top, GLdouble near_value, GLdouble far_value)
{
	MQ_Note (21, left + right, bottom + top, near_value, far_value);
}
void MQ_glMatrixMode (GLenum mode)
{
	MQ_Note (22, mode, 0, 0, 0);
}
void MQ_glViewport (GLint x, GLint y, GLsizei width, GLsizei height)
{
	MQ_Note (23, x, y, width, height);
}
void MQ_glCullFace (GLenum mode)
{
	MQ_Note (24, mode, 0, 0, 0);
}
void MQ_glGetFloatv (GLenum name, GLfloat *values)
{
	int i;
	MQ_Note (25, name, 0, 0, 0);
	for (i = 0; i < 16; i++)
		values[i] = (i % 5) == 0 ? 1.0f : 0.0f;
}
void MQ_glClear (GLbitfield mask)
{
	mq_clear_mask = mask;
	MQ_Note (26, mask, 0, 0, 0);
}
void MQ_glDepthFunc (GLenum function)
{
	mq_depth_func = function;
	MQ_Note (27, function, 0, 0, 0);
}
void MQ_glLoadMatrixf (const GLfloat *values)
{
	MQ_Note (28, values[0], values[5], values[10], values[15]);
}
void MQ_glFinish (void)
{
	MQ_Note (29, 0, 0, 0, 0);
}

void Sys_Error (char *error, ...)
{
	va_list arguments;
	va_start (arguments, error);
	vfprintf (stderr, error, arguments);
	va_end (arguments);
	fputc ('\n', stderr);
	exit (2);
}

double Sys_FloatTime (void)
{
	return 1.0;
}

void VectorMA (vec3_t veca, float scale, vec3_t vecb, vec3_t vecc)
{
	vecc[0] = veca[0] + scale * vecb[0];
	vecc[1] = veca[1] + scale * vecb[1];
	vecc[2] = veca[2] + scale * vecb[2];
}

vec_t Length (vec3_t vector)
{
	return (vec_t)sqrt (DotProduct (vector, vector));
}

vec_t VectorNormalize (vec3_t vector)
{
	vec_t length = Length (vector);
	if (length)
	{
		vector[0] /= length;
		vector[1] /= length;
		vector[2] /= length;
	}
	return length;
}

void AngleVectors (vec3_t angles, vec3_t forward, vec3_t right, vec3_t up)
{
	(void)angles;
	memset (forward, 0, sizeof(vec3_t));
	memset (right, 0, sizeof(vec3_t));
	memset (up, 0, sizeof(vec3_t));
	forward[0] = 1;
	right[1] = -1;
	up[2] = 1;
}

int BoxOnPlaneSide (vec3_t emins, vec3_t emaxs, mplane_t *plane)
{
	float distance1 = DotProduct (emaxs, plane->normal) - plane->dist;
	float distance2 = DotProduct (emins, plane->normal) - plane->dist;
	int sides = distance1 >= 0 ? 1 : 0;
	if (distance2 < 0)
		sides |= 2;
	return sides;
}

void Cvar_Set (char *var_name, char *value)
{
	(void)var_name; (void)value;
	MQ_Note (101, 0, 0, 0, 0);
}

void S_ExtraUpdate (void) { MQ_Note (102, 0, 0, 0, 0); }
void V_SetContentsColor (int contents) { MQ_Note (103, contents, 0, 0, 0); }

void *Mod_Extradata (model_t *model)
{
	return model->cache.data;
}

mleaf_t *Mod_PointInLeaf (vec3_t point, model_t *model)
{
	(void)point;
	return model ? model->leafs : NULL;
}

void Con_Printf (char *format, ...)
{
	(void)format;
}

void Con_DPrintf (char *format, ...)
{
	(void)format;
}

void GL_Bind (int texture)
{
	mq_binds++;
	mq_last_texture = texture;
	MQ_Note (104, texture, 0, 0, 0);
}
void GL_DisableMultitexture (void) { MQ_Note (105, 0, 0, 0, 0); }
void R_MarkLeaves (void) { MQ_Note (106, 0, 0, 0, 0); }
int R_LightPoint (vec3_t point)
{
	(void)point;
	MQ_Note (107, 0, 0, 0, 0);
	return 64;
}
void R_DrawBrushModel (entity_t *entity)
{
	(void)entity;
	MQ_Note (108, 0, 0, 0, 0);
}

void RotatePointAroundVector (vec3_t destination, const vec3_t direction,
	const vec3_t point, float degrees)
{
	(void)direction; (void)degrees;
	VectorCopy (point, destination);
}

void R_AnimateLight (void) { MQ_Note (109, 0, 0, 0, 0); }
void V_CalcBlend (void) { MQ_Note (110, 0, 0, 0, 0); }
void R_DrawWorld (void) { MQ_Note (111, 0, 0, 0, 0); }
void R_RenderDlights (void) { MQ_Note (112, 0, 0, 0, 0); }
void R_DrawParticles (void) { MQ_Note (113, 0, 0, 0, 0); }
void R_DrawWaterSurfaces (void) { MQ_Note (114, 0, 0, 0, 0); }
void R_RenderBrushPoly (msurface_t *surface)
{
	(void)surface;
	MQ_Note (115, 0, 0, 0, 0);
}

typedef union
{
	double alignment;
	byte bytes[4096];
} mq_alias_storage_t;

static aliashdr_t *MQ_MakeAlias (mq_alias_storage_t *storage)
{
	aliashdr_t *header;
	int *commands;
	trivertx_t *vertices;
	int index;
	memset (storage, 0, sizeof(*storage));
	header = (aliashdr_t *)storage->bytes;
	header->scale[0] = 1;
	header->scale[1] = 2;
	header->scale[2] = 3;
	header->scale_origin[0] = 0.5f;
	header->scale_origin[1] = 1.5f;
	header->scale_origin[2] = 2.5f;
	header->numframes = 1;
	header->numposes = 2;
	header->poseverts = 3;
	header->numtris = 1;
	header->frames[0].firstpose = 0;
	header->frames[0].numposes = 2;
	header->frames[0].interval = 0.1f;
	header->gl_texturenum[0][0] = 301;
	header->gl_texturenum[0][1] = 302;
	header->gl_texturenum[0][2] = 303;
	header->gl_texturenum[0][3] = 304;
	header->commands = (int)sizeof(aliashdr_t);
	commands = (int *)(storage->bytes + header->commands);
	commands[0] = 3;
	((float *)&commands[1])[0] = 0.0f;
	((float *)&commands[1])[1] = 0.0f;
	((float *)&commands[3])[0] = 1.0f;
	((float *)&commands[3])[1] = 0.0f;
	((float *)&commands[5])[0] = 0.5f;
	((float *)&commands[5])[1] = 1.0f;
	commands[7] = 0;
	header->posedata = header->commands + 8 * sizeof(int);
	vertices = (trivertx_t *)(storage->bytes + header->posedata);
	for (index = 0; index < 6; index++)
	{
		vertices[index].v[0] = (byte)(1 + index);
		vertices[index].v[1] = (byte)(2 + index);
		vertices[index].v[2] = (byte)(3 + index);
		vertices[index].lightnormalindex = 0;
	}
	return header;
}

static void MQ_MakeSprite (model_t *model, msprite_t *sprite,
	mspriteframe_t *frame, int texture)
{
	memset (model, 0, sizeof(*model));
	memset (sprite, 0, sizeof(*sprite));
	memset (frame, 0, sizeof(*frame));
	model->type = mod_sprite;
	model->cache.data = sprite;
	sprite->type = SPR_VP_PARALLEL;
	sprite->numframes = 1;
	sprite->frames[0].type = SPR_SINGLE;
	sprite->frames[0].frameptr = frame;
	frame->up = 2;
	frame->down = -2;
	frame->left = -1;
	frame->right = 1;
	frame->gl_texturenum = texture;
}

static void MQ_MakeAliasEntity (entity_t *entity, model_t *model,
	aliashdr_t *header)
{
	memset (entity, 0, sizeof(*entity));
	memset (model, 0, sizeof(*model));
	model->type = mod_alias;
	strcpy (model->name, "progs/fixture.mdl");
	model->mins[0] = model->mins[1] = model->mins[2] = -4;
	model->maxs[0] = model->maxs[1] = model->maxs[2] = 4;
	model->cache.data = header;
	entity->model = model;
	entity->origin[0] = 1;
	entity->origin[1] = 2;
	entity->origin[2] = 3;
	entity->angles[0] = 10;
	entity->angles[1] = 20;
	entity->angles[2] = 30;
}

static model_t mq_world_model;
static mleaf_t mq_world_leaf;
static texture_t mq_mirror_texture;
static texture_t *mq_world_textures[1];
static msurface_t mq_mirror_surface;
static byte mq_colormap[256];

static void MQ_PrepareWorld (void)
{
	memset (&mq_world_model, 0, sizeof(mq_world_model));
	memset (&mq_world_leaf, 0, sizeof(mq_world_leaf));
	memset (&mq_mirror_texture, 0, sizeof(mq_mirror_texture));
	memset (&mq_mirror_surface, 0, sizeof(mq_mirror_surface));
	mq_world_leaf.contents = CONTENTS_EMPTY;
	mq_world_model.leafs = &mq_world_leaf;
	mq_world_model.numtextures = 1;
	mq_world_textures[0] = &mq_mirror_texture;
	mq_world_model.textures = mq_world_textures;
	cl.worldmodel = &mq_world_model;
	r_worldentity.model = &mq_world_model;
	mirrortexturenum = 0;
	vid.width = 640;
	vid.height = 480;
	vid.colormap = mq_colormap;
	glwidth = 640;
	glheight = 480;
	glx = 0;
	gly = 0;
	r_refdef.vrect.x = 0;
	r_refdef.vrect.y = 0;
	r_refdef.vrect.width = 640;
	r_refdef.vrect.height = 480;
	r_refdef.fov_x = 90;
	r_refdef.fov_y = 75;
	r_refdef.vieworg[0] = 8;
	r_refdef.vieworg[1] = 4;
	r_refdef.vieworg[2] = 2;
	r_refdef.viewangles[0] = 5;
	r_refdef.viewangles[1] = 15;
	r_refdef.viewangles[2] = 1;
	cl.maxclients = 1;
	cl.stats[STAT_HEALTH] = 100;
	r_drawentities.value = 0;
	r_drawviewmodel.value = 0;
	gl_cull.value = 1;
	gl_polyblend.value = 1;
}

static void MQ_TraceCullBox (void)
{
	vec3_t outside = {-2, -1, -1};
	vec3_t outside_max = {-1, 1, 1};
	vec3_t inside = {1, -1, -1};
	vec3_t inside_max = {2, 1, 1};
	int first, second;
	memset (frustum, 0, sizeof(mplane_t) * 4);
	frustum[0].normal[0] = 1;
	MQ_ResetSink ();
	first = R_CullBox (outside, outside_max);
	second = R_CullBox (inside, inside_max);
	MQ_Emit ("rmain_cull_box", "R_CullBox", first, second, 0, 0, 0, 0);
}

static void MQ_TraceRotate (void)
{
	entity_t entity;
	memset (&entity, 0, sizeof(entity));
	entity.origin[0] = 1;
	entity.origin[1] = 2;
	entity.origin[2] = 3;
	entity.angles[0] = 10;
	entity.angles[1] = 20;
	entity.angles[2] = 30;
	MQ_ResetSink ();
	R_RotateForEntity (&entity);
	MQ_Emit ("rmain_rotate_entity", "R_RotateForEntity", 0, 0, 0, 0, 0, 0);
}

static void MQ_TraceGetSpriteFrame (void)
{
	model_t model;
	msprite_t sprite;
	mspriteframe_t frame;
	entity_t entity;
	mspriteframe_t group_frame0, group_frame1;
	float intervals[2] = {0.25f, 0.5f};
	struct
	{
		int numframes;
		float *intervals;
		mspriteframe_t *frames[2];
	} group;
	mspriteframe_t *single_result, *group_result;
	MQ_MakeSprite (&model, &sprite, &frame, 77);
	memset (&entity, 0, sizeof(entity));
	entity.model = &model;
	MQ_ResetSink ();
	single_result = R_GetSpriteFrame (&entity);
	memset (&group_frame0, 0, sizeof(group_frame0));
	memset (&group_frame1, 0, sizeof(group_frame1));
	group_frame0.gl_texturenum = 81;
	group_frame1.gl_texturenum = 82;
	group.numframes = 2;
	group.intervals = intervals;
	group.frames[0] = &group_frame0;
	group.frames[1] = &group_frame1;
	sprite.frames[0].type = SPR_GROUP;
	sprite.frames[0].frameptr = (mspriteframe_t *)&group;
	cl.time = 0.35;
	group_result = R_GetSpriteFrame (&entity);
	MQ_Emit ("rmain_get_sprite_frame", "R_GetSpriteFrame",
		single_result->gl_texturenum, group_result->gl_texturenum, 0, 0, 0, 0);
}

static void MQ_TraceDrawSprite (void)
{
	model_t model;
	msprite_t sprite;
	mspriteframe_t frame;
	entity_t entity;
	MQ_MakeSprite (&model, &sprite, &frame, 77);
	memset (&entity, 0, sizeof(entity));
	entity.model = &model;
	entity.origin[0] = 4;
	entity.origin[1] = 5;
	entity.origin[2] = 6;
	currententity = &entity;
	vup[0] = 0; vup[1] = 0; vup[2] = 1;
	vright[0] = 0; vright[1] = -1; vright[2] = 0;
	MQ_ResetSink ();
	R_DrawSpriteModel (&entity);
	MQ_Emit ("rmain_draw_sprite", "R_DrawSpriteModel", 0, 0, 0, 0, 0, 0);
}

static void MQ_TraceAliasFrame (void)
{
	mq_alias_storage_t storage;
	aliashdr_t *header = MQ_MakeAlias (&storage);
	shadelight = 2;
	MQ_ResetSink ();
	GL_DrawAliasFrame (header, 0);
	MQ_Emit ("rmain_alias_frame", "GL_DrawAliasFrame", lastposenum, 0, 0, 0, 0, 0);
}

static void MQ_TraceAliasShadow (void)
{
	mq_alias_storage_t storage;
	aliashdr_t *header = MQ_MakeAlias (&storage);
	entity_t entity;
	memset (&entity, 0, sizeof(entity));
	entity.origin[2] = 10;
	currententity = &entity;
	lightspot[2] = 2;
	shadevector[0] = 0.5f;
	shadevector[1] = 0.25f;
	shadevector[2] = 1;
	MQ_ResetSink ();
	GL_DrawAliasShadow (header, 0);
	MQ_Emit ("rmain_alias_shadow", "GL_DrawAliasShadow", 0, 0, 0, 0, 0, 0);
}

static void MQ_TraceSetupAliasFrame (void)
{
	mq_alias_storage_t storage;
	aliashdr_t *header = MQ_MakeAlias (&storage);
	cl.time = 0.35;
	shadelight = 1;
	MQ_ResetSink ();
	R_SetupAliasFrame (0, header);
	MQ_Emit ("rmain_setup_alias_frame", "R_SetupAliasFrame",
		lastposenum, 0, 0, 0, 0, 0);
}

static void MQ_TraceDrawAliasModel (void)
{
	mq_alias_storage_t storage;
	aliashdr_t *header = MQ_MakeAlias (&storage);
	model_t model;
	entity_t *entity = &cl_entities[1];
	int index;
	MQ_MakeAliasEntity (entity, &model, header);
	currententity = entity;
	cl.time = 0.25;
	cl.maxclients = 1;
	for (index = 0; index < 4; index++)
	{
		memset (&frustum[index], 0, sizeof(frustum[index]));
		frustum[index].normal[0] = 1;
		frustum[index].dist = -100;
	}
	memset (cl_dlights, 0, sizeof(cl_dlights));
	r_origin[0] = 10; r_origin[1] = 20; r_origin[2] = 30;
	r_shadows.value = 1;
	gl_smoothmodels.value = 1;
	gl_affinemodels.value = 1;
	gl_nocolors.value = 1;
	c_alias_polys = 0;
	MQ_ResetSink ();
	R_DrawAliasModel (entity);
	MQ_Emit ("rmain_draw_alias_model", "R_DrawAliasModel",
		c_alias_polys, lastposenum, 0, 0, 0, 0);
}

static void MQ_TraceDrawEntities (void)
{
	model_t brush_model, sprite_model;
	msprite_t sprite;
	mspriteframe_t frame;
	entity_t brush_entity, sprite_entity;
	memset (&brush_model, 0, sizeof(brush_model));
	memset (&brush_entity, 0, sizeof(brush_entity));
	memset (&sprite_entity, 0, sizeof(sprite_entity));
	brush_model.type = mod_brush;
	brush_entity.model = &brush_model;
	MQ_MakeSprite (&sprite_model, &sprite, &frame, 88);
	sprite_entity.model = &sprite_model;
	currententity = &sprite_entity;
	cl_numvisedicts = 2;
	cl_visedicts[0] = &brush_entity;
	cl_visedicts[1] = &sprite_entity;
	r_drawentities.value = 1;
	MQ_ResetSink ();
	R_DrawEntitiesOnList ();
	MQ_Emit ("rmain_draw_entities", "R_DrawEntitiesOnList",
		cl_numvisedicts, 0, 0, 0, 0, 0);
}

static void MQ_TraceDrawViewModel (void)
{
	mq_alias_storage_t storage;
	aliashdr_t *header = MQ_MakeAlias (&storage);
	model_t model;
	int index;
	MQ_MakeAliasEntity (&cl.viewent, &model, header);
	cl.time = 0.25;
	cl.items = 0;
	cl.stats[STAT_HEALTH] = 100;
	cl.maxclients = 1;
	for (index = 0; index < 4; index++)
	{
		memset (&frustum[index], 0, sizeof(frustum[index]));
		frustum[index].normal[0] = 1;
		frustum[index].dist = -100;
	}
	r_drawviewmodel.value = 1;
	r_drawentities.value = 1;
	chase_active.value = 0;
	mirror = false;
	gldepthmin = 0;
	gldepthmax = 1;
	MQ_ResetSink ();
	R_DrawViewModel ();
	MQ_Emit ("rmain_draw_view_model", "R_DrawViewModel",
		gldepthmin, gldepthmax, 0, 0, 0, 0);
}

static void MQ_TracePolyBlend (void)
{
	gl_polyblend.value = 1;
	v_blend[0] = 0.1f;
	v_blend[1] = 0.2f;
	v_blend[2] = 0.3f;
	v_blend[3] = 0.4f;
	MQ_ResetSink ();
	R_PolyBlend ();
	MQ_Emit ("rmain_poly_blend", "R_PolyBlend", 0, 0, 0, 0, 0, 0);
}

static void MQ_TraceSignbits (void)
{
	mplane_t plane;
	int result;
	memset (&plane, 0, sizeof(plane));
	plane.normal[0] = -1;
	plane.normal[1] = 2;
	plane.normal[2] = -3;
	MQ_ResetSink ();
	result = SignbitsForPlane (&plane);
	MQ_Emit ("rmain_signbits", "SignbitsForPlane", result, 0, 0, 0, 0, 0);
}

static void MQ_TraceSetFrustum (void)
{
	r_refdef.fov_x = 90;
	r_refdef.fov_y = 75;
	vpn[0] = 1; vpn[1] = 0; vpn[2] = 0;
	vright[0] = 0; vright[1] = -1; vright[2] = 0;
	vup[0] = 0; vup[1] = 0; vup[2] = 1;
	r_origin[0] = 2; r_origin[1] = 3; r_origin[2] = 4;
	MQ_ResetSink ();
	R_SetFrustum ();
	MQ_Emit ("rmain_set_frustum", "R_SetFrustum",
		frustum[0].normal[0], frustum[0].normal[1], frustum[0].dist,
		frustum[2].normal[2], frustum[2].dist, frustum[0].signbits);
}

static void MQ_TraceSetupFrame (void)
{
	MQ_PrepareWorld ();
	r_framecount = 7;
	c_brush_polys = 9;
	c_alias_polys = 11;
	MQ_ResetSink ();
	R_SetupFrame ();
	MQ_Emit ("rmain_setup_frame", "R_SetupFrame",
		r_framecount, r_origin[0], r_origin[1], r_origin[2],
		c_brush_polys, c_alias_polys);
}

static void MQ_TracePerspective (void)
{
	MQ_ResetSink ();
	MYgluPerspective (75, 4.0 / 3.0, 4, 4096);
	MQ_Emit ("rmain_perspective", "MYgluPerspective", 0, 0, 0, 0, 0, 0);
}

static void MQ_TraceSetupGL (void)
{
	MQ_PrepareWorld ();
	MQ_ResetSink ();
	R_SetupGL ();
	MQ_Emit ("rmain_setup_gl", "R_SetupGL", 0, 0, 0, 0, 0, 0);
}

static void MQ_TraceRenderScene (void)
{
	MQ_PrepareWorld ();
	MQ_ResetSink ();
	R_RenderScene ();
	MQ_Emit ("rmain_render_scene", "R_RenderScene",
		r_framecount, c_brush_polys, c_alias_polys, 0, 0, 0);
}

static void MQ_TraceClear (void)
{
	r_mirroralpha.value = 0.5f;
	gl_clear.value = 1;
	gl_ztrick.value = 0;
	MQ_ResetSink ();
	R_Clear ();
	r_mirroralpha.value = 1;
	gl_ztrick.value = 1;
	R_Clear ();
	R_Clear ();
	gl_ztrick.value = 0;
	gl_clear.value = 0;
	R_Clear ();
	MQ_Emit ("rmain_clear", "R_Clear",
		gldepthmin, gldepthmax, 0, 0, 0, 0);
}

static void MQ_TraceMirror (void)
{
	mplane_t plane;
	MQ_PrepareWorld ();
	memset (&plane, 0, sizeof(plane));
	plane.normal[0] = 1;
	plane.dist = 2;
	mirror_plane = &plane;
	mirror = true;
	mq_mirror_texture.texturechain = &mq_mirror_surface;
	cl.viewentity = 1;
	cl_numvisedicts = 0;
	MQ_ResetSink ();
	R_Mirror ();
	MQ_Emit ("rmain_mirror", "R_Mirror",
		r_refdef.vieworg[0], r_refdef.viewangles[0], r_refdef.viewangles[1],
		cl_numvisedicts, gldepthmin, gldepthmax);
}

static void MQ_TraceRenderView (void)
{
	MQ_PrepareWorld ();
	r_mirroralpha.value = 1;
	gl_ztrick.value = 0;
	gl_clear.value = 0;
	v_blend[3] = 0;
	MQ_ResetSink ();
	R_RenderView ();
	MQ_Emit ("rmain_render_view", "R_RenderView",
		r_framecount, c_brush_polys, c_alias_polys, mirror, 0, 0);
}

int main (void)
{
	MQ_PrepareWorld ();
	MQ_TraceCullBox ();
	MQ_TraceRotate ();
	MQ_TraceGetSpriteFrame ();
	MQ_TraceDrawSprite ();
	MQ_TraceAliasFrame ();
	MQ_TraceAliasShadow ();
	MQ_TraceSetupAliasFrame ();
	MQ_TraceDrawAliasModel ();
	MQ_TraceDrawEntities ();
	MQ_TraceDrawViewModel ();
	MQ_TracePolyBlend ();
	MQ_TraceSignbits ();
	MQ_TraceSetFrustum ();
	MQ_TraceSetupFrame ();
	MQ_TracePerspective ();
	MQ_TraceSetupGL ();
	MQ_TraceRenderScene ();
	MQ_TraceClear ();
	MQ_TraceMirror ();
	MQ_TraceRenderView ();
	return 0;
}
