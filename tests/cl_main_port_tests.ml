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
import miniquake.view as view
import miniquake.particles as particles
import miniquake.client_effects as clientEffects

function require(value, name)
  if value != true then return error(9860, name) end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(9861, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(9862, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function newClient()
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  result = client.create(player)
  result.localAuthoritative = false
  return result
end function

function testInitAndClear()
  localClient = newClient()
  registry = cvar.createRegistry()
  require(client.CL_Init(localClient, registry), "CL_Init")
  require(localClient.initialized, "client initialized")
  require(cvar.find(registry, "cl_shownet") is not void, "cl_shownet registered")
  require(cvar.find(registry, "cl_nolerp") is not void, "cl_nolerp registered")
  equal(cvar.variableString(registry, "_cl_name"), "player", "archived client name")

  localClient.connected = true
  localClient.signon = c.SIGNON_PRESPAWN
  localClient.levelName = "stale"
  localClient.entities = [client.createEntity(0), client.createEntity(1)]
  localClient.stats[c.STAT_HEALTH] = 100
  require(client.CL_ClearState(localClient), "CL_ClearState")
  require(localClient.connected, "clear preserves static connection")
  equal(localClient.signon, c.SIGNON_PRESPAWN, "clear preserves static signon")
  equal(localClient.levelName, "", "clear level state")
  equal(len(localClient.entities), 0, "clear entity array")
  equal(localClient.stats[c.STAT_HEALTH], 0, "clear stats")
  return true
end function

function testDynamicLights()
  client.CL_ClearDlights()
  client.CL_SetDlightTime(0.75, 1.0)
  light = client.CL_AllocDlight(17)
  light.radius = 90.0
  light.decay = 40.0
  light.die = 2.0
  same = client.CL_AllocDlight(17)
  equal(same.key, 17, "keyed allocation")
  near(same.radius, 0.0, 0.000001, "keyed allocation resets slot")
  same.radius = 90.0
  same.decay = 40.0
  same.die = 2.0
  client.CL_DecayLights()
  near(same.radius, 80.0, 0.000001, "dynamic-light decay")
  return true
end function

function testServerInfoPreservesEarlierPrint()
  localClient = newClient()
  banner = t.ProtocolEvent("svc_print", "\nMiniQuake 1.09 SERVER (protocol 15)\n")
  info = t.ProtocolEvent("svc_serverinfo", [
    c.PROTOCOL_VERSION,
    1,
    c.GAME_COOP,
    "The Slipgate Complex",
    ["maps/e1m1.bsp"],
    ["misc/h2ohit1.wav"],
  ])
  require(client.applyEvent(localClient, banner), "apply server banner")
  require(client.applyEvent(localClient, info), "apply serverinfo")
  equal(len(localClient.messages), 2, "pre-serverinfo event and title retained")
  equal(localClient.messages[0].command, "svc_print", "retained event kind")
  equal(localClient.messages[1].command, "svc_serverinfo", "serverinfo display event kind")
  equal(len(localClient.printLog), 1, "pre-serverinfo print retained")
  equal(localClient.printLog[0], banner.payload, "retained banner")
  equal(clientEffects.serverInfoLevelText(info.payload[3]), "\u0002The Slipgate Complex\n", "serverinfo title terminates line")
  return true
end function

function testLerpAndRelink()
  localClient = newClient()
  localClient.messageTimes = [2.0, 1.9]
  localClient.time = 1.95
  localClient.velocitySamples = [
    t.Vec3(10.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
  ]
  near(client.CL_LerpPoint(localClient), 0.5, 0.000001, "lerp fraction")

  entity = client.ensureEntity(localClient, 1)
  entity.modelIndex = 1
  entity.messageTime = 2.0
  entity.previousMessageOrigin = t.Vec3(0.0, 0.0, 0.0)
  entity.messageOrigin = t.Vec3(10.0, 0.0, 0.0)
  entity.previousMessageAngles = t.Vec3(0.0, 350.0, 0.0)
  entity.messageAngles = t.Vec3(0.0, 10.0, 0.0)
  entity.forceLink = false
  visible = client.CL_RelinkEntities(localClient)
  equal(len(visible), 1, "visible entity")
  near(entity.origin.x, 5.0, 0.000001, "entity origin interpolation")
  near(entity.angles.y, 360.0, 0.000001, "wrapped angle interpolation")
  near(localClient.player.velocity.x, 5.0, 0.000001, "velocity interpolation")
  localClient.demoPlayback = true
  localClient.viewAngleSamples = [
    t.Vec3(0.0, 10.0, 0.0),
    t.Vec3(0.0, 350.0, 0.0),
  ]
  client.CL_RelinkEntities(localClient)
  near(localClient.command.viewAngles.y, 360.0, 0.000001, "demo camera angle interpolation")
  localClient.demoPlayback = false

  entity.previousMessageOrigin = t.Vec3(0.0, 0.0, 0.0)
  entity.messageOrigin = t.Vec3(200.0, 0.0, 0.0)
  entity.forceLink = false
  client.CL_RelinkEntities(localClient)
  near(entity.origin.x, 200.0, 0.000001, "teleport disables interpolation")

  entity.modelIndex = 1
  entity.messageTime = 1.9
  client.CL_RelinkEntities(localClient)
  equal(entity.modelIndex, 0, "stale packet entity removed")
  return true
end function

function testChangelevelRelinkStability()
  localClient = newClient()
  iteration = 0
  while iteration < 4096
    // Recreate the allocation pattern of svc_serverinfo / CL_ClearState and
    // the first remote interpolation frames after a multiplayer changelevel.
    client.CL_ClearState(localClient)
    localClient.messageTimes = [2.0, 1.9]
    localClient.time = 1.95
    localClient.velocitySamples = [
      t.Vec3(12.0, -8.0, 4.0),
      t.Vec3(2.0, 2.0, -2.0),
    ]
    entity = client.ensureEntity(localClient, 1)
    entity.modelIndex = 1
    entity.messageTime = 2.0
    entity.previousMessageOrigin = t.Vec3(-8.0, 4.0, 16.0)
    entity.messageOrigin = t.Vec3(8.0, 12.0, 24.0)
    entity.previousMessageAngles = t.Vec3(0.0, 350.0, 0.0)
    entity.messageAngles = t.Vec3(0.0, 10.0, 0.0)
    entity.forceLink = false
    client.CL_RelinkEntities(localClient)
    require(localClient.player.velocity.x is not void, "changelevel velocity x initialized")
    require(localClient.player.velocity.y is not void, "changelevel velocity y initialized")
    require(localClient.player.velocity.z is not void, "changelevel velocity z initialized")
    require(entity.origin.x is not void, "changelevel entity origin x initialized")
    near(localClient.player.velocity.x, 7.0, 0.000001, "changelevel velocity x")
    near(localClient.player.velocity.y, -3.0, 0.000001, "changelevel velocity y")
    near(localClient.player.velocity.z, 1.0, 0.000001, "changelevel velocity z")
    near(entity.origin.x, 0.0, 0.000001, "changelevel entity origin x")
    near(
      view.V_CalcRoll(
        localClient.player.renderAngles,
        localClient.player.velocity,
        2.0,
        200.0,
      ),
      0.03,
      0.00001,
      "changelevel angle-vector roll",
    )
    iteration = iteration + 1
  end while
  return true
end function

function configureEffectEntity(localClient, number)
  entity = client.ensureEntity(localClient, number)
  entity.modelIndex = number
  entity.messageTime = 2.0
  entity.origin = t.Vec3(0.0, 0.0, 0.0)
  entity.previousMessageOrigin = t.Vec3(0.0, 0.0, 0.0)
  entity.messageOrigin = t.Vec3(9.0, 0.0, 0.0)
  entity.previousMessageAngles = t.Vec3(0.0, 0.0, 0.0)
  entity.messageAngles = t.Vec3(0.0, 0.0, 0.0)
  entity.forceLink = false
  return entity
end function

function testRelinkModelEffects()
  localClient = newClient()
  localClient.messageTimes = [2.0, 1.9]
  localClient.time = 2.0
  localClient.noLerp = true
  modelFlags = [
    0,
    c.EF_ROTATE,
    c.EF_GIB,
    c.EF_ZOMGIB,
    c.EF_TRACER,
    c.EF_TRACER2,
    c.EF_ROCKET,
    c.EF_GRENADE,
    c.EF_TRACER3,
  ]
  client.CL_SetModelFlags(modelFlags)
  client.CL_SetChaseActive(true)
  client.CL_SetRandomSeed(1)
  client.CL_ClearDlights()

  rotating = configureEffectEntity(localClient, 1)
  rotating.effects = c.EF_BRIGHTFIELD | c.EF_MUZZLEFLASH | c.EF_BRIGHTLIGHT | c.EF_DIMLIGHT
  number = 2
  while number <= 8
    configureEffectEntity(localClient, number)
    number = number + 1
  end while
  localClient.viewEntity = 1

  visible = client.CL_RelinkEntities(localClient)
  equal(len(visible), 8, "chase includes view entity")
  near(rotating.angles.y, 199.9951171875, 0.000001, "EF_ROTATE binary-object yaw")
  effects = client.CL_TakeRelinkParticleEffects()
  equal(len(effects), 8, "brightfield plus seven model trails")
  equal(effects[0].command, "entity_particles", "EF_BRIGHTFIELD event")
  expectedTrailTypes = [2, 4, 3, 5, 0, 1, 6]
  index = 0
  while index < len(expectedTrailTypes)
    equal(effects[index + 1].command, "rocket_trail", "model trail event")
    equal(effects[index + 1].payload[2], expectedTrailTypes[index], "model trail type")
    index = index + 1
  end while
  rocketLight = client.CL_Dlights()[client.CL_DlightIndexForKey(6)]
  near(rocketLight.origin.x, 9.0, 0.000001, "rocket dlight origin")
  near(rocketLight.radius, 200.0, 0.000001, "rocket dlight radius")
  near(rocketLight.die, 2.01, 0.000001, "rocket dlight lifetime")

  client.CL_SetChaseActive(false)
  client.CL_RelinkEntities(localClient)
  equal(len(localClient.visibleEntities), 7, "first-person hides view entity")
  client.CL_TakeRelinkParticleEffects()

  // The integrated host supplies the existing active pool so rand() calls
  // from brightfields, dlights and trails stay interleaved in entity order.
  client.CL_SetRandomSeed(1)
  number = 1
  while number <= 8
    localClient.entities[number].origin = t.Vec3(0.0, 0.0, 0.0)
    number = number + 1
  end while
  client.CL_BeginRelinkParticles([])
  client.CL_RelinkEntities(localClient)
  integrated = client.CL_EndRelinkParticles()
  require(len(integrated) > particles.NUM_VERTEX_NORMALS, "integrated relink emitted brightfield and trails")
  equal(len(client.CL_TakeRelinkParticleEffects()), 0, "integrated effects are not deferred")
  return true
end function

function testDemoAndEntityCommands()
  commands = cmd.create()
  advanced = client.CL_NextDemo(commands, ["demo1", "demo2"], 0)
  require(advanced[0], "next demo queued")
  equal(advanced[1], 1, "next demonum")
  equal(commands.text, "playdemo demo1\n", "playdemo insertion")
  disabled = client.CL_NextDemo(commands, [], 0)
  equal(disabled[1], -1, "empty demo loop disabled")

  localClient = newClient()
  localClient.modelPrecache = ["", "progs/player.mdl"]
  entity = client.ensureEntity(localClient, 1)
  entity.modelIndex = 1
  lines = client.CL_PrintEntities_f(localClient)
  equal(len(lines), 2, "entity diagnostics line count")
  require(client.SetPal(2) == false, "compiled-out SetPal")
  return true
end function

function testConnectionReadSendDisconnect()
  network = netloop.createState()
  localClient = newClient()
  connected = try(client.CL_EstablishConnection(localClient, network, "local"))
  require(connected is not error, "establish loop connection")
  serverSocket = netloop.checkNewConnections(network)
  require(serverSocket is not void, "loop server endpoint")

  localClient.signon = c.SIGNON_SERVERINFO
  require(client.CL_SignonReply(localClient), "stage-one signon reply")
  incoming = sz.alloc(128)
  equal(netmain.NET_GetMessage(serverSocket, incoming, 1.0), 1, "server receives prespawn")
  equal(incoming.data[0], c.CLC_STRINGCMD, "prespawn is string command")

  localClient.signon = c.SIGNONS
  localClient.spawned = true
  client.queueString(localClient, "status\n")
  sendResult = client.CL_SendCmd(localClient, localClient.command)
  equal(sendResult, 1, "CL_SendCmd sends reliable tail")
  sz.clear(incoming)
  equal(netmain.NET_GetMessage(serverSocket, incoming, 1.0), 1, "server receives reliable command")
  equal(incoming.data[0], c.CLC_STRINGCMD, "reliable command opcode")

  serverMessage = sz.alloc(32)
  msg.writeByte(serverMessage, c.SVC_TIME)
  msg.writeFloat(serverMessage, 3.25)
  equal(netmain.NET_SendMessage(serverSocket, serverMessage), 1, "server queues time message")
  equal(client.CL_ReadFromServer(localClient, 0.02, 9.5), 0, "CL_ReadFromServer")
  near(localClient.serverTime, 3.25, 0.000001, "server message time")
  near(localClient.lastMessageTime, 9.5, 0.000001, "realtime receive stamp")

  require(client.CL_Disconnect_f(localClient), "disconnect command")
  require(not localClient.connected, "disconnect clears state")
  equal(localClient.signon, c.SIGNON_NONE, "disconnect clears signon")
  return true
end function

function main(args)
  print "MiniQuake cl_main port tests starting: 8"
  result = try(testInitAndClear())
  if result is error then print "FAIL init/clear: " + result.message; return 1 end if
  print "[1/8] CL_Init / CL_ClearState"
  result = try(testDynamicLights())
  if result is error then print "FAIL dlights: " + result.message; return 1 end if
  print "[2/8] alloc / decay semantics"
  result = try(testServerInfoPreservesEarlierPrint())
  if result is error then print "FAIL serverinfo print retention: " + result.message; return 1 end if
  print "[3/8] serverinfo retains earlier print"
  result = try(testLerpAndRelink())
  if result is error then print "FAIL lerp/relink: " + result.message; return 1 end if
  print "[4/8] lerp / relink"
  result = try(testChangelevelRelinkStability())
  if result is error then print "FAIL changelevel relink stability: " + result.message; return 1 end if
  print "[5/8] changelevel relink allocation stability"
  result = try(testDemoAndEntityCommands())
  if result is error then print "FAIL commands: " + result.message; return 1 end if
  print "[6/8] nextdemo / entities / SetPal"
  result = try(testRelinkModelEffects())
  if result is error then print "FAIL relink model effects: " + result.message; return 1 end if
  print "[7/8] rotate / brightfield / trails / rocket light / chase"
  result = try(testConnectionReadSendDisconnect())
  if result is error then print "FAIL lifecycle: " + result.message; return 1 end if
  print "[8/8] connect / signon / read / send / disconnect"
  print "MiniQuake cl_main port tests passed: 8"
  return 0
end function
