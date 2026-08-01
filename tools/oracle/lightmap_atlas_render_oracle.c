#include <stdio.h>
int main(void) {
  printf("{\"name\":\"atlas_width\",\"value\":%u}\n", (unsigned)128u);
  printf("{\"name\":\"atlas_height\",\"value\":%u}\n", (unsigned)128u);
  printf("{\"name\":\"atlas_pages\",\"value\":%u}\n", (unsigned)64u);
  printf("{\"name\":\"luminance_bytes\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"rgba_bytes\",\"value\":%u}\n", (unsigned)4u);
  printf("{\"name\":\"rgba_2x2_stride10_required\",\"value\":%u}\n", (unsigned)18u);
  printf("{\"name\":\"shared_texture_delete_once\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"fixtures\",\"value\":%u}\n", (unsigned)22u);
  return 0;
}
