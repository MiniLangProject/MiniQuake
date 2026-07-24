#ifndef MINIQUAKE_SYS_WIN_ORACLE_STUBS_H
#define MINIQUAKE_SYS_WIN_ORACLE_STUBS_H

#define WINAPI
#define NULL ((void *)0)
#define false 0
#define true 1
#define FALSE 0
#define TRUE 1
#define SEEK_SET 0
#define SEEK_END 2
#define PAGE_READWRITE 0x04
#define VER_PLATFORM_WIN32s 0
#define VER_PLATFORM_WIN32_NT 2
#define KEY_EVENT 1
#define PM_NOREMOVE 0
#define QS_ALLINPUT 0x04ff
#define STD_INPUT_HANDLE ((unsigned long)-10)
#define STD_OUTPUT_HANDLE ((unsigned long)-11)
#define MB_OK 0
#define MB_SETFOREGROUND 0x00010000
#define MB_ICONSTOP 0x10
#define IDD_DIALOG1 101
#define MAKEINTRESOURCE(value) ((char *)(unsigned long)(value))
#define SWP_NOZORDER 0x0004
#define SWP_NOSIZE 0x0001
#define SW_SHOWDEFAULT 10
#define MAX_NUM_ARGVS 50

typedef unsigned char byte;
typedef int qboolean;
typedef unsigned long DWORD;
typedef void *HANDLE;
typedef void *HINSTANCE;
typedef void *HWND;
typedef char *LPSTR;
typedef void *LPVOID;
typedef char *va_list;

#define va_start(list, last) ((void)((list) = 0))
#define va_end(list) ((void)0)

typedef struct fake_file_s {
    byte data[128];
    int length;
    int position;
    int writable;
    int open;
} FILE;

typedef struct {
    unsigned long LowPart;
    long HighPart;
} LARGE_INTEGER;

typedef struct {
    DWORD dwOSVersionInfoSize;
    DWORD dwMajorVersion;
    DWORD dwMinorVersion;
    DWORD dwBuildNumber;
    DWORD dwPlatformId;
    char szCSDVersion[128];
} OSVERSIONINFO;

typedef struct {
    DWORD dwLength;
    DWORD dwMemoryLoad;
    unsigned __int64 dwTotalPhys;
    unsigned __int64 dwAvailPhys;
    unsigned __int64 dwTotalPageFile;
    unsigned __int64 dwAvailPageFile;
    unsigned __int64 dwTotalVirtual;
    unsigned __int64 dwAvailVirtual;
} MEMORYSTATUS;

typedef struct {
    long left;
    long top;
    long right;
    long bottom;
} RECT;

typedef struct {
    int bKeyDown;
    union {
        unsigned short UnicodeChar;
        char AsciiChar;
    } uChar;
} KEY_EVENT_RECORD;

typedef struct {
    unsigned short EventType;
    union {
        KEY_EVENT_RECORD KeyEvent;
    } Event;
} INPUT_RECORD;

typedef struct {
    int unused;
} MSG;

typedef struct {
    char *basedir;
    char *cachedir;
    int argc;
    char **argv;
    void *membase;
    int memsize;
} quakeparms_t;

typedef struct {
    int paused;
} client_state_t;

typedef struct {
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    void *next;
} cvar_t;

extern int com_argc;
extern char **com_argv;
extern int scr_skipupdate;
extern int DDActive;
extern int block_drawing;
extern client_state_t cl;
extern cvar_t sys_ticrate;
extern int mq_oracle_fatal_mode;
extern int mq_oracle_exit_code;
extern int mq_oracle_stop_after_frame;
extern int mq_oracle_host_frame_calls;
extern int mq_oracle_sametimecount;
extern unsigned int mq_oracle_oldtime;
extern int mq_oracle_first;
extern int errno;

__declspec(dllimport) void * __cdecl memset(void *, int, unsigned __int64);
__declspec(dllimport) void * __cdecl memcpy(void *, const void *, unsigned __int64);
__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
__declspec(dllimport) unsigned __int64 __cdecl strlen(const char *);
void *malloc(unsigned __int64);

int vsprintf(char *, const char *, va_list);
char *strerror(int);
FILE *fopen(const char *, const char *);
int fclose(FILE *);
long ftell(FILE *);
int fseek(FILE *, long, int);
unsigned __int64 fread(void *, unsigned __int64, unsigned __int64, FILE *);
unsigned __int64 fwrite(const void *, unsigned __int64, unsigned __int64, FILE *);
int _mkdir(const char *);

int VID_ForceUnlockedAndReturnState(void);
void VID_ForceLockState(int);
void VID_SetDefaultMode(void);
void Sys_Error(char *, ...);
double Sys_FloatTime(void);
char *Sys_ConsoleInput(void);
void Sys_Quit(void);
void Host_Shutdown(void);
void Host_Init(quakeparms_t *);
void Host_Frame(double);
void DeinitConProc(void);
void InitConProc(HANDLE, HANDLE, HANDLE);
void S_BlockSound(void);
int COM_CheckParm(char *);
void COM_InitArgv(int, char **);
double Q_atof(char *);
int Q_atoi(char *);
int Q_strlen(char *);

int VirtualProtect(LPVOID, unsigned long, DWORD, DWORD *);
int QueryPerformanceFrequency(LARGE_INTEGER *);
int QueryPerformanceCounter(LARGE_INTEGER *);
int GetVersionEx(OSVERSIONINFO *);
int WriteFile(HANDLE, const void *, DWORD, DWORD *, void *);
int MessageBox(HWND, const char *, const char *, unsigned int);
void Sleep(DWORD);
int GetNumberOfConsoleInputEvents(HANDLE, DWORD *);
int ReadConsoleInput(HANDLE, INPUT_RECORD *, DWORD, DWORD *);
int PeekMessage(MSG *, HWND, unsigned int, unsigned int, unsigned int);
int GetMessage(MSG *, HWND, unsigned int, unsigned int);
int TranslateMessage(const MSG *);
long DispatchMessage(const MSG *);
DWORD MsgWaitForMultipleObjects(DWORD, const HANDLE *, int, DWORD, DWORD);
int CloseHandle(HANDLE);
int FreeConsole(void);
void GlobalMemoryStatus(MEMORYSTATUS *);
DWORD GetCurrentDirectory(DWORD, char *);
HWND CreateDialog(HINSTANCE, char *, HWND, void *);
int GetWindowRect(HWND, RECT *);
int SetWindowPos(HWND, HWND, int, int, int, int, unsigned int);
int ShowWindow(HWND, int);
int UpdateWindow(HWND);
int SetForegroundWindow(HWND);
HANDLE CreateEvent(void *, int, int, const char *);
int AllocConsole(void);
HANDLE GetStdHandle(DWORD);

#endif
