#ifndef MINIQUAKE_SND_WIN_ORACLE_STUBS_H
#define MINIQUAKE_SND_WIN_ORACLE_STUBS_H

typedef int qboolean;
typedef unsigned char byte;
typedef long HRESULT;
typedef unsigned long DWORD;
typedef unsigned int UINT;
typedef unsigned short WORD;
typedef void *HANDLE;
typedef void *LPVOID;
typedef int BOOL;
typedef void *HGLOBAL;
typedef void *HINSTANCE;
typedef void *HWND;
typedef char *HPSTR;
typedef void *IUnknown;
typedef struct GUID GUID;
#define WINAPI
#define FAR
#define NULL ((void *)0)
#define false 0
#define true 1
#define FALSE 0
#define TRUE 1

typedef struct
{
    qboolean soundalive;
    qboolean splitbuffer;
    int channels;
    int samples;
    int submission_chunk;
    int samplepos;
    int samplebits;
    int speed;
    unsigned char *buffer;
} dma_t;

typedef struct
{
    WORD wFormatTag;
    WORD nChannels;
    DWORD nSamplesPerSec;
    DWORD nAvgBytesPerSec;
    WORD nBlockAlign;
    WORD wBitsPerSample;
    WORD cbSize;
} WAVEFORMATEX;

typedef struct wavehdr_tag
{
    HPSTR lpData;
    DWORD dwBufferLength;
    DWORD dwBytesRecorded;
    DWORD dwUser;
    DWORD dwFlags;
    DWORD dwLoops;
    struct wavehdr_tag *lpNext;
    DWORD reserved;
} WAVEHDR, *LPWAVEHDR;

typedef void *HWAVEOUT;
typedef HWAVEOUT *LPHWAVEOUT;
typedef struct { DWORD unused; } WAVEOUTCAPS;
typedef struct
{
    UINT wType;
    union { DWORD sample; } u;
} MMTIME;

typedef struct { DWORD dwSize; DWORD dwFlags; } DSCAPS;
typedef struct
{
    DWORD dwSize;
    DWORD dwFlags;
    DWORD dwBufferBytes;
    DWORD dwReserved;
    WAVEFORMATEX *lpwfxFormat;
} DSBUFFERDESC;
typedef struct { DWORD dwSize; DWORD dwFlags; DWORD dwBufferBytes; } DSBCAPS;

typedef struct IDirectSound IDirectSound;
typedef struct IDirectSoundBuffer IDirectSoundBuffer;
typedef IDirectSound *LPDIRECTSOUND;
typedef IDirectSoundBuffer *LPDIRECTSOUNDBUFFER;

typedef struct
{
    HRESULT (*GetCaps)(LPDIRECTSOUND, DSCAPS *);
    HRESULT (*SetCooperativeLevel)(LPDIRECTSOUND, HWND, DWORD);
    HRESULT (*CreateSoundBuffer)(
        LPDIRECTSOUND, DSBUFFERDESC *, LPDIRECTSOUNDBUFFER *, IUnknown *);
    unsigned long (*Release)(LPDIRECTSOUND);
} IDirectSoundVtbl;
struct IDirectSound { IDirectSoundVtbl *lpVtbl; };

typedef struct
{
    HRESULT (*GetCaps)(LPDIRECTSOUNDBUFFER, DSBCAPS *);
    HRESULT (*GetCurrentPosition)(LPDIRECTSOUNDBUFFER, DWORD *, DWORD *);
    HRESULT (*Lock)(
        LPDIRECTSOUNDBUFFER, DWORD, DWORD, void **, DWORD *,
        void **, DWORD *, DWORD);
    HRESULT (*Play)(LPDIRECTSOUNDBUFFER, DWORD, DWORD, DWORD);
    unsigned long (*Release)(LPDIRECTSOUNDBUFFER);
    HRESULT (*SetFormat)(LPDIRECTSOUNDBUFFER, WAVEFORMATEX *);
    HRESULT (*Stop)(LPDIRECTSOUNDBUFFER);
    HRESULT (*Unlock)(
        LPDIRECTSOUNDBUFFER, void *, DWORD, void *, DWORD);
} IDirectSoundBufferVtbl;
struct IDirectSoundBuffer { IDirectSoundBufferVtbl *lpVtbl; };

#define DS_OK 0
#define DSERR_ALLOCATED 1
#define DSERR_BUFFERLOST 2
#define DSCAPS_EMULDRIVER 1
#define DSSCL_NORMAL 1
#define DSSCL_EXCLUSIVE 2
#define DSSCL_WRITEPRIMARY 3
#define DSBCAPS_PRIMARYBUFFER 1
#define DSBCAPS_CTRLFREQUENCY 2
#define DSBCAPS_LOCSOFTWARE 4
#define DSBPLAY_LOOPING 1
#define WAVE_FORMAT_PCM 1
#define WAVE_MAPPER ((UINT)-1)
#define CALLBACK_NULL 0
#define MMSYSERR_NOERROR 0
#define MMSYSERR_ALLOCATED 1
#define GMEM_MOVEABLE 1
#define GMEM_SHARE 2
#define WHDR_DONE 1
#define TIME_SAMPLES 1
#define MB_RETRYCANCEL 1
#define MB_SETFOREGROUND 2
#define MB_ICONEXCLAMATION 4
#define IDRETRY 4

extern int snd_blocked;
extern HWND mainwindow;
extern dma_t sn;
extern dma_t *shm;

void *memset(void *, int, unsigned __int64);
HINSTANCE LoadLibrary(const char *);
void *GetProcAddress(HINSTANCE, const char *);
int MessageBox(HWND, const char *, const char *, UINT);
int COM_CheckParm(char *);
void Con_SafePrintf(char *, ...);
void Con_Printf(char *, ...);
void Con_DPrintf(char *, ...);
UINT waveOutOpen(LPHWAVEOUT, UINT, WAVEFORMATEX *, DWORD, DWORD, DWORD);
UINT waveOutReset(HWAVEOUT);
UINT waveOutUnprepareHeader(HWAVEOUT, LPWAVEHDR, UINT);
UINT waveOutClose(HWAVEOUT);
UINT waveOutPrepareHeader(HWAVEOUT, LPWAVEHDR, UINT);
UINT waveOutWrite(HWAVEOUT, LPWAVEHDR, UINT);
HGLOBAL GlobalAlloc(UINT, DWORD);
LPVOID GlobalLock(HGLOBAL);
BOOL GlobalUnlock(HGLOBAL);
HGLOBAL GlobalFree(HGLOBAL);

void S_BlockSound(void);
void S_UnblockSound(void);
void FreeSound(void);
int SNDDMA_InitDirect(void);
qboolean SNDDMA_InitWav(void);
int SNDDMA_Init(void);
int SNDDMA_GetDMAPos(void);
void SNDDMA_Submit(void);
void SNDDMA_Shutdown(void);

#endif
