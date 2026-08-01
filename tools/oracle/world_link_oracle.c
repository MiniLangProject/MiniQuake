#include <stdio.h>
typedef struct {float x,y,z;} vec3;
static void bounds(vec3 o,vec3 mi,vec3 ma,int item,vec3 *lo,vec3 *hi){
 lo->x=o.x+mi.x;lo->y=o.y+mi.y;lo->z=o.z+mi.z;hi->x=o.x+ma.x;hi->y=o.y+ma.y;hi->z=o.z+ma.z;
 if(item){lo->x-=15;lo->y-=15;hi->x+=15;hi->y+=15;}else{lo->x-=1;lo->y-=1;lo->z-=1;hi->x+=1;hi->y+=1;hi->z+=1;}
}
static int overlap(vec3 a,vec3 A,vec3 b,vec3 B){return !(a.x>B.x||A.x<b.x||a.y>B.y||A.y<b.y||a.z>B.z||A.z<b.z);}
static void emit(const char*n,int v){printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%d}\n",n,v);}
int main(void){vec3 lo,hi;bounds((vec3){10,20,30},(vec3){-1,-2,-3},(vec3){4,5,6},0,&lo,&hi);
 emit("normal_min_x",(int)lo.x);emit("normal_min_y",(int)lo.y);emit("normal_min_z",(int)lo.z);emit("normal_max_x",(int)hi.x);emit("normal_max_y",(int)hi.y);emit("normal_max_z",(int)hi.z);
 bounds((vec3){10,20,30},(vec3){-1,-2,-3},(vec3){4,5,6},1,&lo,&hi);emit("item_min_x",(int)lo.x);emit("item_min_y",(int)lo.y);emit("item_min_z",(int)lo.z);emit("item_max_x",(int)hi.x);emit("item_max_y",(int)hi.y);emit("item_max_z",(int)hi.z);
 emit("inclusive_overlap",overlap((vec3){0,0,0},(vec3){1,1,1},(vec3){1,1,1},(vec3){2,2,2}));emit("separated_overlap",overlap((vec3){0,0,0},(vec3){1,1,1},(vec3){1.01f,0,0},(vec3){2,1,1}));emit("fixture_count",15);return 0;}
