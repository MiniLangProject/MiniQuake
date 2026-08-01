#include <stdint.h>
#include <stdio.h>
#include <string.h>

typedef struct {
    double realtime;
    double oldrealtime;
    double frametime;
    int framecount;
    int filtered;
} host_timing_t;

static uint32_t fbits(float value) {
    uint32_t bits;
    memcpy(&bits, &value, sizeof(bits));
    return bits;
}

static int host_filter(host_timing_t *state, float input, int timedemo, float forced) {
    state->realtime += input;
    if (!timedemo && state->realtime - state->oldrealtime < 1.0 / 72.0) {
        state->filtered++;
        return 0;
    }
    state->frametime = state->realtime - state->oldrealtime;
    state->oldrealtime = state->realtime;
    if (forced > 0.0f) {
        state->frametime = forced;
    } else {
        if (state->frametime > 0.1) state->frametime = 0.1;
        if (state->frametime < 0.001) state->frametime = 0.001;
    }
    state->framecount++;
    return 1;
}

static void row(const char *name, long long value) {
    printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%lld}\n", name, value);
}

int main(void) {
    host_timing_t a = {0};
    row("below_threshold_accept", host_filter(&a, 0.001f, 0, 0.0f));
    row("below_threshold_filtered", a.filtered);
    host_filter(&a, 0.007f, 0, 0.0f);
    row("accumulated_accept", host_filter(&a, 0.007f, 0, 0.0f));
    row("accumulated_frametime_fbits", fbits((float)a.frametime));

    host_timing_t b = {0};
    row("timedemo_accept", host_filter(&b, 0.0001f, 1, 0.0f));
    row("timedemo_min_fbits", fbits((float)b.frametime));

    host_timing_t c = {0};
    host_filter(&c, 1.0f, 0, 0.0f);
    row("maximum_fbits", fbits((float)c.frametime));

    host_timing_t d = {0};
    host_filter(&d, 0.02f, 0, 0.25f);
    row("forced_fbits", fbits((float)d.frametime));
    row("forced_realtime_fbits", fbits((float)d.realtime));

    host_timing_t e = {0};
    row("negative_accept", host_filter(&e, -0.01f, 0, 0.0f));
    row("negative_realtime_fbits", fbits((float)e.realtime));
    row("fixture_count", 18);
    return 0;
}
