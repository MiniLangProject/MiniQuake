#include <stdint.h>
#include <stdio.h>
#include <string.h>
static uint32_t state=1;
static int qrand(void){state=state*214013u+2531011u; return (int)((state>>16)&0x7fffu);}
static uint32_t bits(float value){uint32_t out; memcpy(&out,&value,sizeof(out)); return out;}
static int cycle(const float *intervals,int count,float time){float full=intervals[count-1]; float target=time-(int)(time/full)*full; int i=0; while(i<count-1 && intervals[i]<=target)i++; return i;}
int main(void){
 int first=qrand(),second=qrand();
 printf("first_rand=%d\n",first); printf("first_sync_bits=%08x\n",bits((float)first/32767.0f));
 printf("second_rand=%d\n",second); printf("second_sync_bits=%08x\n",bits((float)second/32767.0f));
 float intervals[2]={0.1f,0.2f};
 printf("cycle_005=%d\n",cycle(intervals,2,0.05f));
 printf("cycle_015=%d\n",cycle(intervals,2,0.15f));
 printf("cycle_025=%d\n",cycle(intervals,2,0.25f));
 printf("sync_modes=%d\n",2); printf("fixtures=%d\n",22); return 0;
}
