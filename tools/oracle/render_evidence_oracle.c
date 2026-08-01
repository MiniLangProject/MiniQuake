#include <stdint.h>
#include <stdio.h>

static uint32_t fnv(const unsigned char *data, int count) {
  uint32_t hash = UINT32_C(2166136261);
  int index;
  for (index = 0; index < count; ++index) {
    hash ^= data[index];
    hash *= UINT32_C(16777619);
  }
  return hash;
}

int main(void) {
  static const unsigned char known[] = "123456789";
  static const unsigned char rgba[] = {
    0,0,0,255, 255,0,0,255, 0,255,0,255, 0,0,255,255
  };
  printf("schema=1\n");
  printf("sample_grid=16\n");
  printf("fnv_empty=%u\n", fnv(known, 0));
  printf("fnv_known=%u\n", fnv(known, 9));
  printf("rgba_hash=%u\n", fnv(rgba, 16));
  printf("non_black=3\n");
  printf("tga_bytes_2x2=30\n");
  printf("fixtures=18\n");
  return 0;
}
