#include <stdint.h>
#include <stdio.h>

int main(void) {
  puts("bsp_version=29");
  puts("mdl_version=6");
  puts("sprite_version=1");
  puts("header_lumps=15");
  puts("max_models=256");
  puts("max_alias_vertices=2000");
  puts("model_types=brush,sprite,alias");
  puts("registry_case_sensitive=1");
  puts("alias_cache_survives_clear=1");
  puts("animation_cycle=2");
  puts("animation_primary_frames=2");
  puts("animation_total=4");
  puts("animation_primary_next=1");
  puts("animation_alternate=2");
  puts("texture_animation_base_name=+0fixture");
  puts("texture_animation_total=4");
  puts("texture_animation_primary_next=1");
  puts("texture_animation_alternate=2");
  puts("submodel_bounds_spread=1");
  puts("submodel_input_mins=-3,-4,0");
  puts("submodel_loaded_mins=-4,-5,-1");
  puts("submodel_input_maxs=2,1,12");
  puts("submodel_loaded_maxs=3,2,13");
  return 0;
}
