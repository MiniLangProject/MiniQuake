/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Frozen observable host/lifecycle ordering for the WinQuake 1.09 compatibility
profile.  Backends may change, but these stage relationships are authoritative.
*/
package miniquake.host_lifecycle_contract

/// Defines the status value used by `miniquake.host_lifecycle_contract`.
const STATUS = "host_lifecycle_109_frozen_v1"
/// Defines the contract fingerprint value used by `miniquake.host_lifecycle_contract`.
const CONTRACT_FINGERPRINT = 0x8cbb709f
/// Defines the savegame version value used by `miniquake.host_lifecycle_contract`.
const SAVEGAME_VERSION = 5
/// Defines the savegame comment length value used by `miniquake.host_lifecycle_contract`.
const SAVEGAME_COMMENT_LENGTH = 39
/// Defines the spawn parm count value used by `miniquake.host_lifecycle_contract`.
const SPAWN_PARM_COUNT = 16
/// Defines the lightstyle count value used by `miniquake.host_lifecycle_contract`.
const LIGHTSTYLE_COUNT = 64
/// Defines the shutdown flush seconds value used by `miniquake.host_lifecycle_contract`.
const SHUTDOWN_FLUSH_SECONDS = 3
/// Defines the shutdown broadcast seconds value used by `miniquake.host_lifecycle_contract`.
const SHUTDOWN_BROADCAST_SECONDS = 5

/// Advance trace stages by one processing step.
/// @param sendStage The send stage input consumed by `frameTraceStages`.
function frameTraceStages(sendStage)
  return [
    "filter", "commands", "net_poll", sendStage, "console", "server",
    "host_time", "client_read", "demo_scene", "entity_relink",
    "entity_effects", "client_events", "qc_control", "centerprint",
    "view", "screen", "dlight_decay", "particles", "audio",
  ]
end function

/// Implements the `localFrameStages` operation for `miniquake.host_lifecycle_contract` (local frame stages).
function localFrameStages()
  return frameTraceStages("local_send")
end function

/// Implements the `remoteFrameStages` operation for `miniquake.host_lifecycle_contract` (remote frame stages).
function remoteFrameStages()
  return frameTraceStages("remote_send")
end function

/// Implements the `demoFrameStages` operation for `miniquake.host_lifecycle_contract` (demo frame stages).
function demoFrameStages()
  return frameTraceStages("demo_send")
end function

/// Implements the `serverFrameStages` operation for `miniquake.host_lifecycle_contract` (server frame stages).
/// @param simulate The simulate input consumed by `serverFrameStages`.
function serverFrameStages(simulate)
  stages = ["clear_datagram", "new_clients", "run_clients"]
  if simulate then stages = stages + ["physics"] end if
  return stages + ["send_messages"]
end function

/// Implements the `mapReplaceStages` operation for `miniquake.host_lifecycle_contract` (map replace stages).
function mapReplaceStages()
  return [
    "stop_demo_loop", "disconnect_client", "shutdown_server",
    "clear_serverflags", "spawn_server", "connect_local",
  ]
end function

// Update subsystem configuration for change level stages.
function changeLevelStages()
  return ["save_spawnparms", "send_reconnect", "spawn_server", "restore_clients"]
end function

/// Implements the `restartStages` operation for `miniquake.host_lifecycle_contract` (restart stages).
function restartStages()
  return ["copy_mapname", "preserve_spawnparms", "spawn_server"]
end function

// Encode and write game stages.
function savegameStages()
  return [
    "v5", "comment39", "spawn16", "skill", "map", "time",
    "styles64", "globals", "edicts",
  ]
end function

// Release state for shutdown stages.
function shutdownStages()
  return [
    "mark_inactive", "disconnect_local", "flush_reliable_3s",
    "broadcast_disconnect_5s", "drop_clients", "clear_server",
  ]
end function

// Report stages and return the corresponding failure status.
function errorStages()
  return [
    "recursion_guard", "end_loading", "shutdown_server",
    "disconnect_client", "stop_demo_loop", "abort_frame",
  ]
end function

/// Returns whether `miniquake.host_lifecycle_contract` can onical text.
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

/// Returns the compatibility fingerprint for `miniquake.host_lifecycle_contract`.
/// @param text Text to parse or process.
function fingerprint(text)
  hash = 2166136261
  for each value in bytes(text)
    hash = ((hash ^ value) * 16777619) & 0xffffffff
  end for
  return hash
end function

/// Implements the `verify` operation for `miniquake.host_lifecycle_contract` (verify).
function verify()
  return fingerprint(canonicalText()) == CONTRACT_FINGERPRINT
end function
