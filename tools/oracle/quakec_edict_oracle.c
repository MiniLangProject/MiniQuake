/* Source-guided pr_edict.c semantic oracle for BP-022. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
static void row(const char *name,long long value){printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%lld}\n",name,value);}
static void textrow(const char *name,const char *value){printf("{\"kind\":\"text\",\"name\":\"%s\",\"value\":\"%s\"}\n",name,value);}
int main(void){
    static const int type_size[8]={1,1,1,3,1,1,1,1};char text[64];float negzero=-0.0f;
    snprintf(text,sizeof(text),"%f",negzero);
    row("type_size_void",type_size[0]);row("type_size_vector",type_size[3]);row("type_size_pointer",type_size[7]);
    row("reuse_early_free_time",1.5f<2.0f);row("reuse_recent_old_slot",(3.75f-3.0f)>0.5f);
    row("reuse_exact_half_second",(3.5f-3.0f)>0.5f);row("angle_hack_pitch",0);row("angle_hack_yaw",90);
    row("light_alias",1);row("unknown_key_continues",1);row("save_global_type_count",3);
    textrow("negative_zero_fixed",text);return 0;
}
