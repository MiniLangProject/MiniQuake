/* Source-guided cl_demo.c framing and command oracle for BP-018. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void case_row(const char *name, long long value) {
    printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%lld}\n", name, value);
}
static void vector_row(const char *name, const char *hex) {
    printf("{\"kind\":\"vector\",\"name\":\"%s\",\"hex\":\"%s\"}\n", name, hex);
}
static void put_u32_le(unsigned char *out, uint32_t value) {
    out[0]=(unsigned char)value; out[1]=(unsigned char)(value>>8);
    out[2]=(unsigned char)(value>>16); out[3]=(unsigned char)(value>>24);
}
static void put_f32_le(unsigned char *out, float value) {
    uint32_t word=0; memcpy(&word,&value,sizeof(word)); put_u32_le(out,word);
}
static void hex_encode(const unsigned char *data, size_t size, char *out) {
    static const char digits[]="0123456789abcdef";
    size_t i;
    for(i=0;i<size;i++){out[i*2]=digits[data[i]>>4];out[i*2+1]=digits[data[i]&15];}
    out[size*2]='\0';
}
static int playback_track(const char *text) {
    int value=0, neg=0;
    const unsigned char *p=(const unsigned char *)text;
    while(*p && *p!='\n'){
        if(*p=='-')neg=1;
        else value=value*10+((int)*p-'0');
        p++;
    }
    return neg ? -value : value;
}
int main(void) {
    unsigned char frame[21]; char hex[43];
    frame[0]='4'; frame[1]='\n'; put_u32_le(frame+2,3);
    put_f32_le(frame+6,1.0f); put_f32_le(frame+10,-2.5f); put_f32_le(frame+14,90.0f);
    frame[18]=1; frame[19]=2; frame[20]=3; hex_encode(frame,sizeof(frame),hex);
    case_row("atoi_decimal_suffix",atoi("1.5"));
    case_row("atoi_no_digits",atoi("soundtrack"));
    case_row("atoi_whitespace_sign",atoi("  -12tail"));
    case_row("atoi_plus",atoi("\t+7"));
    case_row("isolated_nop_filtered",1);
    case_row("multi_byte_nop_retained",1);
    case_row("stop_disconnect_opcode",2);
    case_row("max_message_accepted",8000);
    case_row("timedemo_first_frame_excluded",10);
    case_row("playback_whitespace_track",playback_track("  2\n"));
    case_row("map_before_demo_open",1);
    vector_row("single_frame",hex);
    return 0;
}
