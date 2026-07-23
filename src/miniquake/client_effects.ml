package miniquake.client_effects

import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.particles as particleSystem
import miniquake.sound.mixer as sound
import miniquake.view as view
import miniquake.console as console
import miniquake.cmd as cmd
import miniquake.client as clientRuntime

function appendParticles(current, spawned)
  return particleSystem.appendLimited(current, spawned)
end function

function safeSound(mixer, entityNumber, channelNumber, name, origin, volume, attenuation)
  if mixer is void or not mixer.enabled or name == "" then return false end if
  result = try(sound.startSound(mixer, entityNumber, channelNumber, name, origin, volume, attenuation))
  if result is error then return false end if
  return result
end function

function processTemporary(value, mixer, currentParticles, currentTemporary, currentTime)
  spawned = []
  type = value.type
  if type == c.TE_WIZSPIKE then
    spawned = particleSystem.pointEffect(value.origin, 30, 20, currentTime + 0.6)
    safeSound(mixer, -1, 0, "wizard/hit.wav", value.origin, 1.0, 1.0)
  else if type == c.TE_KNIGHTSPIKE then
    spawned = particleSystem.pointEffect(value.origin, 20, 226, currentTime + 0.6)
    safeSound(mixer, -1, 0, "hknight/hit.wav", value.origin, 1.0, 1.0)
  else if type == c.TE_SPIKE then
    spawned = particleSystem.pointEffect(value.origin, 10, 0, currentTime + 0.6)
    safeSound(mixer, -1, 0, "weapons/tink1.wav", value.origin, 1.0, 1.0)
  else if type == c.TE_SUPERSPIKE then
    spawned = particleSystem.pointEffect(value.origin, 20, 0, currentTime + 0.6)
    safeSound(mixer, -1, 0, "weapons/tink1.wav", value.origin, 1.0, 1.0)
  else if type == c.TE_GUNSHOT then
    spawned = particleSystem.pointEffect(value.origin, 20, 0, currentTime + 0.6)
  else if type == c.TE_EXPLOSION then
    spawned = particleSystem.explosion(value.origin, currentTime)
    light = clientRuntime.CL_AllocDlightAt(0, currentTime)
    light.origin = math.copy(value.origin)
    light.radius = 350.0
    light.die = currentTime + 0.5
    light.decay = 300.0
    safeSound(mixer, -1, 0, "weapons/r_exp3.wav", value.origin, 1.0, 1.0)
  else if type == c.TE_TAREXPLOSION then
    spawned = particleSystem.blobExplosion(value.origin, currentTime)
    safeSound(mixer, -1, 0, "weapons/r_exp3.wav", value.origin, 1.0, 1.0)
  else if type == c.TE_LAVASPLASH then
    spawned = particleSystem.lavaSplash(value.origin, currentTime)
  else if type == c.TE_TELEPORT then
    spawned = particleSystem.teleportSplash(value.origin, currentTime)
  else if type == c.TE_EXPLOSION2 then
    colorStart = (value.entity >> 8) & 255
    colorLength = value.entity & 255
    spawned = particleSystem.explosion2(value.origin, colorStart, colorLength, currentTime)
    light = clientRuntime.CL_AllocDlightAt(0, currentTime)
    light.origin = math.copy(value.origin)
    light.radius = 350.0
    light.die = currentTime + 0.5
    light.decay = 300.0
    safeSound(mixer, -1, 0, "weapons/r_exp3.wav", value.origin, 1.0, 1.0)
  else if type == c.TE_LIGHTNING1 or type == c.TE_LIGHTNING2 or type == c.TE_LIGHTNING3 or type == c.TE_BEAM then
    // Keep active beams as [wire payload, expiry].  The renderer draws these in
    // world space without moving their authoritative endpoints into C.
    kept = []
    for each beam in currentTemporary
      if beam[0].entity != value.entity then kept = kept + [beam] end if
    end for
    currentTemporary = kept + [[value, currentTime + 0.2]]
  end if
  currentParticles = appendParticles(currentParticles, spawned)
  return [currentParticles, currentTemporary]
end function

function pruneTemporary(currentTemporary, currentTime)
  alive = []
  for each item in currentTemporary
    if len(item) >= 2 and item[1] >= currentTime then alive = alive + [item] end if
  end for
  return alive
end function

function process(events, client, player, mixer, viewState, consoleState, commandSystem, currentParticles, currentTemporary, currentTime)
  currentTemporary = pruneTemporary(currentTemporary, currentTime)
  for each item in events
    name = item.command
    payload = item.payload
    if name == "svc_print" then
      console.append(consoleState, payload)
      print payload
    else if name == "svc_centerprint" then
      console.centerPrint(consoleState, payload, currentTime, 2.0)
    else if name == "svc_stufftext" then
      cmd.addText(commandSystem, payload)
    else if name == "svc_sound" then
      packed = payload[3]
      entityNumber = packed >> 3
      channelNumber = packed & 7
      soundIndex = payload[4]
      if soundIndex > 0 and soundIndex < len(client.soundPrecache) then
        safeSound(mixer, entityNumber, channelNumber, client.soundPrecache[soundIndex], payload[5], payload[1] / 255.0, payload[2])
      end if
    else if name == "svc_stopsound" then
      if mixer is not void then sound.stopSound(mixer, payload >> 3, payload & 7) end if
    else if name == "svc_spawnstaticsound" then
      soundIndex = payload[1]
      if soundIndex > 0 and soundIndex < len(client.soundPrecache) then
        safeSound(mixer, 0, 0, client.soundPrecache[soundIndex], payload[0], payload[2] / 255.0, payload[3] / 64.0)
      end if
    else if name == "svc_particle" then
      currentParticles = appendParticles(currentParticles, particleSystem.runEffect(payload[0], payload[1], payload[2], payload[3], currentTime + 0.6))
    else if name == "svc_damage" then
      count = payload[0] * 0.5 + payload[1] * 0.5
      direction = math.subtract(player.origin, payload[2])
      view.addDamage(viewState, count, direction, player.viewAngles, 0.6, 0.6, 0.5)
    else if name == "svc_temp_entity" then
      result = processTemporary(payload, mixer, currentParticles, currentTemporary, currentTime)
      currentParticles = result[0]
      currentTemporary = result[1]
    else if name == "svc_finale" or name == "svc_cutscene" then
      console.centerPrint(consoleState, payload, currentTime, 8.0)
    else if name == "svc_intermission" then
      console.centerPrint(consoleState, "Intermission", currentTime, 4.0)
    end if
  end for
  return [currentParticles, currentTemporary]
end function
