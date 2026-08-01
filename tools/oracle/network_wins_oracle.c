#include <stdint.h>
#include <stdio.h>
static uint16_t sw16(int v){uint16_t n=(uint16_t)v;return (uint16_t)((n<<8)|(n>>8));}
int main(void){
 printf("htons_1234=%04x\n",sw16(0x1234));
 printf("port_neg1=%u\n",(unsigned)(uint16_t)-1);
 printf("port_65536=%u\n",(unsigned)(uint16_t)65536);
 printf("partial_55=10.20.30.55\n");
 return 0;
}
