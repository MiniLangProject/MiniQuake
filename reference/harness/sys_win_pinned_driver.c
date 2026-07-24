#include "sys_win_oracle_stubs.h"

int _fltused = 0;
void __chkstk(void) {}

int com_argc;
char **com_argv;
int scr_skipupdate;
int DDActive;
int block_drawing;
client_state_t cl;
cvar_t sys_ticrate = {"sys_ticrate", "0.05", false, false, 0.05f, NULL};
int mq_oracle_fatal_mode;
int mq_oracle_exit_code;
int mq_oracle_stop_after_frame;
int mq_oracle_host_frame_calls;
int mq_oracle_sametimecount;
unsigned int mq_oracle_oldtime;
int mq_oracle_first = 1;
int errno;

extern FILE *sys_handles[10];
extern int sys_checksum;
extern qboolean isDedicated;
extern qboolean WinNT;
extern qboolean ActiveApp;
extern qboolean Minimized;
extern HANDLE hinput;
extern HANDLE houtput;

void Sys_PageIn(void *, int);
int findhandle(void);
int filelength(FILE *);
int Sys_FileOpenRead(char *, int *);
int Sys_FileOpenWrite(char *);
void Sys_FileClose(int);
void Sys_FileSeek(int, int);
int Sys_FileRead(int, void *, int);
int Sys_FileWrite(int, void *, int);
int Sys_FileTime(char *);
void Sys_mkdir(char *);
void Sys_MakeCodeWriteable(unsigned long, unsigned long);
void Sys_SetFPCW(void);
void Sys_PushFPCW_SetHigh(void);
void Sys_PopFPCW(void);
void MaskExceptions(void);
void Sys_Init(void);
void Sys_Printf(char *, ...);
void Sys_Sleep(void);
void Sys_SendKeyEvents(void);
void SleepUntilInput(int);
void Sys_InitFloatTime(void);
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int);
void mq_sys_win_reset_timer(void);
int mq_sys_win_lowshift(void);
double mq_sys_win_pfreq(void);
double mq_sys_win_curtime(void);
void mq_sys_win_set_clock(double, int);

static FILE read_file;
static FILE write_file;
static int force_fopen_failure;
static int video_unlock_calls;
static int video_lock_calls;
static int last_video_state;
static int mkdir_calls;
static int virtual_protect_success;
static int virtual_protect_calls;
static unsigned long last_protect_start;
static unsigned long last_protect_length;
static unsigned __int64 fake_frequency;
static unsigned __int64 counter_values[32];
static int counter_count;
static int counter_index;
static int version_success;
static DWORD version_major;
static DWORD version_platform;
static int write_calls;
static int written_bytes;
static char output_text[4096];
static int output_length;
static int message_box_calls;
static int host_shutdown_calls;
static int host_init_calls;
static int host_frame_calls;
static int conproc_init_calls;
static int conproc_deinit_calls;
static int block_sound_calls;
static int sleep_calls;
static int slept_ms;
static int wait_calls;
static int waited_ms;
static int close_handle_calls;
static int free_console_calls;
static int console_alloc_success;
static INPUT_RECORD console_queue[32];
static int console_count;
static int console_index;
static int peek_messages;
static int get_message_result;
static int translate_calls;
static int dispatch_calls;
static int create_event_success;
static int init_memsize;
static int init_argc;
static char *argv_default[] = {""};
static char *argv_start[] = {"", "-starttime", "3.5"};
static byte allocation_arena[16 * 1024 * 1024];
static byte oracle_memory[65540];

void *malloc(unsigned __int64 size)
{
    if (size > sizeof(allocation_arena))
        return NULL;
    memset(allocation_arena, 0, size);
    return allocation_arena;
}

static int text_equal(const char *left, const char *right)
{
    while (*left || *right)
        if (*left++ != *right++)
            return 0;
    return 1;
}

static void copy_text(char *destination, const char *source, int capacity)
{
    int index = 0;
    while (source && source[index] && index + 1 < capacity)
    {
        destination[index] = source[index];
        ++index;
    }
    destination[index] = 0;
}

static void append_text(const char *source)
{
    while (*source && output_length + 1 < (int)sizeof(output_text))
        output_text[output_length++] = *source++;
    output_text[output_length] = 0;
}

int vsprintf(char *destination, const char *format, va_list arguments)
{
    (void)arguments;
    copy_text(destination, format, 1024);
    return (int)strlen(destination);
}

char *strerror(int error_number)
{
    (void)error_number;
    return "fixture error";
}

FILE *fopen(const char *path, const char *mode)
{
    if (force_fopen_failure || text_equal(path, "missing"))
        return NULL;
    if (mode[0] == 'r')
    {
        read_file.position = 0;
        read_file.open = 1;
        return &read_file;
    }
    write_file.length = 0;
    write_file.position = 0;
    write_file.writable = 1;
    write_file.open = 1;
    return &write_file;
}

int fclose(FILE *file)
{
    file->open = 0;
    return 0;
}

long ftell(FILE *file) { return file->position; }

int fseek(FILE *file, long offset, int origin)
{
    file->position = origin == SEEK_END ? file->length + (int)offset : (int)offset;
    return 0;
}

unsigned __int64 fread(void *destination, unsigned __int64 size,
                      unsigned __int64 count, FILE *file)
{
    unsigned __int64 bytes = size * count;
    if ((unsigned __int64)file->position + bytes > (unsigned __int64)file->length)
        bytes = (unsigned __int64)(file->length - file->position);
    memcpy(destination, file->data + file->position, bytes);
    file->position += (int)bytes;
    return size ? bytes / size : 0;
}

unsigned __int64 fwrite(const void *source, unsigned __int64 size,
                       unsigned __int64 count, FILE *file)
{
    unsigned __int64 bytes = size * count;
    if ((unsigned __int64)file->position + bytes > sizeof(file->data))
        bytes = sizeof(file->data) - (unsigned __int64)file->position;
    memcpy(file->data + file->position, source, bytes);
    file->position += (int)bytes;
    if (file->position > file->length)
        file->length = file->position;
    return size ? bytes / size : 0;
}

int _mkdir(const char *path)
{
    (void)path;
    ++mkdir_calls;
    return 0;
}

int VID_ForceUnlockedAndReturnState(void)
{
    ++video_unlock_calls;
    return 7;
}

void VID_ForceLockState(int state)
{
    ++video_lock_calls;
    last_video_state = state;
}

void VID_SetDefaultMode(void) {}
void Host_Shutdown(void) { ++host_shutdown_calls; }
void DeinitConProc(void) { ++conproc_deinit_calls; }
void InitConProc(HANDLE file, HANDLE parent, HANDLE child)
{
    (void)file;
    (void)parent;
    (void)child;
    ++conproc_init_calls;
}
void S_BlockSound(void) { ++block_sound_calls; }
void Host_Init(quakeparms_t *parms)
{
    ++host_init_calls;
    init_memsize = parms->memsize;
    init_argc = parms->argc;
}
void Host_Frame(double time)
{
    (void)time;
    ++host_frame_calls;
    mq_oracle_host_frame_calls = host_frame_calls;
}

int COM_CheckParm(char *name)
{
    int index;
    for (index = 1; index < com_argc; ++index)
        if (text_equal(com_argv[index], name))
            return index;
    return 0;
}

void COM_InitArgv(int argc, char **argv)
{
    com_argc = argc;
    com_argv = argv;
}

double Q_atof(char *text)
{
    if (text_equal(text, "3.5"))
        return 3.5;
    return (double)Q_atoi(text);
}

int Q_atoi(char *text)
{
    int sign = 1;
    int result = 0;
    if (*text == '-')
    {
        sign = -1;
        ++text;
    }
    while (*text >= '0' && *text <= '9')
        result = result * 10 + (*text++ - '0');
    return sign * result;
}

int Q_strlen(char *text) { return (int)strlen(text); }

int VirtualProtect(LPVOID address, unsigned long length, DWORD protection,
                   DWORD *old_protection)
{
    (void)protection;
    ++virtual_protect_calls;
    last_protect_start = (unsigned long)address;
    last_protect_length = length;
    *old_protection = 0x20;
    return virtual_protect_success;
}

int QueryPerformanceFrequency(LARGE_INTEGER *frequency)
{
    frequency->LowPart = (unsigned long)(fake_frequency & 0xffffffff);
    frequency->HighPart = (long)(fake_frequency >> 32);
    return fake_frequency != 0;
}

int QueryPerformanceCounter(LARGE_INTEGER *counter)
{
    unsigned __int64 value = 0;
    if (counter_index < counter_count)
        value = counter_values[counter_index++];
    else if (counter_count)
        value = counter_values[counter_count - 1];
    counter->LowPart = (unsigned long)(value & 0xffffffff);
    counter->HighPart = (long)(value >> 32);
    return 1;
}

int GetVersionEx(OSVERSIONINFO *info)
{
    info->dwMajorVersion = version_major;
    info->dwPlatformId = version_platform;
    return version_success;
}

int WriteFile(HANDLE handle, const void *data, DWORD count, DWORD *written,
              void *overlapped)
{
    (void)handle;
    (void)overlapped;
    ++write_calls;
    written_bytes += (int)count;
    if (data && count)
    {
        char temporary[1025];
        int copy = count > 1024 ? 1024 : (int)count;
        memcpy(temporary, data, (unsigned __int64)copy);
        temporary[copy] = 0;
        append_text(temporary);
    }
    if (written)
        *written = count;
    return 1;
}

int MessageBox(HWND window, const char *text, const char *caption,
               unsigned int flags)
{
    (void)window;
    (void)text;
    (void)caption;
    (void)flags;
    ++message_box_calls;
    return 0;
}

void Sleep(DWORD milliseconds)
{
    ++sleep_calls;
    slept_ms += (int)milliseconds;
}

int GetNumberOfConsoleInputEvents(HANDLE input, DWORD *events)
{
    (void)input;
    *events = (DWORD)(console_count - console_index);
    return 1;
}

int ReadConsoleInput(HANDLE input, INPUT_RECORD *record, DWORD requested,
                     DWORD *read)
{
    (void)input;
    (void)requested;
    if (console_index >= console_count)
    {
        *read = 0;
        return 0;
    }
    *record = console_queue[console_index++];
    *read = 1;
    return 1;
}

int PeekMessage(MSG *message, HWND window, unsigned int minimum,
                unsigned int maximum, unsigned int remove)
{
    (void)message;
    (void)window;
    (void)minimum;
    (void)maximum;
    (void)remove;
    if (peek_messages > 0)
    {
        --peek_messages;
        return 1;
    }
    return 0;
}

int GetMessage(MSG *message, HWND window, unsigned int minimum,
               unsigned int maximum)
{
    (void)message;
    (void)window;
    (void)minimum;
    (void)maximum;
    return get_message_result;
}
int TranslateMessage(const MSG *message) { (void)message; ++translate_calls; return 1; }
long DispatchMessage(const MSG *message) { (void)message; ++dispatch_calls; return 0; }

DWORD MsgWaitForMultipleObjects(DWORD count, const HANDLE *handles, int wait_all,
                                DWORD milliseconds, DWORD mask)
{
    (void)count;
    (void)handles;
    (void)wait_all;
    (void)mask;
    ++wait_calls;
    waited_ms = (int)milliseconds;
    return 0;
}

int CloseHandle(HANDLE handle) { (void)handle; ++close_handle_calls; return 1; }
int FreeConsole(void) { ++free_console_calls; return 1; }

void GlobalMemoryStatus(MEMORYSTATUS *status)
{
    status->dwAvailPhys = 1024;
    status->dwTotalPhys = 64 * 1024 * 1024;
}

DWORD GetCurrentDirectory(DWORD capacity, char *destination)
{
    copy_text(destination, "C:\\MiniQuake", (int)capacity);
    return 12;
}

HWND CreateDialog(HINSTANCE instance, char *resource, HWND parent, void *proc)
{
    (void)instance;
    (void)resource;
    (void)parent;
    (void)proc;
    return (HWND)1;
}
int GetWindowRect(HWND window, RECT *rect)
{
    (void)window;
    rect->left = 10; rect->top = 10; rect->right = 210; rect->bottom = 110;
    return 1;
}
int SetWindowPos(HWND window, HWND after, int x, int y, int width, int height,
                 unsigned int flags)
{ (void)window; (void)after; (void)x; (void)y; (void)width; (void)height; (void)flags; return 1; }
int ShowWindow(HWND window, int command) { (void)window; (void)command; return 1; }
int UpdateWindow(HWND window) { (void)window; return 1; }
int SetForegroundWindow(HWND window) { (void)window; return 1; }
HANDLE CreateEvent(void *security, int manual, int initial, const char *name)
{
    (void)security; (void)manual; (void)initial; (void)name;
    return create_event_success ? (HANDLE)11 : NULL;
}
int AllocConsole(void) { return console_alloc_success; }
HANDLE GetStdHandle(DWORD handle) { return (HANDLE)(unsigned __int64)handle; }

static void queue_counter(unsigned __int64 value)
{
    counter_values[counter_count++] = value;
}

static void queue_key(int character, int down)
{
    INPUT_RECORD *record = &console_queue[console_count++];
    memset(record, 0, sizeof(*record));
    record->EventType = KEY_EVENT;
    record->Event.KeyEvent.bKeyDown = down;
    record->Event.KeyEvent.uChar.AsciiChar = (char)character;
}

static void reset_all(void)
{
    int index;
    memset(&read_file, 0, sizeof(read_file));
    memset(&write_file, 0, sizeof(write_file));
    memcpy(read_file.data, "abcdef", 6);
    read_file.length = 6;
    read_file.open = 1;
    force_fopen_failure = 0;
    video_unlock_calls = video_lock_calls = last_video_state = 0;
    mkdir_calls = 0;
    virtual_protect_success = 1;
    virtual_protect_calls = 0;
    last_protect_start = last_protect_length = 0;
    fake_frequency = 1000000;
    counter_count = counter_index = 0;
    version_success = 1;
    version_major = 4;
    version_platform = VER_PLATFORM_WIN32_NT;
    write_calls = written_bytes = output_length = 0;
    output_text[0] = 0;
    message_box_calls = host_shutdown_calls = 0;
    host_init_calls = host_frame_calls = 0;
    conproc_init_calls = conproc_deinit_calls = block_sound_calls = 0;
    sleep_calls = slept_ms = wait_calls = waited_ms = 0;
    close_handle_calls = free_console_calls = 0;
    console_alloc_success = 1;
    console_count = console_index = 0;
    peek_messages = 0;
    get_message_result = 1;
    translate_calls = dispatch_calls = 0;
    create_event_success = 1;
    init_memsize = init_argc = 0;
    mq_oracle_fatal_mode = mq_oracle_exit_code = 0;
    mq_oracle_stop_after_frame = mq_oracle_host_frame_calls = 0;
    scr_skipupdate = 1;
    DDActive = block_drawing = 0;
    cl.paused = 0;
    isDedicated = false;
    ActiveApp = true;
    Minimized = false;
    WinNT = false;
    hinput = (HANDLE)1;
    houtput = (HANDLE)2;
    com_argc = 1;
    com_argv = argv_default;
    sys_checksum = 0;
    for (index = 0; index < 10; ++index)
        sys_handles[index] = NULL;
    mq_sys_win_reset_timer();
}

static char *emit(char *output, const char *function, const char *case_name,
                  int result, int index, int value, int count)
{
    output += sprintf(output,
        "{\"function\":\"%s\",\"case\":\"%s\",\"result\":%d,"
        "\"index\":%d,\"value\":%d,\"count\":%d}\n",
        function, case_name, result, index, value, count);
    return output;
}

__declspec(dllexport) int sys_win_oracle_jsonl(char *output, int capacity)
{
    char *cursor = output;
    byte *memory = oracle_memory;
    int handle;
    int result;
    byte buffer[8];
    char command_line[] = "-dedicated -heapsize 4096";
    (void)capacity;

    reset_all();
    memset(memory, 0, sizeof(oracle_memory));
    memory[0] = 1;
    memory[65536] = 2;
    Sys_PageIn(memory, sizeof(oracle_memory));
    cursor = emit(cursor, "Sys_PageIn", "four_pass", sys_checksum, 0, 0, 4);

    reset_all();
    cursor = emit(cursor, "findhandle", "first_free", findhandle(), 1, 9, 1);

    reset_all();
    read_file.position = 2;
    result = filelength(&read_file);
    buffer[0] = 0;
    fread(buffer, 1, 1, &read_file);
    cursor = emit(cursor, "filelength", "restore_position", result,
                  buffer[0], last_video_state, video_lock_calls);

    reset_all();
    handle = -1;
    result = Sys_FileOpenRead("read", &handle);
    cursor = emit(cursor, "Sys_FileOpenRead", "success", result, handle,
                  sys_handles[handle] != NULL, video_lock_calls);

    reset_all();
    handle = Sys_FileOpenWrite("write");
    cursor = emit(cursor, "Sys_FileOpenWrite", "success", handle,
                  write_file.writable, sys_handles[handle] != NULL, video_lock_calls);

    Sys_FileClose(handle);
    cursor = emit(cursor, "Sys_FileClose", "clear", sys_handles[handle] == NULL,
                  write_file.open, last_video_state, video_lock_calls);

    reset_all();
    handle = 1;
    sys_handles[handle] = &read_file;
    Sys_FileSeek(handle, 4);
    buffer[0] = 0;
    fread(buffer, 1, 1, &read_file);
    cursor = emit(cursor, "Sys_FileSeek", "absolute", buffer[0],
                  last_video_state, video_lock_calls, 1);

    read_file.position = 0;
    memset(buffer, 0, sizeof(buffer));
    result = Sys_FileRead(handle, buffer, 3);
    cursor = emit(cursor, "Sys_FileRead", "bytes", result, buffer[0] * 100 + buffer[2],
                  read_file.position, video_lock_calls);

    reset_all();
    handle = 1;
    sys_handles[handle] = &write_file;
    result = Sys_FileWrite(handle, "XYZ", 3);
    cursor = emit(cursor, "Sys_FileWrite", "bytes", result, write_file.data[0],
                  write_file.length, video_lock_calls);

    reset_all();
    result = Sys_FileTime("read");
    cursor = emit(cursor, "Sys_FileTime", "present", result, read_file.open,
                  last_video_state, video_lock_calls);

    reset_all();
    Sys_mkdir("fixture");
    cursor = emit(cursor, "Sys_mkdir", "delegate", mkdir_calls, 0, 0, 1);

    reset_all();
    Sys_MakeCodeWriteable(4096, 128);
    cursor = emit(cursor, "Sys_MakeCodeWriteable", "protect",
                  virtual_protect_calls, (int)last_protect_start,
                  (int)last_protect_length, 1);

    MaskExceptions();
    cursor = emit(cursor, "MaskExceptions", "x64_noop", 1, 0, 0, 1);
    Sys_SetFPCW();
    cursor = emit(cursor, "Sys_SetFPCW", "x64_noop", 1, 0, 0, 1);
    Sys_PushFPCW_SetHigh();
    cursor = emit(cursor, "Sys_PushFPCW_SetHigh", "x64_noop", 1, 0, 0, 1);
    Sys_PopFPCW();
    cursor = emit(cursor, "Sys_PopFPCW", "x64_noop", 1, 0, 0, 1);

    reset_all();
    fake_frequency = 4000000;
    queue_counter(100);
    Sys_Init();
    cursor = emit(cursor, "Sys_Init", "timer_and_os", 1, mq_sys_win_lowshift(),
                  WinNT, (int)(mq_sys_win_pfreq() * 4000000.0));

    reset_all();
    com_argc = 3;
    com_argv = argv_start;
    queue_counter(100);
    Sys_InitFloatTime();
    cursor = emit(cursor, "Sys_InitFloatTime", "starttime",
                  (int)(mq_sys_win_curtime() * 1000.0), 3, 500, 1);

    reset_all();
    mq_sys_win_set_clock(0.000001, 0);
    queue_counter(100);
    queue_counter(1000100);
    Sys_FloatTime();
    result = (int)(Sys_FloatTime() * 1000.0);
    cursor = emit(cursor, "Sys_FloatTime", "delta", result, 1000, 0, 1);

    reset_all();
    isDedicated = true;
    queue_key('x', 1);
    queue_key('h', 0);
    queue_key('i', 0);
    queue_key('\b', 0);
    queue_key('o', 0);
    queue_key('\r', 0);
    {
        char *line = Sys_ConsoleInput();
        cursor = emit(cursor, "Sys_ConsoleInput", "line_edit",
                      line && line[0] == 'h' && line[1] == 'o' && line[2] == 0,
                      line ? line[0] : 0, line ? line[1] : 0, write_calls);
    }

    reset_all();
    isDedicated = true;
    Sys_Printf("hello");
    cursor = emit(cursor, "Sys_Printf", "dedicated", output_length,
                  write_calls, written_bytes, 1);

    reset_all();
    Sys_Error("fixture failure");
    cursor = emit(cursor, "Sys_Error", "shutdown", mq_oracle_exit_code,
                  message_box_calls, host_shutdown_calls, conproc_deinit_calls);

    reset_all();
    isDedicated = true;
    Sys_Quit();
    cursor = emit(cursor, "Sys_Quit", "shutdown", mq_oracle_exit_code,
                  host_shutdown_calls, free_console_calls, conproc_deinit_calls);

    reset_all();
    Sys_Sleep();
    cursor = emit(cursor, "Sys_Sleep", "one_ms", slept_ms,
                  sleep_calls, 0, 1);

    reset_all();
    peek_messages = 1;
    Sys_SendKeyEvents();
    cursor = emit(cursor, "Sys_SendKeyEvents", "pump", scr_skipupdate,
                  translate_calls, dispatch_calls, 1);

    reset_all();
    SleepUntilInput(50);
    cursor = emit(cursor, "SleepUntilInput", "wait", waited_ms,
                  wait_calls, 0, 1);

    reset_all();
    fake_frequency = 1000000;
    queue_counter(0);
    queue_counter(100000);
    queue_counter(200000);
    mq_oracle_stop_after_frame = 1;
    result = WinMain((HINSTANCE)1, NULL, command_line, 7);
    cursor = emit(cursor, "WinMain", "dedicated_one_frame", result,
                  init_argc, init_memsize / 1024, host_frame_calls);

    return (int)(cursor - output);
}

__declspec(dllexport) int sys_win_error_case(int mode)
{
    int index;
    reset_all();
    mq_oracle_fatal_mode = 1;
    if (mode == 0)
    {
        for (index = 1; index < 10; ++index)
            sys_handles[index] = &read_file;
        return findhandle();
    }
    if (mode == 1)
    {
        virtual_protect_success = 0;
        Sys_MakeCodeWriteable(4096, 128);
        return 0;
    }
    if (mode == 2)
    {
        fake_frequency = 0;
        Sys_Init();
        return 0;
    }
    force_fopen_failure = 1;
    return Sys_FileOpenWrite("write");
}
