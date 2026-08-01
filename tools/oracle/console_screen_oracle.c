#include <stdio.h>
int main(void) {
  int waiting=1, saw_down=0;
  int up_before = waiting && !saw_down;
  saw_down=1;
  int down_pending=waiting;
  waiting=0;
  printf("up_before_down_ignored=%d\n", up_before);
  printf("down_pending=%d\n", down_pending);
  printf("dismissed=%d\n", !waiting);
  printf("notify_edges=2\n");
  return 0;
}
