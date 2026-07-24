#include "snd_win_oracle_stubs.h"

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);

extern qboolean wavonly;
extern qboolean dsound_init;
extern qboolean wav_init;
extern qboolean snd_firsttime;
extern qboolean snd_isdirect;
extern qboolean snd_iswave;
extern int sample16;
extern int snd_sent;
extern int snd_completed;
extern HANDLE hData;
extern HPSTR lpData;
extern HGLOBAL hWaveHdr;
extern LPWAVEHDR lpWaveHdr;
extern HWAVEOUT hWaveOut;
extern DWORD gSndBufSize;

int _fltused = 0;
int snd_blocked;
HWND mainwindow;
dma_t sn;
dma_t *shm;

static unsigned char wave_data[64 * 1024];
static WAVEHDR wave_headers[64];
static int prepare_calls;
static int unprepare_calls;
static int reset_calls;
static int close_calls;
static int write_calls;
static int library_calls;
static int force_wavonly;

HINSTANCE LoadLibrary(const char *name)
{
    (void)name;
    library_calls++;
    return NULL;
}

void *GetProcAddress(HINSTANCE instance, const char *name)
{
    (void)instance;
    (void)name;
    return NULL;
}

int MessageBox(HWND window, const char *text, const char *caption, UINT flags)
{
    (void)window;
    (void)text;
    (void)caption;
    (void)flags;
    return 0;
}

int COM_CheckParm(char *parameter)
{
    const char *wanted = "-wavonly";
    int index = 0;
    if (!force_wavonly)
        return 0;
    while (parameter[index] && wanted[index] &&
           parameter[index] == wanted[index])
        index++;
    return parameter[index] == 0 && wanted[index] == 0;
}

void Con_SafePrintf(char *format, ...)
{
    (void)format;
}

void Con_Printf(char *format, ...)
{
    (void)format;
}

void Con_DPrintf(char *format, ...)
{
    (void)format;
}

UINT waveOutOpen(
    LPHWAVEOUT output, UINT device, WAVEFORMATEX *format,
    DWORD callback, DWORD instance, DWORD flags)
{
    (void)device;
    (void)format;
    (void)callback;
    (void)instance;
    (void)flags;
    *output = (HWAVEOUT)1;
    return MMSYSERR_NOERROR;
}

UINT waveOutReset(HWAVEOUT output)
{
    (void)output;
    reset_calls++;
    return MMSYSERR_NOERROR;
}

UINT waveOutUnprepareHeader(HWAVEOUT output, LPWAVEHDR header, UINT size)
{
    (void)output;
    (void)header;
    (void)size;
    unprepare_calls++;
    return MMSYSERR_NOERROR;
}

UINT waveOutClose(HWAVEOUT output)
{
    (void)output;
    close_calls++;
    return MMSYSERR_NOERROR;
}

UINT waveOutPrepareHeader(HWAVEOUT output, LPWAVEHDR header, UINT size)
{
    (void)output;
    (void)header;
    (void)size;
    prepare_calls++;
    return MMSYSERR_NOERROR;
}

UINT waveOutWrite(HWAVEOUT output, LPWAVEHDR header, UINT size)
{
    (void)output;
    (void)header;
    (void)size;
    write_calls++;
    return MMSYSERR_NOERROR;
}

HGLOBAL GlobalAlloc(UINT flags, DWORD bytes)
{
    (void)flags;
    if (bytes == sizeof(wave_headers))
        return wave_headers;
    return wave_data;
}

LPVOID GlobalLock(HGLOBAL memory)
{
    return memory;
}

BOOL GlobalUnlock(HGLOBAL memory)
{
    (void)memory;
    return TRUE;
}

HGLOBAL GlobalFree(HGLOBAL memory)
{
    (void)memory;
    return NULL;
}

static void clear_runtime(void)
{
    memset(&sn, 0, sizeof(sn));
    shm = &sn;
    wavonly = false;
    dsound_init = false;
    wav_init = false;
    snd_firsttime = true;
    snd_isdirect = false;
    snd_iswave = false;
    sample16 = 0;
    snd_sent = 0;
    snd_completed = 0;
    snd_iswave = true;
    snd_blocked = 0;
    hData = NULL;
    lpData = NULL;
    hWaveHdr = NULL;
    lpWaveHdr = NULL;
    hWaveOut = NULL;
    prepare_calls = 0;
    unprepare_calls = 0;
    reset_calls = 0;
    close_calls = 0;
    write_calls = 0;
    library_calls = 0;
    force_wavonly = 0;
}

__declspec(dllexport) int __cdecl snd_win_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    int result;
    (void)capacity;

    clear_runtime();
    result = SNDDMA_InitDirect();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SNDDMA_InitDirect\",\"case\":\"missing-dsound\","
        "\"result\":%d,\"attempts\":%d,\"direct\":%d}\n",
        result, library_calls, dsound_init);

    clear_runtime();
    result = SNDDMA_InitWav();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SNDDMA_InitWav\",\"case\":\"success\","
        "\"result\":%d,\"wave\":%d,\"channels\":%d,\"bits\":%d,"
        "\"speed\":%d,\"samples\":%d,\"chunk\":%d,\"prepared\":%d,"
        "\"size\":%lu}\n",
        result, wav_init, shm->channels, shm->samplebits, shm->speed,
        shm->samples, shm->submission_chunk, prepare_calls, gSndBufSize);

    snd_blocked = 0;
    reset_calls = 0;
    S_BlockSound();
    cursor += sprintf(
        cursor,
        "{\"function\":\"S_BlockSound\",\"case\":\"wave\","
        "\"blocked\":%d,\"resets\":%d}\n",
        snd_blocked, reset_calls);

    S_UnblockSound();
    cursor += sprintf(
        cursor,
        "{\"function\":\"S_UnblockSound\",\"case\":\"wave\","
        "\"blocked\":%d}\n",
        snd_blocked);

    unprepare_calls = 0;
    close_calls = 0;
    FreeSound();
    cursor += sprintf(
        cursor,
        "{\"function\":\"FreeSound\",\"case\":\"wave\","
        "\"wave\":%d,\"direct\":%d,\"headers\":%d,\"closed\":%d,"
        "\"handle\":%d,\"data\":%d}\n",
        wav_init, dsound_init, unprepare_calls, close_calls,
        hWaveOut != NULL, hData != NULL);

    clear_runtime();
    result = SNDDMA_Init();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SNDDMA_Init\",\"case\":\"fallback\","
        "\"result\":%d,\"direct\":%d,\"wave\":%d,\"first\":%d,"
        "\"direct_pref\":%d,\"wave_pref\":%d}\n",
        result, dsound_init, wav_init, snd_firsttime,
        snd_isdirect, snd_iswave);

    snd_sent = 5;
    snd_completed = 0;
    sample16 = 1;
    shm->samples = 32768;
    result = SNDDMA_GetDMAPos();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SNDDMA_GetDMAPos\",\"case\":\"wave\","
        "\"result\":%d}\n",
        result);

    snd_sent = 0;
    snd_completed = 0;
    write_calls = 0;
    result = 0;
    SNDDMA_Submit();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SNDDMA_Submit\",\"case\":\"refill\","
        "\"sent\":%d,\"completed\":%d,\"writes\":%d}\n",
        snd_sent, snd_completed, write_calls);

    unprepare_calls = 0;
    close_calls = 0;
    SNDDMA_Shutdown();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SNDDMA_Shutdown\",\"case\":\"wave\","
        "\"wave\":%d,\"headers\":%d,\"closed\":%d}\n",
        wav_init, unprepare_calls, close_calls);

    *cursor = 0;
    return (int)(cursor - output);
}
