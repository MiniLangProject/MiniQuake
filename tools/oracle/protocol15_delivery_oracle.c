/* Source-guided reliable-delivery ordering oracle from sv_main.c/cl_main.c. */
#include <stdio.h>

static int outcome(int result) { return result < 0 ? 1 : (result == 0 ? 2 : 3); }
static int initial_plan(int spawned, int sendsignon, double elapsed) {
    if (spawned) return 1 | 8;
    if (!sendsignon) return elapsed > 5.0 ? 2 : 4;
    return 8;
}
static int reliable_plan(int overflowed, int size, int dropasap, int cansend) {
    if (overflowed) return 1;
    if (size <= 0 && !dropasap) return 0;
    if (!cansend) return 2;
    if (dropasap) return 3;
    return 4;
}
static void row(const char *name, int value) {
    printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%d}\n", name, value);
}
int main(void) {
    row("send_failed", outcome(-1));
    row("send_blocked", outcome(0));
    row("send_committed", outcome(1));
    row("spawned_plan", initial_plan(1,0,0.0));
    row("signon_wait_equal", initial_plan(0,0,5.0));
    row("signon_nop_above", initial_plan(0,0,5.000001));
    row("signon_requested", initial_plan(0,1,0.0));
    row("overflow_first", reliable_plan(1,1,1,1));
    row("drop_blocked", reliable_plan(0,0,1,0));
    row("drop_sendable", reliable_plan(0,0,1,1));
    row("reliable_send", reliable_plan(0,1,0,1));
    row("empty_none", reliable_plan(0,0,0,1));
    row("keepalive_equal", 5.0 > 5.0);
    row("keepalive_above", 5.000001 > 5.0);
    return 0;
}
