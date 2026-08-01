#include <stdio.h>
int main(void) {
  printf("{\"name\":\"contract_fingerprint\",\"value\":%u}\n", (unsigned)2221569246u);
  printf("{\"name\":\"near_clip\",\"value\":%u}\n", (unsigned)4u);
  printf("{\"name\":\"far_clip\",\"value\":%u}\n", (unsigned)4096u);
  printf("{\"name\":\"stage_count\",\"value\":%u}\n", (unsigned)7u);
  printf("{\"name\":\"viewport_full_width\",\"value\":%u}\n", (unsigned)640u);
  printf("{\"name\":\"viewport_inset_width\",\"value\":%u}\n", (unsigned)322u);
  printf("{\"name\":\"front_face_culling\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"fixtures\",\"value\":%u}\n", (unsigned)24u);
  return 0;
}
