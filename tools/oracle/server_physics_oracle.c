/* BP-028 independent sv_phys.c numeric and dispatch oracle. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
static uint32_t fbits(float v){uint32_t u;memcpy(&u,&v,4);return u;}
static void row(const char*n,long long v){printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%lld}\n",n,v);}
int main(void){
 row("stop_epsilon_bits",fbits(0.1f));row("step_size_bits",fbits(18.0f));row("max_clip_planes",5);
 row("fly_bumps",4);row("push_overbounce_bits",fbits(1.0f));row("bounce_overbounce_bits",fbits(1.5f));
 row("default_gravity_bits",fbits(1.0f));row("corpse_x_bits",fbits(0.0f));row("corpse_y_bits",fbits(0.0f));row("corpse_z_bits",fbits(-24.0f));
 row("movetype_follow_allowed",0);row("movetype_bouncemissile_allowed",0);row("q2_dispatch_enabled",0);
 row("touch_is_strict_overlap",0);row("pusher_relink_required",1);row("noclip_relink_required",1);
 row("fixture_count",18);row("strict_quake1",1);return 0;
}
