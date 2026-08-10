package miniquake.runtime_validation

import miniquake.types as t
import miniquake.host as host
import miniquake.world_bsp as world
import miniquake.mathlib as math

function inline append(messages, level, text)
  return messages + [level + " " + text]
end function

// Validation runs headless by design, so video-owned objects are absent.  Keep
// all report bookkeeping void-safe and return zero for intentionally omitted
// renderer data instead of dereferencing a missing renderer.
function worldFaceCount(worldModel)
  if worldModel is void then return 0 end if
  return len(worldModel.faces)
end function

function renderSurfaceCount(renderer)
  if renderer is void then return 0 end if
  return len(renderer.surfaces)
end function

function failedReport(messages, mapName, cleanShutdown)
  return t.RuntimeValidation(
    false,
    messages,
    mapName,
    0,
    false,
    0,
    0,
    0,
    0,
    0,
    0,
    1.0,
    0,
    0,
    0,
    0,
    cleanShutdown,
  )
end function

function validate(baseDirectory, gameDirectory, mapName, frameCount)
  if mapName == "" then mapName = "start" end if
  if gameDirectory == "" then gameDirectory = "id1" end if
  if frameCount < 1 then frameCount = 1 end if
  if frameCount > 1000000 then frameCount = 1000000 end if

  args = [
    "-basedir", baseDirectory,
    "-game", gameDirectory,
    "-headless",
    "-nosound",
    "+map", mapName,
  ]
  session = host.create(args)
  initialized = try(host.initialize(session))
  if initialized is error then
    messages = ["FAIL Host_Init: " + initialized.message]
    clean = host.shutdown(session)
    return failedReport(messages, mapName, clean)
  end if

  messages = []
  ok = true
  if not session.server.active then messages = append(messages, "FAIL", "server is not active"); ok = false else messages = append(messages, "OK  ", "local server active") end if
  if session.client.signon != 4 then messages = append(messages, "FAIL", "signon stopped at " + session.client.signon); ok = false else messages = append(messages, "OK  ", "protocol-15 signon reached stage 4") end if
  if not session.client.spawned then messages = append(messages, "FAIL", "local client was not spawned"); ok = false else messages = append(messages, "OK  ", "local client spawned as entity " + session.client.viewEntity) end if
  if session.server.machine is void or session.server.machine.context is void then messages = append(messages, "FAIL", "QuakeC runtime context missing"); ok = false else messages = append(messages, "OK  ", "QuakeC runtime initialized") end if

  faceCount = worldFaceCount(session.server.worldModel)
  if session.server.worldModel is void then
    messages = append(messages, "FAIL", "world BSP missing")
    ok = false
  else
    messages = append(messages, "OK  ", "world BSP faces=" + faceCount)
  end if

  surfaceCount = renderSurfaceCount(session.renderer)
  if session.headless then
    if session.renderer is void then
      messages = append(messages, "OK  ", "renderer intentionally skipped in headless mode")
    else
      messages = append(messages, "WARN", "headless session created render surfaces=" + surfaceCount)
    end if
  else if session.renderer is void then
    messages = append(messages, "FAIL", "world renderer missing")
    ok = false
  else
    messages = append(messages, "OK  ", "render surfaces=" + surfaceCount)
  end if

  if len(session.server.modelPrecache) <= 1 then messages = append(messages, "FAIL", "model precache is empty"); ok = false else messages = append(messages, "OK  ", "models precached=" + (len(session.server.modelPrecache) - 1)) end if
  messages = append(messages, "OK  ", "sounds precached=" + (len(session.server.soundPrecache) - 1))
  if len(session.server.edicts) <= session.server.maxClients then messages = append(messages, "FAIL", "no map edicts were spawned"); ok = false else messages = append(messages, "OK  ", "edicts=" + len(session.server.edicts)) end if

  traceFraction = 1.0
  if session.server.worldModel is not void then
    below = math.subtract(session.player.origin, t.Vec3(0.0, 0.0, 256.0))
    trace = try(world.tracePlayer(session.server.worldModel, session.player.origin, below))
    if trace is error then
      messages = append(messages, "FAIL", "spawn collision trace: " + trace.message)
      ok = false
    else
      traceFraction = trace.fraction
      if trace.allSolid then messages = append(messages, "FAIL", "spawn point is all-solid"); ok = false else messages = append(messages, "OK  ", "spawn collision trace fraction=" + trace.fraction) end if
    end if
  end if

  warmup = 0
  while warmup < 16
    host.frame(session, 0.02)
    warmup = warmup + 1
  end while
  gc_collect()
  liveBefore = heap_count()
  bytesBefore = heap_bytes_used()
  simulatedBefore = session.simulatedFrames
  index = 0
  while index < frameCount
    host.frame(session, 0.02)
    index = index + 1
  end while
  gc_collect()
  liveAfter = heap_count()
  bytesAfter = heap_bytes_used()
  simulated = session.simulatedFrames - simulatedBefore
  if simulated < frameCount - 1 then messages = append(messages, "FAIL", "only " + simulated + " of " + frameCount + " frames simulated"); ok = false else messages = append(messages, "OK  ", "simulated frames=" + simulated) end if
  if liveAfter > liveBefore + 128 then messages = append(messages, "WARN", "live heap objects grew by " + (liveAfter - liveBefore)) else messages = append(messages, "OK  ", "live heap delta=" + (liveAfter - liveBefore)) end if
  if bytesAfter > bytesBefore + 2097152 then messages = append(messages, "WARN", "heap high-water grew by " + (bytesAfter - bytesBefore) + " bytes") else messages = append(messages, "OK  ", "heap high-water delta=" + (bytesAfter - bytesBefore) + " bytes") end if

  signon = session.client.signon
  spawned = session.client.spawned
  edicts = len(session.server.edicts)
  modelCount = len(session.server.modelPrecache)
  soundCount = len(session.server.soundPrecache)
  // faceCount and surfaceCount were captured through void-safe helpers above.
  actualMap = session.server.mapName
  cleanShutdown = host.shutdown(session)
  if not cleanShutdown then messages = append(messages, "FAIL", "Host_Shutdown failed"); ok = false else messages = append(messages, "OK  ", "clean shutdown") end if

  return t.RuntimeValidation(
    ok,
    messages,
    actualMap,
    signon,
    spawned,
    edicts,
    modelCount,
    soundCount,
    faceCount,
    surfaceCount,
    simulated,
    traceFraction,
    liveBefore,
    liveAfter,
    bytesBefore,
    bytesAfter,
    cleanShutdown,
  )
end function

function printReport(report)
  print "MiniQuake runtime validation: " + report.mapName
  for each line in report.messages
    print line
  end for
  print "summary: signon=" + report.signon + " spawned=" + report.spawned + " edicts=" + report.edicts
  print "summary: faces=" + report.worldFaces + " surfaces=" + report.renderSurfaces + " frames=" + report.simulatedFrames
  return report.ok
end function
