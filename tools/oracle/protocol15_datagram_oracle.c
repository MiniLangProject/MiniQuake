/*
 * Source-guided net_dgrm.c scheduling oracle for MiniQuake BP-017.
 * It models only deterministic channel state; socket I/O remains in MiniLang.
 */
#include <stdint.h>
#include <stdio.h>

#define MAX_DATAGRAM 1024u
#define NET_MAXMESSAGE 8192u

static uint32_t next_sequence(uint32_t value) { return value + 1u; }
static uint32_t previous_sequence(uint32_t value) { return value - 1u; }
static unsigned fragments(unsigned length) {
    return (length + MAX_DATAGRAM - 1u) / MAX_DATAGRAM;
}
static int retransmit_due(double now, double last) { return now - last > 1.0; }
static unsigned ack_remaining(unsigned length) {
    return length > MAX_DATAGRAM ? length - MAX_DATAGRAM : 0u;
}
static void row(const char *name, uint64_t value) {
    printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%llu}\n",
           name, (unsigned long long)value);
}

int main(void) {
    row("sequence_next_wrap", next_sequence(UINT32_MAX));
    row("sequence_previous_wrap", previous_sequence(0u));
    row("exact_fragment_eom", 1024u <= MAX_DATAGRAM);
    row("split_fragment_eom", 1025u <= MAX_DATAGRAM);
    row("first_wire_size", 8u + MAX_DATAGRAM);
    row("ack_remaining_1500", ack_remaining(1500u));
    row("ack_sets_sendnext", ack_remaining(1500u) > 0u);
    row("ack_defers_wire_send", 0u);
    row("flush_second_sequence", 1u);
    row("final_ack_cansend", ack_remaining(476u) == 0u);
    row("retransmit_exact_second", retransmit_due(11.0, 10.0));
    row("retransmit_above_second", retransmit_due(11.0001, 10.0));
    row("unreliable_gap", 3u - 0u);
    row("reliable_fragments_2500", fragments(2500u));
    row("reliable_fragments_max", fragments(NET_MAXMESSAGE));
    row("duplicate_data_reack", 1u);
    row("cansend_query_side_effects", 0u);
    row("receive_overflow_guard", NET_MAXMESSAGE + 1u > NET_MAXMESSAGE);
    return 0;
}
