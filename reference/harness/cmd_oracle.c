/* Direct deterministic harness for the pinned WinQuake/cmd.c. */

typedef unsigned char byte;
typedef int qboolean;
typedef int cmd_source_t;
typedef void (*xcommand_t)(void);
typedef struct sizebuf_s {
    qboolean allowoverflow;
    qboolean overflowed;
    byte *data;
    int maxsize;
    int cursize;
} sizebuf_t;
typedef struct client_static_s {
    int state;
    qboolean demoplayback;
    sizebuf_t message;
    byte message_buf[4096];
} client_static_t;

#define true 1
#define false 0
#define NULL 0
#define src_command 0
#define src_client 1
#define ca_disconnected 1
#define ca_connected 2
#define clc_stringcmd 4

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
int _fltused = 0;

client_static_t cls;
int com_argc;
char **com_argv;
char com_token[1024];
qboolean host_initialized;

static byte mq_zone[65536];
static int mq_zone_used;
static byte mq_hunk[65536];
static int mq_hunk_used;
static int mq_print_calls;
static int mq_sys_error_calls;
static int mq_callback_calls;
static int mq_cvar_command;
static char mq_loaded_file[256];

static int mq_strlen(const char *text)
{
    int result = 0;
    while (text && text[result]) result++;
    return result;
}
static void mq_copy(char *destination, const char *source)
{
    while ((*destination++ = *source++) != 0) ;
}
static int mq_compare(const char *left, const char *right)
{
    int index = 0;
    while (left[index] && right[index] && left[index] == right[index]) index++;
    return (unsigned char)left[index] - (unsigned char)right[index];
}
static char mq_lower(char value)
{
    if (value >= 'A' && value <= 'Z') return value + ('a' - 'A');
    return value;
}
static int mq_compare_insensitive(const char *left, const char *right)
{
    int index = 0;
    while (left[index] && right[index] && mq_lower(left[index]) == mq_lower(right[index])) index++;
    return mq_lower(left[index]) - mq_lower(right[index]);
}
static int mq_compare_n(const char *left, const char *right, int count)
{
    int index;
    for (index = 0; index < count; index++) {
        if (left[index] != right[index] || !left[index] || !right[index])
            return (unsigned char)left[index] - (unsigned char)right[index];
    }
    return 0;
}
static void *mq_memcpy(void *destination, const void *source, int length)
{
    byte *out = destination; const byte *in = source; int index;
    for (index = 0; index < length; index++) out[index] = in[index];
    return destination;
}
static char *mq_strcat(char *destination, const char *source)
{
    mq_copy(destination + mq_strlen(destination), source);
    return destination;
}
void *Z_Malloc(int length)
{
    void *result;
    if (mq_zone_used + length > (int)sizeof(mq_zone)) return NULL;
    result = mq_zone + mq_zone_used; mq_zone_used += length;
    return result;
}
void Z_Free(void *value) { (void)value; }
void *Hunk_Alloc(int length)
{
    void *result;
    if (mq_hunk_used + length > (int)sizeof(mq_hunk)) return NULL;
    result = mq_hunk + mq_hunk_used; mq_hunk_used += length;
    return result;
}
int Hunk_LowMark(void) { return mq_hunk_used; }
void Hunk_FreeToLowMark(int mark) { mq_hunk_used = mark; }
void SZ_Alloc(sizebuf_t *buffer, int size)
{
    buffer->data = Hunk_Alloc(size); buffer->maxsize = size; buffer->cursize = 0;
}
void SZ_Clear(sizebuf_t *buffer) { buffer->cursize = 0; }
void SZ_Write(sizebuf_t *buffer, void *data, int length)
{
    if (buffer->cursize + length > buffer->maxsize) return;
    mq_memcpy(buffer->data + buffer->cursize, data, length); buffer->cursize += length;
}
void SZ_Print(sizebuf_t *buffer, char *text)
{
    int length = mq_strlen(text) + 1;
    if (buffer->cursize && buffer->data[buffer->cursize - 1] == 0) {
        buffer->cursize--; SZ_Write(buffer, text, length);
    } else SZ_Write(buffer, text, length);
}
void MSG_WriteByte(sizebuf_t *buffer, int value)
{
    byte item = (byte)value; SZ_Write(buffer, &item, 1);
}
int Q_strlen(char *text) { return mq_strlen(text); }
void Q_memcpy(void *destination, void *source, int length) { mq_memcpy(destination, source, length); }
void Q_strcat(char *destination, char *source) { mq_strcat(destination, source); }
void Q_strcpy(char *destination, char *source) { mq_copy(destination, source); }
int Q_strcmp(char *left, char *right) { return mq_compare(left, right); }
int Q_strcasecmp(char *left, char *right) { return mq_compare_insensitive(left, right); }
int Q_strncmp(char *left, char *right, int count) { return mq_compare_n(left, right, count); }
void Con_Printf(char *format, ...) { (void)format; mq_print_calls++; }
void Sys_Error(char *format, ...) { (void)format; mq_sys_error_calls++; }
char *Cvar_VariableString(char *name)
{
    if (mq_compare(name, "taken") == 0) return "1";
    return "";
}
qboolean Cvar_Command(void) { return mq_cvar_command; }
char *COM_Parse(char *text)
{
    int count = 0;
    while (*text && *text <= ' ' && *text != '\n') text++;
    if (!*text || *text == '\n') { com_token[0] = 0; return text; }
    if (text[0] == '/' && text[1] == '/') { com_token[0] = 0; return text + mq_strlen(text); }
    if (*text == '"') {
        text++;
        while (*text && *text != '"' && count < 1023) com_token[count++] = *text++;
        if (*text == '"') text++;
    } else if (*text == '{' || *text == '}' || *text == ')' || *text == '(' || *text == '\'' || *text == ':') {
        com_token[count++] = *text++;
    } else {
        while (*text > ' ' && *text != '{' && *text != '}' && *text != ')' &&
               *text != '(' && *text != '\'' && *text != ':' && count < 1023)
            com_token[count++] = *text++;
    }
    com_token[count] = 0;
    return text;
}
char *COM_LoadHunkFile(char *name)
{
    (void)name;
    return mq_loaded_file[0] ? mq_loaded_file : NULL;
}
int Cmd_Argc(void);
char *Cmd_Argv(int arg);
char *Cmd_Args(void);
void Cmd_AddCommand(char *name, xcommand_t function);
void Cmd_ExecuteString(char *text, cmd_source_t source);

#define memcpy mq_memcpy
#define strlen mq_strlen
#define strcpy(destination,source) (mq_copy(destination,source),(destination))
#define strcat mq_strcat
#define strcmp mq_compare
/*__PINNED_CMD_SOURCE__*/
#undef memcpy
#undef strlen
#undef strcpy
#undef strcat
#undef strcmp

static void mq_callback(void) { mq_callback_calls++; }
static int mq_text_equal(const char *left, const char *right) { return mq_compare(left, right) == 0; }
static void mq_reset(void)
{
    mq_zone_used = mq_hunk_used = mq_print_calls = mq_sys_error_calls = 0;
    mq_callback_calls = mq_cvar_command = 0;
    mq_loaded_file[0] = 0;
    host_initialized = false;
    cls.state = ca_disconnected; cls.demoplayback = false;
    cls.message.data = cls.message_buf; cls.message.maxsize = sizeof(cls.message_buf); cls.message.cursize = 0;
    cmd_alias = NULL; cmd_functions = NULL; cmd_argc = 0; cmd_args = NULL; cmd_wait = false;
    cmd_text.data = NULL; cmd_text.maxsize = cmd_text.cursize = 0;
}
static void mq_emit(char *output, int capacity, const char *line)
{
    int used = mq_strlen(output), length = mq_strlen(line), index;
    if (used + length + 1 >= capacity) return;
    for (index = 0; index < length; index++) output[used + index] = line[index];
    output[used + length] = '\n'; output[used + length + 1] = 0;
}

__declspec(dllexport) int cmd_oracle_jsonl(char *output, int capacity)
{
    char line[1024];
    char *stuff_argv[] = {"quake", "+foo", "bar", "-x", "+baz", "qux"};
    char token_text[] = "alpha one \"two words\"";
    char alias_text[] = "alias combo echo hi";
    char exec_text[] = "exec script.cfg";
    char forward_text[] = "say hi";
    char *copy;
    qboolean overflow_rejected;

    if (!output || capacity < 2) return -1;
    output[0] = 0;

    mq_reset(); Cmd_Wait_f();
    sprintf(line, "{\"function\":\"Cmd_Wait_f\",\"case\":\"set\",\"wait\":%s}", cmd_wait ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset(); Cbuf_Init();
    sprintf(line, "{\"function\":\"Cbuf_Init\",\"case\":\"capacity\",\"capacity\":%i,\"size\":%i}", cmd_text.maxsize, cmd_text.cursize);
    mq_emit(output, capacity, line);

    mq_reset(); Cbuf_Init();
    cmd_text.cursize = 8190; Cbuf_AddText("x"); Cbuf_AddText("x");
    overflow_rejected = cmd_text.cursize == 8191 && mq_print_calls == 1;
    sprintf(line, "{\"function\":\"Cbuf_AddText\",\"case\":\"boundary\",\"size\":%i,\"overflow_rejected\":%s}", cmd_text.cursize, overflow_rejected ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset(); Cbuf_Init(); Cbuf_AddText("tail"); Cbuf_InsertText("head");
    cmd_text.data[cmd_text.cursize] = 0;
    sprintf(line, "{\"function\":\"Cbuf_InsertText\",\"case\":\"prepend\",\"text\":\"%s\"}", cmd_text.data);
    mq_emit(output, capacity, line);

    mq_reset(); Cbuf_Init(); Cmd_Init(); Cmd_AddCommand("mark", mq_callback);
    Cbuf_AddText("mark one;wait;mark two"); Cbuf_Execute();
    cmd_text.data[cmd_text.cursize] = 0;
    sprintf(line, "{\"function\":\"Cbuf_Execute\",\"case\":\"wait_defers\",\"calls\":%i,\"remaining\":\"%s\"}", mq_callback_calls, cmd_text.data);
    mq_emit(output, capacity, line);

    mq_reset(); Cbuf_Init(); Cmd_TokenizeString("stuffcmds");
    com_argc = 6; com_argv = stuff_argv; Cmd_StuffCmds_f(); cmd_text.data[cmd_text.cursize] = 0;
    sprintf(line, "{\"function\":\"Cmd_StuffCmds_f\",\"case\":\"plus_commands\",\"size\":%i,\"content_ok\":%s}",
        cmd_text.cursize, mq_text_equal((char *)cmd_text.data, "foo bar \nbaz qux\n") ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset(); Cbuf_Init(); mq_copy(mq_loaded_file, "echo loaded\n"); Cmd_TokenizeString(exec_text); Cmd_Exec_f();
    cmd_text.data[cmd_text.cursize] = 0;
    sprintf(line, "{\"function\":\"Cmd_Exec_f\",\"case\":\"loaded\",\"size\":%i,\"content_ok\":%s}",
        cmd_text.cursize, mq_text_equal((char *)cmd_text.data, "echo loaded\n") ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset(); Cmd_TokenizeString("echo one two"); Cmd_Echo_f();
    sprintf(line, "{\"function\":\"Cmd_Echo_f\",\"case\":\"two_args\",\"prints\":%i}", mq_print_calls);
    mq_emit(output, capacity, line);

    mq_reset(); copy = CopyString("quake");
    sprintf(line, "{\"function\":\"CopyString\",\"case\":\"copy\",\"text\":\"%s\",\"distinct\":%s}", copy, copy != (char *)"quake" ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset(); Cmd_TokenizeString(alias_text); Cmd_Alias_f();
    sprintf(line, "{\"function\":\"Cmd_Alias_f\",\"case\":\"create\",\"name\":\"%s\",\"value_size\":%i,\"trailing_space\":%s}",
        cmd_alias->name, mq_strlen(cmd_alias->value),
        mq_text_equal(cmd_alias->value, "echo hi \n") ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset(); Cmd_Init();
    sprintf(line, "{\"function\":\"Cmd_Init\",\"case\":\"stock\",\"commands\":%i}", Cmd_Exists("wait") + Cmd_Exists("exec") + Cmd_Exists("echo") + Cmd_Exists("alias") + Cmd_Exists("cmd") + Cmd_Exists("stuffcmds"));
    mq_emit(output, capacity, line);

    mq_reset(); Cmd_TokenizeString(token_text);
    sprintf(line, "{\"function\":\"Cmd_Argc\",\"case\":\"tokenized\",\"argc\":%i}", Cmd_Argc());
    mq_emit(output, capacity, line);
    sprintf(line, "{\"function\":\"Cmd_Argv\",\"case\":\"bounds\",\"first\":\"%s\",\"missing\":\"%s\"}", Cmd_Argv(0), Cmd_Argv(9));
    mq_emit(output, capacity, line);
    sprintf(line, "{\"function\":\"Cmd_Args\",\"case\":\"tail\",\"args_size\":%i,\"raw_quotes\":%s}",
        mq_strlen(Cmd_Args()), mq_text_equal(Cmd_Args(), "one \"two words\"") ? "true" : "false");
    mq_emit(output, capacity, line);
    sprintf(line, "{\"function\":\"Cmd_TokenizeString\",\"case\":\"quoted\",\"argc\":%i,\"second\":\"%s\",\"third\":\"%s\"}", Cmd_Argc(), Cmd_Argv(1), Cmd_Argv(2));
    mq_emit(output, capacity, line);

    mq_reset(); Cmd_AddCommand("known", mq_callback); Cmd_AddCommand("known", mq_callback); Cmd_AddCommand("taken", mq_callback);
    sprintf(line, "{\"function\":\"Cmd_AddCommand\",\"case\":\"duplicates\",\"exists\":%s,\"rejections\":%i}", Cmd_Exists("known") ? "true" : "false", mq_print_calls);
    mq_emit(output, capacity, line);

    sprintf(line, "{\"function\":\"Cmd_Exists\",\"case\":\"known_missing\",\"known\":%s,\"missing\":%s}", Cmd_Exists("known") ? "true" : "false", Cmd_Exists("missing") ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset(); Cmd_AddCommand("status", mq_callback);
    sprintf(line, "{\"function\":\"Cmd_CompleteCommand\",\"case\":\"prefix\",\"match\":\"%s\",\"case_sensitive_null\":%s}", Cmd_CompleteCommand("sta"), Cmd_CompleteCommand("Sta") == NULL ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset(); Cbuf_Init(); Cmd_AddCommand("known", mq_callback); Cmd_ExecuteString("KNOWN one", src_client);
    sprintf(line, "{\"function\":\"Cmd_ExecuteString\",\"case\":\"registered\",\"calls\":%i,\"source\":%i}", mq_callback_calls, cmd_source);
    mq_emit(output, capacity, line);

    mq_reset(); Cmd_TokenizeString(forward_text); Cmd_ForwardToServer();
    sprintf(line, "{\"function\":\"Cmd_ForwardToServer\",\"case\":\"disconnected\",\"bytes\":%i}", cls.message.cursize);
    mq_emit(output, capacity, line);

    mq_reset(); Cmd_TokenizeString("tool -first value");
    sprintf(line, "{\"function\":\"Cmd_CheckParm\",\"case\":\"found_missing\",\"found\":%i,\"missing\":%i}", Cmd_CheckParm("-FIRST"), Cmd_CheckParm("-none"));
    mq_emit(output, capacity, line);

    return mq_strlen(output);
}
