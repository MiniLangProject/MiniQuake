#include "pr_cmds_oracle_stubs.h"

int _fltused = 0;

static float globals_storage[512];
float *pr_globals = globals_storage;
static char strings_storage[4096];
char *pr_strings = strings_storage;
globalvars_t *pr_global_struct = (globalvars_t *)globals_storage;
static dfunction_t function_storage;
dfunction_t *pr_xfunction = &function_storage;
int pr_argc;
qboolean pr_trace;
server_t sv;
server_static_t svs;
client_t *host_client;
vec3_t vec3_origin;
cvar_t teamplay = {"teamplay", "0"};

static edict_t edicts[32];
static client_t clients[4];
static model_t models[4];
static mleaf_t leaves[4];
static byte pvs_data[16];
static trace_t move_trace;
static int allocation_next;
static int print_calls;
static int debug_print_calls;
static int host_errors;
static int run_errors;
static int sys_errors;
static int link_calls;
static int free_calls;
static int particle_calls;
static int sound_calls;
static int broadcast_calls;
static int client_command_calls;
static int cbuf_calls;
static int cvar_set_calls;
static int edict_print_calls;
static int core_dump_calls;
static int entity_print_calls;
static int move_step_calls;
static int move_step_result;
static int check_bottom_result;
static int point_contents_result;
static int fatal_mode;
static char cbuf_text[256];
static unsigned int random_seed;
static int strings_used;
extern char pr_string_temp[128];

extern char *PF_VarString(int first);
extern void PF_error(void);
extern void PF_objerror(void);
extern void PF_makevectors(void);
extern void PF_setorigin(void);
extern void SetMinMaxSize(edict_t *, float *, float *, qboolean);
extern void PF_setsize(void);
extern void PF_setmodel(void);
extern void PF_bprint(void);
extern void PF_sprint(void);
extern void PF_centerprint(void);
extern void PF_normalize(void);
extern void PF_vlen(void);
extern void PF_vectoyaw(void);
extern void PF_vectoangles(void);
extern void PF_random(void);
extern void PF_particle(void);
extern void PF_ambientsound(void);
extern void PF_sound(void);
extern void PF_break(void);
extern void PF_traceline(void);
extern void PF_checkpos(void);
extern int PF_newcheckclient(int);
extern void PF_checkclient(void);
extern void PF_stuffcmd(void);
extern void PF_localcmd(void);
extern void PF_cvar(void);
extern void PF_cvar_set(void);
extern void PF_findradius(void);
extern void PF_dprint(void);
extern void PF_ftos(void);
extern void PF_fabs(void);
extern void PF_vtos(void);
extern void PF_Spawn(void);
extern void PF_Remove(void);
extern void PF_Find(void);
extern void PR_CheckEmptyString(char *);
extern void PF_precache_file(void);
extern void PF_precache_sound(void);
extern void PF_precache_model(void);
extern void PF_coredump(void);
extern void PF_traceon(void);
extern void PF_traceoff(void);
extern void PF_eprint(void);
extern void PF_walkmove(void);
extern void PF_droptofloor(void);
extern void PF_lightstyle(void);
extern void PF_rint(void);
extern void PF_floor(void);
extern void PF_ceil(void);
extern void PF_checkbottom(void);
extern void PF_pointcontents(void);
extern void PF_nextent(void);
extern void PF_aim(void);
extern void PF_changeyaw(void);
extern sizebuf_t *WriteDest(void);
extern void PF_WriteByte(void);
extern void PF_WriteChar(void);
extern void PF_WriteShort(void);
extern void PF_WriteLong(void);
extern void PF_WriteAngle(void);
extern void PF_WriteCoord(void);
extern void PF_WriteString(void);
extern void PF_WriteEntity(void);
extern void PF_makestatic(void);
extern void PF_setspawnparms(void);
extern void PF_changelevel(void);
extern void PF_Fixme(void);
extern byte checkpvs[];

int mq_strlen(const char *value)
{
    int length = 0;
    while (value && value[length]) length++;
    return length;
}
int mq_strcmp(const char *left, const char *right)
{
    while (*left && *left == *right) { left++; right++; }
    return (unsigned char)*left - (unsigned char)*right;
}
char *mq_strcat(char *destination, const char *source)
{
    int offset = mq_strlen(destination);
    int index = 0;
    while ((destination[offset + index] = source[index]) != 0) index++;
    return destination;
}
void *mq_memcpy(void *destination, const void *source, int count)
{
    byte *out = destination;
    const byte *in = source;
    int index;
    for (index = 0; index < count; index++) out[index] = in[index];
    return destination;
}
static void mq_zero(void *destination, int count)
{
    byte *out = destination;
    int index;
    for (index = 0; index < count; index++) out[index] = 0;
}
int mq_rand(void)
{
    random_seed = random_seed * 214013u + 2531011u;
    return (random_seed >> 16) & 0x7fff;
}
double mq_ceil(double value)
{
    int whole = (int)value;
    if (value > (double)whole) whole++;
    return (double)whole;
}
static int add_string(const char *text)
{
    int result = strings_used;
    int index = 0;
    while ((strings_storage[strings_used++] = text[index++]) != 0) ;
    return result;
}
static void buffer_init(sizebuf_t *buffer, byte *data, int capacity)
{
    buffer->data = data;
    buffer->maxsize = capacity;
    buffer->cursize = 0;
    buffer->allowoverflow = false;
    buffer->overflowed = false;
}
static byte *space(sizebuf_t *buffer, int count)
{
    byte *result = buffer->data + buffer->cursize;
    buffer->cursize += count;
    return result;
}
void MSG_WriteChar(sizebuf_t *buffer, int value) { space(buffer,1)[0]=(byte)value; }
void MSG_WriteByte(sizebuf_t *buffer, int value) { space(buffer,1)[0]=(byte)value; }
void MSG_WriteShort(sizebuf_t *buffer, int value)
{
    byte *out=space(buffer,2); out[0]=(byte)value; out[1]=(byte)(value>>8);
}
void MSG_WriteLong(sizebuf_t *buffer, int value)
{
    byte *out=space(buffer,4); out[0]=(byte)value; out[1]=(byte)(value>>8);
    out[2]=(byte)(value>>16); out[3]=(byte)(value>>24);
}
void MSG_WriteCoord(sizebuf_t *buffer, float value) { MSG_WriteShort(buffer,(int)(value*8)); }
void MSG_WriteAngle(sizebuf_t *buffer, float value) { MSG_WriteByte(buffer,((int)value*256/360)&255); }
void MSG_WriteString(sizebuf_t *buffer, char *value)
{
    if (!value) value="";
    while (*value) MSG_WriteByte(buffer,*value++);
    MSG_WriteByte(buffer,0);
}
void AngleVectors(float *angles, float *forward, float *right, float *up)
{
    double yaw=angles[1]*M_PI/180.0, pitch=angles[0]*M_PI/180.0, roll=angles[2]*M_PI/180.0;
    double sy=sin(yaw),cy=cos(yaw),sp=sin(pitch),cp=cos(pitch),sr=sin(roll),cr=cos(roll);
    forward[0]=(float)(cp*cy);forward[1]=(float)(cp*sy);forward[2]=(float)-sp;
    right[0]=(float)(-sr*sp*cy+-cr*-sy);right[1]=(float)(-sr*sp*sy+-cr*cy);right[2]=(float)(-sr*cp);
    up[0]=(float)(cr*sp*cy+-sr*-sy);up[1]=(float)(cr*sp*sy+-sr*cy);up[2]=(float)(cr*cp);
}
void SV_LinkEdict(edict_t *entity, qboolean touch)
{
    int axis;
    (void)touch;
    for (axis=0;axis<3;axis++)
    {
        entity->v.absmin[axis]=entity->v.origin[axis]+entity->v.mins[axis];
        entity->v.absmax[axis]=entity->v.origin[axis]+entity->v.maxs[axis];
    }
    if (((int)entity->v.flags)&FL_ITEM)
    {
        entity->v.absmin[0]-=15;entity->v.absmin[1]-=15;
        entity->v.absmax[0]+=15;entity->v.absmax[1]+=15;
    }
    else
    {
        for (axis=0;axis<3;axis++) { entity->v.absmin[axis]-=1;entity->v.absmax[axis]+=1; }
    }
    link_calls++;
}
void Con_Printf(char *format, ...) { (void)format;print_calls++; }
void Con_DPrintf(char *format, ...) { (void)format;debug_print_calls++; }
void ED_Print(edict_t *entity) { (void)entity;edict_print_calls++; }
void ED_Free(edict_t *entity) { entity->free=true;free_calls++; }
static void trap_if_fatal(void)
{
    if (fatal_mode) { volatile int *bad=(volatile int *)0; *bad=1; }
}
void Host_Error(char *format, ...) { (void)format;host_errors++;trap_if_fatal(); }
void PR_RunError(char *format, ...) { (void)format;run_errors++;trap_if_fatal(); }
void Sys_Error(char *format, ...) { (void)format;sys_errors++;trap_if_fatal(); }
void SV_BroadcastPrintf(char *format, ...) { (void)format;broadcast_calls++; }
void SV_StartParticle(float *origin, float *direction, int color, int count)
{ (void)origin;(void)direction;(void)color;(void)count;particle_calls++; }
void SV_StartSound(edict_t *entity, int channel, char *sample, int volume, float attenuation)
{ (void)entity;(void)channel;(void)sample;(void)volume;(void)attenuation;sound_calls++; }
trace_t SV_Move(float *start, float *mins, float *maxs, float *end, int type, edict_t *passed)
{ (void)start;(void)mins;(void)maxs;(void)end;(void)type;(void)passed;return move_trace; }
mleaf_t *Mod_PointInLeaf(float *point, model_t *model) { (void)point;return model->leafs+1; }
byte *Mod_LeafPVS(mleaf_t *leaf, model_t *model) { (void)leaf;(void)model;return pvs_data; }
void Host_ClientCommands(char *format, ...) { (void)format;client_command_calls++; }
void Cbuf_AddText(char *text)
{
    int index=0; while ((cbuf_text[index]=text[index])!=0) index++; cbuf_calls++;
}
float Cvar_VariableValue(char *name) { (void)name;return 2.5f; }
void Cvar_Set(char *name, char *value) { (void)name;(void)value;cvar_set_calls++; }
float Length(float *value) { return (float)sqrt(DotProduct(value,value)); }
edict_t *ED_Alloc(void)
{
    edict_t *result=&edicts[allocation_next++];
    result->free=false;
    return result;
}
void ED_PrintEdicts(void) { core_dump_calls++; }
void ED_PrintNum(int number) { (void)number;entity_print_calls++; }
qboolean SV_movestep(edict_t *entity, float *movement, qboolean relink)
{ (void)entity;(void)movement;(void)relink;move_step_calls++;return move_step_result; }
qboolean SV_CheckBottom(edict_t *entity) { (void)entity;return check_bottom_result; }
int SV_PointContents(float *point) { (void)point;return point_contents_result; }
float VectorNormalize(float *value)
{
    float length=Length(value);
    if (length) { value[0]/=length;value[1]/=length;value[2]/=length; }
    return length;
}
float anglemod(float value)
{
    int fixed=(int)(value*(65536.0/360.0));
    return (360.0/65536.0)*(fixed&65535);
}
model_t *Mod_ForName(char *name, qboolean crash) { (void)name;(void)crash;return &models[1]; }
int SV_ModelIndex(char *name)
{
    int index=0; while(sv.model_precache[index]) { if(!mq_strcmp(sv.model_precache[index],name))return index;index++; }
    return 0;
}
char *va(char *format, ...)
{
    static char text[256];
    int index=0;
    while ((text[index]=format[index])!=0) index++;
    return text;
}
void SV_MoveToGoal(void) {}

static void reset_all(void)
{
    int index;
    mq_zero(globals_storage,sizeof(globals_storage));
    mq_zero(strings_storage,sizeof(strings_storage));
    mq_zero(&sv,sizeof(sv));
    mq_zero(&svs,sizeof(svs));
    mq_zero(edicts,sizeof(edicts));
    mq_zero(clients,sizeof(clients));
    mq_zero(models,sizeof(models));
    mq_zero(leaves,sizeof(leaves));
    mq_zero(pvs_data,sizeof(pvs_data));
    mq_zero(&move_trace,sizeof(move_trace));
    strings_storage[0]=0;
    strings_used=1;
    sv.edicts=edicts;
    sv.num_edicts=8;
    sv.worldmodel=&models[0];
    models[0].numleafs=8;
    models[0].leafs=leaves;
    models[1].mins[0]=models[1].mins[1]=models[1].mins[2]=-16;
    models[1].maxs[0]=models[1].maxs[1]=models[1].maxs[2]=16;
    svs.maxclients=2;
    svs.clients=clients;
    for(index=0;index<4;index++) buffer_init(&clients[index].message,clients[index].message_buf,sizeof(clients[index].message_buf));
    buffer_init(&sv.signon,sv.signon_buf,sizeof(sv.signon_buf));
    buffer_init(&sv.datagram,sv.datagram_buf,sizeof(sv.datagram_buf));
    buffer_init(&sv.reliable_datagram,sv.reliable_buf,sizeof(sv.reliable_buf));
    allocation_next=3;
    print_calls=debug_print_calls=host_errors=run_errors=sys_errors=0;
    link_calls=free_calls=particle_calls=sound_calls=broadcast_calls=0;
    client_command_calls=cbuf_calls=cvar_set_calls=edict_print_calls=0;
    core_dump_calls=entity_print_calls=move_step_calls=0;
    move_step_result=check_bottom_result=0;
    point_contents_result=-2;
    fatal_mode=0;
    cbuf_text[0]=0;
    pr_argc=0;
    pr_trace=false;
    random_seed=1;
    teamplay.value=0;
    function_storage.s_name=0;
}

static void parm_word(int index, int value) { G_INT(OFS_PARM0+index*3)=value; }
static void parm_float(int index, float value) { G_FLOAT(OFS_PARM0+index*3)=value; }
static void parm_vector(int index, float x, float y, float z)
{
    float *value=G_VECTOR(OFS_PARM0+index*3);
    value[0]=x;value[1]=y;value[2]=z;
}
static void parm_string(int index, const char *text) { parm_word(index,add_string(text)); }
static int text_checksum(const char *text)
{
    int result=0;
    int index=0;
    while (text[index]) { result+=(index+1)*(unsigned char)text[index];index++; }
    return result;
}
static int data_checksum(const byte *data, int size)
{
    int result=0;
    int index;
    for (index=0;index<size;index++) result+=(index+1)*data[index];
    return result;
}
static char *emit(
    char *cursor, const char *function_name, const char *case_name,
    int i0, int i1, float f0, float f1, float f2, float f3)
{
    cursor += sprintf(
        cursor,
        "{\"function\":\"%s\",\"case\":\"%s\",\"i0\":%d,\"i1\":%d,"
        "\"f0\":%.9g,\"f1\":%.9g,\"f2\":%.9g,\"f3\":%.9g}\n",
        function_name,case_name,i0,i1,f0,f1,f2,f3);
    return cursor;
}

__declspec(dllexport) int __cdecl pr_cmds_oracle_jsonl(char *output, int capacity)
{
    char *cursor=output;
    char *value;
    float mins[3],maxs[3];
    int field;
    sizebuf_t *destination;
    (void)capacity;
    output[0]=0;

    reset_all();pr_argc=3;parm_string(0,"one");parm_string(1," two");parm_string(2," three");value=PF_VarString(0);
    cursor=emit(cursor,"PF_VarString","variadic",mq_strlen(value),text_checksum(value),0,0,0,0);

    reset_all();pr_argc=1;parm_string(0,"fatal");pr_global_struct->self=1;PF_error();
    cursor=emit(cursor,"PF_error","terminal_body",host_errors,print_calls+edict_print_calls,0,0,0,0);

    reset_all();pr_argc=1;parm_string(0,"object");pr_global_struct->self=2;PF_objerror();
    cursor=emit(cursor,"PF_objerror","free_self",host_errors,free_calls,0,0,0,0);

    reset_all();parm_vector(0,0,90,0);PF_makevectors();
    cursor=emit(cursor,"PF_makevectors","yaw90",0,0,pr_global_struct->v_forward[0],pr_global_struct->v_forward[1],pr_global_struct->v_right[0],pr_global_struct->v_up[2]);

    reset_all();parm_word(0,2);parm_vector(1,10,20,30);PF_setorigin();
    cursor=emit(cursor,"PF_setorigin","relink",link_calls,0,edicts[2].v.origin[0],edicts[2].v.origin[1],edicts[2].v.origin[2],edicts[2].v.absmin[0]);

    reset_all();mins[0]=-1;mins[1]=-2;mins[2]=-3;maxs[0]=4;maxs[1]=5;maxs[2]=6;SetMinMaxSize(&edicts[2],mins,maxs,true);
    cursor=emit(cursor,"SetMinMaxSize","axis_aligned",link_calls,0,edicts[2].v.mins[1],edicts[2].v.maxs[2],edicts[2].v.size[0],edicts[2].v.size[2]);

    reset_all();parm_word(0,2);parm_vector(1,-1,-2,-3);parm_vector(2,4,5,6);PF_setsize();
    cursor=emit(cursor,"PF_setsize","bounds",link_calls,0,edicts[2].v.mins[0],edicts[2].v.maxs[1],edicts[2].v.size[0],edicts[2].v.size[2]);

    reset_all();sv.model_precache[0]=pr_strings+add_string("progs/test.mdl");sv.models[0]=&models[1];parm_word(0,2);parm_word(1,(int)(sv.model_precache[0]-pr_strings));PF_setmodel();
    cursor=emit(cursor,"PF_setmodel","precache",link_calls,(int)edicts[2].v.modelindex,edicts[2].v.mins[0],edicts[2].v.maxs[0],edicts[2].v.size[0],0);

    reset_all();pr_argc=2;parm_string(0,"hello");parm_string(1," world");PF_bprint();
    cursor=emit(cursor,"PF_bprint","variadic",broadcast_calls,0,0,0,0,0);

    reset_all();pr_argc=3;parm_word(0,1);parm_string(1,"client");parm_string(2," text");PF_sprint();
    cursor=emit(cursor,"PF_sprint","client",clients[0].message.cursize,clients[0].message.data[0],0,0,0,0);

    reset_all();pr_argc=2;parm_word(0,1);parm_string(1,"center");PF_centerprint();
    cursor=emit(cursor,"PF_centerprint","client",clients[0].message.cursize,clients[0].message.data[0],0,0,0,0);

    reset_all();parm_vector(0,3,4,0);PF_normalize();
    cursor=emit(cursor,"PF_normalize","three_four",0,0,G_FLOAT(OFS_RETURN),G_FLOAT(OFS_RETURN+1),G_FLOAT(OFS_RETURN+2),0);

    reset_all();parm_vector(0,3,4,12);PF_vlen();
    cursor=emit(cursor,"PF_vlen","length",0,0,G_FLOAT(OFS_RETURN),0,0,0);

    reset_all();parm_vector(0,1,2,0);PF_vectoyaw();
    cursor=emit(cursor,"PF_vectoyaw","quadrant",0,0,G_FLOAT(OFS_RETURN),0,0,0);

    reset_all();parm_vector(0,1,1,1);PF_vectoangles();
    cursor=emit(cursor,"PF_vectoangles","angles",0,0,G_FLOAT(OFS_RETURN),G_FLOAT(OFS_RETURN+1),G_FLOAT(OFS_RETURN+2),0);

    reset_all();PF_random();
    cursor=emit(cursor,"PF_random","msvc",0,0,G_FLOAT(OFS_RETURN),0,0,0);

    reset_all();parm_vector(0,1,2,3);parm_vector(1,4,5,6);parm_float(2,7);parm_float(3,8);PF_particle();
    cursor=emit(cursor,"PF_particle","dispatch",particle_calls,0,0,0,0,0);

    reset_all();sv.sound_precache[0]=pr_strings+add_string("amb.wav");parm_vector(0,8,16,24);parm_word(1,(int)(sv.sound_precache[0]-pr_strings));parm_float(2,.5f);parm_float(3,1.5f);PF_ambientsound();
    cursor=emit(cursor,"PF_ambientsound","signon",sv.signon.cursize,sv.signon.data[0],0,0,0,0);

    reset_all();parm_word(0,2);parm_float(1,3);parm_string(2,"sound.wav");parm_float(3,.5f);parm_float(4,1.25f);PF_sound();
    cursor=emit(cursor,"PF_sound","dispatch",sound_calls,sys_errors,0,0,0,0);

    reset_all();move_trace.fraction=1;move_trace.endpos[0]=10;move_trace.endpos[1]=10;move_trace.endpos[2]=10;parm_vector(0,0,0,0);parm_vector(1,10,10,10);parm_float(2,1);parm_word(3,2);PF_traceline();
    cursor=emit(cursor,"PF_traceline","no_world",pr_global_struct->trace_ent,0,pr_global_struct->trace_fraction,pr_global_struct->trace_endpos[0],pr_global_struct->trace_plane_normal[2],pr_global_struct->trace_plane_dist);

    reset_all();G_FLOAT(OFS_RETURN)=9;PF_checkpos();
    cursor=emit(cursor,"PF_checkpos","empty_body",0,0,G_FLOAT(OFS_RETURN),0,0,0);

    reset_all();edicts[1].v.health=100;edicts[2].v.health=100;pvs_data[0]=3;field=PF_newcheckclient(1);
    cursor=emit(cursor,"PF_newcheckclient","cycle",field,pvs_data[0],0,0,0,0);

    reset_all();edicts[1].v.health=0;sv.lastcheck=1;sv.lastchecktime=1;sv.time=1.05f;pr_global_struct->self=2;PF_checkclient();
    cursor=emit(cursor,"PF_checkclient","dead",G_INT(OFS_RETURN),0,0,0,0,0);

    reset_all();parm_word(0,1);parm_string(1,"echo hi\n");PF_stuffcmd();
    cursor=emit(cursor,"PF_stuffcmd","client",client_command_calls,0,0,0,0,0);

    reset_all();parm_string(0,"echo local\n");PF_localcmd();
    cursor=emit(cursor,"PF_localcmd","append",cbuf_calls,text_checksum(cbuf_text),0,0,0,0);

    reset_all();parm_string(0,"skill");PF_cvar();
    cursor=emit(cursor,"PF_cvar","value",0,0,G_FLOAT(OFS_RETURN),0,0,0);

    reset_all();parm_string(0,"skill");parm_string(1,"3");PF_cvar_set();
    cursor=emit(cursor,"PF_cvar_set","set",cvar_set_calls,0,0,0,0,0);

    reset_all();edicts[1].v.solid=1;edicts[1].v.origin[0]=2;edicts[2].v.solid=1;edicts[2].v.origin[0]=6;parm_vector(0,0,0,0);parm_float(1,8);PF_findradius();
    cursor=emit(cursor,"PF_findradius","chain",G_INT(OFS_RETURN),edicts[2].v.chain,edicts[1].v.chain,0,0,0);

    reset_all();pr_argc=2;parm_string(0,"debug");parm_string(1," text");PF_dprint();
    cursor=emit(cursor,"PF_dprint","variadic",debug_print_calls,0,0,0,0,0);

    reset_all();parm_float(0,12.5f);PF_ftos();
    cursor=emit(cursor,"PF_ftos","format",mq_strlen(pr_string_temp),text_checksum(pr_string_temp),0,0,0,0);

    reset_all();parm_float(0,-12.5f);PF_fabs();
    cursor=emit(cursor,"PF_fabs","absolute",0,0,G_FLOAT(OFS_RETURN),0,0,0);

    reset_all();parm_vector(0,1.25f,-2.5f,3);PF_vtos();
    cursor=emit(cursor,"PF_vtos","format",mq_strlen(pr_string_temp),text_checksum(pr_string_temp),0,0,0,0);

    reset_all();PF_Spawn();
    cursor=emit(cursor,"PF_Spawn","allocate",G_INT(OFS_RETURN),edicts[G_INT(OFS_RETURN)].free,0,0,0,0);

    reset_all();parm_word(0,2);PF_Remove();
    cursor=emit(cursor,"PF_Remove","free",edicts[2].free,free_calls,0,0,0,0);

    reset_all();field=(int *)(&edicts[0].v.classname)-(int *)(&edicts[0].v);edicts[2].v.classname=add_string("target");parm_word(0,0);parm_word(1,field);parm_string(2,"target");PF_Find();
    cursor=emit(cursor,"PF_Find","field",G_INT(OFS_RETURN),G_INT(OFS_RETURN)==2,0,0,0,0);

    reset_all();PR_CheckEmptyString("valid");
    cursor=emit(cursor,"PR_CheckEmptyString","valid",run_errors,0,0,0,0,0);

    reset_all();parm_string(0,"maps/e1m1.bsp");PF_precache_file();
    cursor=emit(cursor,"PF_precache_file","identity",G_INT(OFS_RETURN)==G_INT(OFS_PARM0),0,0,0,0,0);

    reset_all();sv.state=ss_loading;parm_string(0,"sound/test.wav");PF_precache_sound();
    cursor=emit(cursor,"PF_precache_sound","insert",sv.sound_precache[0]!=NULL,G_INT(OFS_RETURN)==G_INT(OFS_PARM0),0,0,0,0);

    reset_all();sv.state=ss_loading;parm_string(0,"progs/test.mdl");PF_precache_model();
    cursor=emit(cursor,"PF_precache_model","insert",sv.model_precache[0]!=NULL,sv.models[0]!=NULL,0,0,0,0);

    reset_all();PF_coredump();
    cursor=emit(cursor,"PF_coredump","dump",core_dump_calls,0,0,0,0,0);

    reset_all();PF_traceon();
    cursor=emit(cursor,"PF_traceon","enable",pr_trace,0,0,0,0,0);

    reset_all();pr_trace=true;PF_traceoff();
    cursor=emit(cursor,"PF_traceoff","disable",pr_trace,0,0,0,0,0);

    reset_all();parm_word(0,2);PF_eprint();
    cursor=emit(cursor,"PF_eprint","print",entity_print_calls,0,0,0,0,0);

    reset_all();pr_global_struct->self=2;edicts[2].v.flags=FL_ONGROUND;parm_float(0,90);parm_float(1,16);move_step_result=true;PF_walkmove();
    cursor=emit(cursor,"PF_walkmove","grounded",move_step_calls,0,G_FLOAT(OFS_RETURN),0,0,0);

    reset_all();pr_global_struct->self=2;edicts[2].v.origin[2]=100;move_trace.fraction=1;PF_droptofloor();
    cursor=emit(cursor,"PF_droptofloor","land",link_calls,edicts[2].v.groundentity,G_FLOAT(OFS_RETURN),edicts[2].v.origin[2],edicts[2].v.flags,0);

    reset_all();sv.state=ss_active;clients[0].active=true;parm_float(0,3);parm_string(1,"abc");PF_lightstyle();
    cursor=emit(cursor,"PF_lightstyle","broadcast",clients[0].message.cursize,clients[0].message.data[0],0,0,0,0);

    reset_all();parm_float(0,-1.5f);PF_rint();cursor=emit(cursor,"PF_rint","negative",0,0,G_FLOAT(OFS_RETURN),0,0,0);
    reset_all();parm_float(0,-1.2f);PF_floor();cursor=emit(cursor,"PF_floor","negative",0,0,G_FLOAT(OFS_RETURN),0,0,0);
    reset_all();parm_float(0,-1.2f);PF_ceil();cursor=emit(cursor,"PF_ceil","negative",0,0,G_FLOAT(OFS_RETURN),0,0,0);

    reset_all();check_bottom_result=false;parm_word(0,2);PF_checkbottom();cursor=emit(cursor,"PF_checkbottom","no_world",0,0,G_FLOAT(OFS_RETURN),0,0,0);
    reset_all();point_contents_result=-1;parm_vector(0,1,2,3);PF_pointcontents();cursor=emit(cursor,"PF_pointcontents","no_world",0,0,G_FLOAT(OFS_RETURN),0,0,0);

    reset_all();edicts[1].free=true;edicts[2].free=false;parm_word(0,0);PF_nextent();cursor=emit(cursor,"PF_nextent","skip_free",G_INT(OFS_RETURN),0,0,0,0,0);

    reset_all();parm_word(0,1);parm_float(1,1000);pr_global_struct->v_forward[0]=1;edicts[2].v.takedamage=DAMAGE_AIM;move_trace.ent=&edicts[2];PF_aim();
    cursor=emit(cursor,"PF_aim","straight",0,0,G_FLOAT(OFS_RETURN),G_FLOAT(OFS_RETURN+1),G_FLOAT(OFS_RETURN+2),0);

    reset_all();pr_global_struct->self=2;edicts[2].v.angles[1]=350;edicts[2].v.ideal_yaw=10;edicts[2].v.yaw_speed=5;PF_changeyaw();
    cursor=emit(cursor,"PF_changeyaw","wrap",0,0,edicts[2].v.angles[1],0,0,0);

    reset_all();parm_float(0,2);destination=WriteDest();cursor=emit(cursor,"WriteDest","reliable",destination==&sv.reliable_datagram,0,0,0,0,0);

#define WRITE_CASE(FUNCTION,VALUE,EXPECTED) reset_all();parm_float(0,0);parm_float(1,(VALUE));FUNCTION();cursor=emit(cursor,#FUNCTION,"broadcast",sv.datagram.cursize,sv.datagram.data[0],(EXPECTED),0,0,0)
    WRITE_CASE(PF_WriteByte,254,254);
    WRITE_CASE(PF_WriteChar,-2,254);
    WRITE_CASE(PF_WriteShort,-1234,46);
    WRITE_CASE(PF_WriteLong,305419896,120);
    WRITE_CASE(PF_WriteAngle,90.75f,64);
    WRITE_CASE(PF_WriteCoord,-12.25f,158);
#undef WRITE_CASE
    reset_all();parm_float(0,0);parm_string(1,"quake");PF_WriteString();cursor=emit(cursor,"PF_WriteString","broadcast",sv.datagram.cursize,data_checksum(sv.datagram.data,sv.datagram.cursize),0,0,0,0);
    reset_all();parm_float(0,0);parm_word(1,513);PF_WriteEntity();cursor=emit(cursor,"PF_WriteEntity","broadcast",sv.datagram.cursize,sv.datagram.data[0],sv.datagram.data[1],0,0,0);

    reset_all();sv.model_precache[0]=pr_strings+add_string("progs/test.mdl");edicts[2].v.model=(int)(sv.model_precache[0]-pr_strings);edicts[2].v.origin[0]=8;parm_word(0,2);PF_makestatic();
    cursor=emit(cursor,"PF_makestatic","baseline",sv.signon.cursize,sv.signon.data[0],edicts[2].free,0,0,0);

    reset_all();parm_word(0,1);for(field=0;field<16;field++)clients[0].spawn_parms[field]=(float)(field+1);PF_setspawnparms();
    cursor=emit(cursor,"PF_setspawnparms","copy",0,0,pr_global_struct->parm1,pr_global_struct->parm8,pr_global_struct->parm16,0);

    reset_all();parm_string(0,"e1m2");PF_changelevel();
    cursor=emit(cursor,"PF_changelevel","once",svs.changelevel_issued,cbuf_calls,0,0,0,0);

    reset_all();PF_Fixme();
    cursor=emit(cursor,"PF_Fixme","runerror",run_errors,0,0,0,0,0);

    *cursor=0;
    return (int)(cursor-output);
}

__declspec(dllexport) int __cdecl pr_cmds_fatal_case(int which)
{
    float mins[3]={1,0,0};
    float maxs[3]={0,0,0};
    reset_all();
    fatal_mode=1;
    if (which==0) PF_error();
    if (which==1) PF_objerror();
    if (which==2) PF_break();
    if (which==3) PF_Fixme();
    if (which==4) SetMinMaxSize(&edicts[2],mins,maxs,false);
    if (which==5) { parm_word(0,2);parm_float(1,0);parm_string(2,"bad.wav");parm_float(3,2);parm_float(4,1);PF_sound(); }
    if (which==6) { parm_word(0,2);parm_float(1,0);parm_string(2,"bad.wav");parm_float(3,1);parm_float(4,5);PF_sound(); }
    if (which==7) { parm_word(0,2);parm_float(1,8);parm_string(2,"bad.wav");parm_float(3,1);parm_float(4,1);PF_sound(); }
    if (which==8) { parm_word(0,0);parm_string(1,"cmd\n");PF_stuffcmd(); }
    if (which==9) PR_CheckEmptyString(" bad");
    if (which==10) { parm_string(0,"bad.wav");PF_precache_sound(); }
    if (which==11) { sv.state=ss_loading;parm_string(0," bad.mdl");PF_precache_model(); }
    if (which==12) { parm_float(0,4);WriteDest(); }
    if (which==13) { parm_float(0,1);pr_global_struct->msg_entity=0;WriteDest(); }
    if (which==14) { parm_word(0,0);PF_setspawnparms(); }
    if (which==15) { parm_word(0,2);parm_string(1,"missing.mdl");PF_setmodel(); }
    return 0;
}
