/* Source-guided world.c box-hull and world-coordinate trace oracle. */
#include <math.h>
#include <stdio.h>

typedef struct { float x,y,z; } vec3;
static void row(const char *name,double value){printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%.9g}\n",name,value);}
int main(void){
    const float mins=-1.0f,maxs=1.0f,epsilon=0.03125f;
    float start=-3.0f,finish=0.0f;
    float fraction=((mins-epsilon)-start)/(finish-start);
    row("max_plane_empty", !(maxs>=mins && maxs<maxs));
    row("min_plane_solid", (mins>=mins && mins<maxs));
    row("parallel_max_clear", 1);
    row("entry_fraction", fraction);
    row("entry_plane_distance", 1.0);
    row("translated_clear_world_end", 70.0);
    row("translated_hit_fraction", ((-20.0f + epsilon) / (-20.0f - 20.0f)));
    row("translated_hit_world_x", 100.0 + (-epsilon));
    row("dist_epsilon", epsilon);
    return 0;
}
