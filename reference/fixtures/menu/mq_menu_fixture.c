/* Direct execution harness for the unchanged pinned WinQuake/menu.c. */
#include "quakedef.h"
#include "winquake.h"
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DECL(name, args) void name args
DECL(M_DrawCharacter,(int,int,int)); DECL(M_Print,(int,int,char*));
DECL(M_PrintWhite,(int,int,char*)); DECL(M_DrawTransPic,(int,int,qpic_t*));
DECL(M_DrawPic,(int,int,qpic_t*)); DECL(M_BuildTranslationTable,(int,int));
DECL(M_DrawTransPicTranslate,(int,int,qpic_t*)); DECL(M_DrawTextBox,(int,int,int,int));
DECL(M_ToggleMenu_f,(void)); DECL(M_Menu_Main_f,(void)); DECL(M_Main_Draw,(void)); DECL(M_Main_Key,(int));
DECL(M_Menu_SinglePlayer_f,(void)); DECL(M_SinglePlayer_Draw,(void)); DECL(M_SinglePlayer_Key,(int));
DECL(M_ScanSaves,(void)); DECL(M_Menu_Load_f,(void)); DECL(M_Menu_Save_f,(void));
DECL(M_Load_Draw,(void)); DECL(M_Save_Draw,(void)); DECL(M_Load_Key,(int)); DECL(M_Save_Key,(int));
DECL(M_Menu_MultiPlayer_f,(void)); DECL(M_MultiPlayer_Draw,(void)); DECL(M_MultiPlayer_Key,(int));
DECL(M_Menu_Setup_f,(void)); DECL(M_Setup_Draw,(void)); DECL(M_Setup_Key,(int));
DECL(M_Menu_Net_f,(void)); DECL(M_Net_Draw,(void)); DECL(M_Net_Key,(int));
DECL(M_Menu_Options_f,(void)); DECL(M_AdjustSliders,(int)); DECL(M_DrawSlider,(int,int,float));
DECL(M_DrawCheckbox,(int,int,int)); DECL(M_Options_Draw,(void)); DECL(M_Options_Key,(int));
DECL(M_Menu_Keys_f,(void)); void M_FindKeysForCommand(char*,int*);
DECL(M_UnbindCommand,(char*)); DECL(M_Keys_Draw,(void)); DECL(M_Keys_Key,(int));
DECL(M_Menu_Video_f,(void)); DECL(M_Video_Draw,(void)); DECL(M_Video_Key,(int));
DECL(M_Menu_Help_f,(void)); DECL(M_Help_Draw,(void)); DECL(M_Help_Key,(int));
DECL(M_Menu_Quit_f,(void)); DECL(M_Quit_Key,(int)); DECL(M_Quit_Draw,(void));
DECL(M_Menu_LanConfig_f,(void)); DECL(M_LanConfig_Draw,(void)); DECL(M_LanConfig_Key,(int));
DECL(M_Menu_GameOptions_f,(void)); DECL(M_GameOptions_Draw,(void)); DECL(M_NetStart_Change,(int));
DECL(M_GameOptions_Key,(int)); DECL(M_Menu_Search_f,(void)); DECL(M_Search_Draw,(void));
DECL(M_Search_Key,(int)); DECL(M_Menu_ServerList_f,(void)); DECL(M_ServerList_Draw,(void));
DECL(M_ServerList_Key,(int)); DECL(M_Init,(void)); DECL(M_Draw,(void)); DECL(M_Keydown,(int));
DECL(M_ConfigureNetSubsystem,(void));

extern int m_state, m_main_cursor, m_singleplayer_cursor, load_cursor;
extern int m_multiplayer_cursor, setup_cursor, m_net_cursor, options_cursor;
extern int keys_cursor, help_page, lanConfig_cursor, gameoptions_cursor, slist_cursor;

viddef_t vid;
client_static_t cls;
client_state_t cl;
server_t sv;
server_static_t svs;
keydest_t key_dest;
double host_time, realtime;
char com_gamedir[MAX_OSPATH] = ".";
qboolean serialAvailable, ipxAvailable, tcpipAvailable;
qboolean rogue, hipnotic;
float scr_con_current;
int scr_fullupdate, scr_copyeverything;
qboolean slistInProgress, slistSilent, slistLocal;
int hostCacheCount, net_hostport = 26000, DEFAULTnet_hostport = 26000;
hostcache_t hostcache[HOSTCACHESIZE];
char my_tcpip_address[NET_NAMELEN] = "127.0.0.1";
char my_ipx_address[NET_NAMELEN] = "00000000";
char *keybindings[256];
qboolean bigendien;
void (*GetComPortConfig)(int,int*,int*,int*,qboolean*);
void (*SetComPortConfig)(int,int,int,int,qboolean);
void (*GetModemConfig)(int,char*,char*,char*,char*);
void (*SetModemConfig)(int,char*,char*,char*,char*);

#define CVAR(var, text, val) cvar_t var = {#var, text, false, false, val}
CVAR(cl_name,"player",0); CVAR(hostname,"fixture",0); CVAR(cl_color,"0",0);
CVAR(scr_viewsize,"100",100); CVAR(v_gamma,"1",1); CVAR(sensitivity,"3",3);
CVAR(bgmvolume,"1",1); CVAR(volume,"0.7",0.7); CVAR(cl_forwardspeed,"200",200);
CVAR(cl_backspeed,"200",200); CVAR(m_pitch,"0.022",0.022);
CVAR(lookspring,"0",0); CVAR(lookstrafe,"0",0); CVAR(_windowed_mouse,"0",0);
CVAR(registered,"1",1); CVAR(coop,"0",0); CVAR(teamplay,"0",0);
CVAR(skill,"1",1); CVAR(fraglimit,"0",0); CVAR(timelimit,"0",0);

modestate_t modestate = MS_WINDOWED;
static struct { int width,height; byte data[4]; } fixture_pic = {160,24,{0}};
static int draw_calls, sound_calls, command_calls;

static void Emit(const char *name) {
    printf("{\"function\":\"%s\",\"scene\":\"execute\",\"executed\":1}\n", name);
}
#define RUN0(name) do { name(); Emit(#name); } while (0)
#define RUN1(name,arg) do { name(arg); Emit(#name); } while (0)

qpic_t *Draw_CachePic(char *path) { (void)path; return (qpic_t*)&fixture_pic; }
void Draw_Character(int x,int y,int n) {(void)x;(void)y;(void)n;++draw_calls;}
void Draw_Pic(int x,int y,qpic_t*p){(void)x;(void)y;(void)p;++draw_calls;}
void Draw_TransPic(int x,int y,qpic_t*p){(void)x;(void)y;(void)p;++draw_calls;}
void Draw_TransPicTranslate(int x,int y,qpic_t*p,byte*t){(void)x;(void)y;(void)p;(void)t;++draw_calls;}
void Draw_ConsoleBackground(int lines){(void)lines;++draw_calls;}
void Draw_FadeScreen(void){++draw_calls;}
void S_LocalSound(char *name){(void)name;++sound_calls;}
void S_ExtraUpdate(void){}
void Cbuf_AddText(char *text){(void)text;++command_calls;}
void Cbuf_InsertText(char *text){(void)text;++command_calls;}
void Cmd_AddCommand(char *name,xcommand_t fn){(void)name;(void)fn;++command_calls;}
void Cvar_Set(char *name,char *value){(void)name;(void)value;}
void Cvar_SetValue(char *name,float value){(void)name;(void)value;}
void Con_ToggleConsole_f(void){key_dest=key_game;}
void CL_NextDemo(void){}
void SCR_BeginLoadingPlaque(void){}
qboolean SCR_ModalMessage(char *text){(void)text;return true;}
void Host_Quit_f(void){}
void NET_Poll(void){}
void NET_Slist_f(void){slistInProgress=false;}
char *Key_KeynumToString(int key){static char value[16];sprintf(value,"%d",key);return value;}
void Key_SetBinding(int keynum,char *binding){keybindings[keynum]=binding;}
void VID_LockBuffer(void){}
void VID_UnlockBuffer(void){}
int Q_atoi(char *text){return atoi(text);}
void Q_memcpy(void*d,void*s,int n){memcpy(d,s,(size_t)n);}
void Q_strcpy(char*d,char*s){strcpy(d,s);}
int Q_strcmp(char*a,char*b){return strcmp(a,b);}
char *va(char *format,...){static char b[4][1024];static int i;va_list a;char*r=b[i++&3];va_start(a,format);vsprintf(r,format,a);va_end(a);return r;}

static void VideoDraw(void){++draw_calls;}
static void VideoKey(int key){(void)key;}
static void GetCom(int p,int*a,int*b,int*c,qboolean*d){(void)p;*a=0x3f8;*b=4;*c=9600;*d=false;}
static void SetCom(int p,int a,int b,int c,qboolean d){(void)p;(void)a;(void)b;(void)c;(void)d;}
static void GetMod(int p,char*a,char*b,char*c,char*d){(void)p;strcpy(a,"T");strcpy(b,"");strcpy(c,"");strcpy(d,"");}
static void SetMod(int p,char*a,char*b,char*c,char*d){(void)p;(void)a;(void)b;(void)c;(void)d;}

int main(void) {
    int keys[2];
    vid.width=640; vid.height=480; vid.numpages=3;
    sv.active=true; svs.maxclients=1; svs.maxclientslimit=16;
    cls.state=ca_disconnected; cls.demonum=2;
    tcpipAvailable=true; serialAvailable=false; ipxAvailable=false;
    hostCacheCount=1; strcpy(hostcache[0].name,"fixture"); strcpy(hostcache[0].map,"start");
    strcpy(hostcache[0].cname,"127.0.0.1"); hostcache[0].users=1; hostcache[0].maxusers=4;
    vid_menudrawfn=VideoDraw; vid_menukeyfn=VideoKey;
    GetComPortConfig=GetCom; SetComPortConfig=SetCom; GetModemConfig=GetMod; SetModemConfig=SetMod;

    M_DrawCharacter(1,2,3); Emit("M_DrawCharacter");
    M_Print(1,2,"ab"); Emit("M_Print"); M_PrintWhite(1,2,"ab"); Emit("M_PrintWhite");
    M_DrawTransPic(1,2,(qpic_t*)&fixture_pic); Emit("M_DrawTransPic");
    M_DrawPic(1,2,(qpic_t*)&fixture_pic); Emit("M_DrawPic");
    M_BuildTranslationTable(16,144); Emit("M_BuildTranslationTable");
    M_DrawTransPicTranslate(1,2,(qpic_t*)&fixture_pic); Emit("M_DrawTransPicTranslate");
    M_DrawTextBox(8,8,4,2); Emit("M_DrawTextBox");
    key_dest=key_game; RUN0(M_ToggleMenu_f);
    RUN0(M_Menu_Main_f); RUN0(M_Main_Draw); RUN1(M_Main_Key,K_DOWNARROW);
    RUN0(M_Menu_SinglePlayer_f); RUN0(M_SinglePlayer_Draw); RUN1(M_SinglePlayer_Key,K_DOWNARROW);
    RUN0(M_ScanSaves); RUN0(M_Menu_Load_f); RUN0(M_Menu_Save_f); RUN0(M_Load_Draw); RUN0(M_Save_Draw);
    RUN1(M_Load_Key,K_DOWNARROW); RUN1(M_Save_Key,K_DOWNARROW);
    RUN0(M_Menu_MultiPlayer_f); RUN0(M_MultiPlayer_Draw); RUN1(M_MultiPlayer_Key,K_DOWNARROW);
    RUN0(M_Menu_Setup_f); RUN0(M_Setup_Draw); RUN1(M_Setup_Key,K_DOWNARROW);
    RUN0(M_Menu_Net_f); RUN0(M_Net_Draw); RUN1(M_Net_Key,K_DOWNARROW);
    RUN0(M_Menu_Options_f); options_cursor=3; RUN1(M_AdjustSliders,1);
    M_DrawSlider(8,8,0.5f); Emit("M_DrawSlider"); M_DrawCheckbox(8,8,1); Emit("M_DrawCheckbox");
    RUN0(M_Options_Draw); RUN1(M_Options_Key,K_DOWNARROW);
    RUN0(M_Menu_Keys_f); M_FindKeysForCommand("+attack",keys); Emit("M_FindKeysForCommand");
    M_UnbindCommand("+attack"); Emit("M_UnbindCommand"); RUN0(M_Keys_Draw); RUN1(M_Keys_Key,K_DOWNARROW);
    RUN0(M_Menu_Video_f); RUN0(M_Video_Draw); RUN1(M_Video_Key,K_DOWNARROW);
    RUN0(M_Menu_Help_f); RUN0(M_Help_Draw); RUN1(M_Help_Key,K_RIGHTARROW);
    RUN0(M_Menu_Quit_f); RUN1(M_Quit_Key,'n'); RUN0(M_Quit_Draw);
    m_net_cursor=3; RUN0(M_Menu_LanConfig_f); RUN0(M_LanConfig_Draw); RUN1(M_LanConfig_Key,K_DOWNARROW);
    RUN0(M_Menu_GameOptions_f); RUN0(M_GameOptions_Draw); RUN1(M_NetStart_Change,1); RUN1(M_GameOptions_Key,K_DOWNARROW);
    RUN0(M_Menu_Search_f); RUN0(M_Search_Draw); RUN1(M_Search_Key,K_ESCAPE);
    RUN0(M_Menu_ServerList_f); RUN0(M_ServerList_Draw); RUN1(M_ServerList_Key,K_DOWNARROW);
    RUN0(M_Init); m_state=1; key_dest=key_menu; RUN0(M_Draw); RUN1(M_Keydown,K_DOWNARROW);
    RUN0(M_ConfigureNetSubsystem);
    return 0;
}
