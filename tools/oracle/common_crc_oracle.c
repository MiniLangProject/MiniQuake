#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint16_t crc_byte(uint16_t crc, unsigned data) {
  uint16_t v = (uint16_t)(crc ^ ((data & 255u) << 8));
  for (int i=0;i<8;i++) { unsigned shifted=((unsigned)v << 1); v=(uint16_t)((v & 0x8000u) ? (shifted ^ 0x1021u) : shifted); }
  return v;
}
static uint16_t crc_block(const unsigned char *p, size_t n) {
  uint16_t c=0xffffu; while(n--) c=crc_byte(c,*p++); return c;
}
static uint32_t fbits(float x) { union { float f; uint32_t u; } v; v.f=x; return v.u; }
int main(void) {
  const unsigned char check[]="123456789";
  const unsigned char sub[]="234";
  printf("atof_12_1_bits=0x%08x\n", fbits((float)12.1));
  printf("negative_zero_bits=0x%08x\n", fbits(-0.0f));
  printf("atoi_decimal_wrap=%d\n", (int32_t)0x80000000u);
  printf("atoi_hex_wrap=%d\n", (int32_t)0xffffffffu);
  printf("crc_123456789=0x%04x\n", crc_block(check,9));
  printf("crc_subrange_234=0x%04x\n", crc_block(sub,3));
  printf("filebase_short=?model?\n");
  printf("default_hidden=.quake.cfg\n");
  return 0;
}
