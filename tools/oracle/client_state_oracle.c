#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint32_t bits(float x) {
    uint32_t u;
    memcpy(&u, &x, sizeof(u));
    return u;
}

static void row(const char *name, int64_t value) {
    printf("{\"name\":\"%s\",\"value\":%lld}\n", name, (long long)value);
}

/* mathlib.c: anglemod(float a) */
static float quake_anglemod(float a) {
    a = (float)((360.0 / 65536.0) * ((int)(a * (65536.0 / 360.0)) & 65535));
    return a;
}

int main(void) {
    double newest = 2.0;
    double oldest = 1.9;
    double now = 1.95;
    float f = (float)(newest - oldest);
    float frac = (float)((now - oldest) / (double)f);
    float d = 10.0f - 350.0f;
    float a;
    float r;
    double cl_time = 1.0;
    float bobjrotate;

    if (d < -180.0f) d += 360.0f;
    a = 350.0f + 0.5f * d;
    r = 100.0f - 0.25f * 40.0f;

    /* CL_LerpPoint: cl_nolerp snaps cl.time before CL_RelinkEntities computes bobjrotate. */
    cl_time = newest;
    bobjrotate = quake_anglemod((float)(100.0 * cl_time));

    row("lerp_half_fbits", bits(frac));
    row("angle_wrap_fbits", bits(a));
    row("dlight_decay_fbits", bits(r));
    row("nolerp_time_fbits", bits((float)cl_time));
    row("nolerp_rotate_fbits", bits(bobjrotate));
    row("float_integer_boundary", bits(16777217.0f));
    row("max_visedicts", 256);
    row("fixtures", 20);
    return 0;
}
