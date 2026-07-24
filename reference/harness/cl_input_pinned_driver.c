#include "cl_input_oracle_stubs.h"

int _fltused;
cvar_t lookspring={"lookspring","0",0,0,0,0};
double host_frametime;
client_state_t cl;
client_static_t cls;

static char command_argument[64];
static int print_calls;
static int start_drift_calls;
static int stop_drift_calls;
static int disconnect_calls;
static int net_send_calls;
static int net_send_result;
static byte sent_data[128];
static int sent_size;
static int registered_count;
static int registered_checksum;
static qsocket_t socket_value;

static void zero_bytes(void *target, int count)
{
    byte *bytes=(byte *)target;
    int index;
    for (index=0;index<count;index++) bytes[index]=0;
}

static int text_checksum(const char *text)
{
    int result=0;
    int index=0;
    while (text[index]) { result+=(index+1)*(unsigned char)text[index];index++; }
    return result;
}

static int data_checksum(const byte *data, int count)
{
    int result=0;
    int index;
    for (index=0;index<count;index++) result+=(index+1)*data[index];
    return result;
}

static void set_argument(const char *text)
{
    int index=0;
    while ((command_argument[index]=text[index])!=0) index++;
}

char *Cmd_Argv(int index)
{
    static char empty[1]={0};
    if (index==1) return command_argument;
    return empty;
}

int mq_atoi(char *text)
{
    int sign=1;
    int value=0;
    if (*text=='-') { sign=-1;text++; }
    if (text[0]=='0' && (text[1]=='x' || text[1]=='X'))
    {
        text+=2;
        while (*text)
        {
            int digit;
            if (*text>='0' && *text<='9') digit=*text-'0';
            else if (*text>='a' && *text<='f') digit=*text-'a'+10;
            else if (*text>='A' && *text<='F') digit=*text-'A'+10;
            else break;
            value=value*16+digit;
            text++;
        }
        return sign*value;
    }
    while (*text>='0' && *text<='9') { value=value*10+(*text-'0');text++; }
    return sign*value;
}

int Q_atoi(char *text) { return mq_atoi(text); }
void Con_Printf(char *format, ...) { (void)format;print_calls++; }
void V_StartPitchDrift(void) { start_drift_calls++; }
void V_StopPitchDrift(void) { stop_drift_calls++; }

float anglemod(float angle)
{
    return (360.0f/65536.0f)*((int)(angle*(65536.0f/360.0f))&65535);
}

void *Q_memset(void *destination, int value, int count)
{
    byte *bytes=(byte *)destination;
    int index;
    for (index=0;index<count;index++) bytes[index]=(byte)value;
    return destination;
}

static void write_byte(sizebuf_t *buffer, int value)
{
    if (buffer->cursize<buffer->maxsize) buffer->data[buffer->cursize++]=(byte)value;
}

void MSG_WriteByte(sizebuf_t *buffer, int value) { write_byte(buffer,value); }
void MSG_WriteShort(sizebuf_t *buffer, int value)
{
    write_byte(buffer,value);
    write_byte(buffer,value>>8);
}
void MSG_WriteFloat(sizebuf_t *buffer, float value)
{
    union { float value; unsigned int bits; } converted;
    converted.value=value;
    write_byte(buffer,converted.bits);
    write_byte(buffer,converted.bits>>8);
    write_byte(buffer,converted.bits>>16);
    write_byte(buffer,converted.bits>>24);
}
void MSG_WriteAngle(sizebuf_t *buffer, float value)
{
    write_byte(buffer,((int)(value*256.0f/360.0f))&255);
}

int NET_SendUnreliableMessage(qsocket_t *socket, sizebuf_t *buffer)
{
    int index;
    (void)socket;
    net_send_calls++;
    sent_size=buffer->cursize;
    for (index=0;index<sent_size;index++) sent_data[index]=buffer->data[index];
    return net_send_result;
}

void CL_Disconnect(void)
{
    disconnect_calls++;
    cl.movemessages=0;
    cls.signon=0;
}

void Cmd_AddCommand(char *name, void (*function)(void))
{
    int index=0;
    (void)function;
    registered_count++;
    while (name[index])
    {
        registered_checksum+=(registered_count+index)*(unsigned char)name[index];
        index++;
    }
}

static void reset_all(void)
{
    zero_bytes(&cl,sizeof(cl));
    zero_bytes(&cls,sizeof(cls));
    zero_bytes(&in_mlook,sizeof(in_mlook));
    zero_bytes(&in_klook,sizeof(in_klook));
    zero_bytes(&in_left,sizeof(in_left));
    zero_bytes(&in_right,sizeof(in_right));
    zero_bytes(&in_forward,sizeof(in_forward));
    zero_bytes(&in_back,sizeof(in_back));
    zero_bytes(&in_lookup,sizeof(in_lookup));
    zero_bytes(&in_lookdown,sizeof(in_lookdown));
    zero_bytes(&in_moveleft,sizeof(in_moveleft));
    zero_bytes(&in_moveright,sizeof(in_moveright));
    zero_bytes(&in_strafe,sizeof(in_strafe));
    zero_bytes(&in_speed,sizeof(in_speed));
    zero_bytes(&in_use,sizeof(in_use));
    zero_bytes(&in_jump,sizeof(in_jump));
    zero_bytes(&in_attack,sizeof(in_attack));
    zero_bytes(&in_up,sizeof(in_up));
    zero_bytes(&in_down,sizeof(in_down));
    in_impulse=0;
    command_argument[0]=0;
    print_calls=start_drift_calls=stop_drift_calls=disconnect_calls=0;
    net_send_calls=sent_size=registered_count=registered_checksum=0;
    net_send_result=1;
    lookspring.value=0;
    cl_upspeed.value=200;
    cl_forwardspeed.value=200;
    cl_backspeed.value=200;
    cl_sidespeed.value=350;
    cl_movespeedkey.value=2;
    cl_yawspeed.value=140;
    cl_pitchspeed.value=150;
    cl_anglespeedkey.value=1.5f;
    host_frametime=0.1;
    cls.signon=SIGNONS;
    cls.netcon=&socket_value;
}

static char *emit(
    char *cursor, const char *function_name, const char *case_name,
    int i0, int i1, float f0, float f1, float f2, float f3)
{
    cursor+=sprintf(
        cursor,
        "{\"function\":\"%s\",\"case\":\"%s\",\"i0\":%d,\"i1\":%d,"
        "\"f0\":%.9g,\"f1\":%.9g,\"f2\":%.9g,\"f3\":%.9g}\n",
        function_name,case_name,i0,i1,f0,f1,f2,f3);
    return cursor;
}

typedef void (*input_function_t)(void);

static char *wrapper_event(
    char *cursor, const char *name, input_function_t function, kbutton_t *button,
    qboolean release)
{
    reset_all();
    set_argument("17");
    if (release)
    {
        KeyDown(button);
        function();
    }
    else
        function();
    return emit(cursor,name,release?"release":"press",button->down[0],button->state,0,0,0,0);
}

__declspec(dllexport) int __cdecl cl_input_oracle_jsonl(char *output, int capacity)
{
    char *cursor=output;
    usercmd_t command;
    int state_before;
    float key_value;
    float key_matrix[4];
    (void)capacity;

    reset_all();set_argument("11");KeyDown(&in_forward);set_argument("12");KeyDown(&in_forward);set_argument("13");KeyDown(&in_forward);
    cursor=emit(cursor,"KeyDown","two_owner_limit",in_forward.down[0],in_forward.down[1],in_forward.state,print_calls,0,0);

    reset_all();set_argument("11");KeyDown(&in_forward);set_argument("12");KeyDown(&in_forward);set_argument("11");KeyUp(&in_forward);set_argument("12");KeyUp(&in_forward);
    cursor=emit(cursor,"KeyUp","last_owner_release",in_forward.down[0],in_forward.down[1],in_forward.state,0,0,0);

    reset_all();in_forward.down[0]=11;in_forward.state=1;set_argument("");KeyUp(&in_forward);
    cursor=emit(cursor,"KeyUp","manual_unstick",in_forward.down[0],in_forward.down[1],in_forward.state,0,0,0);

#define WRAPPER_PAIR(DOWN,UP,BUTTON) \
    cursor=wrapper_event(cursor,#DOWN,DOWN,&BUTTON,false); \
    cursor=wrapper_event(cursor,#UP,UP,&BUTTON,true)
    WRAPPER_PAIR(IN_KLookDown,IN_KLookUp,in_klook);
    reset_all();lookspring.value=1;set_argument("17");IN_MLookDown();
    cursor=emit(cursor,"IN_MLookDown","press",in_mlook.down[0],0,in_mlook.state,0,0,0);
    IN_MLookUp();
    cursor=emit(cursor,"IN_MLookUp","lookspring",in_mlook.down[0],start_drift_calls,in_mlook.state,0,0,0);
    WRAPPER_PAIR(IN_UpDown,IN_UpUp,in_up);
    WRAPPER_PAIR(IN_DownDown,IN_DownUp,in_down);
    WRAPPER_PAIR(IN_LeftDown,IN_LeftUp,in_left);
    WRAPPER_PAIR(IN_RightDown,IN_RightUp,in_right);
    WRAPPER_PAIR(IN_ForwardDown,IN_ForwardUp,in_forward);
    WRAPPER_PAIR(IN_BackDown,IN_BackUp,in_back);
    WRAPPER_PAIR(IN_LookupDown,IN_LookupUp,in_lookup);
    WRAPPER_PAIR(IN_LookdownDown,IN_LookdownUp,in_lookdown);
    WRAPPER_PAIR(IN_MoveleftDown,IN_MoveleftUp,in_moveleft);
    WRAPPER_PAIR(IN_MoverightDown,IN_MoverightUp,in_moveright);
    WRAPPER_PAIR(IN_SpeedDown,IN_SpeedUp,in_speed);
    WRAPPER_PAIR(IN_StrafeDown,IN_StrafeUp,in_strafe);
    WRAPPER_PAIR(IN_AttackDown,IN_AttackUp,in_attack);
    WRAPPER_PAIR(IN_UseDown,IN_UseUp,in_use);
    WRAPPER_PAIR(IN_JumpDown,IN_JumpUp,in_jump);
#undef WRAPPER_PAIR

    reset_all();set_argument("0x10");IN_Impulse();
    cursor=emit(cursor,"IN_Impulse","q_atoi",in_impulse,0,0,0,0,0);

    reset_all();in_attack.state=7;state_before=in_attack.state;key_value=CL_KeyState(&in_attack);
    cursor=emit(cursor,"CL_KeyState","both_edges",state_before,0,key_value,in_attack.state,0,0);

    reset_all();in_attack.state=0;key_matrix[0]=CL_KeyState(&in_attack);in_attack.state=1;key_matrix[1]=CL_KeyState(&in_attack);in_attack.state=3;key_matrix[2]=CL_KeyState(&in_attack);in_attack.state=6;key_matrix[3]=CL_KeyState(&in_attack);
    cursor=emit(cursor,"CL_KeyState","state_matrix",0,0,key_matrix[0],key_matrix[1],key_matrix[2],key_matrix[3]);

    reset_all();cl.viewangles[PITCH]=0;cl.viewangles[YAW]=10;cl.viewangles[ROLL]=70;in_speed.state=1;in_right.state=1;in_lookup.state=3;CL_AdjustAngles();
    cursor=emit(cursor,"CL_AdjustAngles","speed_turn_look",stop_drift_calls,0,cl.viewangles[PITCH],cl.viewangles[YAW],cl.viewangles[ROLL],in_lookup.state);

    reset_all();zero_bytes(&command,sizeof(command));in_strafe.state=1;in_right.state=1;in_moveright.state=3;in_up.state=1;in_forward.state=1;in_speed.state=1;CL_BaseMove(&command);
    cursor=emit(cursor,"CL_BaseMove","strafe_speed",in_right.state,in_moveright.state,command.forwardmove,command.sidemove,command.upmove,cl.viewangles[YAW]);

    reset_all();cls.signon=2;command.forwardmove=9;command.sidemove=8;command.upmove=7;CL_BaseMove(&command);
    cursor=emit(cursor,"CL_BaseMove","unsigned",0,0,command.forwardmove,command.sidemove,command.upmove,0);

    reset_all();zero_bytes(&command,sizeof(command));command.forwardmove=123.75f;command.sidemove=-45.5f;command.upmove=7.9f;cl.viewangles[0]=10;cl.viewangles[1]=20;cl.viewangles[2]=30;cl.mtime[0]=12.5;cl.movemessages=2;in_attack.state=3;in_jump.state=3;in_impulse=7;CL_SendMove(&command);
    cursor=emit(cursor,"CL_SendMove","wire",net_send_calls,sent_size,data_checksum(sent_data,sent_size),in_attack.state,in_jump.state,in_impulse);

    reset_all();zero_bytes(&command,sizeof(command));CL_SendMove(&command);CL_SendMove(&command);
    cursor=emit(cursor,"CL_SendMove","stale",net_send_calls,cl.movemessages,0,0,0,0);

    reset_all();zero_bytes(&command,sizeof(command));cl.movemessages=2;net_send_result=0;CL_SendMove(&command);
    cursor=emit(cursor,"CL_SendMove","backpressure",net_send_calls,disconnect_calls,cl.movemessages,0,0,0);

    reset_all();zero_bytes(&command,sizeof(command));cl.movemessages=2;net_send_result=-1;CL_SendMove(&command);
    cursor=emit(cursor,"CL_SendMove","lost",net_send_calls,disconnect_calls,cl.movemessages,0,0,0);

    reset_all();zero_bytes(&command,sizeof(command));cls.demoplayback=true;in_attack.state=3;in_impulse=9;CL_SendMove(&command);
    cursor=emit(cursor,"CL_SendMove","demo",net_send_calls,cl.movemessages,in_attack.state,in_impulse,0,0);

    reset_all();CL_InitInput();
    cursor=emit(cursor,"CL_InitInput","register",registered_count,registered_checksum,0,0,0,0);

    *cursor=0;
    return (int)(cursor-output);
}
