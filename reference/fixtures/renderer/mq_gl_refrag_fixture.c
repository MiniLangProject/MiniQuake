/*
Deterministic diagnostic sink for original GLQuake gl_refrag.c bodies.
Linked only into the generated differential executable.
*/

#include "mq_gl_refrag_fixture.h"

client_state_t cl;
int r_framecount;
int cl_numvisedicts;
entity_t *cl_visedicts[MAX_VISEDICTS];

extern mnode_t *r_pefragtopnode;
extern efrag_t **lastlink;
extern vec3_t r_emins, r_emaxs;
extern entity_t *r_addent;

extern void R_RemoveEfrags (entity_t *ent);
extern void R_SplitEntityOnNode (mnode_t *node);
extern void R_AddEfrags (entity_t *ent);
extern void R_StoreEfrags (efrag_t **ppefrag);

static const char *mq_scene;
static const char *mq_function;
static unsigned int mq_sequence;

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

int MQ_BoxOnPlaneSide (const vec3_t mins, const vec3_t maxs,
	const mplane_t *plane)
{
	float distances[2];
	int sides = 0;
	distances[0] =
		plane->normal[0] * maxs[0] +
		plane->normal[1] * maxs[1] +
		plane->normal[2] * maxs[2] - plane->dist;
	distances[1] =
		plane->normal[0] * mins[0] +
		plane->normal[1] * mins[1] +
		plane->normal[2] * mins[2] - plane->dist;
	if (distances[0] >= 0)
		sides = 1;
	if (distances[1] < 0)
		sides |= 2;
	return sides;
}

typedef struct
{
	mplane_t plane;
	mnode_t root;
	mleaf_t leaves[2];
	model_t world;
	model_t entity_model;
	entity_t entities[2];
	efrag_t fragments[4];
} mq_refrag_fixture_t;

static void MQ_InitFixture (mq_refrag_fixture_t *fixture)
{
	int index;
	memset (fixture, 0, sizeof(*fixture));
	memset (&cl, 0, sizeof(cl));
	memset (cl_visedicts, 0, sizeof(cl_visedicts));
	r_framecount = 7;
	cl_numvisedicts = 0;
	fixture->plane.normal[0] = 1;
	fixture->root.contents = 0;
	fixture->root.plane = &fixture->plane;
	fixture->root.children[0] = (mnode_t *)&fixture->leaves[0];
	fixture->root.children[1] = (mnode_t *)&fixture->leaves[1];
	fixture->leaves[0].contents = -1;
	fixture->leaves[1].contents = -1;
	fixture->leaves[0].parent = &fixture->root;
	fixture->leaves[1].parent = &fixture->root;
	fixture->world.nodes = &fixture->root;
	fixture->entity_model.type = mod_brush;
	for (index = 0; index < 3; ++index)
	{
		fixture->entity_model.mins[index] = -1;
		fixture->entity_model.maxs[index] = 1;
	}
	fixture->entities[0].model = &fixture->entity_model;
	fixture->entities[1].model = &fixture->entity_model;
	fixture->fragments[0].entnext = &fixture->fragments[1];
	fixture->fragments[1].entnext = &fixture->fragments[2];
	fixture->fragments[2].entnext = &fixture->fragments[3];
	cl.free_efrags = &fixture->fragments[0];
	cl.worldmodel = &fixture->world;
}

static int MQ_EntityFragmentCount (entity_t *entity)
{
	int count = 0;
	efrag_t *fragment;
	for (fragment = entity->efrag; fragment; fragment = fragment->entnext)
		++count;
	return count;
}

static void MQ_RunRemoveEfrags (void)
{
	mq_refrag_fixture_t fixture;
	MQ_InitFixture (&fixture);
	R_AddEfrags (&fixture.entities[0]);
	MQ_ResetTrace ("refrag_remove", "R_RemoveEfrags");
	R_RemoveEfrags (&fixture.entities[0]);
	MQ_Prefix ("state");
	printf ("[%d,%d,%d,%d]}\n",
		MQ_EntityFragmentCount (&fixture.entities[0]),
		fixture.leaves[0].efrags != 0,
		fixture.leaves[1].efrags != 0,
		cl.free_efrags != 0);
}

static void MQ_RunSplitEntityOnNode (void)
{
	mq_refrag_fixture_t fixture;
	MQ_InitFixture (&fixture);
	r_addent = &fixture.entities[0];
	lastlink = &fixture.entities[0].efrag;
	r_pefragtopnode = 0;
	r_emins[0] = r_emins[1] = r_emins[2] = -1;
	r_emaxs[0] = r_emaxs[1] = r_emaxs[2] = 1;
	MQ_ResetTrace ("refrag_split", "R_SplitEntityOnNode");
	R_SplitEntityOnNode (&fixture.root);
	MQ_Prefix ("state");
	printf ("[%d,%d,%d,%d]}\n",
		MQ_EntityFragmentCount (&fixture.entities[0]),
		r_pefragtopnode == &fixture.root,
		fixture.leaves[0].efrags != 0,
		fixture.leaves[1].efrags != 0);
}

static void MQ_RunAddEfrags (void)
{
	mq_refrag_fixture_t fixture;
	MQ_InitFixture (&fixture);
	MQ_ResetTrace ("refrag_add", "R_AddEfrags");
	R_AddEfrags (&fixture.entities[0]);
	MQ_Prefix ("state");
	printf ("[%d,%d,%d,%d]}\n",
		MQ_EntityFragmentCount (&fixture.entities[0]),
		fixture.entities[0].topnode == &fixture.root,
		fixture.leaves[0].efrags != 0,
		fixture.leaves[1].efrags != 0);
}

static void MQ_RunStoreEfrags (void)
{
	mq_refrag_fixture_t fixture;
	MQ_InitFixture (&fixture);
	R_AddEfrags (&fixture.entities[0]);
	R_AddEfrags (&fixture.entities[1]);
	MQ_ResetTrace ("refrag_store", "R_StoreEfrags");
	R_StoreEfrags (&fixture.leaves[0].efrags);
	MQ_Prefix ("state");
	printf ("[%d]}\n", cl_numvisedicts);
}

int main (void)
{
	MQ_RunRemoveEfrags ();
	MQ_RunSplitEntityOnNode ();
	MQ_RunAddEfrags ();
	MQ_RunStoreEfrags ();
	return 0;
}
