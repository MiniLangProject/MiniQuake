/*
 * Stub environment and deterministic diagnostics for the pinned
 * WinQuake/cl_demo.c.  tools/cl_demo_differential.py inserts the source file
 * at the marker below; no function body is copied into this harness.
 */

typedef unsigned char byte;
typedef int qboolean;
typedef struct mq_file_s {
    byte data[16384];
    int length;
    int position;
    int closed;
} FILE;
typedef struct sizebuf_s {
    qboolean allowoverflow;
    qboolean overflowed;
    byte *data;
    int maxsize;
    int cursize;
} sizebuf_t;
typedef struct client_static_s {
    int state;
    int signon;
    qboolean demoplayback;
    qboolean demorecording;
    qboolean timedemo;
    int forcetrack;
    int demonum;
    FILE *demofile;
    int td_lastframe;
    int td_startframe;
    float td_starttime;
    void *netcon;
} client_static_t;
typedef struct client_state_s {
    float time;
    float mtime[2];
    float viewangles[3];
    float mviewangles[2][3];
} client_state_t;

#define true 1
#define false 0
#define SIGNONS 4
#define MAX_MSGLEN 8000
#define MAX_OSPATH 260
#define ca_disconnected 0
#define ca_connected 1
#define src_command 1
#define svc_nop 1
#define svc_disconnect 2
#define NULL 0
#define VectorCopy(a,b) do { (b)[0]=(a)[0]; (b)[1]=(a)[1]; (b)[2]=(a)[2]; } while (0)

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
int _fltused = 0;

client_static_t cls;
client_state_t cl;
sizebuf_t net_message;
int host_framecount;
float realtime;
int cmd_source;
char com_gamedir[MAX_OSPATH];

static byte mq_net_data[MAX_MSGLEN];
static FILE mq_record_file;
static FILE mq_play_file;
static char mq_open_path[MAX_OSPATH];
static char mq_executed_command[MAX_OSPATH];
static char mq_last_print[256];
static int mq_disconnect_calls;
static int mq_error;
static int mq_net_index;
static int mq_net_count;
static int mq_net_returns[8];
static int mq_net_lengths[8];
static byte mq_net_payloads[8][32];
static int mq_finish_frames;
static float mq_finish_time;
static float mq_finish_fps;

static int mq_strlen(const char *text)
{
    int result = 0;
    while (text[result])
        result++;
    return result;
}

static void mq_copy(char *destination, const char *source)
{
    while ((*destination++ = *source++) != 0)
        ;
}

static void mq_append_text(char *destination, const char *source)
{
    int offset = mq_strlen(destination);
    mq_copy(destination + offset, source);
}

char *mq_strcpy(char *destination, const char *source)
{
    mq_copy(destination, source);
    return destination;
}

char *strstr(const char *text, const char *needle)
{
    int i;
    int j;
    if (!needle[0])
        return (char *)text;
    for (i = 0; text[i]; i++) {
        for (j = 0; needle[j] && text[i+j] == needle[j]; j++)
            ;
        if (!needle[j])
            return (char *)(text + i);
    }
    return 0;
}

int atoi(const char *text)
{
    int sign = 1;
    int value = 0;
    if (*text == '-') {
        sign = -1;
        text++;
    }
    while (*text >= '0' && *text <= '9') {
        value = value * 10 + (*text - '0');
        text++;
    }
    return value * sign;
}

int LittleLong(int value)
{
    return value;
}

float LittleFloat(float value)
{
    return value;
}

int fwrite(const void *source, int size, int count, FILE *file)
{
    const byte *input = (const byte *)source;
    int total = size * count;
    int index;
    if (!file || file->closed || file->position + total > (int)sizeof(file->data))
        return 0;
    for (index = 0; index < total; index++)
        file->data[file->position + index] = input[index];
    file->position += total;
    if (file->position > file->length)
        file->length = file->position;
    return count;
}

int fread(void *destination, int size, int count, FILE *file)
{
    byte *output = (byte *)destination;
    int total = size * count;
    int available;
    int copied;
    int index;
    if (!file || file->closed)
        return 0;
    available = file->length - file->position;
    copied = available < total ? available : total;
    for (index = 0; index < copied; index++)
        output[index] = file->data[file->position + index];
    file->position += copied;
    return copied == total ? count : 0;
}

int fflush(FILE *file)
{
    (void)file;
    return 0;
}

int fclose(FILE *file)
{
    if (file)
        file->closed = 1;
    return 0;
}

FILE *fopen(const char *name, const char *mode)
{
    int index;
    (void)mode;
    mq_copy(mq_open_path, name);
    mq_record_file.length = 0;
    mq_record_file.position = 0;
    mq_record_file.closed = 0;
    for (index = 0; index < (int)sizeof(mq_record_file.data); index++)
        mq_record_file.data[index] = 0;
    return &mq_record_file;
}

int fprintf(FILE *file, const char *format, int value)
{
    char text[64];
    int length;
    (void)format;
    sprintf(text, "%i\n", value);
    length = mq_strlen(text);
    return fwrite(text, 1, length, file);
}

int getc(FILE *file)
{
    if (!file || file->position >= file->length)
        return -1;
    return file->data[file->position++];
}

void Con_Printf(const char *format, ...)
{
    mq_copy(mq_last_print, format);
}

void Sys_Error(const char *format, ...)
{
    (void)format;
    mq_error = 1;
}

void SZ_Clear(sizebuf_t *buffer)
{
    buffer->cursize = 0;
}

void MSG_WriteByte(sizebuf_t *buffer, int value)
{
    if (buffer->cursize < buffer->maxsize)
        buffer->data[buffer->cursize++] = (byte)value;
}

static int mq_cmd_argc;
static const char *mq_cmd_argv[8];

int Cmd_Argc(void)
{
    return mq_cmd_argc;
}

char *Cmd_Argv(int index)
{
    if (index < 0 || index >= mq_cmd_argc)
        return "";
    return (char *)mq_cmd_argv[index];
}

char *va(const char *format, const char *value)
{
    static char text[MAX_OSPATH];
    (void)format;
    sprintf(text, "map %s", value);
    return text;
}

void Cmd_ExecuteString(char *text, int source)
{
    (void)source;
    mq_copy(mq_executed_command, text);
}

void COM_DefaultExtension(char *path, const char *extension)
{
    int length = mq_strlen(path);
    int index;
    for (index = length - 1; index >= 0 && path[index] != '/' && path[index] != '\\'; index--)
        if (path[index] == '.')
            return;
    mq_append_text(path, extension);
}

int COM_FOpenFile(char *name, FILE **file)
{
    (void)name;
    mq_play_file.position = 0;
    mq_play_file.closed = 0;
    *file = &mq_play_file;
    return mq_play_file.length;
}

void CL_Disconnect(void)
{
    mq_disconnect_calls++;
    cls.state = ca_disconnected;
}

int NET_GetMessage(void *connection)
{
    int result;
    int length;
    int index;
    (void)connection;
    if (mq_net_index >= mq_net_count)
        return 0;
    result = mq_net_returns[mq_net_index];
    length = mq_net_lengths[mq_net_index];
    net_message.cursize = length;
    for (index = 0; index < length; index++)
        net_message.data[index] = mq_net_payloads[mq_net_index][index];
    mq_net_index++;
    return result;
}

void mq_capture_timedemo(int frames, float seconds, float fps)
{
    mq_finish_frames = frames;
    mq_finish_time = seconds;
    mq_finish_fps = fps;
}

#define strcpy mq_strcpy
/*__PINNED_CL_DEMO_SOURCE__*/
#undef strcpy

static void mq_zero(void *value, int length)
{
    byte *bytes = (byte *)value;
    int index;
    for (index = 0; index < length; index++)
        bytes[index] = 0;
}

static void mq_reset(void)
{
    mq_zero(&cls, sizeof(cls));
    mq_zero(&cl, sizeof(cl));
    mq_zero(&mq_record_file, sizeof(mq_record_file));
    mq_zero(&mq_play_file, sizeof(mq_play_file));
    mq_zero(mq_open_path, sizeof(mq_open_path));
    mq_zero(mq_executed_command, sizeof(mq_executed_command));
    mq_zero(mq_last_print, sizeof(mq_last_print));
    mq_zero(mq_net_returns, sizeof(mq_net_returns));
    mq_zero(mq_net_lengths, sizeof(mq_net_lengths));
    mq_zero(mq_net_payloads, sizeof(mq_net_payloads));
    net_message.data = mq_net_data;
    net_message.maxsize = MAX_MSGLEN;
    net_message.cursize = 0;
    cmd_source = src_command;
    mq_disconnect_calls = 0;
    mq_error = 0;
    mq_net_index = 0;
    mq_net_count = 0;
    mq_finish_frames = 0;
    mq_finish_time = 0;
    mq_finish_fps = 0;
    mq_copy(com_gamedir, "game");
}

static void mq_load(FILE *file, const byte *data, int length)
{
    int index;
    mq_zero(file, sizeof(*file));
    for (index = 0; index < length; index++)
        file->data[index] = data[index];
    file->length = length;
}

static void mq_put_i32(byte *data, int offset, int value)
{
    data[offset+0] = (byte)(value & 255);
    data[offset+1] = (byte)((value >> 8) & 255);
    data[offset+2] = (byte)((value >> 16) & 255);
    data[offset+3] = (byte)((value >> 24) & 255);
}

static void mq_put_f32(byte *data, int offset, float value)
{
    union { float f; byte b[4]; } converted;
    int index;
    converted.f = value;
    for (index = 0; index < 4; index++)
        data[offset+index] = converted.b[index];
}

static int mq_frame_message(byte *data, int offset, float x, float y, float z, byte opcode)
{
    mq_put_i32(data, offset, 1);
    mq_put_f32(data, offset + 4, x);
    mq_put_f32(data, offset + 8, y);
    mq_put_f32(data, offset + 12, z);
    data[offset + 16] = opcode;
    return offset + 17;
}

static void mq_emit(char *output, int capacity, const char *line)
{
    int used = mq_strlen(output);
    int length = mq_strlen(line);
    int index;
    if (used + length + 1 >= capacity)
        return;
    for (index = 0; index < length; index++)
        output[used+index] = line[index];
    output[used+length] = '\n';
    output[used+length+1] = 0;
}

__declspec(dllexport) int cl_demo_oracle_jsonl(char *output, int capacity)
{
    char line[1024];
    byte playback_data[256];
    int playback_length;
    int first;
    int second;
    int third;

    if (!output || capacity < 2)
        return -1;
    output[0] = 0;

    mq_reset();
    cls.demofile = &mq_record_file;
    net_message.cursize = 2;
    net_message.data[0] = svc_nop;
    net_message.data[1] = svc_disconnect;
    cl.viewangles[0] = 1.0f;
    cl.viewangles[1] = -2.5f;
    cl.viewangles[2] = 90.0f;
    CL_WriteDemoMessage();
    sprintf(line, "{\"function\":\"CL_WriteDemoMessage\",\"case\":\"framing\",\"file_length\":%i,\"length_prefix\":%i,\"payload\":[%i,%i],\"viewangles\":[%g,%g,%g]}",
        mq_record_file.length, mq_record_file.data[0], mq_record_file.data[16],
        mq_record_file.data[17], cl.viewangles[0], cl.viewangles[1], cl.viewangles[2]);
    mq_emit(output, capacity, line);

    mq_reset();
    cls.demorecording = true;
    cls.demofile = &mq_record_file;
    cl.viewangles[0] = 4.0f;
    cl.viewangles[1] = 5.0f;
    cl.viewangles[2] = 6.0f;
    CL_Stop_f();
    sprintf(line, "{\"function\":\"CL_Stop_f\",\"case\":\"disconnect\",\"recording\":%s,\"closed\":%s,\"file_length\":%i,\"opcode\":%i}",
        cls.demorecording ? "true" : "false", mq_record_file.closed ? "true" : "false",
        mq_record_file.length, mq_record_file.data[16]);
    mq_emit(output, capacity, line);

    mq_reset();
    mq_cmd_argc = 4;
    mq_cmd_argv[0] = "record";
    mq_cmd_argv[1] = "fixture";
    mq_cmd_argv[2] = "e1m1";
    mq_cmd_argv[3] = "4";
    CL_Record_f();
    sprintf(line, "{\"function\":\"CL_Record_f\",\"case\":\"map_track\",\"recording\":%s,\"forcetrack\":%i,\"header\":[%i,%i],\"map\":\"%s\",\"filename\":\"fixture.dem\"}",
        cls.demorecording ? "true" : "false", cls.forcetrack,
        mq_record_file.data[0], mq_record_file.data[1], mq_executed_command + 4);
    mq_emit(output, capacity, line);

    mq_reset();
    playback_data[0] = ' ';
    playback_data[1] = '2';
    playback_data[2] = '\n';
    mq_load(&mq_play_file, playback_data, 3);
    mq_cmd_argc = 2;
    mq_cmd_argv[0] = "playdemo";
    mq_cmd_argv[1] = "fixture";
    CL_PlayDemo_f();
    sprintf(line, "{\"function\":\"CL_PlayDemo_f\",\"case\":\"header_whitespace\",\"forcetrack\":%i,\"playback\":%s,\"connected\":%s,\"disconnect_calls\":%i}",
        cls.forcetrack, cls.demoplayback ? "true" : "false",
        cls.state == ca_connected ? "true" : "false", mq_disconnect_calls);
    mq_emit(output, capacity, line);

    mq_reset();
    playback_data[0] = '-';
    playback_data[1] = '1';
    playback_data[2] = '\n';
    mq_load(&mq_play_file, playback_data, 3);
    mq_cmd_argc = 2;
    mq_cmd_argv[0] = "timedemo";
    mq_cmd_argv[1] = "fixture";
    host_framecount = 30;
    CL_TimeDemo_f();
    sprintf(line, "{\"function\":\"CL_TimeDemo_f\",\"case\":\"start\",\"timedemo\":%s,\"start_frame\":%i,\"last_frame\":%i,\"playback\":%s}",
        cls.timedemo ? "true" : "false", cls.td_startframe, cls.td_lastframe,
        cls.demoplayback ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cls.timedemo = true;
    cls.td_startframe = 10;
    cls.td_starttime = 5.0f;
    host_framecount = 21;
    realtime = 9.0f;
    CL_FinishTimeDemo();
    sprintf(line, "{\"function\":\"CL_FinishTimeDemo\",\"case\":\"first_frame_excluded\",\"timedemo\":%s,\"frames\":%i,\"seconds\":%g,\"fps\":%g}",
        cls.timedemo ? "true" : "false", mq_finish_frames, mq_finish_time, mq_finish_fps);
    mq_emit(output, capacity, line);

    mq_reset();
    cls.demoplayback = true;
    cls.timedemo = true;
    cls.demofile = &mq_play_file;
    cls.state = ca_connected;
    cls.td_startframe = 10;
    cls.td_starttime = 5.0f;
    host_framecount = 21;
    realtime = 9.0f;
    CL_StopPlayback();
    sprintf(line, "{\"function\":\"CL_StopPlayback\",\"case\":\"timedemo_eof\",\"playback\":%s,\"connected\":%s,\"closed\":%s,\"frames\":%i,\"seconds\":%g,\"fps\":%g}",
        cls.demoplayback ? "true" : "false", cls.state == ca_connected ? "true" : "false",
        mq_play_file.closed ? "true" : "false", mq_finish_frames, mq_finish_time, mq_finish_fps);
    mq_emit(output, capacity, line);

    mq_reset();
    playback_length = 0;
    playback_length = mq_frame_message(playback_data, playback_length, 10, 20, 30, svc_nop);
    mq_load(&mq_play_file, playback_data, playback_length);
    cls.demoplayback = true;
    cls.demofile = &mq_play_file;
    cls.signon = SIGNONS;
    cl.time = 1.0f;
    cl.mtime[0] = 1.1f;
    first = CL_GetMessage();
    cl.time = 1.2f;
    second = CL_GetMessage();
    sprintf(line, "{\"function\":\"CL_GetMessage\",\"case\":\"pacing_viewangles\",\"blocked\":%i,\"read\":%i,\"cursize\":%i,\"viewangles\":[%g,%g,%g]}",
        first, second, net_message.cursize, cl.mviewangles[0][0],
        cl.mviewangles[0][1], cl.mviewangles[0][2]);
    mq_emit(output, capacity, line);

    mq_reset();
    playback_length = 0;
    playback_length = mq_frame_message(playback_data, playback_length, 1, 2, 3, svc_nop);
    playback_length = mq_frame_message(playback_data, playback_length, 4, 5, 6, svc_disconnect);
    mq_load(&mq_play_file, playback_data, playback_length);
    cls.demoplayback = true;
    cls.demofile = &mq_play_file;
    cls.signon = SIGNONS;
    cls.timedemo = true;
    cls.td_startframe = 10;
    cls.td_lastframe = -1;
    host_framecount = 10;
    realtime = 6.0f;
    first = CL_GetMessage();
    second = CL_GetMessage();
    host_framecount = 11;
    realtime = 7.0f;
    third = CL_GetMessage();
    sprintf(line, "{\"function\":\"CL_GetMessage\",\"case\":\"timedemo_pacing\",\"first\":%i,\"same_frame\":%i,\"second_frame\":%i,\"last_frame\":%i,\"start_time\":%g,\"previous_angle\":%g,\"current_angle\":%g}",
        first, second, third, cls.td_lastframe, cls.td_starttime,
        cl.mviewangles[1][0], cl.mviewangles[0][0]);
    mq_emit(output, capacity, line);

    host_framecount = 12;
    realtime = 8.0f;
    first = CL_GetMessage();
    sprintf(line, "{\"function\":\"CL_GetMessage\",\"case\":\"eof_disconnect\",\"result\":%i,\"playback\":%s,\"connected\":%s,\"timedemo\":%s,\"frames\":%i,\"seconds\":%g}",
        first, cls.demoplayback ? "true" : "false",
        cls.state == ca_connected ? "true" : "false",
        cls.timedemo ? "true" : "false", mq_finish_frames, mq_finish_time);
    mq_emit(output, capacity, line);

    mq_reset();
    cls.demorecording = true;
    cls.demofile = &mq_record_file;
    cl.viewangles[0] = 7;
    cl.viewangles[1] = 8;
    cl.viewangles[2] = 9;
    mq_net_count = 3;
    mq_net_returns[0] = 1;
    mq_net_lengths[0] = 1;
    mq_net_payloads[0][0] = svc_nop;
    mq_net_returns[1] = 1;
    mq_net_lengths[1] = 2;
    mq_net_payloads[1][0] = svc_nop;
    mq_net_payloads[1][1] = svc_nop;
    mq_net_returns[2] = 0;
    first = CL_GetMessage();
    sprintf(line, "{\"function\":\"CL_GetMessage\",\"case\":\"network_keepalive_record\",\"result\":%i,\"net_calls\":%i,\"recorded_length\":%i,\"payload\":[%i,%i]}",
        first, mq_net_index, mq_record_file.length,
        mq_record_file.data[16], mq_record_file.data[17]);
    mq_emit(output, capacity, line);

    return mq_strlen(output);
}
