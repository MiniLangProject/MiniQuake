#include <stdio.h>
int main(void) {
  double firstx=(10.0+0.0)*0.5, firsty=(-6.0+0.0)*0.5;
  double secondx=(6.0+10.0)*0.5, secondy=(2.0-6.0)*0.5;
  printf("first=%.1f,%.1f\n", firstx, firsty);
  printf("second=%.1f,%.1f\n", secondx, secondy);
  printf("device_clear_preserves_buttons=1\n");
  return 0;
}
