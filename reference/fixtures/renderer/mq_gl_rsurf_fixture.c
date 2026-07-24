/*
Deterministic diagnostic sink for original GLQuake gl_rsurf.c bodies.
Linked only into the generated differential executable.
*/

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include "mq_gl_rsurf_fixture.h"

client_state_t cl;
dlight_t cl_dlights[MAX_DLIGHTS];
int d_lightstylevalue[MAX_LIGHTSTYLES];
cvar_t r_fullbright;
cvar_t gl_texsort;
cvar_t r_lightmap;
cvar_t r_dynamic;
cvar_t r_wateralpha;
cvar_t r_mirroralpha;
cvar_t r_novis;
cvar_t gl_keeptjunctions;
cvar_t gl_flashblend;
int gl_lightmap_format = GL_LUMINANCE;
qboolean gl_mtexable;
int r_framecount;
int r_visframecount;
int c_brush_polys;
entity_t *currententity;
int currenttexture;
double realtime;
float r_world_matrix[16];
qboolean mirror;
mplane_t *mirror_plane;
int mirrortexturenum;
vec3_t modelorg;
refdef_t r_refdef;
mleaf_t *r_viewleaf;
mleaf_t *r_oldviewleaf;
int texture_extension_number = 1000;
qboolean isPermedia;
int solidskytexture = 701;
int alphaskytexture = 702;
float speedscale;

extern int lightmap_bytes;
extern int lightmap_textures;
extern unsigned int blocklights[18 * 18];
extern int active_lightmaps;
extern glpoly_t *lightmap_polys[64];
extern qboolean lightmap_modified[64];
extern byte lightmap_rectchange[64][4];
extern int allocated[64][128];
extern byte lightmaps[4 * 64 * 128 * 128];
extern msurface_t *skychain;
extern msurface_t *waterchain;
extern qboolean mtexenabled;
extern lpMTexFUNC qglMTexCoord2fSGIS;
extern lpSelTexFUNC qglSelectTextureSGIS;
extern mvertex_t *r_pcurrentvertbase;
extern model_t *currentmodel;
extern int nColinElim;

extern void R_AddDynamicLights (msurface_t *surface);
extern void R_BuildLightMap (msurface_t *surface, byte *destination, int stride);
extern texture_t *R_TextureAnimation (texture_t *base);
extern void GL_DisableMultitexture (void);
extern void GL_EnableMultitexture (void);
extern void R_DrawSequentialPoly (msurface_t *surface);
extern void DrawGLWaterPoly (glpoly_t *polygon);
extern void DrawGLWaterPolyLightmap (glpoly_t *polygon);
extern void DrawGLPoly (glpoly_t *polygon);
extern void R_BlendLightmaps (void);
extern void R_RenderBrushPoly (msurface_t *surface);
extern void R_RenderDynamicLightmaps (msurface_t *surface);
extern void R_MirrorChain (msurface_t *surface);
extern void R_DrawWaterSurfaces (void);
extern void DrawTextureChains (void);
extern void R_DrawBrushModel (entity_t *entity);
extern void R_RecursiveWorldNode (mnode_t *node);
extern void R_DrawWorld (void);
extern void R_MarkLeaves (void);
extern int AllocBlock (int width, int height, int *x, int *y);
extern void BuildSurfaceDisplayList (msurface_t *surface);
extern void GL_CreateSurfaceLightmap (msurface_t *surface);
extern void GL_BuildLightmaps (void);

static const char *mq_scene;
static const char *mq_function;
static unsigned int mq_sequence;
static byte mq_hunk[1024 * 1024];
static size_t mq_hunk_used;

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

void *Hunk_Alloc (int size)
{
	size_t aligned = ((size_t)size + 15u) & ~15u;
	void *result;
	if (mq_hunk_used + aligned > sizeof(mq_hunk))
		Sys_Error ("fixture hunk exhausted");
	result = mq_hunk + mq_hunk_used;
	memset (result, 0, aligned);
	mq_hunk_used += aligned;
	return result;
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

float VectorNormalize (vec3_t vector)
{
	float length = (float)sqrt (DotProduct (vector, vector));
	if (length != 0)
	{
		vector[0] /= length;
		vector[1] /= length;
		vector[2] /= length;
	}
	return length;
}

int COM_CheckParm (const char *parameter)
{
	(void)parameter;
	return 0;
}

void GL_Bind (int texture)
{
	MQ_Prefix ("bind_texture");
	printf ("[%u,%d]}\n", GL_TEXTURE_2D, texture);
}

void GL_SelectTexture (GLenum target)
{
	MQ_Prefix ("select_texture");
	printf ("[%u]}\n", target);
}

void EmitWaterPolys (msurface_t *surface)
{
	MQ_Prefix ("emit_water");
	printf ("[%d]}\n", surface ? surface->flags : -1);
}

void EmitSkyPolys (msurface_t *surface)
{
	MQ_Prefix ("emit_sky");
	printf ("[%d]}\n", surface ? surface->flags : -1);
}

void EmitBothSkyLayers (msurface_t *surface)
{
	MQ_Prefix ("emit_both_sky");
	printf ("[%d]}\n", surface ? surface->flags : -1);
}

void R_DrawSkyChain (msurface_t *surface)
{
	int count = 0;
	while (surface)
	{
		++count;
		surface = surface->texturechain;
	}
	MQ_Prefix ("draw_sky_chain");
	printf ("[%d]}\n", count);
}

void R_ClearSkyBox (void) {}
void R_DrawSkyBox (void) {}

void R_MarkLights (dlight_t *light, int bit, mnode_t *node)
{
	(void)light;
	(void)node;
	MQ_Prefix ("mark_lights");
	printf ("[%d]}\n", bit);
}

qboolean R_CullBox (const float *minimums, const float *maximums)
{
	(void)minimums;
	(void)maximums;
	return false;
}

void R_StoreEfrags (efrag_t **efrags)
{
	(void)efrags;
	MQ_Prefix ("store_efrags");
	printf ("[]}\n");
}

void AngleVectors (const vec3_t angles, vec3_t forward, vec3_t right, vec3_t up)
{
	(void)angles;
	forward[0] = 1; forward[1] = 0; forward[2] = 0;
	right[0] = 0; right[1] = -1; right[2] = 0;
	up[0] = 0; up[1] = 0; up[2] = 1;
}

void R_RotateForEntity (entity_t *entity)
{
	MQ_Prefix ("translate");
	printf ("[%.9g,%.9g,%.9g]}\n",
		entity->origin[0], entity->origin[1], entity->origin[2]);
	MQ_Prefix ("rotate");
	printf ("[%.9g,0,0,1]}\n", entity->angles[1]);
	MQ_Prefix ("rotate");
	printf ("[%.9g,0,1,0]}\n", -entity->angles[0]);
	MQ_Prefix ("rotate");
	printf ("[%.9g,1,0,0]}\n", entity->angles[2]);
}

byte *Mod_LeafPVS (mleaf_t *leaf, model_t *model)
{
	static byte visibility[1] = {1};
	(void)leaf;
	(void)model;
	return visibility;
}

void glBegin (GLenum mode)
{
	MQ_Prefix ("begin");
	printf ("[%u]}\n", mode);
}

void glEnd (void)
{
	MQ_Prefix ("end");
	printf ("[]}\n");
}

void glTexCoord2f (float s, float t)
{
	MQ_Prefix ("texcoord");
	printf ("[%.9g,%.9g]}\n", s, t);
}

void glVertex3fv (const float *vertex)
{
	MQ_Prefix ("vertex");
	printf ("[%.9g,%.9g,%.9g]}\n", vertex[0], vertex[1], vertex[2]);
}

void glEnable (GLenum capability)
{
	MQ_Prefix ("enable");
	printf ("[%u]}\n", capability);
}

void glDisable (GLenum capability)
{
	MQ_Prefix ("disable");
	printf ("[%u]}\n", capability);
}

void glBlendFunc (GLenum source, GLenum destination)
{
	MQ_Prefix ("blend_function");
	printf ("[%u,%u]}\n", source, destination);
}

void glDepthMask (byte enabled)
{
	MQ_Prefix ("depth_mask");
	printf ("[%u]}\n", (unsigned int)enabled);
}

void glTexEnvf (GLenum target, GLenum name, float value)
{
	MQ_Prefix ("texture_environment");
	printf ("[%u,%u,%.9g]}\n", target, name, value);
}

void glColor3f (float red, float green, float blue)
{
	MQ_Prefix ("color");
	printf ("[%.9g,%.9g,%.9g,1]}\n", red, green, blue);
}

void glColor4f (float red, float green, float blue, float alpha)
{
	MQ_Prefix ("color");
	printf ("[%.9g,%.9g,%.9g,%.9g]}\n", red, green, blue, alpha);
}

void glTexSubImage2D (GLenum target, int level, int x, int y,
	int width, int height, GLenum format, GLenum type, const void *pixels)
{
	size_t length = (size_t)width * (size_t)height * (size_t)lightmap_bytes;
	MQ_Prefix ("upload_subimage");
	printf ("[%u,%d,%d,%d,%d,%d,%u,%u,%u]}\n", target, level,
		x, y, width, height, format, type, MQ_Hash (pixels, length));
}

void glTexParameterf (GLenum target, GLenum name, float value)
{
	MQ_Prefix ("texture_parameter");
	printf ("[%u,%u,%.9g]}\n", target, name, value);
}

void glTexImage2D (GLenum target, int level, int internal_format,
	int width, int height, int border, GLenum format, GLenum type,
	const void *pixels)
{
	size_t length = (size_t)width * (size_t)height * (size_t)lightmap_bytes;
	MQ_Prefix ("upload_lightmap");
	printf ("[%u,%d,%d,%d,%d,%d,%u,%u,%u]}\n", target, level,
		internal_format, width, height, border, format, type,
		MQ_Hash (pixels, length));
}

void glLoadMatrixf (const float *matrix)
{
	MQ_Prefix ("load_matrix");
	printf ("[%u]}\n", MQ_Hash (matrix, 16 * sizeof(float)));
}

void glPushMatrix (void)
{
	MQ_Prefix ("push_matrix");
	printf ("[]}\n");
}

void glPopMatrix (void)
{
	MQ_Prefix ("pop_matrix");
	printf ("[]}\n");
}

static void MQ_MultiTexCoord (GLenum target, GLfloat s, GLfloat t)
{
	MQ_Prefix ("multitexcoord");
	printf ("[%u,%.9g,%.9g]}\n", target, s, t);
}

typedef struct
{
	mplane_t plane;
	texture_t texture;
	mtexinfo_t texinfo;
	msurface_t surface;
	glpoly_t polygon;
	byte samples[8];
	model_t model;
	texture_t *textures[4];
} mq_surface_fixture_t;

static void MQ_SetVertex (float *vertex, float x, float y, float z,
	float s, float t, float light_s, float light_t)
{
	vertex[0] = x; vertex[1] = y; vertex[2] = z;
	vertex[3] = s; vertex[4] = t;
	vertex[5] = light_s; vertex[6] = light_t;
}

static void MQ_ResetGlobals (void)
{
	memset (&cl, 0, sizeof(cl));
	memset (cl_dlights, 0, sizeof(cl_dlights));
	memset (d_lightstylevalue, 0, sizeof(d_lightstylevalue));
	memset (blocklights, 0, 18 * 18 * sizeof(blocklights[0]));
	memset (lightmap_polys, 0, 64 * sizeof(lightmap_polys[0]));
	memset (lightmap_modified, 0, 64 * sizeof(lightmap_modified[0]));
	memset (lightmap_rectchange, 0, 64 * 4);
	memset (allocated, 0, 64 * 128 * sizeof(allocated[0][0]));
	memset (lightmaps, 0, 4 * 64 * 128 * 128);
	memset (r_world_matrix, 0, sizeof(r_world_matrix));
	r_world_matrix[0] = r_world_matrix[5] = 1;
	r_world_matrix[10] = r_world_matrix[15] = 1;
	r_fullbright.value = 0;
	gl_texsort.value = 1;
	r_lightmap.value = 0;
	r_dynamic.value = 1;
	r_wateralpha.value = 1;
	r_mirroralpha.value = 1;
	r_novis.value = 0;
	gl_keeptjunctions.value = 0;
	gl_flashblend.value = 1;
	gl_lightmap_format = GL_LUMINANCE;
	gl_mtexable = false;
	r_framecount = 7;
	r_visframecount = 3;
	c_brush_polys = 0;
	currenttexture = -1;
	realtime = 0.25;
	mirror = false;
	mirror_plane = 0;
	mirrortexturenum = 3;
	skychain = 0;
	waterchain = 0;
	mtexenabled = false;
	lightmap_bytes = 1;
	lightmap_textures = 500;
	active_lightmaps = 0;
	texture_extension_number = 1000;
	qglMTexCoord2fSGIS = MQ_MultiTexCoord;
	qglSelectTextureSGIS = 0;
	mq_hunk_used = 0;
}

static void MQ_InitSurface (mq_surface_fixture_t *fixture)
{
	int index;
	memset (fixture, 0, sizeof(*fixture));
	fixture->plane.normal[2] = 1;
	fixture->texture.width = 64;
	fixture->texture.height = 64;
	fixture->texture.gl_texturenum = 77;
	strcpy (fixture->texture.name, "fixture");
	fixture->texinfo.vecs[0][0] = 1;
	fixture->texinfo.vecs[1][1] = 1;
	fixture->texinfo.texture = &fixture->texture;
	fixture->surface.plane = &fixture->plane;
	fixture->surface.extents[0] = 16;
	fixture->surface.extents[1] = 16;
	fixture->surface.texinfo = &fixture->texinfo;
	fixture->surface.polys = &fixture->polygon;
	fixture->surface.styles[0] = 0;
	fixture->surface.styles[1] = 1;
	fixture->surface.styles[2] = 255;
	fixture->surface.samples = fixture->samples;
	fixture->surface.lightmaptexturenum = 0;
	fixture->surface.light_s = 2;
	fixture->surface.light_t = 3;
	fixture->polygon.numverts = 4;
	MQ_SetVertex (fixture->polygon.verts[0], 0, 0, 0, 0, 0, .1f, .2f);
	MQ_SetVertex (fixture->polygon.verts[1], 16, 0, 0, 1, 0, .3f, .2f);
	MQ_SetVertex (fixture->polygon.verts[2], 16, 16, 0, 1, 1, .3f, .4f);
	MQ_SetVertex (fixture->polygon.verts[3], 0, 16, 0, 0, 1, .1f, .4f);
	for (index = 0; index < 8; ++index)
		fixture->samples[index] = (byte)(20 + index * 7);
	fixture->model.numsurfaces = 1;
	fixture->model.surfaces = &fixture->surface;
	fixture->model.lightdata = fixture->samples;
	fixture->textures[0] = &fixture->texture;
	fixture->model.numtextures = 1;
	fixture->model.textures = fixture->textures;
	cl.worldmodel = &fixture->model;
	d_lightstylevalue[0] = 256;
	d_lightstylevalue[1] = 128;
	fixture->surface.cached_light[0] = 256;
	fixture->surface.cached_light[1] = 128;
}

static void MQ_InitWorldTree (mq_surface_fixture_t *fixture, mnode_t nodes[3])
{
	memset (nodes, 0, 3 * sizeof(nodes[0]));
	nodes[0].contents = 0;
	nodes[0].visframe = r_visframecount;
	nodes[0].plane = &fixture->plane;
	nodes[0].children[0] = &nodes[1];
	nodes[0].children[1] = &nodes[2];
	nodes[0].firstsurface = 0;
	nodes[0].numsurfaces = 1;
	nodes[1].contents = CONTENTS_SOLID;
	nodes[2].contents = CONTENTS_SOLID;
	fixture->surface.visframe = r_framecount;
	fixture->model.nodes = nodes;
	fixture->model.numnodes = 3;
	modelorg[2] = 10;
}

static void MQ_ResultHash (const char *operation, const void *data, size_t length)
{
	MQ_Prefix (operation);
	printf ("[%u]}\n", MQ_Hash (data, length));
}

static void MQ_RunAddDynamicLights (void)
{
	mq_surface_fixture_t fixture;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	fixture.surface.dlightbits = 1;
	cl_dlights[0].origin[0] = 8;
	cl_dlights[0].origin[1] = 8;
	cl_dlights[0].origin[2] = 16;
	cl_dlights[0].radius = 64;
	MQ_ResetTrace ("rsurf_add_dynamic_lights", "R_AddDynamicLights");
	R_AddDynamicLights (&fixture.surface);
	MQ_ResultHash ("blocklights_hash", blocklights, 4 * sizeof(unsigned int));
}

static void MQ_RunBuildLightMap (void)
{
	mq_surface_fixture_t fixture;
	byte destination[12];
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	memset (destination, 0xCC, sizeof(destination));
	MQ_ResetTrace ("rsurf_build_lightmap", "R_BuildLightMap");
	R_BuildLightMap (&fixture.surface, destination, 6);
	MQ_ResultHash ("lightmap_hash", destination, sizeof(destination));
	MQ_Prefix ("cached_styles");
	printf ("[%d,%d,%d]}\n", fixture.surface.cached_light[0],
		fixture.surface.cached_light[1], fixture.surface.cached_dlight);
}

static void MQ_RunTextureAnimation (void)
{
	texture_t first, second, alternate;
	entity_t entity;
	texture_t *selected;
	MQ_ResetGlobals ();
	memset (&first, 0, sizeof(first));
	memset (&second, 0, sizeof(second));
	memset (&alternate, 0, sizeof(alternate));
	memset (&entity, 0, sizeof(entity));
	first.gl_texturenum = 10; first.anim_total = 4;
	first.anim_min = 0; first.anim_max = 2; first.anim_next = &second;
	second.gl_texturenum = 11; second.anim_total = 4;
	second.anim_min = 2; second.anim_max = 4; second.anim_next = &first;
	alternate.gl_texturenum = 20;
	first.alternate_anims = &alternate;
	currententity = &entity;
	cl.time = 0.3;
	MQ_ResetTrace ("rsurf_texture_animation", "R_TextureAnimation");
	selected = R_TextureAnimation (&first);
	MQ_Prefix ("selected_texture"); printf ("[%d]}\n", selected->gl_texturenum);
	entity.frame = 1;
	selected = R_TextureAnimation (&first);
	MQ_Prefix ("selected_texture"); printf ("[%d]}\n", selected->gl_texturenum);
}

static void MQ_RunMultitexture (void)
{
	MQ_ResetGlobals ();
	mtexenabled = true;
	MQ_ResetTrace ("rsurf_disable_multitexture", "GL_DisableMultitexture");
	GL_DisableMultitexture ();
	MQ_Prefix ("state"); printf ("[%d]}\n", mtexenabled);
	MQ_ResetGlobals ();
	gl_mtexable = true;
	MQ_ResetTrace ("rsurf_enable_multitexture", "GL_EnableMultitexture");
	GL_EnableMultitexture ();
	MQ_Prefix ("state"); printf ("[%d]}\n", mtexenabled);
}

static void MQ_RunDrawPolygons (void)
{
	mq_surface_fixture_t fixture;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	MQ_ResetTrace ("rsurf_draw_water_poly", "DrawGLWaterPoly");
	DrawGLWaterPoly (&fixture.polygon);
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	MQ_ResetTrace ("rsurf_draw_water_lightmap", "DrawGLWaterPolyLightmap");
	DrawGLWaterPolyLightmap (&fixture.polygon);
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	MQ_ResetTrace ("rsurf_draw_poly", "DrawGLPoly");
	DrawGLPoly (&fixture.polygon);
}

static void MQ_RunSequential (qboolean multitexture)
{
	mq_surface_fixture_t fixture;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	gl_mtexable = multitexture;
	lightmap_modified[0] = multitexture;
	lightmap_rectchange[0][0] = 2;
	lightmap_rectchange[0][1] = 3;
	lightmap_rectchange[0][2] = 2;
	lightmap_rectchange[0][3] = 2;
	MQ_ResetTrace (
		multitexture ? "rsurf_sequential_mtex" : "rsurf_sequential_single",
		"R_DrawSequentialPoly");
	R_DrawSequentialPoly (&fixture.surface);
}

static void MQ_RunBlendLightmaps (void)
{
	mq_surface_fixture_t fixture;
	glpoly_t underwater;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	underwater = fixture.polygon;
	underwater.flags = SURF_UNDERWATER;
	fixture.polygon.chain = &underwater;
	lightmap_polys[0] = &fixture.polygon;
	lightmap_modified[0] = true;
	lightmap_rectchange[0][1] = 3;
	lightmap_rectchange[0][3] = 2;
	MQ_ResetTrace ("rsurf_blend_lightmaps", "R_BlendLightmaps");
	R_BlendLightmaps ();
}

static void MQ_RunRenderBrushPoly (int flags, const char *scene)
{
	mq_surface_fixture_t fixture;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	fixture.surface.flags = flags;
	MQ_ResetTrace (scene, "R_RenderBrushPoly");
	R_RenderBrushPoly (&fixture.surface);
	if (!(flags & (SURF_DRAWSKY | SURF_DRAWTURB)))
	{
		MQ_Prefix ("chain_state");
		printf ("[%d,%d]}\n", lightmap_polys[0] == &fixture.polygon,
			c_brush_polys);
	}
}

static void MQ_RunDynamicLightmaps (void)
{
	mq_surface_fixture_t fixture;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	fixture.surface.cached_light[0] = 1;
	MQ_ResetTrace ("rsurf_dynamic_lightmaps", "R_RenderDynamicLightmaps");
	R_RenderDynamicLightmaps (&fixture.surface);
	MQ_Prefix ("dynamic_state");
	printf ("[%d,%u,%u,%u,%u,%d]}\n", lightmap_modified[0],
		lightmap_rectchange[0][0], lightmap_rectchange[0][1],
		lightmap_rectchange[0][2], lightmap_rectchange[0][3],
		c_brush_polys);
	MQ_ResultHash ("atlas_hash", lightmaps, sizeof(lightmaps));
}

static void MQ_RunMirrorChain (void)
{
	mq_surface_fixture_t fixture;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	MQ_ResetTrace ("rsurf_mirror_chain", "R_MirrorChain");
	R_MirrorChain (&fixture.surface);
	MQ_Prefix ("mirror_state");
	printf ("[%d,%d]}\n", mirror, mirror_plane == &fixture.plane);
}

static void MQ_RunAllocBlock (void)
{
	int x = -1, y = -1;
	int texture;
	MQ_ResetGlobals ();
	MQ_ResetTrace ("rsurf_alloc_block", "AllocBlock");
	texture = AllocBlock (4, 3, &x, &y);
	MQ_Prefix ("allocation");
	printf ("[%d,%d,%d,%d,%d]}\n", texture, x, y,
		allocated[0][x], allocated[0][x + 3]);
}

static void MQ_RunDisplayList (void)
{
	mq_surface_fixture_t fixture;
	mvertex_t vertices[5];
	medge_t edges[6];
	int surfedges[5] = {1, 2, 3, 4, 5};
	model_t model;
	int index;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	memset (vertices, 0, sizeof(vertices));
	memset (edges, 0, sizeof(edges));
	memset (&model, 0, sizeof(model));
	vertices[0].position[0] = 0; vertices[0].position[1] = 0;
	vertices[1].position[0] = 8; vertices[1].position[1] = 0;
	vertices[2].position[0] = 16; vertices[2].position[1] = 0;
	vertices[3].position[0] = 16; vertices[3].position[1] = 16;
	vertices[4].position[0] = 0; vertices[4].position[1] = 16;
	for (index = 1; index <= 5; ++index)
	{
		edges[index].v[0] = (unsigned short)(index - 1);
		edges[index].v[1] = (unsigned short)(index == 5 ? 0 : index);
	}
	model.vertexes = vertices;
	model.edges = edges;
	model.surfedges = surfedges;
	currentmodel = &model;
	r_pcurrentvertbase = vertices;
	fixture.surface.firstedge = 0;
	fixture.surface.numedges = 5;
	fixture.surface.polys = 0;
	MQ_ResetTrace ("rsurf_build_display_list", "BuildSurfaceDisplayList");
	BuildSurfaceDisplayList (&fixture.surface);
	MQ_Prefix ("display_list");
	printf ("[%d,%d", fixture.surface.polys->numverts, nColinElim);
	for (index = 0; index < fixture.surface.polys->numverts; ++index)
		printf (",%.9g,%.9g,%.9g,%.9g,%.9g",
			fixture.surface.polys->verts[index][0],
			fixture.surface.polys->verts[index][1],
			fixture.surface.polys->verts[index][3],
			fixture.surface.polys->verts[index][5],
			fixture.surface.polys->verts[index][6]);
	printf ("]}\n");
}

static void MQ_RunCreateSurfaceLightmap (void)
{
	mq_surface_fixture_t fixture;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	MQ_ResetTrace ("rsurf_create_surface_lightmap", "GL_CreateSurfaceLightmap");
	GL_CreateSurfaceLightmap (&fixture.surface);
	MQ_Prefix ("surface_lightmap");
	printf ("[%d,%d,%d]}\n", fixture.surface.lightmaptexturenum,
		fixture.surface.light_s, fixture.surface.light_t);
	MQ_ResultHash ("atlas_hash", lightmaps, sizeof(lightmaps));
}

static void MQ_RunBuildLightmaps (void)
{
	mq_surface_fixture_t fixture;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	fixture.model.vertexes = 0;
	fixture.model.edges = 0;
	fixture.model.surfedges = 0;
	/* Use a sky surface so display-list edge reconstruction is skipped while
	   GL_CreateSurfaceLightmap's early-return body is still executed. */
	fixture.surface.flags = SURF_DRAWSKY;
	cl.model_precache[1] = &fixture.model;
	MQ_ResetTrace ("rsurf_build_lightmaps", "GL_BuildLightmaps");
	GL_BuildLightmaps ();
	MQ_Prefix ("build_state");
	printf ("[%d,%d,%d]}\n", r_framecount, lightmap_textures,
		texture_extension_number);
}

static void MQ_RunDrawTextureChains (void)
{
	mq_surface_fixture_t fixture;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	gl_texsort.value = 0;
	fixture.surface.flags = SURF_DRAWSKY;
	skychain = &fixture.surface;
	MQ_ResetTrace ("rsurf_draw_texture_chains", "DrawTextureChains");
	DrawTextureChains ();
}

static void MQ_RunDrawWaterSurfaces (void)
{
	mq_surface_fixture_t fixture;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	gl_texsort.value = 0;
	r_wateralpha.value = 0.5f;
	fixture.surface.flags = SURF_DRAWTURB;
	waterchain = &fixture.surface;
	MQ_ResetTrace ("rsurf_draw_water_surfaces", "R_DrawWaterSurfaces");
	R_DrawWaterSurfaces ();
}

static void MQ_RunDrawBrushModel (void)
{
	mq_surface_fixture_t fixture;
	entity_t entity;
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	memset (&entity, 0, sizeof(entity));
	fixture.model.firstmodelsurface = 0;
	fixture.model.nummodelsurfaces = 1;
	entity.model = &fixture.model;
	r_refdef.vieworg[2] = 10;
	MQ_ResetTrace ("rsurf_draw_brush_model", "R_DrawBrushModel");
	R_DrawBrushModel (&entity);
}

static void MQ_RunRecursiveWorldNode (void)
{
	mq_surface_fixture_t fixture;
	mnode_t nodes[3];
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	MQ_InitWorldTree (&fixture, nodes);
	gl_texsort.value = 0;
	MQ_ResetTrace ("rsurf_recursive_world_node", "R_RecursiveWorldNode");
	R_RecursiveWorldNode (&nodes[0]);
}

static void MQ_RunDrawWorld (void)
{
	mq_surface_fixture_t fixture;
	mnode_t nodes[3];
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	MQ_InitWorldTree (&fixture, nodes);
	gl_texsort.value = 0;
	r_refdef.vieworg[2] = 10;
	MQ_ResetTrace ("rsurf_draw_world", "R_DrawWorld");
	R_DrawWorld ();
}

static void MQ_RunMarkLeaves (void)
{
	mq_surface_fixture_t fixture;
	mnode_t root;
	mleaf_t leaves[2];
	MQ_ResetGlobals (); MQ_InitSurface (&fixture);
	memset (&root, 0, sizeof(root));
	memset (leaves, 0, sizeof(leaves));
	fixture.model.numleafs = 1;
	fixture.model.leafs = leaves;
	leaves[1].parent = &root;
	r_viewleaf = &leaves[1];
	r_oldviewleaf = 0;
	r_novis.value = 1;
	MQ_ResetTrace ("rsurf_mark_leaves", "R_MarkLeaves");
	R_MarkLeaves ();
	MQ_Prefix ("visframe");
	printf ("[%d]}\n", r_visframecount);
}

int main (void)
{
	MQ_RunAddDynamicLights ();
	MQ_RunBuildLightMap ();
	MQ_RunTextureAnimation ();
	MQ_RunMultitexture ();
	MQ_RunDrawPolygons ();
	MQ_RunSequential (false);
	MQ_RunSequential (true);
	MQ_RunBlendLightmaps ();
	MQ_RunRenderBrushPoly (0, "rsurf_render_brush_normal");
	MQ_RunRenderBrushPoly (SURF_DRAWSKY, "rsurf_render_brush_sky");
	MQ_RunRenderBrushPoly (SURF_DRAWTURB, "rsurf_render_brush_turb");
	MQ_RunDynamicLightmaps ();
	MQ_RunMirrorChain ();
	MQ_RunAllocBlock ();
	MQ_RunDisplayList ();
	MQ_RunCreateSurfaceLightmap ();
	MQ_RunBuildLightmaps ();
	MQ_RunDrawWaterSurfaces ();
	MQ_RunDrawTextureChains ();
	MQ_RunDrawBrushModel ();
	MQ_RunRecursiveWorldNode ();
	MQ_RunDrawWorld ();
	MQ_RunMarkLeaves ();
	return 0;
}
