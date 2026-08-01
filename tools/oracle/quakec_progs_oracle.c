/* Source-guided dprograms_t ABI and PR_LoadProgs oracle for BP-020. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

typedef struct { int32_t version, crc, ofs_statements, numstatements, ofs_globaldefs,
    numglobaldefs, ofs_fielddefs, numfielddefs, ofs_functions, numfunctions,
    ofs_strings, numstrings, ofs_globals, numglobals, entityfields; } dprograms_t;
typedef struct { uint16_t op; int16_t a,b,c; } dstatement_t;
typedef struct { uint16_t type, ofs; int32_t s_name; } ddef_t;
typedef struct { int32_t first_statement, parm_start, locals, profile, s_name, s_file,
    numparms; uint8_t parm_size[8]; } dfunction_t;

static uint16_t crc_process(uint16_t crc, uint8_t data) {
    uint16_t value=(uint16_t)(crc ^ ((uint16_t)data<<8));
    int bit;
    for(bit=0;bit<8;bit++) {
        uint32_t shifted=(uint32_t)value<<1;
        value=(uint16_t)((value&0x8000u)?(shifted^0x1021u):shifted);
    }
    return value;
}
static uint16_t crc_block(const uint8_t *data,size_t size) {
    uint16_t crc=0xffffu; size_t i;
    for(i=0;i<size;i++) crc=crc_process(crc,data[i]);
    return crc;
}
static void put16(uint8_t *p,uint16_t v){p[0]=(uint8_t)v;p[1]=(uint8_t)(v>>8);}
static void put32(uint8_t *p,uint32_t v){p[0]=(uint8_t)v;p[1]=(uint8_t)(v>>8);p[2]=(uint8_t)(v>>16);p[3]=(uint8_t)(v>>24);}
static size_t fixture(uint8_t *data) {
    static const uint8_t strings[]={0,'t','i','m','e',0,'h','e','a','l','t','h',0,
        'm','a','i','n',0,'f','i','x','t','u','r','e','.','q','c',0};
    const uint32_t so=60,gdo=68,fdo=84,fo=100,stro=172,go=172+(uint32_t)sizeof(strings),gc=32;
    memset(data,0,go+gc*4u);
    put32(data+0,6);put32(data+4,5927);put32(data+8,so);put32(data+12,1);
    put32(data+16,gdo);put32(data+20,2);put32(data+24,fdo);put32(data+28,2);
    put32(data+32,fo);put32(data+36,2);put32(data+40,stro);put32(data+44,(uint32_t)sizeof(strings));
    put32(data+48,go);put32(data+52,gc);put32(data+56,4);
    put16(data+so,0);
    put16(data+gdo,0);put16(data+gdo+2,0);put32(data+gdo+4,0);
    put16(data+gdo+8,2);put16(data+gdo+10,28);put32(data+gdo+12,1);
    put16(data+fdo,0);put16(data+fdo+2,0);put32(data+fdo+4,0);
    put16(data+fdo+8,2);put16(data+fdo+10,1);put32(data+fdo+12,6);
    put32(data+fo+36,0);put32(data+fo+40,28);put32(data+fo+44,1);
    put32(data+fo+52,13);put32(data+fo+56,18);put32(data+fo+60,0);
    memcpy(data+stro,strings,sizeof(strings));
    return go+gc*4u;
}
static void row(const char *name,long long value){printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%lld}\n",name,value);}
int main(void){
    uint8_t data[512];size_t size=fixture(data);
    row("sizeof_dprograms",(long long)sizeof(dprograms_t));
    row("sizeof_dstatement",(long long)sizeof(dstatement_t));
    row("sizeof_ddef",(long long)sizeof(ddef_t));
    row("sizeof_dfunction",(long long)sizeof(dfunction_t));
    row("type_size_void",1);row("type_size_vector",3);row("type_size_pointer",1);
    row("prog_version",6);row("progheader_crc",5927);
    row("fixture_bytes",(long long)size);row("fixture_runtime_crc",crc_block(data,size));
    return 0;
}
