package miniquake.client_effects

import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.particles as particleSystem
import miniquake.sound.mixer as sound
import miniquake.view as view
import miniquake.console as console
import miniquake.cmd as cmd
import miniquake.client as clientRuntime
import miniquake.cvar as cvar
import miniquake.protocol_transients as transients

function appendParticles(current, spawned)
  return particleSystem.appendLimited(current, spawned)
end function

function safeSound(mixer, entityNumber, channelNumber, name, origin, volume, attenuation)
  if mixer is void or not mixer.enabled or name == "" then return false end if
  result = try(sound.startSound(mixer, entityNumber, channelNumber, name, origin, volume, attenuation))
  if result is error then return false end if
  return result
end function

// TE_SPIKE and TE_SUPERSPIKE share the engine-wide C rand() stream with the
// particle and entity-effect code.  Four out of five impacts use tink1; the
// fifth consumes a second random value to select one of the three ricochets
// (with the original 0/3 fall-through both selecting ric3).
function spikeImpactSound()
  if particleSystem.compatRand() % 5 != 0 then return "weapons/tink1.wav" end if
  random = particleSystem.compatRand() & 3
  if random == 1 then return "weapons/ric1.wav" end if
  if random == 2 then return "weapons/ric2.wav" end if
  return "weapons/ric3.wav"
end function

function processTemporary(value, mixer, currentParticles, currentTemporary, currentTime)
  spawned = []
  type = value.type
  if type == c.TE_WIZSPIKE then
    spawned = particleSystem.pointEffect(value.origin, 30, 20, currentTime)
    safeSound(mixer, -1, 0, "wizard/hit.wav", value.origin, 1.0, 1.0)
  else if type == c.TE_KNIGHTSPIKE then
    spawned = particleSystem.pointEffect(value.origin, 20, 226, currentTime)
    safeSound(mixer, -1, 0, "hknight/hit.wav", value.origin, 1.0, 1.0)
  else if type == c.TE_SPIKE then
    spawned = particleSystem.pointEffect(value.origin, 10, 0, currentTime)
    safeSound(mixer, -1, 0, spikeImpactSound(), value.origin, 1.0, 1.0)
  else if type == c.TE_SUPERSPIKE then
    spawned = particleSystem.pointEffect(value.origin, 20, 0, currentTime)
    safeSound(mixer, -1, 0, spikeImpactSound(), value.origin, 1.0, 1.0)
  else if type == c.TE_GUNSHOT then
    spawned = particleSystem.pointEffect(value.origin, 20, 0, currentTime)
  else if type == c.TE_EXPLOSION then
    spawned = particleSystem.explosion(value.origin, currentTime)
    light = clientRuntime.CL_AllocDlightAt(0, currentTime)
    light.origin = math.copy(value.origin)
    light.radius = 350.0
    light.die = transients.dynamicLightDieTime(currentTime)
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
    light.die = transients.dynamicLightDieTime(currentTime)
    light.decay = 300.0
    safeSound(mixer, -1, 0, "weapons/r_exp3.wav", value.origin, 1.0, 1.0)
  else if type == c.TE_LIGHTNING1 or type == c.TE_LIGHTNING2 or type == c.TE_LIGHTNING3 or type == c.TE_BEAM then
    // Keep active beams as [wire payload, expiry], but retain the original
    // fixed 24-slot replacement/allocation order from CL_ParseBeam.
    currentTemporary = transients.updateCompactBeamList(currentTemporary, value, currentTime)
  end if
  currentParticles = appendParticles(currentParticles, spawned)
  return [currentParticles, currentTemporary]
end function

// Retained state mirrors the original fixed cl_beams[MAX_BEAMS] array.  Expired
// entries are kept because CL_ParseBeam first searches by entity before it
// searches for a free or expired slot.
function retainTemporarySlots(currentTemporary)
  return transients.normalizeCompactBeamList(currentTemporary)
end function

// Active view mirrors CL_UpdateTEnts: an expired beam is not rendered or
// exposed to callers, while the retained state above still remembers its slot.
function pruneTemporary(currentTemporary, currentTime)
  return transients.activeCompactBeamList(currentTemporary, currentTime)
end function

function serverInfoRuleText()
  return "\n\n\u001d\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001e\u001f\n\n"
end function

function serverInfoLevelText(levelName)
  return "\u0002" + levelName + "\n"
end function

function process(events, client, player, mixer, viewState, consoleState, commandSystem, currentParticles, currentTemporary, currentTime, registry)
  currentTemporary = retainTemporarySlots(currentTemporary)
  for each item in events
    name = item.command
    payload = item.payload
    if name == "svc_print" then
      console.Con_Printf(consoleState, payload, consoleState.dedicated, false)
    else if name == "svc_serverinfo" then
      // WinQuake separates these calls so the level title receives the brown
      // alternate-font mask while the decorative rule does not.
      console.Con_Printf(consoleState, serverInfoRuleText(), consoleState.dedicated, false)
      console.Con_Printf(consoleState, serverInfoLevelText(payload[3]), consoleState.dedicated, false)
    else if name == "svc_centerprint" then
      console.centerPrint(consoleState, payload, currentTime, 2.0)
    else if name == "svc_stufftext" then
      cmd.addText(commandSystem, payload)
    else if name == "svc_sound" then
      packed = payload[3]
      entityNumber = transients.soundEntity(packed)
      channelNumber = transients.soundChannel(packed)
      soundIndex = payload[4]
      if soundIndex > 0 and soundIndex < len(client.soundPrecache) then
        safeSound(mixer, entityNumber, channelNumber, client.soundPrecache[soundIndex], payload[5], transients.clientSoundVolume(payload[1]), transients.cFloat(payload[2]))
      end if
    else if name == "svc_stopsound" then
      if mixer is not void then sound.stopSound(mixer, transients.soundEntity(payload), transients.soundChannel(payload)) end if
    else if name == "svc_spawnstaticsound" then
      soundIndex = payload[1]
      if soundIndex > 0 and soundIndex < len(client.soundPrecache) then
        if mixer is not void then sound.staticSound(mixer, client.soundPrecache[soundIndex], payload[0], transients.staticSoundVolume(payload[2]), transients.staticSoundAttenuation(payload[3])) end if
      end if
    else if name == "svc_particle" then
      currentParticles = appendParticles(currentParticles, particleSystem.runEffect(payload[0], payload[1], payload[2], payload[3], currentTime))
    else if name == "svc_damage" then
      // V_ParseDamage receives the impact source, not a pre-normalized vector.
      // Preserve the original armor/blood split because it controls both the
      // minimum kick and the damage cshift color.
      view.V_ParseDamage(
        viewState,
        payload[0],
        payload[1],
        payload[2],
        player.origin,
        player.renderAngles,
        cvar.variableValue(registry, "v_kickroll"),
        cvar.variableValue(registry, "v_kickpitch"),
        cvar.variableValue(registry, "v_kicktime"),
      )
    else if name == "svc_temp_entity" then
      result = processTemporary(payload, mixer, currentParticles, currentTemporary, currentTime)
      currentParticles = result[0]
      currentTemporary = result[1]
    else if name == "svc_finale" or name == "svc_cutscene" then
      console.centerPrint(consoleState, payload, currentTime, 8.0)
    else if name == "svc_intermission" then
      console.centerPrint(consoleState, "Intermission", currentTime, 4.0)
    else if name == "svc_setpause" then
      if mixer is not void then
        if payload != 0 then sound.pauseMusic(mixer) else sound.resumeMusic(mixer) end if
      end if
    else if name == "svc_sellscreen" then
      cmd.insertText(commandSystem, "help\n")
    end if
  end for
  return [currentParticles, currentTemporary]
end function
