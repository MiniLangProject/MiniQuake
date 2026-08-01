#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint32_t fnv1a(const char *text) {
  uint32_t value = 0x811c9dc5u;
  while (*text) {
    value ^= (unsigned char)*text++;
    value *= 0x01000193u;
  }
  return value;
}

int main(void) {
  const char *contract =
    "core_assets_memory_109_frozen_v1\n"
    "common_q_atof_binary32=1\n"
    "common_q_atoi_int32=1\n"
    "quake_text_abi=quake_latin1_cstring_v1\n"
    "pak_entry_bytes=64\n"
    "pack_name_bytes=56\n"
    "max_pack_files=2048\n"
    "wad_name_bytes=16\n"
    "wad_lumpinfo_bytes=32\n"
    "bsp_version=29\n"
    "mdl_version=6\n"
    "sprite_version=1\n"
    "hunk_alignment=16\n"
    "zone_alignment=8\n"
    "hunk_name_bytes=8\n"
    "cache_name_bytes=15\n"
    "zone_dynamic_size=49152\n"
    "retail_evidence_files=4\n";
  printf("fingerprint=0x%08x\n", fnv1a(contract));
  puts("hunk_span_1=32");
  puts("hunk_span_17=48");
  puts("zone_alignment=8");
  puts("hunk_alignment=16");
  puts("dynamic_zone_size=49152");
  puts("retail_evidence_files=4");
  return fnv1a(contract) == 0x6c8d974du ? 0 : 1;
}
