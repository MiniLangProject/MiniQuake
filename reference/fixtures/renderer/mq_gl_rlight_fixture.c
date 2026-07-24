/*
Deterministic diagnostic sink for original GLQuake gl_rlight.c bodies.
This source is linked only into the generated differential executable.
*/

#include <stdio.h>
#include <string.h>
#include "mq_gl_rlight_fixture.h"

client_state_t cl;
lightstyle_t cl_lightstyle[MAX_LIGHTSTYLES];
int d_lightstylevalue[MAX_LIGHTSTYLES];
float v_blend[4];
dlight_t cl_dlights[MAX_DLIGHTS];
cvar_t gl_flashblend;
int r_framecount;
vec3_t r_origin;
vec3_t vpn;
vec3_t vright;
vec3_t vup;

extern int r_dlightframecount;
extern mplane_t *lightplane;
extern vec3_t lightspot;

static const char *mq_scene;
static const char *mq_function;
static unsigned int mq_sequence;

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

void glColor3f (float red, float green, float blue)
{
	MQ_Prefix ("color");
	printf ("[%.9g,%.9g,%.9g,1]}\n", red, green, blue);
}

void glVertex3fv (const float *vertex)
{
	MQ_Prefix ("vertex");
	printf ("[%.9g,%.9g,%.9g]}\n", vertex[0], vertex[1], vertex[2]);
}

void glDepthMask (unsigned char enabled)
{
	MQ_Prefix ("depth_mask");
	printf ("[%u]}\n", (unsigned int)enabled);
}

void glDisable (unsigned int capability)
{
	MQ_Prefix ("disable");
	printf ("[%u]}\n", capability);
}

void glShadeModel (unsigned int mode)
{
	MQ_Prefix ("shade_model");
	printf ("[%u]}\n", mode);
}

void glEnable (unsigned int capability)
{
	MQ_Prefix ("enable");
	printf ("[%u]}\n", capability);
}

void glBlendFunc (unsigned int source, unsigned int destination)
{
	MQ_Prefix ("blend_function");
	printf ("[%u,%u]}\n", source, destination);
}

static void MQ_SetVector (vec3_t vector, float x, float y, float z)
{
	vector[0] = x;
	vector[1] = y;
	vector[2] = z;
}

static void MQ_InitView (void)
{
	MQ_SetVector (r_origin, 0, 0, 0);
	MQ_SetVector (vpn, 1, 0, 0);
	MQ_SetVector (vright, 0, 1, 0);
	MQ_SetVector (vup, 0, 0, 1);
}

static void MQ_RunAnimate (void)
{
	memset (cl_lightstyle, 0, sizeof(cl_lightstyle));
	cl.time = 0.1;
	cl_lightstyle[0].length = 2;
	memcpy (cl_lightstyle[0].map, "az", 2);
	cl_lightstyle[1].length = 3;
	memcpy (cl_lightstyle[1].map, "mmn", 3);
	MQ_Reset ("rlight_animate", "R_AnimateLight");
	R_AnimateLight ();
	MQ_Prefix ("lightstyles");
	printf ("[%d,%d,%d,%d]}\n", d_lightstylevalue[0],
		d_lightstylevalue[1], d_lightstylevalue[2],
		d_lightstylevalue[MAX_LIGHTSTYLES - 1]);
}

static void MQ_RunBlend (void)
{
	v_blend[0] = 0.1f;
	v_blend[1] = 0.2f;
	v_blend[2] = 0.3f;
	v_blend[3] = 0.4f;
	MQ_Reset ("rlight_add_blend", "AddLightBlend");
	AddLightBlend (1.0f, 0.5f, 0.0f, 0.25f);
	MQ_Prefix ("blend");
	printf ("[%.9g,%.9g,%.9g,%.9g]}\n",
		v_blend[0], v_blend[1], v_blend[2], v_blend[3]);
}

static dlight_t MQ_OutsideLight (void)
{
	dlight_t light;
	memset (&light, 0, sizeof(light));
	MQ_SetVector (light.origin, 100, 0, 0);
	light.radius = 10;
	light.die = 1;
	return light;
}

static void MQ_RunRenderDlight (void)
{
	dlight_t light = MQ_OutsideLight ();
	MQ_InitView ();
	cl.time = 0;
	MQ_Reset ("rlight_render_dlight", "R_RenderDlight");
	R_RenderDlight (&light);
}

static void MQ_RunRenderDlightInside (void)
{
	dlight_t light;
	memset (&light, 0, sizeof(light));
	MQ_SetVector (light.origin, 1, 0, 0);
	light.radius = 20;
	light.die = 1;
	memset (v_blend, 0, sizeof(v_blend));
	MQ_InitView ();
	cl.time = 0;
	MQ_Reset ("rlight_render_dlight_inside", "R_RenderDlight");
	R_RenderDlight (&light);
	MQ_Prefix ("blend");
	printf ("[%.9g,%.9g,%.9g,%.9g]}\n",
		v_blend[0], v_blend[1], v_blend[2], v_blend[3]);
}

static void MQ_RunRenderDlights (void)
{
	memset (cl_dlights, 0, sizeof(cl_dlights));
	cl_dlights[0] = MQ_OutsideLight ();
	cl_dlights[1].radius = 20;
	cl_dlights[1].die = -1;
	MQ_InitView ();
	cl.time = 0;
	gl_flashblend.value = 1;
	r_framecount = 12;
	MQ_Reset ("rlight_render_dlights", "R_RenderDlights");
	R_RenderDlights ();
	MQ_Prefix ("dlight_frame");
	printf ("[%d]}\n", r_dlightframecount);
}

typedef struct
{
	mplane_t plane;
	mtexinfo_t texinfo;
	msurface_t surface;
	mnode_t nodes[3];
	model_t model;
	byte samples[4];
	byte lightdata;
} mq_world_fixture_t;

static void MQ_InitWorld (mq_world_fixture_t *world)
{
	memset (world, 0, sizeof(*world));
	MQ_SetVector (world->plane.normal, 0, 0, 1);
	world->plane.dist = 0;
	world->plane.type = 2;
	world->texinfo.vecs[0][0] = 1;
	world->texinfo.vecs[1][1] = 1;
	world->surface.texinfo = &world->texinfo;
	world->surface.extents[0] = 16;
	world->surface.extents[1] = 16;
	world->surface.samples = world->samples;
	world->surface.styles[0] = 0;
	world->surface.styles[1] = 255;
	world->surface.styles[2] = 255;
	world->surface.styles[3] = 255;
	world->samples[0] = 100;
	world->nodes[0].contents = 0;
	world->nodes[0].plane = &world->plane;
	world->nodes[0].children[0] = &world->nodes[1];
	world->nodes[0].children[1] = &world->nodes[2];
	world->nodes[0].firstsurface = 0;
	world->nodes[0].numsurfaces = 1;
	world->nodes[1].contents = -1;
	world->nodes[2].contents = -1;
	world->model.surfaces = &world->surface;
	world->model.nodes = world->nodes;
	world->model.lightdata = &world->lightdata;
	cl.worldmodel = &world->model;
}

static void MQ_RunMarkLights (void)
{
	mq_world_fixture_t world;
	dlight_t light = MQ_OutsideLight ();
	MQ_InitWorld (&world);
	r_dlightframecount = 7;
	MQ_Reset ("rlight_mark_lights", "R_MarkLights");
	R_MarkLights (&light, 4, world.nodes);
	MQ_Prefix ("surface_mark");
	printf ("[%d,%d]}\n", world.surface.dlightframe,
		world.surface.dlightbits);
}

static void MQ_RunPushDlights (void)
{
	mq_world_fixture_t world;
	MQ_InitWorld (&world);
	memset (cl_dlights, 0, sizeof(cl_dlights));
	cl_dlights[0] = MQ_OutsideLight ();
	cl.time = 0;
	gl_flashblend.value = 0;
	r_framecount = 7;
	MQ_Reset ("rlight_push_dlights", "R_PushDlights");
	R_PushDlights ();
	MQ_Prefix ("surface_mark");
	printf ("[%d,%d,%d]}\n", world.surface.dlightframe,
		world.surface.dlightbits, r_dlightframecount);
}

static void MQ_TraceLightPointResult (int result)
{
	MQ_Prefix ("light_point");
	printf ("[%d,%.9g,%.9g,%.9g,%.9g,%.9g,%.9g,%.9g]}\n",
		result, lightspot[0], lightspot[1], lightspot[2],
		lightplane ? lightplane->normal[0] : 0,
		lightplane ? lightplane->normal[1] : 0,
		lightplane ? lightplane->normal[2] : 0,
		lightplane ? lightplane->dist : 0);
}

static void MQ_RunRecursiveLightPoint (void)
{
	mq_world_fixture_t world;
	vec3_t start, end;
	int result;
	MQ_InitWorld (&world);
	d_lightstylevalue[0] = 550;
	MQ_SetVector (start, 0, 0, 10);
	MQ_SetVector (end, 0, 0, -10);
	lightplane = 0;
	memset (lightspot, 0, sizeof(lightspot));
	MQ_Reset ("rlight_recursive_light_point", "RecursiveLightPoint");
	result = RecursiveLightPoint (world.nodes, start, end);
	MQ_TraceLightPointResult (result);
}

static void MQ_RunLightPoint (void)
{
	mq_world_fixture_t world;
	vec3_t point;
	int result;
	MQ_InitWorld (&world);
	d_lightstylevalue[0] = 550;
	MQ_SetVector (point, 0, 0, 10);
	lightplane = 0;
	memset (lightspot, 0, sizeof(lightspot));
	MQ_Reset ("rlight_light_point", "R_LightPoint");
	result = R_LightPoint (point);
	MQ_TraceLightPointResult (result);
}

static void MQ_RunLightPointNoData (void)
{
	mq_world_fixture_t world;
	vec3_t point;
	int result;
	MQ_InitWorld (&world);
	world.model.lightdata = 0;
	MQ_SetVector (point, 0, 0, 10);
	MQ_Reset ("rlight_light_point_no_data", "R_LightPoint");
	result = R_LightPoint (point);
	MQ_Prefix ("light_point");
	printf ("[%d]}\n", result);
}

int main (void)
{
	MQ_RunAnimate ();
	MQ_RunBlend ();
	MQ_RunRenderDlight ();
	MQ_RunRenderDlightInside ();
	MQ_RunRenderDlights ();
	MQ_RunMarkLights ();
	MQ_RunPushDlights ();
	MQ_RunRecursiveLightPoint ();
	MQ_RunLightPoint ();
	MQ_RunLightPointNoData ();
	return 0;
}
