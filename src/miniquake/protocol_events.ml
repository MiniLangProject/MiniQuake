/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Protocol-15 transient-event and scoreboard payloads shared by the integrated
server, the direct sv_main pendant and QuakeC builtins.  These helpers retain
the C function-parameter boundaries and byte order from sv_main.c, host.c,
host_cmd.c, pr_cmds.c and r_part.c.
*/
package miniquake.protocol_events

import miniquake.types as t
import miniquake.constants as c
import miniquake.message as msg
import miniquake.native as native
import miniquake.protocol_text as protocolText

const MAX_PLAYER_NAME_BYTES = 15

// Provide c float behavior for the active subsystem.
function cFloat(value)
  return native.bitsFloat(native.floatBits(value))
end function

// Provide c float product behavior for the active subsystem.
function cFloatProduct(left, right)
  return cFloat(cFloat(left) * cFloat(right))
end function

// SV_StartParticle and SV_StartSound share the historical 16-byte preflight.
// Equality is accepted; only cursize > MAX_DATAGRAM-16 is rejected.
function canWriteTransient(buffer)
  return buffer.curSize <= c.MAX_DATAGRAM - 16
end function

// Encode and write spawn static.
function writeSpawnStatic(buffer, modelIndex, frame, colormap, skin, origin, angles)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_SPAWNSTATIC)
  msg.writeByte(buffer, modelIndex)
  msg.writeByte(buffer, frame)
  msg.writeByte(buffer, colormap)
  msg.writeByte(buffer, skin)
  msg.writeCoord(buffer, origin.x)
  msg.writeAngle(buffer, angles.x)
  msg.writeCoord(buffer, origin.y)
  msg.writeAngle(buffer, angles.y)
  msg.writeCoord(buffer, origin.z)
  msg.writeAngle(buffer, angles.z)
  return buffer.curSize - start
end function

// Encode and write static entity.
function writeStaticEntity(buffer, baseline)
  return writeSpawnStatic(
    buffer,
    baseline.modelIndex,
    baseline.frame,
    baseline.colormap,
    baseline.skin,
    baseline.origin,
    baseline.angles,
  )
end function

// Return static sound volume byte derived from the active module state.
function staticSoundVolumeByte(volume)
  // PF_ambientsound evaluates vol*255 as binary32 and then passes the result
  // to MSG_WriteByte's int parameter.  The original performs no clamping.
  return native.trunc(cFloatProduct(volume, 255.0))
end function

// Return static sound attenuation byte derived from the active module state.
function staticSoundAttenuationByte(attenuation)
  return native.trunc(cFloatProduct(attenuation, 64.0))
end function

// Encode and write static sound.
function writeStaticSound(buffer, origin, soundIndex, volume, attenuation)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_SPAWNSTATICSOUND)
  msg.writeCoord(buffer, origin.x)
  msg.writeCoord(buffer, origin.y)
  msg.writeCoord(buffer, origin.z)
  msg.writeByte(buffer, soundIndex)
  msg.writeByte(buffer, staticSoundVolumeByte(volume))
  msg.writeByte(buffer, staticSoundAttenuationByte(attenuation))
  return buffer.curSize - start
end function

// Return particle direction byte derived from the active module state.
function particleDirectionByte(value)
  result = native.trunc(cFloatProduct(value, 16.0))
  if result > 127 then result = 127 end if
  if result < -128 then result = -128 end if
  return result
end function

// Encode and write particle.
function writeParticle(buffer, origin, direction, count, color)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_PARTICLE)
  msg.writeCoord(buffer, origin.x)
  msg.writeCoord(buffer, origin.y)
  msg.writeCoord(buffer, origin.z)
  msg.writeChar(buffer, particleDirectionByte(direction.x))
  msg.writeChar(buffer, particleDirectionByte(direction.y))
  msg.writeChar(buffer, particleDirectionByte(direction.z))
  msg.writeByte(buffer, count)
  msg.writeByte(buffer, color)
  return buffer.curSize - start
end function

// R_ParseParticleEffect expands the special wire value 255 to 1024 particles.
function particleCount(wireValue)
  value = native.trunc(wireValue)
  if value == 255 then return 1024 end if
  return value
end function

// Return truncate player name derived from the active module state.
function truncatePlayerName(text)
  return protocolText.truncate(text, MAX_PLAYER_NAME_BYTES)
end function

// Encode and write update name.
function writeUpdateName(buffer, clientIndex, name)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_UPDATENAME)
  msg.writeByte(buffer, clientIndex)
  msg.writeString(buffer, name)
  return buffer.curSize - start
end function

// Encode and write update frags.
function writeUpdateFrags(buffer, clientIndex, frags)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_UPDATEFRAGS)
  msg.writeByte(buffer, clientIndex)
  // edict->v.frags is a QuakeC float passed to MSG_WriteShort(int).
  msg.writeShort(buffer, cFloat(frags))
  return buffer.curSize - start
end function

// Encode and write update colors.
function writeUpdateColors(buffer, clientIndex, colors)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_UPDATECOLORS)
  msg.writeByte(buffer, clientIndex)
  msg.writeByte(buffer, colors)
  return buffer.curSize - start
end function

// Encode and write score state.
function writeScoreState(buffer, clientIndex, name, oldFrags, colors)
  start = buffer.curSize
  writeUpdateName(buffer, clientIndex, name)
  writeUpdateFrags(buffer, clientIndex, oldFrags)
  writeUpdateColors(buffer, clientIndex, colors)
  return buffer.curSize - start
end function

// Encode and write score reset.
function writeScoreReset(buffer, clientIndex)
  return writeScoreState(buffer, clientIndex, "", 0, 0)
end function

// Encode and write disconnect.
function writeDisconnect(buffer)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_DISCONNECT)
  return buffer.curSize - start
end function

// Provide frag changed behavior for the active subsystem.
function fragChanged(oldFrags, currentFrags)
  // client_t.old_frags is int while edict->v.frags is float. C compares them
  // before converting the new float back to int. Fractional mod values thus
  // remain changed and are rebroadcast every frame, just like the original.
  return cFloat(oldFrags) != cFloat(currentFrags)
end function

// Provide stored frag behavior for the active subsystem.
function storedFrag(currentFrags)
  return native.trunc(cFloat(currentFrags))
end function
