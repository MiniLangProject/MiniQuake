/*
Deterministic diagnostic sink for original GLQuake gl_rmisc.c bodies.
Linked only into the generated differential executable.
*/

#include "mq_gl_rmisc_fixture.h"

texture_t *r_notexture_mip;
int particletexture;
int texture_extension_number;
int gl_alpha_format = GL_RGBA;
int gl_solid_format = GL_RGBA;
int playertextures;
qboolean envmap;
refdef_t r_refdef;
int glx, gly, glwidth, glheight;
client_state_t cl;
entity_t cl_entities[MAX_CLIENTS + 1];
entity_t *currententity;
unsigned int d_8to24table[256];
int d_lightstylevalue[MAX_LIGHTSTYLES];
entity_t r_worldentity;
mleaf_t *r_viewleaf;
int skytexturenum;
int mirrortexturenum;
qboolean gl_mtexable;
byte *hunk_base;
byte **player_8bit_texels_tbl;

cvar_t gl_finish, r_norefresh, r_lightmap, r_fullbright, r_drawentities;
cvar_t r_drawviewmodel, r_shadows, r_mirroralpha, r_wateralpha;
cvar_t r_dynamic, r_novis, r_speeds, gl_clear, gl_texsort;
cvar_t gl_cull, gl_smoothmodels, gl_affinemodels, gl_polyblend;
cvar_t gl_flashblend, gl_playermip, gl_nocolors;
cvar_t gl_keeptjunctions, gl_reporttjunctions, gl_doubleeyes;
cvar_t gl_max_size;

static const char *mq_scene;
static const char *mq_function;
static unsigned int mq_sequence;
static byte mq_hunk[4096];
static int mq_bound_texture;
static unsigned int mq_upload_hash;
static int mq_upload_width;
static int mq_upload_height;
static int mq_commands;
static int mq_cvars;
static int mq_init_particles;
static int mq_clear_particles;
static int mq_build_lightmaps;
static int mq_render_views;
static int mq_end_rendering;
static int mq_last_draw_buffer;
static int mq_float_time_calls;

typedef struct
{
	aliashdr_t header;
	byte skin[16];
} mq_alias_fixture_t;

extern void R_InitTextures (void);
extern void R_InitParticleTexture (void);
extern void R_Envmap_f (void);
extern void R_Init (void);
extern void R_TranslatePlayerSkin (int playernum);
extern void R_NewMap (void);
extern void R_TimeRefresh_f (void);
extern void D_FlushCaches (void);

static void MQ_ResetTrace (const char *scene, const char *function)
{
	mq_scene = scene;
	mq_function = function;
	mq_sequence = 0;
}

static void MQ_Prefix (const char *operation)
{
	printf ("{\"schema\":\"miniquake.renderer.gl.v1\","
		"\"scene\":\"%s\",\"function\":\"%s\",\"seq\":%u,"
		"\"op\":\"%s\",\"args\":", mq_scene, mq_function,
		mq_sequence++, operation);
}

static unsigned int MQ_Hash (const void *pointer, size_t length)
{
	const byte *data = (const byte *)pointer;
	unsigned int hash = 2166136261u;
	size_t index;
	for (index = 0; index < length; ++index)
	{
		hash ^= data[index];
		hash *= 16777619u;
	}
	return hash;
}

static void MQ_ResetGlobals (void)
{
	int index;
	memset (mq_hunk, 0, sizeof(mq_hunk));
	memset (&cl, 0, sizeof(cl));
	memset (cl_entities, 0, sizeof(cl_entities));
	memset (&r_refdef, 0, sizeof(r_refdef));
	memset (d_lightstylevalue, 0, sizeof(d_lightstylevalue));
	memset (&r_worldentity, 0, sizeof(r_worldentity));
	r_notexture_mip = 0;
	particletexture = 0;
	texture_extension_number = 1000;
	playertextures = 0;
	envmap = false;
	r_viewleaf = 0;
	skytexturenum = -1;
	mirrortexturenum = -1;
	gl_mtexable = false;
	gl_texsort.value = 1;
	gl_max_size.value = 4;
	gl_playermip.value = 0;
	mq_bound_texture = -1;
	mq_upload_hash = 0;
	mq_upload_width = 0;
	mq_upload_height = 0;
	mq_commands = 0;
	mq_cvars = 0;
	mq_init_particles = 0;
	mq_clear_particles = 0;
	mq_build_lightmaps = 0;
	mq_render_views = 0;
	mq_end_rendering = 0;
	mq_last_draw_buffer = -1;
	mq_float_time_calls = 0;
	for (index = 0; index < 256; ++index)
		d_8to24table[index] = 0xff000000u |
			((unsigned int)index << 16) |
			((unsigned int)index << 8) |
			(unsigned int)index;
}

void *Hunk_AllocName (int size, const char *name)
{
	(void)name;
	if (size > (int)sizeof(mq_hunk))
		Sys_Error ("fixture hunk overflow");
	memset (mq_hunk, 0, (size_t)size);
	return mq_hunk;
}

void GL_DisableMultitexture (void) {}

void GL_Bind (int texture)
{
	mq_bound_texture = texture;
}

void glTexImage2D (GLenum target, int level, int internal_format,
	int width, int height, int border, GLenum format, GLenum type,
	const void *pixels)
{
	(void)target; (void)level; (void)internal_format; (void)border;
	(void)format; (void)type;
	mq_upload_width = width;
	mq_upload_height = height;
	mq_upload_hash = MQ_Hash (pixels, (size_t)width * (size_t)height * 4u);
}

void glTexEnvf (GLenum target, GLenum name, float value)
{
	(void)target; (void)name; (void)value;
}

void glTexParameterf (GLenum target, GLenum name, float value)
{
	(void)target; (void)name; (void)value;
}

void glDrawBuffer (GLenum mode)
{
	mq_last_draw_buffer = (int)mode;
}

void glReadBuffer (GLenum mode)
{
	(void)mode;
}

void glReadPixels (int x, int y, int width, int height,
	GLenum format, GLenum type, void *pixels)
{
	(void)x; (void)y; (void)format; (void)type;
	memset (pixels, mq_render_views & 255, (size_t)width * (size_t)height * 4u);
}

void glFinish (void) {}

void GL_BeginRendering (int *x, int *y, int *width, int *height)
{
	*x = *y = 0;
	*width = *height = 256;
}

void GL_EndRendering (void)
{
	++mq_end_rendering;
}

void R_RenderView (void)
{
	++mq_render_views;
}

void COM_WriteFile (const char *name, const void *data, int length)
{
	(void)data;
	MQ_Prefix ("env_view");
	printf ("[%d,%.9g,%.9g,%d]}\n", name[3] - '0',
		r_refdef.viewangles[0], r_refdef.viewangles[1], length);
}

void Cmd_AddCommand (const char *name, void (*function)(void))
{
	(void)name; (void)function;
	++mq_commands;
}

void Cvar_RegisterVariable (cvar_t *variable)
{
	(void)variable;
	++mq_cvars;
}

void Cvar_SetValue (const char *name, float value)
{
	if (!strcmp (name, "gl_texsort"))
		gl_texsort.value = value;
}

void R_InitParticles (void)
{
	++mq_init_particles;
}

void R_ClearParticles (void)
{
	++mq_clear_particles;
}

void GL_BuildLightmaps (void)
{
	++mq_build_lightmaps;
}

void *Mod_Extradata (model_t *model)
{
	return model->extradata;
}

qboolean VID_Is8bit (void)
{
	return false;
}

void GL_Upload8_EXT (byte *data, int width, int height,
	qboolean mipmap, qboolean alpha)
{
	(void)mipmap; (void)alpha;
	mq_upload_width = width;
	mq_upload_height = height;
	mq_upload_hash = MQ_Hash (data, (size_t)width * (size_t)height);
}

double Sys_FloatTime (void)
{
	return mq_float_time_calls++ == 0 ? 10.0 : 12.0;
}

void Con_Printf (const char *format, ...)
{
	(void)format;
}

void Sys_Error (const char *format, ...)
{
	va_list arguments;
	va_start (arguments, format);
	vfprintf (stderr, format, arguments);
	va_end (arguments);
	fputc ('\n', stderr);
	exit (2);
}

void R_ReadPointFile_f (void) {}

static void MQ_RunInitTextures (void)
{
	byte *pixels;
	MQ_ResetGlobals ();
	MQ_ResetTrace ("rmisc_init_textures", "R_InitTextures");
	R_InitTextures ();
	pixels = (byte *)r_notexture_mip + r_notexture_mip->offsets[0];
	MQ_Prefix ("texture");
	printf ("[%u,%u,%u,%u,%u,%u]}\n",
		r_notexture_mip->width, r_notexture_mip->height,
		r_notexture_mip->offsets[0], r_notexture_mip->offsets[1],
		r_notexture_mip->offsets[2],
		MQ_Hash (pixels, 16 * 16 + 8 * 8 + 4 * 4 + 2 * 2));
}

static void MQ_RunInitParticleTexture (void)
{
	MQ_ResetGlobals ();
	MQ_ResetTrace ("rmisc_init_particle", "R_InitParticleTexture");
	R_InitParticleTexture ();
	MQ_Prefix ("particle");
	printf ("[%d,%d,%d,%d,%u]}\n", particletexture,
		texture_extension_number, mq_bound_texture,
		mq_upload_width * mq_upload_height, mq_upload_hash);
}

static void MQ_RunEnvmap (void)
{
	MQ_ResetGlobals ();
	MQ_ResetTrace ("rmisc_envmap", "R_Envmap_f");
	R_Envmap_f ();
	MQ_Prefix ("state");
	printf ("[%d,%d,%d,%d]}\n", envmap, mq_render_views,
		mq_last_draw_buffer, mq_end_rendering);
}

static void MQ_RunInit (void)
{
	MQ_ResetGlobals ();
	gl_mtexable = true;
	MQ_ResetTrace ("rmisc_init", "R_Init");
	R_Init ();
	MQ_Prefix ("state");
	printf ("[%d,%d,%d,%d,%d,%d]}\n", mq_commands, mq_cvars,
		mq_init_particles, playertextures, texture_extension_number,
		(int)gl_texsort.value);
}

static void MQ_RunTranslatePlayerSkin (void)
{
	mq_alias_fixture_t alias;
	model_t model;
	int index;
	MQ_ResetGlobals ();
	memset (&alias, 0, sizeof(alias));
	memset (&model, 0, sizeof(model));
	alias.header.skinwidth = 4;
	alias.header.skinheight = 4;
	alias.header.numskins = 1;
	alias.header.texels[0] = (int)offsetof(mq_alias_fixture_t, skin);
	for (index = 0; index < 16; ++index)
		alias.skin[index] = (byte)(TOP_RANGE + index);
	model.type = mod_alias;
	model.extradata = &alias;
	cl_entities[1].model = &model;
	cl_entities[1].skinnum = 0;
	cl.scores[0].colors = 0xd3;
	playertextures = 2000;
	MQ_ResetTrace ("rmisc_translate_skin", "R_TranslatePlayerSkin");
	R_TranslatePlayerSkin (0);
	MQ_Prefix ("skin");
	printf ("[%d,%d,%d,%u]}\n", mq_bound_texture,
		mq_upload_width, mq_upload_height, mq_upload_hash);
}

static void MQ_RunNewMap (void)
{
	model_t world;
	mleaf_t leaves[2];
	texture_t sky, mirror_texture, brick;
	texture_t *textures[3];
	MQ_ResetGlobals ();
	memset (&world, 0, sizeof(world));
	memset (leaves, 0, sizeof(leaves));
	memset (&sky, 0, sizeof(sky));
	memset (&mirror_texture, 0, sizeof(mirror_texture));
	memset (&brick, 0, sizeof(brick));
	strcpy (sky.name, "skyfixture");
	strcpy (mirror_texture.name, "window02_1");
	strcpy (brick.name, "brick");
	sky.texturechain = (void *)1;
	mirror_texture.texturechain = (void *)1;
	brick.texturechain = (void *)1;
	textures[0] = &sky; textures[1] = &mirror_texture; textures[2] = &brick;
	leaves[0].efrags = (void *)1;
	leaves[1].efrags = (void *)1;
	world.numleafs = 2;
	world.leafs = leaves;
	world.numtextures = 3;
	world.textures = textures;
	cl.worldmodel = &world;
	r_viewleaf = &leaves[1];
	MQ_ResetTrace ("rmisc_new_map", "R_NewMap");
	R_NewMap ();
	MQ_Prefix ("state");
	printf ("[%d,%d,%d,%d,%d,%d,%d,%d,%d]}\n",
		d_lightstylevalue[0], d_lightstylevalue[255],
		r_worldentity.model == &world,
		leaves[0].efrags == 0 && leaves[1].efrags == 0,
		r_viewleaf == 0, skytexturenum, mirrortexturenum,
		mq_clear_particles, mq_build_lightmaps);
}

static void MQ_RunTimeRefresh (void)
{
	MQ_ResetGlobals ();
	MQ_ResetTrace ("rmisc_time_refresh", "R_TimeRefresh_f");
	R_TimeRefresh_f ();
	MQ_Prefix ("state");
	printf ("[%d,%.9g,%d,%d]}\n", mq_render_views,
		r_refdef.viewangles[1], mq_last_draw_buffer, mq_end_rendering);
}

static void MQ_RunFlushCaches (void)
{
	MQ_ResetGlobals ();
	MQ_ResetTrace ("rmisc_flush_caches", "D_FlushCaches");
	D_FlushCaches ();
	MQ_Prefix ("state");
	printf ("[]}\n");
}

int main (void)
{
	MQ_RunInitTextures ();
	MQ_RunInitParticleTexture ();
	MQ_RunEnvmap ();
	MQ_RunInit ();
	MQ_RunTranslatePlayerSkin ();
	MQ_RunNewMap ();
	MQ_RunTimeRefresh ();
	MQ_RunFlushCaches ();
	return 0;
}
