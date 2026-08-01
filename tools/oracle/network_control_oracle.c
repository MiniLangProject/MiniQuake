#include <stdio.h>
#include <string.h>

typedef struct {
    const char *name;
    const char *value;
    int server;
} rule_t;

/* Return 0 for net_dgrm.c's silent unknown-previous path. Return 1 when a
 * reply is emitted; empty strings represent the command-only terminator. */
static int next_rule(const rule_t *rules, int count, const char *previous,
                     const char **name, const char **value) {
    int start = 0;
    int i;
    if (previous[0] != '\0') {
        int found = -1;
        for (i = 0; i < count; ++i) {
            if (strcmp(rules[i].name, previous) == 0) {
                found = i;
                break;
            }
        }
        if (found < 0) return 0;
        start = found + 1;
    }
    for (i = start; i < count; ++i) {
        if (rules[i].server) {
            *name = rules[i].name;
            *value = rules[i].value;
            return 1;
        }
    }
    *name = "";
    *value = "";
    return 1;
}

int main(void) {
    const rule_t rules[] = {
        {"deathmatch", "1", 1},
        {"developer", "0", 0},
        {"fraglimit", "20", 1},
    };
    const char *name = NULL;
    const char *value = NULL;

    printf("protocol=3\n");
    printf("game=QUAKE\n");
    printf("host_cache=8\n");
    printf("request=1,2,3,4\n");
    printf("reply=129,130,131,132,133\n");
    if (!next_rule(rules, 3, "", &name, &value)) return 1;
    printf("rule_first=%s:%s\n", name, value);
    if (!next_rule(rules, 3, "deathmatch", &name, &value)) return 1;
    printf("rule_next=%s:%s\n", name, value);
    if (!next_rule(rules, 3, "fraglimit", &name, &value)) return 1;
    printf("rule_end=%s\n", name[0] == '\0' && value[0] == '\0' ? "terminator" : "invalid");
    printf("rule_unknown=%s\n", next_rule(rules, 3, "missing", &name, &value) ? "reply" : "no_reply");
    return 0;
}
