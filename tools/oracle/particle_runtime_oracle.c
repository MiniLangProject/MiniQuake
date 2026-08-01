#include <stdint.h>
#include <stdio.h>
#include <string.h>
static uint32_t bits(float x){uint32_t u;memcpy(&u,&x,4);return u;}
static void row(const char*n,int64_t v){printf("{\"name\":\"%s\",\"value\":%lld}\n",n,(long long)v);}
int main(void){float dt=.1f;float g400=dt*400.0f*.05f;float g800=dt*800.0f*.05f;row("custom_gravity_fbits",bits(10.0f-g400));row("default_gravity_fbits",bits(10.0f-g800));row("blob2_x_fbits",bits(10.0f-10.0f*(4.0f*dt)));row("blob2_z_zero_gravity_fbits",bits(10.0f));row("blob2_z_gravity_fbits",bits(10.0f-g800));row("explode_x_fbits",bits(10.0f+10.0f*(4.0f*dt)));row("float_integer_boundary",bits(16777217.0f));row("fixtures",22);return 0;}
