#include <stdio.h>
int main(void) {
  printf("{\"name\":\"active_at_deadline\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"expired_before_deadline\",\"value\":%u}\n", (unsigned)0u);
  printf("{\"name\":\"zero_radius_inactive\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"push_target_frame_delta\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"max_dlight_bits\",\"value\":%u}\n", (unsigned)32u);
  printf("{\"name\":\"brush_root_marking\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"frame_order_push_animate_advance\",\"value\":%u}\n", (unsigned)1u);
  printf("{\"name\":\"fixtures\",\"value\":%u}\n", (unsigned)20u);
  return 0;
}
