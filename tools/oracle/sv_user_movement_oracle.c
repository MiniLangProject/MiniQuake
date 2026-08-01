/* Source-guided sv_user.c intention and angle oracle. */
#include <math.h>
#include <stdint.h>
#include <stdio.h>
static void row(const char *name, double value){printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%.9g}\n",name,value);}
int main(void){
  const double pitch=60.0*3.14159265358979323846/180.0;
  row("pitch60_forward_x",cos(pitch)*100.0);
  row("nonwalk_upmove",25.0);
  row("walk_vertical",0.0);
  row("teleport_backmove",0.0);
  row("maxspeed",320.0);
  row("air_cap",30.0);
  row("idle_water_sink",-42.0);
  row("forward_water",70.0);
  row("ideal_pitch",-0.8);
  row("read_angle_128",((int8_t)128)*(360.0/256.0));
  row("punch_x",2.7);
  row("punch_y",3.6);
  row("fixture_count",16.0);
  return 0;
}
