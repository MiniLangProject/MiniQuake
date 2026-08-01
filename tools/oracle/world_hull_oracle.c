#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define CONTENTS_EMPTY -1
#define CONTENTS_SOLID -2
#define CONTENTS_WATER -3
#define DIST_EPSILON (1.0f / 32.0f)

typedef struct { float x,y,z; } vec3;
typedef struct { vec3 mins,maxs; } box_hull;

static uint32_t bits(float value) { uint32_t out; memcpy(&out,&value,sizeof(out)); return out; }

static int point_contents(const box_hull *h, int node, vec3 p) {
    while (node >= 0) {
        int axis, side, empty_side;
        float coordinate, distance;
        if (node > 5) return 0x7fffffff;
        axis = node >> 1;
        coordinate = axis == 0 ? p.x : axis == 1 ? p.y : p.z;
        if (node == 0) distance=h->maxs.x;
        else if (node == 1) distance=h->mins.x;
        else if (node == 2) distance=h->maxs.y;
        else if (node == 3) distance=h->mins.y;
        else if (node == 4) distance=h->maxs.z;
        else distance=h->mins.z;
        side = coordinate < distance;
        empty_side = node & 1;
        if (side == empty_side) return CONTENTS_EMPTY;
        if (node == 5) return CONTENTS_SOLID;
        ++node;
    }
    return node;
}

static float cross_fraction(float start, float end, float plane) {
    float t1=start-plane, t2=end-plane;
    return (t1-DIST_EPSILON)/(t1-t2);
}

static void emit_i(const char *name, int value) {
    printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%d}\n",name,value);
}
static void emit_u(const char *name, uint32_t value) {
    printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%u}\n",name,value);
}
int main(void) {
    box_hull h={{-2,-3,-4},{2,3,4}};
    emit_i("inside",point_contents(&h,0,(vec3){0,0,0}));
    emit_i("max_x",point_contents(&h,0,(vec3){2,0,0}));
    emit_i("min_x",point_contents(&h,0,(vec3){-2,0,0}));
    emit_i("max_y",point_contents(&h,0,(vec3){0,3,0}));
    emit_i("min_y",point_contents(&h,0,(vec3){0,-3,0}));
    emit_i("max_z",point_contents(&h,0,(vec3){0,0,4}));
    emit_i("min_z",point_contents(&h,0,(vec3){0,0,-4}));
    emit_i("start_node_1",point_contents(&h,1,(vec3){100,0,0}));
    emit_i("negative_leaf",point_contents(&h,CONTENTS_WATER,(vec3){0,0,0}));
    emit_i("bad_node",point_contents(&h,6,(vec3){0,0,0}));
    emit_u("cross_fraction_bits",bits(cross_fraction(4.0f,-4.0f,2.0f)));
    emit_u("cross_endpoint_bits",bits(4.0f+(-8.0f)*cross_fraction(4.0f,-4.0f,2.0f)));
    emit_i("quake1_rotated_brush_enabled",0);
    emit_i("fixture_count",14);
    return 0;
}
