#include "conproc_oracle_stubs.h"

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);

extern HANDLE heventDone;
extern HANDLE hfileBuffer;
extern HANDLE heventChildSend;
extern HANDLE heventParentSend;
extern HANDLE hStdout;
extern HANDLE hStdin;

static int request_buffer[256];
static int wait_index;
static int map_calls;
static int unmap_calls;
static int child_signals;
static int done_signals;
static int screen_width = 100;
static int screen_height = 40;
static int maximum_width = 120;
static int maximum_height = 80;
static INPUT_RECORD input_records[32];
static int input_count;

int _fltused = 0;

HANDLE CreateEvent(void *attributes, BOOL manual, BOOL initial, const char *name)
{
    (void)attributes;
    (void)manual;
    (void)initial;
    (void)name;
    return (HANDLE)40;
}

HANDLE CreateThread(
    void *attributes, DWORD stack, LPTHREAD_START_ROUTINE function,
    void *parameter, DWORD flags, DWORD *identifier)
{
    (void)attributes;
    (void)stack;
    (void)function;
    (void)parameter;
    (void)flags;
    *identifier = 77;
    return (HANDLE)41;
}

BOOL CloseHandle(HANDLE handle)
{
    (void)handle;
    return TRUE;
}

HANDLE GetStdHandle(DWORD kind)
{
    return kind == STD_OUTPUT_HANDLE ? (HANDLE)50 : (HANDLE)60;
}

BOOL SetEvent(HANDLE event)
{
    if (event == (HANDLE)30)
        child_signals++;
    if (event == (HANDLE)40)
        done_signals++;
    return TRUE;
}

DWORD WaitForMultipleObjects(
    DWORD count, const HANDLE *events, BOOL all, DWORD timeout)
{
    (void)count;
    (void)events;
    (void)all;
    (void)timeout;
    return wait_index++ == 0 ? WAIT_OBJECT_0 : WAIT_OBJECT_0 + 1;
}

LPVOID MapViewOfFile(
    HANDLE file, DWORD access, DWORD high, DWORD low, DWORD size)
{
    (void)file;
    (void)access;
    (void)high;
    (void)low;
    (void)size;
    map_calls++;
    return request_buffer;
}

BOOL UnmapViewOfFile(LPVOID pointer)
{
    (void)pointer;
    unmap_calls++;
    return TRUE;
}

BOOL GetConsoleScreenBufferInfo(
    HANDLE output, CONSOLE_SCREEN_BUFFER_INFO *info)
{
    (void)output;
    info->dwSize.X = (SHORT)screen_width;
    info->dwSize.Y = (SHORT)screen_height;
    info->srWindow.Left = 0;
    info->srWindow.Top = 0;
    info->srWindow.Right = (SHORT)(screen_width - 1);
    info->srWindow.Bottom = (SHORT)(screen_height - 1);
    return TRUE;
}

BOOL ReadConsoleOutputCharacter(
    HANDLE output, LPTSTR text, DWORD count, COORD origin, DWORD *read)
{
    DWORD index;
    (void)output;
    (void)origin;
    for (index = 0; index < count; index++)
        text[index] = (char)('A' + (index % 26));
    *read = count;
    return TRUE;
}

BOOL WriteConsoleInput(
    HANDLE input, const INPUT_RECORD *record, DWORD count, DWORD *written)
{
    (void)input;
    (void)count;
    input_records[input_count++] = *record;
    *written = 1;
    return TRUE;
}

COORD GetLargestConsoleWindowSize(HANDLE output)
{
    COORD result;
    (void)output;
    result.X = (SHORT)maximum_width;
    result.Y = (SHORT)maximum_height;
    return result;
}

BOOL SetConsoleWindowInfo(
    HANDLE output, BOOL absolute, const SMALL_RECT *window)
{
    (void)output;
    (void)absolute;
    (void)window;
    return TRUE;
}

BOOL SetConsoleScreenBufferSize(HANDLE output, COORD size)
{
    (void)output;
    screen_width = size.X;
    screen_height = size.Y;
    return TRUE;
}

int toupper(int value)
{
    if (value >= 'a' && value <= 'z')
        return value - ('a' - 'A');
    return value;
}

int isupper(int value)
{
    return value >= 'A' && value <= 'Z';
}

int isalpha(int value)
{
    return (value >= 'A' && value <= 'Z') ||
        (value >= 'a' && value <= 'z');
}

int isdigit(int value)
{
    return value >= '0' && value <= '9';
}

void Con_SafePrintf(char *format, ...)
{
    (void)format;
}

static void reset_console(int width, int height, int max_width, int max_height)
{
    screen_width = width;
    screen_height = height;
    maximum_width = max_width;
    maximum_height = max_height;
}

__declspec(dllexport) int __cdecl conproc_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    char text[200];
    char input[] = "aB\n";
    int lines = 0;
    BOOL result;
    LPVOID mapped;
    (void)capacity;

    reset_console(100, 40, 120, 80);
    InitConProc((HANDLE)10, (HANDLE)20, (HANDLE)30);
    cursor += sprintf(
        cursor,
        "{\"function\":\"InitConProc\",\"case\":\"valid\","
        "\"file\":%d,\"parent\":%d,\"child\":%d,\"done\":%d,"
        "\"stdout\":%d,\"stdin\":%d,\"width\":%d,\"height\":%d}\n",
        hfileBuffer == (HANDLE)10, heventParentSend == (HANDLE)20,
        heventChildSend == (HANDLE)30, heventDone != NULL,
        hStdout == (HANDLE)50, hStdin == (HANDLE)60,
        screen_width, screen_height);

    done_signals = 0;
    DeinitConProc();
    cursor += sprintf(
        cursor,
        "{\"function\":\"DeinitConProc\",\"case\":\"active\","
        "\"signals\":%d}\n",
        done_signals);

    reset_console(80, 25, 120, 80);
    request_buffer[0] = CCOM_SET_SCR_LINES;
    request_buffer[1] = 33;
    wait_index = 0;
    map_calls = 0;
    unmap_calls = 0;
    child_signals = 0;
    result = (BOOL)RequestProc(0);
    cursor += sprintf(
        cursor,
        "{\"function\":\"RequestProc\",\"case\":\"set-lines\","
        "\"result\":%d,\"response\":%d,\"height\":%d,\"maps\":%d,"
        "\"unmaps\":%d,\"signals\":%d}\n",
        result, request_buffer[0], screen_height, map_calls,
        unmap_calls, child_signals);

    map_calls = 0;
    mapped = GetMappedBuffer((HANDLE)10);
    cursor += sprintf(
        cursor,
        "{\"function\":\"GetMappedBuffer\",\"case\":\"valid\","
        "\"mapped\":%d,\"maps\":%d}\n",
        mapped == request_buffer, map_calls);

    unmap_calls = 0;
    ReleaseMappedBuffer(mapped);
    cursor += sprintf(
        cursor,
        "{\"function\":\"ReleaseMappedBuffer\",\"case\":\"valid\","
        "\"unmaps\":%d}\n",
        unmap_calls);

    reset_console(80, 47, 120, 80);
    result = GetScreenBufferLines(&lines);
    cursor += sprintf(
        cursor,
        "{\"function\":\"GetScreenBufferLines\",\"case\":\"success\","
        "\"result\":%d,\"lines\":%d}\n",
        result, lines);

    result = SetScreenBufferLines(31);
    cursor += sprintf(
        cursor,
        "{\"function\":\"SetScreenBufferLines\",\"case\":\"resize\","
        "\"result\":%d,\"width\":%d,\"height\":%d}\n",
        result, screen_width, screen_height);

    result = ReadText(text, 1, 2);
    cursor += sprintf(
        cursor,
        "{\"function\":\"ReadText\",\"case\":\"inclusive\","
        "\"result\":%d,\"length\":%d,\"first\":%d,\"last\":%d}\n",
        result, 160, (unsigned char)text[0], (unsigned char)text[159]);

    input_count = 0;
    result = WriteText(input);
    cursor += sprintf(
        cursor,
        "{\"function\":\"WriteText\",\"case\":\"keys\","
        "\"result\":%d,\"events\":%d,\"first_char\":%d,\"first_vk\":%d,"
        "\"first_scan\":%d,\"upper_shift\":%d,\"return_char\":%d,"
        "\"return_scan\":%d}\n",
        result, input_count,
        (unsigned char)input_records[0].Event.KeyEvent.uChar.AsciiChar,
        input_records[0].Event.KeyEvent.wVirtualKeyCode,
        input_records[0].Event.KeyEvent.wVirtualScanCode,
        input_records[2].Event.KeyEvent.dwControlKeyState != 0,
        (unsigned char)input_records[4].Event.KeyEvent.uChar.AsciiChar,
        input_records[4].Event.KeyEvent.wVirtualScanCode);

    cursor += sprintf(
        cursor,
        "{\"function\":\"CharToCode\",\"case\":\"classes\","
        "\"return\":%d,\"lower\":%d,\"upper\":%d,\"zero\":%d,"
        "\"nine\":%d,\"punct\":%d}\n",
        CharToCode(13), CharToCode('a'), CharToCode('Z'),
        CharToCode('0'), CharToCode('9'), CharToCode('!'));

    reset_console(100, 40, 90, 35);
    result = SetConsoleCXCY((HANDLE)50, 120, 80);
    cursor += sprintf(
        cursor,
        "{\"function\":\"SetConsoleCXCY\",\"case\":\"clamp-shrink\","
        "\"result\":%d,\"width\":%d,\"height\":%d}\n",
        result, screen_width, screen_height);

    *cursor = 0;
    return (int)(cursor - output);
}
