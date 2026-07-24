/*
Deterministic dependency fixture for the pinned WinQuake/view.c translation
unit.  All 23 active view bodies are compiled directly from the pinned source.
*/

#include "quakedef.h"
#include "r_local.h"

viddef_t vid;
client_state_t cl;
client_static_t cls;
entity_t cl_entities[MAX_EDICTS];
refdef_t r_refdef;
double host_frametime;
byte *host_basepal;
qboolean noclip_anglehack;
qboolean con_forcedup;
int in_forward, in_forward2, in_back;
vrect_t scr_vrect;

cvar_t cl_forwardspeed = {"cl_forwardspeed", "200"};
cvar_t chase_active = {"chase_active", "0"};
cvar_t scr_viewsize = {"viewsize", "100"};

extern cvar_t lcd_x, lcd_yaw;
extern cvar_t scr_ofsx, scr_ofsy, scr_ofsz;
extern cvar_t cl_rollspeed, cl_rollangle, cl_bob, cl_bobcycle, cl_bobup;
extern cvar_t v_kicktime, v_kickroll, v_kickpitch;
extern cvar_t v_iyaw_cycle, v_iroll_cycle, v_ipitch_cycle;
extern cvar_t v_iyaw_level, v_iroll_level, v_ipitch_level, v_idlescale;
extern cvar_t v_centermove, v_centerspeed, v_gamma, gl_cshiftpercent;
extern float v_dmg_time, v_dmg_roll, v_dmg_pitch;
extern float v_blend[4];
extern byte gammatable[256], ramps[3][256];
extern cshift_t cshift_empty;
extern vec3_t right;

float V_CalcRoll (vec3_t angles, vec3_t velocity);
float V_CalcBob (void);
void V_StartPitchDrift (void);
void V_StopPitchDrift (void);
void V_DriftPitch (void);
void BuildGammaTable (float gamma);
qboolean V_CheckGamma (void);
void V_ParseDamage (void);
void V_cshift_f (void);
void V_BonusFlash_f (void);
void V_SetContentsColor (int contents);
void V_CalcPowerupCshift (void);
void V_CalcBlend (void);
void V_UpdatePalette (void);
float angledelta (float angle);
void CalcGunAngle (void);
void V_BoundOffsets (void);
void V_AddIdle (void);
void V_CalcViewRoll (void);
void V_CalcIntermissionRefdef (void);
void V_CalcRefdef (void);
void V_RenderView (void);
void V_Init (void);

static int mq_push_dlights;
static int mq_render_view;
static int mq_cvar_sets;
static int mq_commands;
static int mq_cvars;
static int mq_palette_calls;
static unsigned long mq_palette_hash;
static byte mq_base_palette[768];
static byte mq_colormap[256];
static model_t mq_weapon_model;

static int mq_msg_bytes[2];
static float mq_msg_coords[3];
static int mq_msg_byte_index, mq_msg_coord_index;
static const char *mq_command_args[5];

static unsigned long MQ_HashBytes (const byte *data, int length)
{
	unsigned long hash = 2166136261UL;
	int index;
	for (index = 0; index < length; index++)
	{
		hash ^= data[index];
		hash *= 16777619UL;
	}
	return hash;
}

static void MQ_ResetCounters (void)
{
	mq_push_dlights = 0;
	mq_render_view = 0;
	mq_cvar_sets = 0;
	mq_commands = 0;
	mq_cvars = 0;
	mq_palette_calls = 0;
	mq_palette_hash = 0;
}

static void MQ_Emit (const char *scene, const char *function_name,
	double a, double b, double c, double d, double e, double f)
{
	printf (
		"{\"schema\":\"miniquake.view.v1\",\"scene\":\"%s\","
		"\"function\":\"%s\",\"seq\":0,\"op\":\"state\",\"args\":["
		"%d,%d,%d,%d,%d,%d,%lu,"
		"%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,"
		"%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,"
		"%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,"
		"%.12g,%.12g,%.12g,%.12g,%.12g,%.12g]}\n",
		scene, function_name,
		mq_push_dlights, mq_render_view, mq_cvar_sets, mq_commands,
		mq_cvars, mq_palette_calls, mq_palette_hash,
		r_refdef.vieworg[0], r_refdef.vieworg[1], r_refdef.vieworg[2],
		r_refdef.viewangles[0], r_refdef.viewangles[1], r_refdef.viewangles[2],
		cl.viewent.origin[0], cl.viewent.origin[1], cl.viewent.origin[2],
		cl.viewent.angles[0], cl.viewent.angles[1], cl.viewent.angles[2],
		v_dmg_time, v_dmg_roll, v_dmg_pitch,
		v_blend[0], v_blend[1], v_blend[2], v_blend[3],
		a, b, c, d, e, f);
}

void AngleVectors (vec3_t angles, vec3_t forward, vec3_t right_value,
	vec3_t up_value)
{
	float angle;
	float sr, sp, sy, cr, cp, cy;
	angle = angles[YAW] * (M_PI * 2 / 360);
	sy = sin (angle); cy = cos (angle);
	angle = angles[PITCH] * (M_PI * 2 / 360);
	sp = sin (angle); cp = cos (angle);
	angle = angles[ROLL] * (M_PI * 2 / 360);
	sr = sin (angle); cr = cos (angle);
	forward[0] = cp * cy;
	forward[1] = cp * sy;
	forward[2] = -sp;
	right_value[0] = (-sr * sp * cy + -cr * -sy);
	right_value[1] = (-sr * sp * sy + -cr * cy);
	right_value[2] = -sr * cp;
	up_value[0] = (cr * sp * cy + -sr * -sy);
	up_value[1] = (cr * sp * sy + -sr * cy);
	up_value[2] = cr * cp;
}

vec_t VectorNormalize (vec3_t vector)
{
	float length = (float)sqrt (DotProduct(vector, vector));
	if (length)
	{
		vector[0] /= length;
		vector[1] /= length;
		vector[2] /= length;
	}
	return length;
}

float anglemod (float angle)
{
	return (360.0 / 65536) *
		((int)(angle * (65536.0 / 360.0)) & 65535);
}

int MSG_ReadByte (void)
{
	return mq_msg_bytes[mq_msg_byte_index++];
}

float MSG_ReadCoord (void)
{
	return mq_msg_coords[mq_msg_coord_index++];
}

char *Cmd_Argv (int index)
{
	return (char *)mq_command_args[index];
}

void Cvar_Set (char *name, char *value)
{
	float parsed = (float)atof (value);
	mq_cvar_sets++;
	if (!strcmp(name, "scr_ofsx")) scr_ofsx.value = parsed;
	if (!strcmp(name, "scr_ofsy")) scr_ofsy.value = parsed;
	if (!strcmp(name, "scr_ofsz")) scr_ofsz.value = parsed;
}

void VID_ShiftPalette (byte *palette)
{
	mq_palette_calls++;
	mq_palette_hash = MQ_HashBytes (palette, 768);
}

void R_PushDlights (void) { mq_push_dlights++; }
void R_RenderView (void) { mq_render_view++; }
void Chase_Update (void) {}

void Cmd_AddCommand (char *name, void (*function)(void))
{
	(void)name; (void)function;
	mq_commands++;
}

void Cvar_RegisterVariable (cvar_t *variable)
{
	(void)variable;
	mq_cvars++;
}

static void MQ_SetDefaults (void)
{
	int index;
	memset (&cl, 0, sizeof(cl));
	memset (&cls, 0, sizeof(cls));
	memset (cl_entities, 0, sizeof(cl_entities));
	memset (&r_refdef, 0, sizeof(r_refdef));
	memset (&vid, 0, sizeof(vid));
	memset (&mq_weapon_model, 0, sizeof(mq_weapon_model));
	host_frametime = 0.1;
	noclip_anglehack = false;
	con_forcedup = false;
	cl.viewentity = 1;
	cl.maxclients = 1;
	cl.time = 2;
	cl.oldtime = 1.9f;
	cl.viewheight = 22;
	cl.onground = true;
	cl.stats[STAT_HEALTH] = 100;
	cl.stats[STAT_WEAPON] = 1;
	cl.stats[STAT_WEAPONFRAME] = 2;
	cl.model_precache[1] = &mq_weapon_model;
	vid.colormap = mq_colormap;
	vid.width = 640;
	vid.height = 480;
	vid.rowbytes = 640;
	vid.aspect = 1;
	static byte mq_video_buffer[4096];
	vid.buffer = mq_video_buffer;
	r_refdef.vrect.width = 640;
	r_refdef.vrect.height = 480;
	cl_forwardspeed.value = 200;
	lcd_x.value = 0;
	lcd_yaw.value = 0;
	scr_ofsx.value = scr_ofsy.value = scr_ofsz.value = 0;
	cl_rollspeed.value = 200;
	cl_rollangle.value = 2;
	cl_bob.value = 0.02f;
	cl_bobcycle.value = 0.6f;
	cl_bobup.value = 0.5f;
	v_kicktime.value = 0.5f;
	v_kickroll.value = 0.6f;
	v_kickpitch.value = 0.6f;
	v_centermove.value = 0.15f;
	v_centerspeed.value = 500;
	v_iyaw_cycle.value = 2;
	v_iroll_cycle.value = 0.5f;
	v_ipitch_cycle.value = 1;
	v_iyaw_level.value = 0.3f;
	v_iroll_level.value = 0.1f;
	v_ipitch_level.value = 0.3f;
	v_idlescale.value = 0;
	v_gamma.value = 1;
	gl_cshiftpercent.value = 100;
	scr_viewsize.value = 100;
	chase_active.value = 0;
	v_dmg_time = v_dmg_roll = v_dmg_pitch = 0;
	memset (v_blend, 0, sizeof(float) * 4);
	for (index = 0; index < 768; index++)
		mq_base_palette[index] = (byte)(index & 255);
	host_basepal = mq_base_palette;
	MQ_ResetCounters ();
}

static void MQ_TraceCalcRoll (void)
{
	vec3_t angles = {0, 0, 0};
	vec3_t velocity = {0, 100, 0};
	float result;
	MQ_SetDefaults ();
	result = V_CalcRoll (angles, velocity);
	MQ_Emit ("view_calc_roll", "V_CalcRoll", result, 0, 0, 0, 0, 0);
}

static void MQ_TraceCalcBob (void)
{
	float result;
	MQ_SetDefaults ();
	cl.time = 0.15f;
	cl.velocity[0] = 100;
	cl.velocity[2] = 999;
	result = V_CalcBob ();
	MQ_Emit ("view_calc_bob", "V_CalcBob", result, 0, 0, 0, 0, 0);
}

static void MQ_TraceStartDrift (void)
{
	MQ_SetDefaults ();
	cl.laststop = 1;
	cl.time = 2;
	cl.nodrift = true;
	V_StartPitchDrift ();
	MQ_Emit ("view_start_drift", "V_StartPitchDrift",
		cl.pitchvel, cl.nodrift, cl.driftmove, 0, 0, 0);
}

static void MQ_TraceStopDrift (void)
{
	MQ_SetDefaults ();
	cl.pitchvel = 500;
	V_StopPitchDrift ();
	MQ_Emit ("view_stop_drift", "V_StopPitchDrift",
		cl.laststop, cl.nodrift, cl.pitchvel, 0, 0, 0);
}

static void MQ_TraceDriftPitch (void)
{
	MQ_SetDefaults ();
	cl.nodrift = false;
	cl.pitchvel = 100;
	cl.idealpitch = 10;
	cl.viewangles[PITCH] = 0;
	V_DriftPitch ();
	MQ_Emit ("view_drift_pitch", "V_DriftPitch",
		cl.viewangles[PITCH], cl.pitchvel, cl.driftmove, 0, 0, 0);
}

static void MQ_TraceBuildGamma (void)
{
	MQ_SetDefaults ();
	BuildGammaTable (0.5f);
	MQ_Emit ("view_build_gamma", "BuildGammaTable",
		MQ_HashBytes(gammatable, 256), gammatable[0], gammatable[128],
		gammatable[255], 0, 0);
}

static void MQ_TraceCheckGamma (void)
{
	int first, second;
	MQ_SetDefaults ();
	v_gamma.value = 0.7f;
	first = V_CheckGamma ();
	second = V_CheckGamma ();
	MQ_Emit ("view_check_gamma", "V_CheckGamma",
		first, second, vid.recalc_refdef, MQ_HashBytes(gammatable, 256), 0, 0);
}

static void MQ_TraceParseDamage (void)
{
	MQ_SetDefaults ();
	mq_msg_bytes[0] = 20;
	mq_msg_bytes[1] = 10;
	mq_msg_coords[0] = 10;
	mq_msg_coords[1] = 0;
	mq_msg_coords[2] = 0;
	mq_msg_byte_index = mq_msg_coord_index = 0;
	V_ParseDamage ();
	MQ_Emit ("view_parse_damage", "V_ParseDamage",
		cl.cshifts[CSHIFT_DAMAGE].destcolor[0],
		cl.cshifts[CSHIFT_DAMAGE].destcolor[1],
		cl.cshifts[CSHIFT_DAMAGE].destcolor[2],
		cl.cshifts[CSHIFT_DAMAGE].percent,
		cl.faceanimtime, 0);
}

static void MQ_TraceCshift (void)
{
	MQ_SetDefaults ();
	mq_command_args[1] = "1";
	mq_command_args[2] = "2";
	mq_command_args[3] = "3";
	mq_command_args[4] = "4";
	V_cshift_f ();
	MQ_Emit ("view_cshift", "V_cshift_f",
		cshift_empty.destcolor[0], cshift_empty.destcolor[1],
		cshift_empty.destcolor[2], cshift_empty.percent, 0, 0);
}

static void MQ_TraceBonus (void)
{
	MQ_SetDefaults ();
	V_BonusFlash_f ();
	MQ_Emit ("view_bonus", "V_BonusFlash_f",
		cl.cshifts[CSHIFT_BONUS].destcolor[0],
		cl.cshifts[CSHIFT_BONUS].destcolor[1],
		cl.cshifts[CSHIFT_BONUS].destcolor[2],
		cl.cshifts[CSHIFT_BONUS].percent, 0, 0);
}

static void MQ_TraceContents (void)
{
	int code = 0;
	MQ_SetDefaults ();
	V_SetContentsColor (CONTENTS_LAVA);
	code += cl.cshifts[CSHIFT_CONTENTS].destcolor[0];
	V_SetContentsColor (CONTENTS_SLIME);
	code += cl.cshifts[CSHIFT_CONTENTS].destcolor[1];
	V_SetContentsColor (CONTENTS_WATER);
	code += cl.cshifts[CSHIFT_CONTENTS].percent;
	V_SetContentsColor (CONTENTS_EMPTY);
	MQ_Emit ("view_contents", "V_SetContentsColor",
		code, cl.cshifts[CSHIFT_CONTENTS].destcolor[0],
		cl.cshifts[CSHIFT_CONTENTS].destcolor[1],
		cl.cshifts[CSHIFT_CONTENTS].destcolor[2],
		cl.cshifts[CSHIFT_CONTENTS].percent, 0);
}

static void MQ_TracePowerup (void)
{
	int code = 0;
	MQ_SetDefaults ();
	cl.items = IT_QUAD; V_CalcPowerupCshift ();
	code += cl.cshifts[CSHIFT_POWERUP].destcolor[2];
	cl.items = IT_SUIT; V_CalcPowerupCshift ();
	code += cl.cshifts[CSHIFT_POWERUP].destcolor[1];
	cl.items = IT_INVISIBILITY; V_CalcPowerupCshift ();
	code += cl.cshifts[CSHIFT_POWERUP].percent;
	cl.items = IT_INVULNERABILITY; V_CalcPowerupCshift ();
	code += cl.cshifts[CSHIFT_POWERUP].destcolor[0];
	cl.items = 0; V_CalcPowerupCshift ();
	MQ_Emit ("view_powerup", "V_CalcPowerupCshift",
		code, cl.cshifts[CSHIFT_POWERUP].percent, 0, 0, 0, 0);
}

static void MQ_SetBlendShifts (void)
{
	cl.cshifts[0].destcolor[0] = 130;
	cl.cshifts[0].destcolor[1] = 80;
	cl.cshifts[0].destcolor[2] = 50;
	cl.cshifts[0].percent = 128;
	cl.cshifts[1].destcolor[0] = 200;
	cl.cshifts[1].destcolor[1] = 100;
	cl.cshifts[1].destcolor[2] = 100;
	cl.cshifts[1].percent = 45;
	cl.cshifts[2].destcolor[0] = 215;
	cl.cshifts[2].destcolor[1] = 186;
	cl.cshifts[2].destcolor[2] = 69;
	cl.cshifts[2].percent = 50;
	cl.cshifts[3].destcolor[2] = 255;
	cl.cshifts[3].percent = 30;
}

static void MQ_TraceBlend (void)
{
	MQ_SetDefaults ();
	MQ_SetBlendShifts ();
	V_CalcBlend ();
	MQ_Emit ("view_blend", "V_CalcBlend", 0, 0, 0, 0, 0, 0);
}

static void MQ_TraceUpdatePalette (void)
{
	int changed;
	MQ_SetDefaults ();
	MQ_SetBlendShifts ();
	cl.items = IT_QUAD;
	v_gamma.value = 0.7f;
	V_UpdatePalette ();
	changed = mq_palette_calls;
	MQ_Emit ("view_update_palette", "V_UpdatePalette",
		changed, cl.cshifts[CSHIFT_DAMAGE].percent,
		cl.cshifts[CSHIFT_BONUS].percent,
		MQ_HashBytes(&ramps[0][0], 3 * 256), 0, 0);
}

static void MQ_TraceAngleDelta (void)
{
	float result;
	MQ_SetDefaults ();
	result = angledelta (270);
	MQ_Emit ("view_angle_delta", "angledelta", result, 0, 0, 0, 0, 0);
}

static void MQ_TraceGunAngle (void)
{
	MQ_SetDefaults ();
	cl.time = 1;
	r_refdef.viewangles[0] = 10;
	r_refdef.viewangles[1] = 20;
	r_refdef.viewangles[2] = 3;
	cl.viewent.angles[2] = 4;
	v_idlescale.value = 1;
	CalcGunAngle ();
	MQ_Emit ("view_gun_angle", "CalcGunAngle", 0, 0, 0, 0, 0, 0);
}

static void MQ_TraceBoundOffsets (void)
{
	MQ_SetDefaults ();
	cl_entities[1].origin[0] = 10;
	cl_entities[1].origin[1] = 20;
	cl_entities[1].origin[2] = 30;
	r_refdef.vieworg[0] = -100;
	r_refdef.vieworg[1] = 100;
	r_refdef.vieworg[2] = 100;
	V_BoundOffsets ();
	MQ_Emit ("view_bound_offsets", "V_BoundOffsets", 0, 0, 0, 0, 0, 0);
}

static void MQ_TraceAddIdle (void)
{
	MQ_SetDefaults ();
	cl.time = 1;
	v_idlescale.value = 1;
	r_refdef.viewangles[0] = 10;
	r_refdef.viewangles[1] = 20;
	r_refdef.viewangles[2] = 3;
	V_AddIdle ();
	MQ_Emit ("view_add_idle", "V_AddIdle", 0, 0, 0, 0, 0, 0);
}

static void MQ_TraceViewRoll (void)
{
	MQ_SetDefaults ();
	cl.velocity[1] = 100;
	v_dmg_time = 0.5f;
	v_dmg_roll = 6;
	v_dmg_pitch = 3;
	V_CalcViewRoll ();
	MQ_Emit ("view_calc_view_roll", "V_CalcViewRoll", 0, 0, 0, 0, 0, 0);
}

static void MQ_TraceIntermission (void)
{
	MQ_SetDefaults ();
	cl.time = 1;
	cl_entities[1].origin[0] = 10;
	cl_entities[1].origin[1] = 20;
	cl_entities[1].origin[2] = 30;
	cl_entities[1].angles[0] = 5;
	cl_entities[1].angles[1] = 15;
	cl_entities[1].angles[2] = 2;
	cl.viewent.model = &mq_weapon_model;
	V_CalcIntermissionRefdef ();
	MQ_Emit ("view_intermission", "V_CalcIntermissionRefdef",
		cl.viewent.model == NULL, 0, 0, 0, 0, 0);
}

static void MQ_PrepareRefdef (void)
{
	MQ_SetDefaults ();
	cl_entities[1].origin[0] = 10;
	cl_entities[1].origin[1] = 20;
	cl_entities[1].origin[2] = 0;
	cl_entities[1].angles[1] = 15;
	cl.viewangles[0] = 5;
	cl.viewangles[1] = 15;
	cl.velocity[0] = 100;
	cl.punchangle[0] = 1;
	cl.punchangle[1] = 2;
	cl.punchangle[2] = 3;
	cl.nodrift = true;
}

static void MQ_TraceCalcRefdef (void)
{
	MQ_PrepareRefdef ();
	V_CalcRefdef ();
	MQ_Emit ("view_calc_refdef", "V_CalcRefdef",
		cl.viewent.model == &mq_weapon_model, cl.viewent.frame,
		cl.viewent.colormap == vid.colormap,
		cl_entities[1].angles[0], cl_entities[1].angles[1], 0);
}

static void MQ_TraceRenderView (void)
{
	MQ_PrepareRefdef ();
	cl.maxclients = 2;
	scr_ofsx.value = 5;
	scr_ofsy.value = 6;
	scr_ofsz.value = 7;
	lcd_x.value = 2;
	lcd_yaw.value = 1;
	V_RenderView ();
	MQ_Emit ("view_render_view", "V_RenderView",
		vid.rowbytes, vid.aspect, r_refdef.vrect.height,
		scr_ofsx.value, scr_ofsy.value, scr_ofsz.value);
}

static void MQ_TraceInit (void)
{
	MQ_SetDefaults ();
	memset (gammatable, 0, 256);
	V_Init ();
	MQ_Emit ("view_init", "V_Init",
		MQ_HashBytes(gammatable, 256), gammatable[0],
		gammatable[128], gammatable[255], 0, 0);
}

int main (void)
{
	MQ_TraceCalcRoll ();
	MQ_TraceCalcBob ();
	MQ_TraceStartDrift ();
	MQ_TraceStopDrift ();
	MQ_TraceDriftPitch ();
	MQ_TraceBuildGamma ();
	MQ_TraceCheckGamma ();
	MQ_TraceParseDamage ();
	MQ_TraceCshift ();
	MQ_TraceBonus ();
	MQ_TraceContents ();
	MQ_TracePowerup ();
	MQ_TraceBlend ();
	MQ_TraceUpdatePalette ();
	MQ_TraceAngleDelta ();
	MQ_TraceGunAngle ();
	MQ_TraceBoundOffsets ();
	MQ_TraceAddIdle ();
	MQ_TraceViewRoll ();
	MQ_TraceIntermission ();
	MQ_TraceCalcRefdef ();
	MQ_TraceRenderView ();
	MQ_TraceInit ();
	return 0;
}
