#include <stdio.h>
int main(void) {
  printf("{\"name\":\"world_front_positive\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"world_front_negative\",\"value\":%u}\n", (unsigned)0u);
  printf("{\"name\":\"world_back_negative\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"underwater_bypass\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"brush_epsilon_milli\",\"value\":%u}\n", (unsigned)10u);
  printf("{\"name\":\"texture_head_insertion\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"translucent_water_deferred\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"fixtures\",\"value\":%u}\n", (unsigned)20u);
  return 0;
}
