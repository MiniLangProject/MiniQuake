#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint32_t bits(float value) { uint32_t out; memcpy(&out, &value, sizeof(out)); return out; }
static int shade_row(float yaw) { return ((int)(yaw * (16.0f / 360.0f))) & 15; }
static int clamp_byte(float value) { int v=(int)value; if(v<0)v=0; if(v>255)v=255; return v; }
int main(void) {
  float lheight=13.0f-3.0f;
  printf("shadow_lheight_bits=%08x\n", bits(lheight));
  float height=-lheight+1.0f;
  printf("shadow_height_bits=%08x\n", bits(height));
  printf("shade_row_0=%d\n", shade_row(0.0f));
  printf("shade_row_90=%d\n", shade_row(90.0f));
  printf("shade_row_180=%d\n", shade_row(180.0f));
  printf("shade_row_270=%d\n", shade_row(270.0f));
  printf("shade_row_360=%d\n", shade_row(360.0f));
  printf("shade_row_negative=%d\n", shade_row(-90.0f));
  printf("clamp_low=%d\n", clamp_byte(-4.0f));
  printf("clamp_trunc=%d\n", clamp_byte(12.9f));
  printf("clamp_high=%d\n", clamp_byte(999.0f));
  printf("shadedot_quant=%d\n", 16);
  printf("shadow_uses_entity_origin=%d\n", 1);
  printf("multitexture_reset=%d\n", 1);
  printf("fixtures=%d\n", 22);
  return 0;
}
