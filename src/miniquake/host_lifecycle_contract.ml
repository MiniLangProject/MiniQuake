/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Frozen observable host/lifecycle ordering for the WinQuake 1.09 compatibility
profile.  Backends may change, but these stage relationships are authoritative.
*/

package miniquake.host_lifecycle_contract

const STATUS = "host_lifecycle_109_frozen_v1"
const CONTRACT_FINGERPRINT = 0x8cbb709f
const SAVEGAME_VERSION = 5
const SAVEGAME_COMMENT_LENGTH = 39
const SPAWN_PARM_COUNT = 16
const LIGHTSTYLE_COUNT = 64
const SHUTDOWN_FLUSH_SECONDS = 3
const SHUTDOWN_BROADCAST_SECONDS = 5

function frameTraceStages(sendStage)
  return [
    "filter", "commands", "net_poll", sendStage, "console", "server",
    "host_time", "client_read", "demo_scene", "entity_relink",
    "entity_effects", "client_events", "qc_control", "centerprint",
    "view", "screen", "dlight_decay", "particles", "audio",
  ]
end function

function localFrameStages()
  return frameTraceStages("local_send")
end function

function remoteFrameStages()
  return frameTraceStages("remote_send")
end function

function demoFrameStages()
  return frameTraceStages("demo_send")
end function

function serverFrameStages(simulate)
  stages = ["clear_datagram", "new_clients", "run_clients"]
  if simulate then stages = stages + ["physics"] end if
  return stages + ["send_messages"]
end function

function mapReplaceStages()
  return [
    "stop_demo_loop", "disconnect_client", "shutdown_server",
    "clear_serverflags", "spawn_server", "connect_local",
  ]
end function

function changeLevelStages()
  return ["save_spawnparms", "send_reconnect", "spawn_server", "restore_clients"]
end function

function restartStages()
  return ["copy_mapname", "preserve_spawnparms", "spawn_server"]
end function

function savegameStages()
  return [
    "v5", "comment39", "spawn16", "skill", "map", "time",
    "styles64", "globals", "edicts",
  ]
end function

function shutdownStages()
  return [
    "mark_inactive", "disconnect_local", "flush_reliable_3s",
    "broadcast_disconnect_5s", "drop_clients", "clear_server",
  ]
end function

function errorStages()
  return [
    "recursion_guard", "end_loading", "shutdown_server",
    "disconnect_client", "stop_demo_loop", "abort_frame",
  ]
end function

function canonicalText()
  text = "status=host_lifecycle_109_frozen_v1\n"
  text = text + "filter=rand,realtime,gate,clamp\n"
  text = text + "frame=filter,commands,net_poll,client_send,console,server,host_time,client_read,demo_scene,entity_relink,entity_effects,client_events,qc_control,centerprint,view,screen,dlight_decay,particles,audio\n"
  text = text + "server=clear_datagram,new_clients,run_clients,physics,send_messages\n"
  text = text + "map=stop_demo_loop,disconnect_client,shutdown_server,clear_serverflags,spawn_server,connect_local\n"
  text = text + "changelevel=save_spawnparms,send_reconnect,spawn_server,restore_clients\n"
  text = text + "restart=copy_mapname,preserve_spawnparms,spawn_server\n"
  text = text + "save=v5,comment39,spawn16,skill,map,time,styles64,globals,edicts\n"
  text = text + "shutdown=mark_inactive,disconnect_local,flush_reliable_3s,broadcast_disconnect_5s,drop_clients,clear_server\n"
  text = text + "error=recursion_guard,end_loading,shutdown_server,disconnect_client,stop_demo_loop,abort_frame\n"
  return text
end function

function fingerprint(text)
  hash = 2166136261
  for each value in bytes(text)
    hash = ((hash ^ value) * 16777619) & 0xffffffff
  end for
  return hash
end function

function verify()
  return fingerprint(canonicalText()) == CONTRACT_FINGERPRINT
end function
