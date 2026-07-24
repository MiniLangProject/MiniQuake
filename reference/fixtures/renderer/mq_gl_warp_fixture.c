/*
Deterministic diagnostic sink for original GLQuake gl_warp.c bodies.
This source is linked only into the generated differential executable.
*/

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mq_gl_warp_fixture.h"

model_t *loadmodel;
double realtime;
vec3_t r_origin;
cvar_t gl_subdivide_size = {128.0f};
unsigned int d_8to24table[256];
int texture_extension_number = 900;
int gl_solid_format = 3;
int gl_alpha_format = 4;

extern int solidskytexture;
extern int alphaskytexture;
extern float speedscale;
extern msurface_t *warpface;

static const char *mq_scene;
static const char *mq_function;
static unsigned int mq_sequence;
static byte mq_hunk[1024 * 1024];
static size_t mq_hunk_used;

static void MQ_Reset (const char *scene, const char *function)
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

static unsigned int MQ_Hash (const byte *data, size_t length)
{
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

void GL_Bind (int texture)
{
	MQ_Prefix ("bind_texture");
	printf ("[%u,%d]}\n", GL_TEXTURE_2D, texture);
}

void GL_DisableMultitexture (void)
{
	MQ_Prefix ("disable_multitexture");
	printf ("[]}\n");
}

void glBegin (unsigned int mode)
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

void glEnable (unsigned int capability)
{
	MQ_Prefix ("enable");
	printf ("[%u]}\n", capability);
}

void glDisable (unsigned int capability)
{
	MQ_Prefix ("disable");
	printf ("[%u]}\n", capability);
}

void glTexImage2D (unsigned int target, int level, int internal_format,
	int width, int height, int border, unsigned int format,
	unsigned int type, const void *pixels)
{
	size_t length = (size_t)width * (size_t)height * 4u;
	MQ_Prefix ("upload_rgba");
	printf ("[%u,%d,%d,%d,%d,%d,%u,%u,%u]}\n", target, level,
		internal_format, width, height, border, format, type,
		MQ_Hash ((const byte *)pixels, length));
}

void glTexParameterf (unsigned int target, unsigned int parameter, float value)
{
	MQ_Prefix ("texture_parameter");
	printf ("[%u,%u,%.9g]}\n", target, parameter, value);
}

static void MQ_SetVertex (float *vertex, float x, float y, float z,
	float s, float t)
{
	vertex[0] = x;
	vertex[1] = y;
	vertex[2] = z;
	vertex[3] = s;
	vertex[4] = t;
	vertex[5] = 0;
	vertex[6] = 0;
}

static void MQ_InitQuad (glpoly_t *polygon)
{
	memset (polygon, 0, sizeof(*polygon));
	polygon->numverts = 4;
	MQ_SetVertex (polygon->verts[0], -64, -32, 16, 0, 0);
	MQ_SetVertex (polygon->verts[1], 64, -32, 16, 64, 0);
	MQ_SetVertex (polygon->verts[2], 64, 32, 16, 64, 64);
	MQ_SetVertex (polygon->verts[3], -64, 32, 16, 0, 64);
}

static void MQ_TracePolygons (glpoly_t *polygon)
{
	int polygon_index = 0;
	while (polygon)
	{
		int vertex_index;
		MQ_Prefix ("polygon");
		printf ("[%d,%d", polygon_index, polygon->numverts);
		for (vertex_index = 0; vertex_index < polygon->numverts; ++vertex_index)
		{
			float *vertex = polygon->verts[vertex_index];
			printf (",%.9g,%.9g,%.9g,%.9g,%.9g",
				vertex[0], vertex[1], vertex[2], vertex[3], vertex[4]);
		}
		printf ("]}\n");
		polygon = polygon->next;
		++polygon_index;
	}
}

static void MQ_RunBoundPoly (void)
{
	float vertices[12] = {-7, 4, 11, 3, -5, 2, 9, 1, -13, 0, 6, 8};
	vec3_t minimums, maximums;
	MQ_Reset ("warp_bound_poly", "BoundPoly");
	BoundPoly (4, vertices, minimums, maximums);
	MQ_Prefix ("bounds");
	printf ("[%.9g,%.9g,%.9g,%.9g,%.9g,%.9g]}\n",
		minimums[0], minimums[1], minimums[2],
		maximums[0], maximums[1], maximums[2]);
}

static void MQ_RunSubdividePolygon (void)
{
	float vertices[12] = {-64, -64, 0, 64, -64, 0,
		64, 64, 0, -64, 64, 0};
	mtexinfo_t info;
	msurface_t surface;
	memset (&info, 0, sizeof(info));
	memset (&surface, 0, sizeof(surface));
	info.vecs[0][0] = 1;
	info.vecs[1][1] = 1;
	surface.texinfo = &info;
	warpface = &surface;
	mq_hunk_used = 0;
	MQ_Reset ("warp_subdivide_polygon", "SubdividePolygon");
	SubdividePolygon (4, vertices);
	MQ_TracePolygons (surface.polys);
}

static void MQ_RunSubdivideSurface (void)
{
	mvertex_t vertices[4];
	medge_t edges[5];
	int surfedges[4] = {1, 2, 3, 4};
	model_t model;
	mtexinfo_t info;
	msurface_t surface;
	memset (vertices, 0, sizeof(vertices));
	memset (edges, 0, sizeof(edges));
	memset (&model, 0, sizeof(model));
	memset (&info, 0, sizeof(info));
	memset (&surface, 0, sizeof(surface));
	vertices[0].position[0] = -64; vertices[0].position[1] = -64;
	vertices[1].position[0] = 64; vertices[1].position[1] = -64;
	vertices[2].position[0] = 64; vertices[2].position[1] = 64;
	vertices[3].position[0] = -64; vertices[3].position[1] = 64;
	edges[1].v[0] = 0; edges[1].v[1] = 1;
	edges[2].v[0] = 1; edges[2].v[1] = 2;
	edges[3].v[0] = 2; edges[3].v[1] = 3;
	edges[4].v[0] = 3; edges[4].v[1] = 0;
	model.vertexes = vertices;
	model.edges = edges;
	model.surfedges = surfedges;
	loadmodel = &model;
	info.vecs[0][0] = 1;
	info.vecs[1][1] = 1;
	surface.firstedge = 0;
	surface.numedges = 4;
	surface.texinfo = &info;
	mq_hunk_used = 0;
	MQ_Reset ("warp_gl_subdivide_surface", "GL_SubdivideSurface");
	GL_SubdivideSurface (&surface);
	MQ_TracePolygons (surface.polys);
}

static void MQ_RunWater (void)
{
	glpoly_t polygon;
	msurface_t surface;
	MQ_InitQuad (&polygon);
	memset (&surface, 0, sizeof(surface));
	surface.polys = &polygon;
	realtime = 0.25;
	MQ_Reset ("warp_emit_water", "EmitWaterPolys");
	EmitWaterPolys (&surface);
}

static void MQ_RunSky (void)
{
	glpoly_t polygon;
	msurface_t surface;
	MQ_InitQuad (&polygon);
	memset (&surface, 0, sizeof(surface));
	surface.polys = &polygon;
	r_origin[0] = 3; r_origin[1] = -2; r_origin[2] = 1;
	speedscale = 17;
	MQ_Reset ("warp_emit_sky", "EmitSkyPolys");
	EmitSkyPolys (&surface);
}

static void MQ_RunBothSkyLayers (void)
{
	glpoly_t polygon;
	msurface_t surface;
	MQ_InitQuad (&polygon);
	memset (&surface, 0, sizeof(surface));
	surface.polys = &polygon;
	r_origin[0] = 3; r_origin[1] = -2; r_origin[2] = 1;
	realtime = 20;
	solidskytexture = 701;
	alphaskytexture = 702;
	MQ_Reset ("warp_both_sky_layers", "EmitBothSkyLayers");
	EmitBothSkyLayers (&surface);
}

static void MQ_RunSkyChain (void)
{
	glpoly_t first_polygon, second_polygon;
	msurface_t first_surface, second_surface;
	MQ_InitQuad (&first_polygon);
	MQ_InitQuad (&second_polygon);
	second_polygon.verts[0][2] = 32;
	second_polygon.verts[1][2] = 32;
	second_polygon.verts[2][2] = 32;
	second_polygon.verts[3][2] = 32;
	memset (&first_surface, 0, sizeof(first_surface));
	memset (&second_surface, 0, sizeof(second_surface));
	first_surface.polys = &first_polygon;
	first_surface.texturechain = &second_surface;
	second_surface.polys = &second_polygon;
	r_origin[0] = 3; r_origin[1] = -2; r_origin[2] = 1;
	realtime = 20;
	solidskytexture = 701;
	alphaskytexture = 702;
	MQ_Reset ("warp_draw_sky_chain", "R_DrawSkyChain");
	R_DrawSkyChain (&first_surface);
}

typedef struct
{
	texture_t texture;
	byte pixels[256 * 128];
} mq_texture_fixture_t;

static void MQ_RunInitSky (void)
{
	mq_texture_fixture_t fixture;
	int index;
	int x, y;
	memset (&fixture, 0, sizeof(fixture));
	fixture.texture.width = 256;
	fixture.texture.height = 128;
	fixture.texture.offsets[0] = (unsigned int)offsetof(
		mq_texture_fixture_t, pixels);
	for (index = 0; index < 256; ++index)
	{
		byte *rgba = (byte *)&d_8to24table[index];
		rgba[0] = (byte)(index * 3);
		rgba[1] = (byte)(index * 5);
		rgba[2] = (byte)(index * 7);
		rgba[3] = index == 255 ? 0 : 255;
	}
	for (y = 0; y < 128; ++y)
		for (x = 0; x < 256; ++x)
			fixture.pixels[y * 256 + x] = x >= 128
				? (byte)(((x + y) % 254) + 1)
				: (byte)((x * 3 + y * 5) & 255);
	solidskytexture = 0;
	alphaskytexture = 0;
	texture_extension_number = 900;
	MQ_Reset ("warp_init_sky", "R_InitSky");
	R_InitSky (&fixture.texture);
}

int main (void)
{
	MQ_RunBoundPoly ();
	MQ_RunSubdividePolygon ();
	MQ_RunSubdivideSurface ();
	MQ_RunWater ();
	MQ_RunSky ();
	MQ_RunBothSkyLayers ();
	MQ_RunSkyChain ();
	MQ_RunInitSky ();
	return 0;
}
