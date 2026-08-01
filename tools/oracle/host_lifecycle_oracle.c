#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint32_t fnv1a(const unsigned char *data, size_t length) {
    uint32_t hash = 2166136261u;
    size_t index;
    for (index = 0; index < length; ++index) {
        hash ^= data[index];
        hash *= 16777619u;
    }
    return hash;
}
static void row(const char *name, unsigned long long value) {
    printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%llu}\n", name, value);
}
int main(void) {
    static const char contract[] =
        "status=host_lifecycle_109_frozen_v1\n"
        "filter=rand,realtime,gate,clamp\n"
        "frame=filter,commands,net_poll,client_send,console,server,host_time,client_read,demo_scene,entity_relink,entity_effects,client_events,qc_control,centerprint,view,screen,dlight_decay,particles,audio\n"
        "server=clear_datagram,new_clients,run_clients,physics,send_messages\n"
        "map=stop_demo_loop,disconnect_client,shutdown_server,clear_serverflags,spawn_server,connect_local\n"
        "changelevel=save_spawnparms,send_reconnect,spawn_server,restore_clients\n"
        "restart=copy_mapname,preserve_spawnparms,spawn_server\n"
        "save=v5,comment39,spawn16,skill,map,time,styles64,globals,edicts\n"
        "shutdown=mark_inactive,disconnect_local,flush_reliable_3s,broadcast_disconnect_5s,drop_clients,clear_server\n"
        "error=recursion_guard,end_loading,shutdown_server,disconnect_client,stop_demo_loop,abort_frame\n";
    row("contract_fingerprint", fnv1a((const unsigned char *)contract, strlen(contract)));
    row("frame_trace_stages", 19);
    row("server_physics_stages", 5);
    row("map_replace_stages", 6);
    row("changelevel_stages", 4);
    row("restart_stages", 3);
    row("savegame_stages", 9);
    row("shutdown_stages", 6);
    row("shutdown_flush_seconds", 3);
    row("shutdown_broadcast_seconds", 5);
    row("fixture_count", 24);
    return 0;
}
