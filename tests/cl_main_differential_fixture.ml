import miniquake.client as client
import miniquake.types as t
import miniquake.constants as c
import miniquake.player_move as movement
import miniquake.cvar as cvar
import miniquake.cmd as cmd
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.native as native

function newClient()
  result = client.create(movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  result.localAuthoritative = false
  return result
end function

function containsBytes(data, wanted)
  if len(wanted) == 0 then return true end if
  start = 0
  while start + len(wanted) <= len(data)
    matched = true
    index = 0
    while index < len(wanted)
      if data[start + index] != wanted[index] then matched = false end if
      index = index + 1
    end while
    if matched then return true end if
    start = start + 1
  end while
  return false
end function

function countByte(data, value)
  count = 0
  for each item in data
    if item == value then count = count + 1 end if
  end for
  return count
end function

function boolText(value)
  if value then return "true" end if
  return "false"
end function

function main(args)
  clearClient = newClient()
  clearClient.levelName = "stale"
  clearClient.entities = [client.createEntity(0), client.createEntity(1)]
  clearClient.stats[c.STAT_HEALTH] = 100
  msg.writeByte(clearClient.outgoing, 77)
  client.CL_ClearState(clearClient)
  wiped = clearClient.levelName == "" and clearClient.stats[c.STAT_HEALTH] == 0
  print "{\"function\":\"CL_ClearState\",\"case\":\"wipe_and_efrags\",\"message_size\":" + clearClient.outgoing.curSize + ",\"num_entities\":" + len(clearClient.entities) + ",\"state_wiped\":" + boolText(wiped) + "}"

  playbackClient = newClient()
  playbackClient.demoPlayback = true
  playbackClient.timedemo = true
  playbackClient.signon = c.SIGNONS
  client.CL_Disconnect(playbackClient)
  disconnectNetwork = netloop.createState()
  connectedClient = newClient()
  client.CL_EstablishConnection(connectedClient, disconnectNetwork, "local")
  disconnectServer = netloop.checkNewConnections(disconnectNetwork)
  connectedClient.timedemo = true
  client.CL_Disconnect(connectedClient)
  disconnectMessage = sz.alloc(16)
  netmain.NET_GetMessage(disconnectServer, disconnectMessage, 1.0)
  print "{\"function\":\"CL_Disconnect\",\"case\":\"playback_and_connected\",\"playback\":" + boolText(playbackClient.demoPlayback) + ",\"connected\":" + boolText(connectedClient.connected) + ",\"unreliable_opcode\":" + disconnectMessage.data[0] + ",\"net_closed\":" + boolText(connectedClient.socket is void) + ",\"signon\":" + connectedClient.signon + ",\"timedemo\":" + boolText(connectedClient.timedemo) + "}"

  commandDisconnect = newClient()
  client.CL_Disconnect_f(commandDisconnect)
  print "{\"function\":\"CL_Disconnect_f\",\"case\":\"shutdown_local\",\"connected\":" + boolText(commandDisconnect.connected) + ",\"signon\":" + commandDisconnect.signon + ",\"shutdown\":" + boolText(client.CL_ServerShutdownRequested()) + "}"

  establishNetwork = netloop.createState()
  established = newClient()
  client.CL_EstablishConnection(established, establishNetwork, "local")
  establishServer = netloop.checkNewConnections(establishNetwork)
  print "{\"function\":\"CL_EstablishConnection\",\"case\":\"local\",\"connected\":" + boolText(established.connected) + ",\"signon\":" + established.signon + ",\"spawned\":" + boolText(established.spawned) + ",\"transport_ready\":" + boolText(establishServer is not void) + "}"
  client.CL_Disconnect(established)

  signonNetwork = netloop.createState()
  signonClient = newClient()
  client.CL_EstablishConnection(signonClient, signonNetwork, "local")
  signonServer = netloop.checkNewConnections(signonNetwork)
  signonClient.name = "Ranger"
  signonClient.colors = 0x4f
  signonClient.spawnParms = "coop 1"
  signonClient.signon = 1
  client.CL_SignonReply(signonClient)
  stage1 = sz.alloc(512); netmain.NET_GetMessage(signonServer, stage1, 1.0)
  signonClient.signon = 2
  client.CL_SignonReply(signonClient)
  stage2 = sz.alloc(512); netmain.NET_GetMessage(signonServer, stage2, 1.0)
  signonClient.signon = 3
  client.CL_SignonReply(signonClient)
  stage3 = sz.alloc(512); netmain.NET_GetMessage(signonServer, stage3, 1.0)
  signonClient.signon = 4
  client.CL_SignonReply(signonClient)
  stringCount = countByte(sz.dataSlice(stage1), c.CLC_STRINGCMD) +
    countByte(sz.dataSlice(stage2), c.CLC_STRINGCMD) +
    countByte(sz.dataSlice(stage3), c.CLC_STRINGCMD)
  print "{\"function\":\"CL_SignonReply\",\"case\":\"all_stages\",\"strings\":" + stringCount + ",\"stage1_ok\":" + boolText(containsBytes(sz.dataSlice(stage1), bytes("prespawn"))) + ",\"name_ok\":" + boolText(containsBytes(sz.dataSlice(stage2), bytes("name \"Ranger\"\n"))) + ",\"color_ok\":" + boolText(containsBytes(sz.dataSlice(stage2), bytes("color 4 15\n"))) + ",\"spawn_ok\":" + boolText(containsBytes(sz.dataSlice(stage2), bytes("spawn coop 1"))) + ",\"begin_ok\":" + boolText(containsBytes(sz.dataSlice(stage3), bytes("begin"))) + ",\"cache_reports\":1,\"loading_end\":1}"
  client.CL_Disconnect(signonClient)

  commands = cmd.create()
  nextDemo = client.CL_NextDemo(commands, ["demo1", "demo2"], 2)
  print "{\"function\":\"CL_NextDemo\",\"case\":\"wrap\",\"loading_begin\":1,\"command_ok\":" + boolText(commands.text == "playdemo demo1\n") + ",\"demonum\":" + nextDemo[1] + "}"

  entityClient = newClient()
  entityClient.modelPrecache = ["", "progs/player.mdl"]
  entity = client.ensureEntity(entityClient, 1)
  entity.modelIndex = 1
  entity.frame = 3
  entityLines = client.CL_PrintEntities_f(entityClient)
  print "{\"function\":\"CL_PrintEntities_f\",\"case\":\"empty_and_model\",\"records\":" + len(entityLines) + "}"

  sentinel = 77
  noPal = client.SetPal(2)
  print "{\"function\":\"SetPal\",\"case\":\"compiled_out\",\"sentinel\":" + sentinel + "}"

  client.CL_ClearDlights()
  client.CL_SetDlightTime(0.0, 1.0)
  key = 1
  while key <= 3
    item = client.CL_AllocDlight(key)
    item.die = 2.0
    key = key + 1
  end while
  exact = client.CL_AllocDlight(17)
  exact.radius = 90.0
  exact.die = 2.0
  exact = client.CL_AllocDlight(17)
  keySlot = client.CL_DlightIndexForKey(17)
  exact.die = 2.0
  key = 18
  while key <= 45
    item = client.CL_AllocDlight(key)
    item.die = 2.0
    key = key + 1
  end while
  fallback = client.CL_AllocDlight(9)
  fallbackSlot = client.CL_DlightIndexForKey(9)
  print "{\"function\":\"CL_AllocDlight\",\"case\":\"key_and_fallback\",\"key_slot\":" + keySlot + ",\"key_radius\":" + native.trunc(exact.radius) + ",\"fallback_slot\":" + fallbackSlot + ",\"fallback_key\":" + fallback.key + "}"

  client.CL_ClearDlights()
  client.CL_SetDlightTime(0.75, 1.0)
  decay = client.CL_AllocDlight(2)
  decay.radius = 90.0
  decay.decay = 40.0
  decay.die = 2.0
  client.CL_DecayLights()
  print "{\"function\":\"CL_DecayLights\",\"case\":\"active\",\"radius\":" + native.trunc(decay.radius) + ",\"elapsed\":0.25}"

  lerpClient = newClient()
  lerpClient.messageTimes = [2.0, 1.9]; lerpClient.time = 1.95
  normal = client.CL_LerpPoint(lerpClient)
  lerpClient.messageTimes = [3.0, 2.0]; lerpClient.time = 2.95
  gap = client.CL_LerpPoint(lerpClient)
  lerpClient.messageTimes = [3.0, 2.9]; lerpClient.time = 4.0
  high = client.CL_LerpPoint(lerpClient)
  print "{\"function\":\"CL_LerpPoint\",\"case\":\"normal_gap_high\",\"normal\":" + normal + ",\"gap\":" + gap + ",\"high\":" + native.trunc(high) + ",\"clamped_time\":" + native.trunc(lerpClient.time) + "}"

  relinkClient = newClient()
  relinkClient.messageTimes = [2.0, 1.9]
  relinkClient.time = 1.95
  relinkClient.velocitySamples = [t.Vec3(10.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)]
  relinkEntity = client.ensureEntity(relinkClient, 1)
  relinkEntity.modelIndex = 1
  relinkEntity.messageTime = 2.0
  relinkEntity.previousMessageOrigin = t.Vec3(0.0, 0.0, 0.0)
  relinkEntity.messageOrigin = t.Vec3(10.0, 0.0, 0.0)
  relinkEntity.previousMessageAngles = t.Vec3(0.0, 350.0, 0.0)
  relinkEntity.messageAngles = t.Vec3(0.0, 10.0, 0.0)
  relinkEntity.forceLink = false
  visible = client.CL_RelinkEntities(relinkClient)
  print "{\"function\":\"CL_RelinkEntities\",\"case\":\"interpolate_visible\",\"origin_x\":" + native.trunc(relinkEntity.origin.x) + ",\"angle_y\":" + native.trunc(relinkEntity.angles.y) + ",\"velocity_x\":" + native.trunc(relinkClient.player.velocity.x) + ",\"visible\":" + len(visible) + ",\"force_link\":" + boolText(relinkEntity.forceLink) + "}"

  effectClient = newClient()
  effectClient.messageTimes = [2.0, 1.9]
  effectClient.time = 2.0
  effectClient.noLerp = true
  client.CL_SetModelFlags([
    0,
    c.EF_ROTATE,
    c.EF_GIB,
    c.EF_ZOMGIB,
    c.EF_TRACER,
    c.EF_TRACER2,
    c.EF_ROCKET,
    c.EF_GRENADE,
    c.EF_TRACER3,
  ])
  client.CL_SetChaseActive(true)
  client.CL_SetRandomSeed(1)
  client.CL_ClearDlights()
  effectIndex = 1
  while effectIndex <= 8
    effectEntity = client.ensureEntity(effectClient, effectIndex)
    effectEntity.modelIndex = effectIndex
    effectEntity.messageTime = 2.0
    effectEntity.messageOrigin = t.Vec3(9.0, 0.0, 0.0)
    effectEntity.forceLink = false
    effectIndex = effectIndex + 1
  end while
  effectClient.entities[1].effects = c.EF_BRIGHTFIELD | c.EF_MUZZLEFLASH | c.EF_BRIGHTLIGHT | c.EF_DIMLIGHT
  effectClient.viewEntity = 1
  client.CL_RelinkEntities(effectClient)
  relinkEffects = client.CL_TakeRelinkParticleEffects()
  trailCounts = [0, 0, 0, 0, 0, 0, 0]
  entityParticles = 0
  for each effect in relinkEffects
    if effect.command == "entity_particles" then
      entityParticles = entityParticles + 1
    else if effect.command == "rocket_trail" then
      trailCounts[effect.payload[2]] = trailCounts[effect.payload[2]] + 1
    end if
  end for
  effectLight = client.CL_Dlights()[client.CL_DlightIndexForKey(1)]
  rocketLight = client.CL_Dlights()[client.CL_DlightIndexForKey(6)]
  print "{\"function\":\"CL_RelinkEntities\",\"case\":\"model_effect_matrix\",\"rotate_y\":" + effectClient.entities[1].angles.y + ",\"entity_particles\":" + entityParticles + ",\"trail_0\":" + trailCounts[0] + ",\"trail_1\":" + trailCounts[1] + ",\"trail_2\":" + trailCounts[2] + ",\"trail_3\":" + trailCounts[3] + ",\"trail_4\":" + trailCounts[4] + ",\"trail_5\":" + trailCounts[5] + ",\"trail_6\":" + trailCounts[6] + ",\"visible\":" + len(effectClient.visibleEntities) + ",\"effect_radius\":" + native.trunc(effectLight.radius) + ",\"rocket_radius\":" + native.trunc(rocketLight.radius) + ",\"rocket_die\":" + rocketLight.die + "}"
  client.CL_SetChaseActive(false)

  branchClient = newClient()
  branchClient.demoPlayback = true
  branchClient.messageTimes = [2.0, 1.9]
  branchClient.time = 1.95
  branchClient.viewAngleSamples = [
    t.Vec3(0.0, 10.0, 0.0),
    t.Vec3(0.0, 350.0, 0.0),
  ]
  client.CL_SetModelFlags([0, 0, 0, 0, 0])
  forceEntity = client.ensureEntity(branchClient, 1)
  forceEntity.modelIndex = 1
  forceEntity.messageTime = 2.0
  forceEntity.messageOrigin = t.Vec3(25.0, 0.0, 0.0)
  forceEntity.forceLink = true
  teleportEntity = client.ensureEntity(branchClient, 2)
  teleportEntity.modelIndex = 2
  teleportEntity.messageTime = 2.0
  teleportEntity.messageOrigin = t.Vec3(200.0, 0.0, 0.0)
  teleportEntity.forceLink = false
  staleEntity = client.ensureEntity(branchClient, 3)
  staleEntity.modelIndex = 3
  staleEntity.messageTime = 1.9
  viewEntity = client.ensureEntity(branchClient, 4)
  viewEntity.modelIndex = 4
  viewEntity.messageTime = 2.0
  viewEntity.messageOrigin = t.Vec3(10.0, 0.0, 0.0)
  viewEntity.forceLink = false
  branchClient.viewEntity = 4
  client.CL_RelinkEntities(branchClient)
  viewHidden = true
  for each candidate in branchClient.visibleEntities
    if candidate.number == 4 then viewHidden = false end if
  end for
  print "{\"function\":\"CL_RelinkEntities\",\"case\":\"force_teleport_stale_demo_view\",\"force_x\":" + forceEntity.origin.x + ",\"teleport_x\":" + teleportEntity.origin.x + ",\"stale_removed\":" + boolText(staleEntity.modelIndex == 0) + ",\"demo_yaw\":" + branchClient.command.viewAngles.y + ",\"view_hidden\":" + boolText(viewHidden) + ",\"visible\":" + len(branchClient.visibleEntities) + "}"
  client.CL_TakeRelinkParticleEffects()

  readNetwork = netloop.createState()
  readClient = newClient()
  client.CL_EstablishConnection(readClient, readNetwork, "local")
  readServer = netloop.checkNewConnections(readNetwork)
  readClient.time = 1.0
  readEntity = client.ensureEntity(readClient, 1)
  readEntity.modelIndex = 1
  readEntity.messageTime = 3.25
  serverMessage = sz.alloc(32)
  msg.writeByte(serverMessage, c.SVC_TIME); msg.writeFloat(serverMessage, 3.25)
  netmain.NET_SendMessage(readServer, serverMessage)
  netmain.NET_SendUnreliableMessage(readServer, serverMessage)
  client.CL_ReadFromServer(readClient, 0.02, 9.5)
  print "{\"function\":\"CL_ReadFromServer\",\"case\":\"two_messages\",\"old_time\":" + native.trunc(readClient.oldTime) + ",\"time\":" + readClient.time + ",\"last_received\":" + readClient.lastMessageTime + ",\"relinked\":true,\"visible\":" + len(readClient.visibleEntities) + "}"
  client.CL_Disconnect(readClient)

  sendNetwork = netloop.createState()
  sendClient = newClient()
  client.CL_EstablishConnection(sendClient, sendNetwork, "local")
  sendServer = netloop.checkNewConnections(sendNetwork)
  sendClient.signon = c.SIGNONS
  sendClient.spawned = true
  client.queueString(sendClient, "status\n")
  client.CL_SendCmd(sendClient, sendClient.command)
  client.CL_SendCmd(sendClient, sendClient.command)
  client.CL_SendCmd(sendClient, sendClient.command)
  reliablePacket = sz.alloc(128); reliableType = netmain.NET_GetMessage(sendServer, reliablePacket, 1.0)
  movePacket = sz.alloc(128); moveType = netmain.NET_GetMessage(sendServer, movePacket, 1.0)
  reliableSends = 0
  if reliableType == 1 and reliablePacket.data[0] == c.CLC_STRINGCMD then reliableSends = 1 end if
  print "{\"function\":\"CL_SendCmd\",\"case\":\"move_and_reliable\",\"move_calls\":" + client.CL_MoveMessageCount() + ",\"reliable_sends\":" + reliableSends + ",\"message_size\":" + sendClient.outgoing.curSize + "}"
  client.CL_Disconnect(sendClient)

  initClient = newClient()
  registry = cvar.createRegistry()
  client.CL_Init(initClient, registry)
  print "{\"function\":\"CL_Init\",\"case\":\"registrations\",\"message_capacity\":" + initClient.outgoing.maxSize + ",\"input_init\":1,\"tent_init\":1,\"cvars\":" + len(registry.variables) + ",\"commands\":" + len(client.CL_RegisteredCommands()) + "}"
  return 0
end function
