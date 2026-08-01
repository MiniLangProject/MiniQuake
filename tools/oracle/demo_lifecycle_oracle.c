#include <stdint.h>
#include <stdio.h>
#include <string.h>
static uint32_t fbits(float v){uint32_t b;memcpy(&b,&v,4);return b;}
static int track(const unsigned char *s){int v=0,neg=0;while(*s!='\n'){int c=*s++;if(c=='-')neg=1;else v=v*10+(c-'0');}return neg?-v:v;}
static void row(const char*n,long long v){printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%lld}\n",n,v);}
int main(void){
 row("track_zero",track((const unsigned char*)"0\n"));
 row("track_negative",track((const unsigned char*)"-12\n"));
 row("track_raw_A",track((const unsigned char*)"A\n"));
 row("track_space_1",track((const unsigned char*)" 1\n"));
 row("demo_header_bytes",16);
 row("timedemo_frames",(20-10)-1);
 float seconds=(float)(102.50000001-100.0);float fps=9/seconds;
 row("timedemo_seconds_bits",fbits(seconds));row("timedemo_fps_bits",fbits(fps));
 row("fixture_count",20);return 0;
}
