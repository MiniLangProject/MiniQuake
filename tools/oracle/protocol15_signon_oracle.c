/* Source-guided Protocol-15 signon oracle derived from cl_main.c/host_cmd.c. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static unsigned char out[8192];
static size_t used;

static void clear(void) { used = 0; }
static void byte_value(int value) { out[used++] = (unsigned char)value; }
static void cstring(const char *text) {
    size_t length = strlen(text);
    memcpy(out + used, text, length);
    used += length;
    out[used++] = 0;
}
static void stringcmd(const char *text) { byte_value(4); cstring(text); }
static void emit(const char *name) {
    size_t index;
    printf("{\"kind\":\"vector\",\"name\":\"%s\",\"bytes\":\"", name);
    for (index = 0; index < used; ++index) printf("%02x", out[index]);
    printf("\",\"length\":%zu}\n", used);
}

int main(void) {
    clear(); stringcmd("prespawn"); emit("client_stage_1");
    clear();
    stringcmd("name \"Ranger\"\n");
    stringcmd("color 31 13\n");
    stringcmd("spawn 1 2 3");
    emit("client_stage_2_unmasked_high");
    clear(); stringcmd("begin"); emit("client_stage_3");
    clear(); emit("client_stage_4");
    clear();
    byte_value(25); byte_value(1);
    byte_value(25); byte_value(2);
    byte_value(25); byte_value(3);
    emit("server_signon_markers_1_2_3");
    clear(); byte_value(20); byte_value(25); byte_value(2); emit("server_prespawn_append");
    return 0;
}
