#include <stdio.h>
#include <stdlib.h>

static double q_atof_compat(const char *s) {
  int sign = 1;
  if (*s == '-') { sign = -1; ++s; }
  if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) {
    int value = 0; s += 2;
    while (*s) {
      int digit;
      if (*s >= '0' && *s <= '9') digit = *s - '0';
      else if (*s >= 'a' && *s <= 'f') digit = *s - 'a' + 10;
      else if (*s >= 'A' && *s <= 'F') digit = *s - 'A' + 10;
      else break;
      value = value * 16 + digit; ++s;
    }
    return (double)(sign * value);
  }
  return (double)sign * strtod(s, NULL);
}

int main(void) {
  puts("status=gameplay_presentation_109_frozen_v1");
  puts("fingerprint=0xad91624c");
  puts("host_color_parser=atoi");
  puts("host_give_parser=atoi");
  puts("host_viewframe_parser=atoi");
  puts("host_edict_parser=q_atoi");
  puts("host_player_index_parser=q_atof");
  printf("crt_atoi_space_plus=%d\n", atoi("  +12junk"));
  printf("crt_atoi_hex=%d\n", atoi("0x20"));
  printf("crt_atoi_character=%d\n", atoi("'A"));
  printf("q_atof_hex=%d\n", (int)q_atof_compat("0x3"));
  puts("screen_loading_sound_order=before_connection_gate");
  puts("screenshot_failure_text=PCX");
  return 0;
}
