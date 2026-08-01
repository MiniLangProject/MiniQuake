#include <stdio.h>
static int sbar_x(int width,int deathmatch){return deathmatch?0:(width-320)/2;}
static int sbar_lines(float size,int intermission){if(intermission)return 0;if(size>=120.0f)return 0;if(size>=110.0f)return 24;return 48;}
int main(void){
 printf("sbar_coop_640=%d\n",sbar_x(640,0)); printf("sbar_dm_640=%d\n",sbar_x(640,1));
 printf("normal_overlay_stages=%d\n",11); printf("set2d_stages=%d\n",11);
 printf("tga_1x1=%d\n",18+3); printf("tga_640x480=%d\n",18+640*480*3);
 printf("viewmodel_depth_milli=%d\n",300); printf("sbar_lines_100=%d\n",sbar_lines(100.0f,0));
 printf("sbar_lines_110=%d\n",sbar_lines(110.0f,0)); printf("sbar_lines_120=%d\n",sbar_lines(120.0f,0));
 printf("fixtures=%d\n",24); return 0;
}
