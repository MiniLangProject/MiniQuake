#include "pr_edict_oracle_stubs.h"

int _fltused = 0;
server_t sv;
server_static_t svs;
vec3_t vec3_origin = {0,0,0};
cvar_t deathmatch = {"deathmatch","0",0,0,0,0};
int current_skill = 1;
char com_token[1024];
int com_filesize;

static byte edict_storage[4096];
static dprograms_t header;
static ddef_t fielddefs[4], globaldefs[3];
static dfunction_t functions[3];
static dstatement_t statements[2];
static float globals_data[64];
static char strings_data[2048];
static globalvars_t globals_struct;
static byte progs_blob[4096];
static int string_used;
static int print_count, file_calls, command_count, cvar_count;
static int execute_count, unlink_count, host_errors, sys_errors, fatal_mode;
static char command_argument[16] = "0";

void ED_ClearEdict(edict_t *);
edict_t *ED_Alloc(void);
void ED_Free(edict_t *);
ddef_t *ED_GlobalAtOfs(int);
ddef_t *ED_FieldAtOfs(int);
ddef_t *ED_FindField(char *);
ddef_t *ED_FindGlobal(char *);
dfunction_t *ED_FindFunction(char *);
eval_t *GetEdictFieldValue(edict_t *,char *);
char *PR_ValueString(etype_t,eval_t *);
char *PR_UglyValueString(etype_t,eval_t *);
char *PR_GlobalString(int);
char *PR_GlobalStringNoContents(int);
void ED_Print(edict_t *);
void ED_Write(FILE *,edict_t *);
void ED_PrintNum(int);
void ED_PrintEdicts(void);
void ED_PrintEdict_f(void);
void ED_Count(void);
void ED_WriteGlobals(FILE *);
void ED_ParseGlobals(char *);
char *ED_NewString(char *);
qboolean ED_ParseEpair(void *,ddef_t *,char *);
char *ED_ParseEdict(char *,edict_t *);
void ED_LoadFromFile(char *);
void PR_LoadProgs(void);
void PR_Init(void);

int mq_strlen(const char *value) { int n=0; while(value[n])++n; return n; }
int mq_strcmp(const char *a,const char *b)
{ while(*a&&*a==*b){++a;++b;} return (byte)*a-(byte)*b; }
char *mq_strcpy(char *d,const char *s)
{ char *r=d; while((*d++=*s++)!=0){} return r; }
char *mq_strcat(char *d,const char *s)
{ char *r=d; while(*d)++d; while((*d++=*s++)!=0){} return r; }
float mq_atof(const char *s)
{
    float value=0, scale=0.1f; int sign=1;
    if(*s=='-'){sign=-1;++s;} while(*s>='0'&&*s<='9'){value=value*10+(*s++-'0');}
    if(*s=='.'){++s;while(*s>='0'&&*s<='9'){value+=(*s++-'0')*scale;scale*=0.1f;}}
    return value*sign;
}
int mq_atoi(const char *s) { return (int)mq_atof(s); }
int mq_fprintf(FILE *file,char *format,...)
{ (void)format; ++file->calls; ++file_calls; return 1; }
void Sys_Error(char *format,...)
{ (void)format;++sys_errors;if(fatal_mode){volatile int *p=(int *)0;*p=1;} }
void Host_Error(char *format,...)
{ (void)format;++host_errors;if(fatal_mode){volatile int *p=(int *)0;*p=1;} }
void Con_Printf(char *format,...) { (void)format;++print_count; }
void Con_DPrintf(char *format,...) { (void)format;++print_count; }
void SV_UnlinkEdict(edict_t *entity) { (void)entity;++unlink_count; }

static int whitespace(char c) { return c==' '||c=='\n'||c=='\r'||c=='\t'; }
char *COM_Parse(char *data)
{
    int n=0; if(!data){com_token[0]=0;return NULL;}
    while(*data&&whitespace(*data))++data;
    if(!*data){com_token[0]=0;return NULL;}
    if(*data=='{'||*data=='}'){com_token[0]=*data++;com_token[1]=0;return data;}
    if(*data=='"'){++data;while(*data&&*data!='"'&&n<1023)com_token[n++]=*data++;
        if(*data=='"')++data;com_token[n]=0;return data;}
    while(*data&&!whitespace(*data)&&*data!='{'&&*data!='}'&&n<1023)
        com_token[n++]=*data++;
    com_token[n]=0;return data;
}
void *Hunk_Alloc(int size)
{
    char *result=strings_data+string_used; string_used+=size;
    if(string_used>1900)string_used=1900; return result;
}
void CRC_Init(unsigned short *crc){*crc=0xffff;}
void CRC_ProcessByte(unsigned short *crc,byte value){*crc=(unsigned short)(*crc^value);}
int LittleLong(int value){return value;}
short LittleShort(short value){return value;}
int Q_atoi(char *value){return mq_atoi(value);}
char *Cmd_Argv(int index){(void)index;return command_argument;}
void Cmd_AddCommand(char *name,void (*function)(void))
{(void)name;(void)function;++command_count;}
void Cvar_RegisterVariable(cvar_t *variable){(void)variable;++cvar_count;}
void PR_Profile_f(void){}
void PR_ExecuteProgram(func_t function){(void)function;++execute_count;}

static void put_string(int offset,const char *value){mq_strcpy(strings_data+offset,value);}
static int field_offset(void *field)
{ return (int)(((byte *)field-(byte *)&((edict_t *)edict_storage)->v)/4); }

static void setup_program(void)
{
    edict_t *first=(edict_t *)edict_storage;
    memset(&header,0,sizeof(header)); memset(fielddefs,0,sizeof(fielddefs));
    memset(globaldefs,0,sizeof(globaldefs)); memset(functions,0,sizeof(functions));
    memset(statements,0,sizeof(statements)); memset(globals_data,0,sizeof(globals_data));
    memset(strings_data,0,sizeof(strings_data)); string_used=512;
    put_string(1,"health"); put_string(16,"classname"); put_string(32,"globalx");
    put_string(48,"spawnfn"); put_string(64,"fixture.qc");
    header.version=PROG_VERSION; header.crc=PROGHEADER_CRC;
    header.numfielddefs=3; header.numglobaldefs=2; header.numfunctions=2;
    header.numglobals=64; header.entityfields=sizeof(entvars_t)/4;
    fielddefs[1].type=ev_float; fielddefs[1].ofs=(short)field_offset(&first->v.health); fielddefs[1].s_name=1;
    fielddefs[2].type=ev_string; fielddefs[2].ofs=(short)field_offset(&first->v.classname); fielddefs[2].s_name=16;
    globaldefs[1].type=ev_float|DEF_SAVEGLOBAL; globaldefs[1].ofs=10; globaldefs[1].s_name=32;
    functions[1].s_name=48; functions[1].s_file=64;
    progs=&header; pr_fielddefs=fielddefs; pr_globaldefs=globaldefs;
    pr_functions=functions; pr_statements=statements; pr_strings=strings_data;
    pr_globals=globals_data; pr_global_struct=&globals_struct;
    pr_edict_size=sizeof(edict_t);
}

static void make_blob(void)
{
    dprograms_t *p=(dprograms_t *)progs_blob; int offset=sizeof(dprograms_t);
    memset(progs_blob,0,sizeof(progs_blob)); *p=header;
    p->ofs_statements=offset;p->numstatements=1;offset+=sizeof(dstatement_t);
    p->ofs_globaldefs=offset;p->numglobaldefs=2;
    ((ddef_t *)(progs_blob+offset))[1]=globaldefs[1];offset+=2*sizeof(ddef_t);
    p->ofs_fielddefs=offset;p->numfielddefs=3;
    ((ddef_t *)(progs_blob+offset))[1]=fielddefs[1];
    ((ddef_t *)(progs_blob+offset))[2]=fielddefs[2];offset+=3*sizeof(ddef_t);
    p->ofs_functions=offset;p->numfunctions=2;
    ((dfunction_t *)(progs_blob+offset))[1]=functions[1];offset+=2*sizeof(dfunction_t);
    p->ofs_strings=offset;p->numstrings=128;
    memset(progs_blob+offset,0,128);
    mq_strcpy((char *)progs_blob+offset+1,"health");
    mq_strcpy((char *)progs_blob+offset+16,"classname");
    mq_strcpy((char *)progs_blob+offset+32,"globalx");
    mq_strcpy((char *)progs_blob+offset+48,"spawnfn");offset+=128;
    p->ofs_globals=offset;p->numglobals=64;offset+=64*4;
    p->entityfields=header.entityfields;p->version=PROG_VERSION;p->crc=PROGHEADER_CRC;
    com_filesize=offset;
}
void *COM_LoadHunkFile(char *name){(void)name;make_blob();return progs_blob;}

static void reset_all(void)
{
    memset(edict_storage,0,sizeof(edict_storage)); memset(&globals_struct,0,sizeof(globals_struct));
    setup_program(); sv.edicts=(edict_t *)edict_storage;sv.num_edicts=2;sv.max_edicts=16;sv.time=10;
    svs.maxclients=0;deathmatch.value=0;current_skill=1;
    print_count=file_calls=command_count=cvar_count=execute_count=unlink_count=0;
    host_errors=sys_errors=fatal_mode=0;mq_strcpy(command_argument,"0");
}
static char *emit(char *out,const char *fn,const char *cs,int result,int index,float value,int count)
{
    out+=sprintf(out,"{\"function\":\"%s\",\"case\":\"%s\",\"result\":%d,"
        "\"index\":%d,\"value\":%.9g,\"count\":%d}\n",fn,cs,result,index,value,count);
    return out;
}

__declspec(dllexport) int __cdecl pr_edict_oracle_jsonl(char *output,int capacity)
{
    char *c=output; edict_t *entity; ddef_t *def; eval_t value; FILE file; char *text;
    (void)capacity;
    reset_all();entity=EDICT_NUM(1);entity->v.health=9;entity->free=true;ED_ClearEdict(entity);
    c=emit(c,"ED_ClearEdict","clear",!entity->free,1,entity->v.health,0);
    reset_all();entity=ED_Alloc();c=emit(c,"ED_Alloc","append",1,NUM_FOR_EDICT(entity),0,sv.num_edicts);
    ED_Free(entity);c=emit(c,"ED_Free","release",entity->free,NUM_FOR_EDICT(entity),entity->freetime,unlink_count);
    reset_all();def=ED_GlobalAtOfs(10);c=emit(c,"ED_GlobalAtOfs","hit",def!=NULL,def?def->ofs:0,0,0);
    def=ED_FieldAtOfs(fielddefs[1].ofs);c=emit(c,"ED_FieldAtOfs","hit",def!=NULL,def?def->ofs:0,0,0);
    def=ED_FindField("health");c=emit(c,"ED_FindField","name",def!=NULL,def?def->ofs:0,0,0);
    def=ED_FindGlobal("globalx");c=emit(c,"ED_FindGlobal","name",def!=NULL,def?def->ofs:0,0,0);
    c=emit(c,"ED_FindFunction","name",ED_FindFunction("spawnfn")!=NULL,1,0,0);
    entity=EDICT_NUM(1);entity->v.health=12.5f;
    c=emit(c,"GetEdictFieldValue","health",GetEdictFieldValue(entity,"health")!=NULL,1,GetEdictFieldValue(entity,"health")->_float,0);
    memset(&value,0,sizeof(value));value._float=12.5f;text=PR_ValueString(ev_float,&value);
    c=emit(c,"PR_ValueString","float",1,mq_strlen(text),value._float,0);
    text=PR_UglyValueString(ev_float,&value);c=emit(c,"PR_UglyValueString","float",1,mq_strlen(text),value._float,0);
    globals_data[10]=12.5f;text=PR_GlobalString(10);c=emit(c,"PR_GlobalString","known",1,mq_strlen(text),globals_data[10],0);
    text=PR_GlobalStringNoContents(10);c=emit(c,"PR_GlobalStringNoContents","known",1,mq_strlen(text),0,0);
    print_count=0;ED_Print(entity);c=emit(c,"ED_Print","active",1,1,entity->v.health,print_count);
    file.calls=0;ED_Write(&file,entity);c=emit(c,"ED_Write","active",1,1,0,file.calls);
    print_count=0;ED_PrintNum(1);c=emit(c,"ED_PrintNum","one",1,1,0,print_count);
    print_count=0;ED_PrintEdicts();c=emit(c,"ED_PrintEdicts","all",1,sv.num_edicts,0,print_count);
    print_count=0;mq_strcpy(command_argument,"1");ED_PrintEdict_f();c=emit(c,"ED_PrintEdict_f","command",1,1,0,print_count);
    print_count=0;EDICT_NUM(1)->v.model=1;EDICT_NUM(1)->v.solid=1;EDICT_NUM(1)->v.movetype=MOVETYPE_STEP;
    ED_Count();c=emit(c,"ED_Count","summary",1,sv.num_edicts,0,print_count);
    file.calls=0;ED_WriteGlobals(&file);c=emit(c,"ED_WriteGlobals","saved",1,10,globals_data[10],file.calls);
    ED_ParseGlobals("\"globalx\" \"7.5\" }");c=emit(c,"ED_ParseGlobals","float",1,10,globals_data[10],host_errors);
    text=ED_NewString("a\\nb");c=emit(c,"ED_NewString","escape",text[1]=='\n',mq_strlen(text),0,0);
    globals_data[10]=0;ED_ParseEpair(globals_data,&globaldefs[1],"3.25");
    c=emit(c,"ED_ParseEpair","float",1,10,globals_data[10],0);
    entity=EDICT_NUM(1);ED_ParseEdict("\"health\" \"42\" }",entity);
    c=emit(c,"ED_ParseEdict","pair",1,1,entity->v.health,0);
    reset_all();ED_LoadFromFile("{ \"classname\" \"spawnfn\" \"health\" \"5\" }");
    c=emit(c,"ED_LoadFromFile","world_spawn",1,0,EDICT_NUM(0)->v.health,execute_count);
    reset_all();PR_LoadProgs();c=emit(c,"PR_LoadProgs","synthetic",progs->version,pr_edict_size,pr_crc,progs->numfunctions);
    reset_all();PR_Init();c=emit(c,"PR_Init","register",1,command_count,0,cvar_count);
    reset_all();entity=EDICT_NUM(1);c=emit(c,"EDICT_NUM","valid",1,1,0,entity!=NULL);
    c=emit(c,"NUM_FOR_EDICT","valid",NUM_FOR_EDICT(entity),1,0,0);
    *c=0;return (int)(c-output);
}

__declspec(dllexport) int __cdecl pr_edict_error_case(int mode)
{
    edict_t *entity;
    reset_all();fatal_mode=1;
    if (mode == 0)
        EDICT_NUM(-1);
    else
    {
        entity=EDICT_NUM(sv.num_edicts);
        NUM_FOR_EDICT(entity);
    }
    return 0;
}
