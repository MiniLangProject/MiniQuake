#include <stdio.h>
#include <string.h>
int main(void) {
  const char *s = "-attack 65\n-forward 97\n-attack 97\n";
  printf("key_count=256\n");
  printf("history_lines=32\n");
  printf("release_bytes=%zu\n", strlen(s));
  printf("release=%s", s);
  return 0;
}
