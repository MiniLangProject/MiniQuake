#ifndef MINIQUAKE_KEYS_ORACLE_STUBS_H
#define MINIQUAKE_KEYS_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
typedef struct keys_oracle_file_s FILE;
typedef void (*xcommand_t)(void);

#ifndef NULL
#define NULL ((void *)0)
#endif

#define false 0
#define true 1

#define K_TAB 9
#define K_ENTER 13
#define K_ESCAPE 27
#define K_SPACE 32
#define K_BACKSPACE 127
#define K_UPARROW 128
#define K_DOWNARROW 129
#define K_LEFTARROW 130
#define K_RIGHTARROW 131
#define K_ALT 132
#define K_CTRL 133
#define K_SHIFT 134
#define K_F1 135
#define K_F2 136
#define K_F3 137
#define K_F4 138
#define K_F5 139
#define K_F6 140
#define K_F7 141
#define K_F8 142
#define K_F9 143
#define K_F10 144
#define K_F11 145
#define K_F12 146
#define K_INS 147
#define K_DEL 148
#define K_PGDN 149
#define K_PGUP 150
#define K_HOME 151
#define K_END 152
#define K_MOUSE1 200
#define K_MOUSE2 201
#define K_MOUSE3 202
#define K_JOY1 203
#define K_JOY2 204
#define K_JOY3 205
#define K_JOY4 206
#define K_AUX1 207
#define K_AUX2 208
#define K_AUX3 209
#define K_AUX4 210
#define K_AUX5 211
#define K_AUX6 212
#define K_AUX7 213
#define K_AUX8 214
#define K_AUX9 215
#define K_AUX10 216
#define K_AUX11 217
#define K_AUX12 218
#define K_AUX13 219
#define K_AUX14 220
#define K_AUX15 221
#define K_AUX16 222
#define K_AUX17 223
#define K_AUX18 224
#define K_AUX19 225
#define K_AUX20 226
#define K_AUX21 227
#define K_AUX22 228
#define K_AUX23 229
#define K_AUX24 230
#define K_AUX25 231
#define K_AUX26 232
#define K_AUX27 233
#define K_AUX28 234
#define K_AUX29 235
#define K_AUX30 236
#define K_AUX31 237
#define K_AUX32 238
#define K_MWHEELUP 239
#define K_MWHEELDOWN 240
#define K_PAUSE 255

typedef enum
{
    key_game,
    key_console,
    key_message,
    key_menu
} keydest_t;

typedef struct
{
    int state;
    qboolean demoplayback;
} client_static_t;

typedef struct
{
    unsigned width;
    unsigned height;
} viddef_t;

#define ca_disconnected 0

extern client_static_t cls;
extern viddef_t vid;
extern qboolean con_forcedup;
extern int con_backscroll;
extern int con_totallines;

void Cbuf_AddText(char *text);
void Con_Printf(char *format, ...);
char *Cmd_CompleteCommand(char *partial);
char *Cvar_CompleteVariable(char *partial);
char *Q_strcpy(char *destination, char *source);
int Q_strlen(char *text);
int Q_strcasecmp(char *left, char *right);
void SCR_UpdateScreen(void);
void Z_Free(void *pointer);
void *Z_Malloc(int size);
int Cmd_Argc(void);
char *Cmd_Argv(int index);
void Cmd_AddCommand(char *name, xcommand_t function);
void M_Keydown(int key);
void M_ToggleMenu_f(void);
void Sys_Error(char *format, ...);
char *keys_oracle_strcat(char *destination, const char *source);
int keys_oracle_sprintf(
    char *destination, const char *format, char *text, int number);
int keys_oracle_fprintf(
    FILE *file, const char *format, char *key, char *binding);

#ifdef MINIQUAKE_PINNED_ORACLE
#define sprintf keys_oracle_sprintf
#define fprintf keys_oracle_fprintf
#define strcat keys_oracle_strcat
#endif

void Key_Console(int key);
void Key_Message(int key);
int Key_StringToKeynum(char *text);
char *Key_KeynumToString(int keynum);
void Key_SetBinding(int keynum, char *binding);
void Key_Unbind_f(void);
void Key_Unbindall_f(void);
void Key_Bind_f(void);
void Key_WriteBindings(FILE *file);
void Key_Init(void);
void Key_Event(int key, qboolean down);
void Key_ClearStates(void);

#endif
