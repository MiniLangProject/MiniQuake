#ifndef MINIQUAKE_CONPROC_ORACLE_STUBS_H
#define MINIQUAKE_CONPROC_ORACLE_STUBS_H

typedef void *HANDLE;
typedef void *LPVOID;
typedef char *LPTSTR;
typedef const char *LPCTSTR;
typedef unsigned long DWORD;
typedef int BOOL;
typedef unsigned short WORD;
typedef short SHORT;
typedef DWORD (*LPTHREAD_START_ROUTINE)(DWORD);

#ifndef NULL
#define NULL ((void *)0)
#endif
#define FALSE 0
#define TRUE 1
#define INFINITE 0xffffffffUL
#define WAIT_OBJECT_0 0
#define FILE_MAP_READ 1
#define FILE_MAP_WRITE 2
#define STD_OUTPUT_HANDLE ((DWORD)-11)
#define STD_INPUT_HANDLE ((DWORD)-10)
#define KEY_EVENT 1
#define CCOM_WRITE_TEXT 0x2
#define CCOM_GET_TEXT 0x3
#define CCOM_GET_SCR_LINES 0x4
#define CCOM_SET_SCR_LINES 0x5

typedef struct
{
    SHORT X;
    SHORT Y;
} COORD;

typedef struct
{
    SHORT Left;
    SHORT Top;
    SHORT Right;
    SHORT Bottom;
} SMALL_RECT;

typedef struct
{
    COORD dwSize;
    COORD dwCursorPosition;
    WORD wAttributes;
    SMALL_RECT srWindow;
    COORD dwMaximumWindowSize;
} CONSOLE_SCREEN_BUFFER_INFO;

typedef struct
{
    BOOL bKeyDown;
    WORD wRepeatCount;
    WORD wVirtualKeyCode;
    WORD wVirtualScanCode;
    union
    {
        char AsciiChar;
        unsigned short UnicodeChar;
    } uChar;
    DWORD dwControlKeyState;
} KEY_EVENT_RECORD;

typedef struct
{
    WORD EventType;
    union
    {
        KEY_EVENT_RECORD KeyEvent;
    } Event;
} INPUT_RECORD;

HANDLE CreateEvent(void *, BOOL, BOOL, const char *);
HANDLE CreateThread(
    void *, DWORD, LPTHREAD_START_ROUTINE, void *, DWORD, DWORD *);
BOOL CloseHandle(HANDLE);
HANDLE GetStdHandle(DWORD);
BOOL SetEvent(HANDLE);
DWORD WaitForMultipleObjects(DWORD, const HANDLE *, BOOL, DWORD);
LPVOID MapViewOfFile(HANDLE, DWORD, DWORD, DWORD, DWORD);
BOOL UnmapViewOfFile(LPVOID);
BOOL GetConsoleScreenBufferInfo(HANDLE, CONSOLE_SCREEN_BUFFER_INFO *);
BOOL ReadConsoleOutputCharacter(
    HANDLE, LPTSTR, DWORD, COORD, DWORD *);
BOOL WriteConsoleInput(HANDLE, const INPUT_RECORD *, DWORD, DWORD *);
COORD GetLargestConsoleWindowSize(HANDLE);
BOOL SetConsoleWindowInfo(HANDLE, BOOL, const SMALL_RECT *);
BOOL SetConsoleScreenBufferSize(HANDLE, COORD);
int toupper(int);
int isupper(int);
int isalpha(int);
int isdigit(int);
void Con_SafePrintf(char *, ...);

void InitConProc(HANDLE, HANDLE, HANDLE);
void DeinitConProc(void);
DWORD RequestProc(DWORD);
LPVOID GetMappedBuffer(HANDLE);
void ReleaseMappedBuffer(LPVOID);
BOOL GetScreenBufferLines(int *);
BOOL SetScreenBufferLines(int);
BOOL ReadText(LPTSTR, int, int);
BOOL WriteText(LPCTSTR);
int CharToCode(char);
BOOL SetConsoleCXCY(HANDLE, int, int);

#endif
