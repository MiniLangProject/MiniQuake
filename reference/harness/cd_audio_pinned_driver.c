#include "cd_audio_oracle_stubs.h"

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
__declspec(dllimport) void *__cdecl memset(void *, int, unsigned __int64);

extern qboolean cdValid;
extern qboolean playing;
extern qboolean wasPlaying;
extern qboolean initialized;
extern qboolean enabled;
extern qboolean playLooping;
extern float cdvolume;
extern byte remap[100];
extern byte playTrack;
extern byte maxTrack;

int _fltused = 0;
HWND mainwindow;
cvar_t bgmvolume = {"bgmvolume", "1", 1, 0, 1.0f, NULL};
client_static_t cls = {ca_connected};

static int command_argc;
static char *command_argv[8];
static int registered_commands;
static int play_calls;
static int stop_calls;
static int pause_calls;
static int close_calls;

DWORD mciSendCommand(
    UINT device, UINT message, DWORD flags, DWORD parameter)
{
    (void)device;
    (void)flags;
    if (message == MCI_OPEN)
    {
        MCI_OPEN_PARMS *open_parameters = (MCI_OPEN_PARMS *)(LPVOID)parameter;
        open_parameters->wDeviceID = 7;
        return 0;
    }
    if (message == MCI_STATUS)
    {
        MCI_STATUS_PARMS *status = (MCI_STATUS_PARMS *)(LPVOID)parameter;
        if (status->dwItem == MCI_STATUS_READY)
            status->dwReturn = 1;
        else if (status->dwItem == MCI_STATUS_NUMBER_OF_TRACKS)
            status->dwReturn = 12;
        else if (status->dwItem == MCI_CDA_STATUS_TYPE_TRACK)
            status->dwReturn = MCI_CDA_TRACK_AUDIO;
        else if (status->dwItem == MCI_STATUS_LENGTH)
            status->dwReturn = 100;
        return 0;
    }
    if (message == MCI_PLAY)
        play_calls++;
    else if (message == MCI_STOP)
        stop_calls++;
    else if (message == MCI_PAUSE)
        pause_calls++;
    else if (message == MCI_CLOSE)
        close_calls++;
    return 0;
}

void Con_DPrintf(char *format, ...)
{
    (void)format;
}

void Con_Printf(char *format, ...)
{
    (void)format;
}

int Cmd_Argc(void)
{
    return command_argc;
}

char *Cmd_Argv(int index)
{
    if (index < 0 || index >= command_argc)
        return "";
    return command_argv[index];
}

static int lower_ascii(int value)
{
    if (value >= 'A' && value <= 'Z')
        return value + ('a' - 'A');
    return value;
}

int Q_strcasecmp(char *left, char *right)
{
    while (*left || *right)
    {
        int a = lower_ascii((unsigned char)*left++);
        int b = lower_ascii((unsigned char)*right++);
        if (a != b)
            return a - b;
    }
    return 0;
}

int Q_atoi(char *text)
{
    int sign = 1;
    int value = 0;
    if (*text == '-')
    {
        sign = -1;
        text++;
    }
    while (*text >= '0' && *text <= '9')
        value = value * 10 + (*text++ - '0');
    return value * sign;
}

void Cvar_SetValue(char *name, float value)
{
    (void)name;
    bgmvolume.value = value;
}

void Cmd_AddCommand(char *name, xcommand_t function)
{
    (void)name;
    (void)function;
    registered_commands++;
}

int COM_CheckParm(char *parameter)
{
    (void)parameter;
    return 0;
}

static void set_arguments(
    int count, char *zero, char *one, char *two, char *three)
{
    command_argc = count;
    command_argv[0] = zero;
    command_argv[1] = one;
    command_argv[2] = two;
    command_argv[3] = three;
}

__declspec(dllexport) int __cdecl cd_audio_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    int result;
    int resumed;
    int paused;
    float resumed_volume;
    (void)capacity;

    play_calls = 0;
    stop_calls = 0;
    pause_calls = 0;
    close_calls = 0;
    registered_commands = 0;
    result = CDAudio_Init();
    cursor += sprintf(
        cursor,
        "{\"function\":\"CDAudio_Init\",\"case\":\"ready\","
        "\"result\":%d,\"initialized\":%d,\"enabled\":%d,\"valid\":%d,"
        "\"max\":%d,\"registered\":%d,\"remap\":%d}\n",
        result, initialized, enabled, cdValid, maxTrack,
        registered_commands, remap[7]);

    cdvolume = 1.0f;
    bgmvolume.value = 1.0f;
    CDAudio_Play(3, true);
    cursor += sprintf(
        cursor,
        "{\"function\":\"CDAudio_Play\",\"case\":\"loop\","
        "\"playing\":%d,\"was\":%d,\"looping\":%d,\"track\":%d,"
        "\"plays\":%d}\n",
        playing, wasPlaying, playLooping, playTrack, play_calls);

    CDAudio_Pause();
    cursor += sprintf(
        cursor,
        "{\"function\":\"CDAudio_Pause\",\"case\":\"active\","
        "\"playing\":%d,\"was\":%d,\"pauses\":%d}\n",
        playing, wasPlaying, pause_calls);

    CDAudio_Resume();
    cursor += sprintf(
        cursor,
        "{\"function\":\"CDAudio_Resume\",\"case\":\"paused\","
        "\"playing\":%d,\"was\":%d,\"plays\":%d,\"track\":%d}\n",
        playing, wasPlaying, play_calls, playTrack);

    CDAudio_Stop();
    cursor += sprintf(
        cursor,
        "{\"function\":\"CDAudio_Stop\",\"case\":\"active\","
        "\"playing\":%d,\"was\":%d,\"stops\":%d}\n",
        playing, wasPlaying, stop_calls);

    cdvolume = 0.0f;
    bgmvolume.value = 0.0f;
    set_arguments(4, "cd", "remap", "5", "7");
    CD_f();
    set_arguments(3, "cd", "loop", "2", "");
    CD_f();
    cursor += sprintf(
        cursor,
        "{\"function\":\"CD_f\",\"case\":\"remap-loop\","
        "\"remap\":[%d,%d],\"track\":%d,\"playing\":%d,\"was\":%d,"
        "\"looping\":%d}\n",
        remap[1], remap[2], playTrack, playing, wasPlaying, playLooping);

    bgmvolume.value = 1.0f;
    CDAudio_Update();
    resumed = playing;
    resumed_volume = cdvolume;
    bgmvolume.value = 0.0f;
    CDAudio_Update();
    paused = !playing && wasPlaying;
    cursor += sprintf(
        cursor,
        "{\"function\":\"CDAudio_Update\",\"case\":\"binary-volume\","
        "\"resumed\":%d,\"resume_volume\":%.9g,\"paused\":%d,"
        "\"volume\":%.9g}\n",
        resumed, resumed_volume, paused, cdvolume);

    CDAudio_Shutdown();
    cursor += sprintf(
        cursor,
        "{\"function\":\"CDAudio_Shutdown\",\"case\":\"close\","
        "\"initialized\":%d,\"enabled\":%d,\"playing\":%d,\"closes\":%d}\n",
        initialized, enabled, playing, close_calls);

    *cursor = 0;
    return (int)(cursor - output);
}
