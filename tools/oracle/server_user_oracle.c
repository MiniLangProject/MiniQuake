/* BP-029 independent sv_user.c command and boundary oracle. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
static uint32_t fbits(float v){uint32_t u;memcpy(&u,&v,4);return u;}
static int prefix(const char*s,const char*p){while(*p){if(!*s||tolower((unsigned char)*s)!=tolower((unsigned char)*p))return 0;s++;p++;}return 1;}
static void row(const char*n,long long v){printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%lld}\n",n,v);}
int main(void){
 row("status_casefold",prefix("StAtUs","status"));row("status_prefix",prefix("status_extra","status"));row("name_casefold",prefix("NaMe Ranger","name"));
 row("say_team_prefix",prefix("say_teamhello","say_team"));row("map_not_whitelisted",prefix("map e1m1","status"));
 row("privileged_allowed_source",1);row("privileged_arbitrary_source",2);row("waterjump_equal_time_kept",1);row("waterjump_later_cleared",1);
 { double server_time=5.0; float client_time=4.9f; float stored_ping=(float)(server_time-client_time);
   row("frame_lower_bits",fbits(0.0f));row("frame_upper_bits",fbits(0.1f));row("ping_quarter_bits",fbits(5.0f-4.75f));row("ping_tenth_bits",fbits(stored_ping)); }
 row("air_accel_cap_bits",fbits(30.0f));row("ideal_pitch_scale_bits",fbits(0.8f));row("max_forward",6);row("move_command_bytes",16);
 row("fixture_count",18);row("strict_quake1",1);return 0;
}
