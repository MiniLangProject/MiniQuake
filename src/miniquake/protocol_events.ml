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

/// Defines the max player name bytes value used by `miniquake.protocol_events`.
const MAX_PLAYER_NAME_BYTES = 15

/// Implements the `cFloat` operation for `miniquake.protocol_events` (c float).
/// @param value Value consumed by `cFloat`.
function cFloat(value)
  return native.bitsFloat(native.floatBits(value))
end function

/// Implements the `cFloatProduct` operation for `miniquake.protocol_events` (c float product).
/// @param left The left input consumed by `cFloatProduct`.
/// @param right The right input consumed by `cFloatProduct`.
function cFloatProduct(left, right)
  return cFloat(cFloat(left) * cFloat(right))
end function

/// SV_StartParticle and SV_StartSound share the historical 16-byte preflight.
/// Equality is accepted; only cursize > MAX_DATAGRAM-16 is rejected.
/// @param buffer The buffer input consumed by `canWriteTransient`.
function canWriteTransient(buffer)
  return buffer.curSize <= c.MAX_DATAGRAM - 16
end function

/// Encode and write spawn static.
/// @param buffer The buffer input consumed by `writeSpawnStatic`.
/// @param modelIndex Zero-based index of the requested entry.
/// @param frame The frame input consumed by `writeSpawnStatic`.
/// @param colormap The colormap input consumed by `writeSpawnStatic`.
/// @param skin The skin input consumed by `writeSpawnStatic`.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
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

/// Encode and write static entity.
/// @param buffer The buffer input consumed by `writeStaticEntity`.
/// @param baseline The baseline input consumed by `writeStaticEntity`.
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

/// Return static sound volume byte derived from the active module state.
/// @param volume The volume input consumed by `staticSoundVolumeByte`.
function staticSoundVolumeByte(volume)
  // PF_ambientsound evaluates vol*255 as binary32 and then passes the result
  // to MSG_WriteByte's int parameter.  The original performs no clamping.
  return native.trunc(cFloatProduct(volume, 255.0))
end function

/// Return static sound attenuation byte derived from the active module state.
/// @param attenuation The attenuation input consumed by `staticSoundAttenuationByte`.
function staticSoundAttenuationByte(attenuation)
  return native.trunc(cFloatProduct(attenuation, 64.0))
end function

/// Encode and write static sound.
/// @param buffer The buffer input consumed by `writeStaticSound`.
/// @param origin World-space origin of the operation.
/// @param soundIndex Zero-based index of the requested entry.
/// @param volume The volume input consumed by `writeStaticSound`.
/// @param attenuation The attenuation input consumed by `writeStaticSound`.
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

/// Return particle direction byte derived from the active module state.
/// @param value Value consumed by `particleDirectionByte`.
function particleDirectionByte(value)
  result = native.trunc(cFloatProduct(value, 16.0))
  if result > 127 then result = 127 end if
  if result < -128 then result = -128 end if
  return result
end function

/// Encode and write particle.
/// @param buffer The buffer input consumed by `writeParticle`.
/// @param origin World-space origin of the operation.
/// @param direction The direction input consumed by `writeParticle`.
/// @param count Number of entries or units to process.
/// @param color Color value used by the operation.
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

/// R_ParseParticleEffect expands the special wire value 255 to 1024 particles.
/// @param wireValue The wire value input consumed by `particleCount`.
function particleCount(wireValue)
  value = native.trunc(wireValue)
  if value == 255 then return 1024 end if
  return value
end function

/// Return truncate player name derived from the active module state.
/// @param text Text to parse or process.
function truncatePlayerName(text)
  return protocolText.truncate(text, MAX_PLAYER_NAME_BYTES)
end function

/// Encode and write update name.
/// @param buffer The buffer input consumed by `writeUpdateName`.
/// @param clientIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
function writeUpdateName(buffer, clientIndex, name)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_UPDATENAME)
  msg.writeByte(buffer, clientIndex)
  msg.writeString(buffer, name)
  return buffer.curSize - start
end function

/// Encode and write update frags.
/// @param buffer The buffer input consumed by `writeUpdateFrags`.
/// @param clientIndex Zero-based index of the requested entry.
/// @param frags The frags input consumed by `writeUpdateFrags`.
function writeUpdateFrags(buffer, clientIndex, frags)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_UPDATEFRAGS)
  msg.writeByte(buffer, clientIndex)
  // edict->v.frags is a QuakeC float passed to MSG_WriteShort(int).
  msg.writeShort(buffer, cFloat(frags))
  return buffer.curSize - start
end function

/// Encode and write update colors.
/// @param buffer The buffer input consumed by `writeUpdateColors`.
/// @param clientIndex Zero-based index of the requested entry.
/// @param colors The colors input consumed by `writeUpdateColors`.
function writeUpdateColors(buffer, clientIndex, colors)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_UPDATECOLORS)
  msg.writeByte(buffer, clientIndex)
  msg.writeByte(buffer, colors)
  return buffer.curSize - start
end function

/// Encode and write score state.
/// @param buffer The buffer input consumed by `writeScoreState`.
/// @param clientIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
/// @param oldFrags The old frags input consumed by `writeScoreState`.
/// @param colors The colors input consumed by `writeScoreState`.
function writeScoreState(buffer, clientIndex, name, oldFrags, colors)
  start = buffer.curSize
  writeUpdateName(buffer, clientIndex, name)
  writeUpdateFrags(buffer, clientIndex, oldFrags)
  writeUpdateColors(buffer, clientIndex, colors)
  return buffer.curSize - start
end function

/// Encode and write score reset.
/// @param buffer The buffer input consumed by `writeScoreReset`.
/// @param clientIndex Zero-based index of the requested entry.
function writeScoreReset(buffer, clientIndex)
  return writeScoreState(buffer, clientIndex, "", 0, 0)
end function

/// Encode and write disconnect.
/// @param buffer The buffer input consumed by `writeDisconnect`.
function writeDisconnect(buffer)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_DISCONNECT)
  return buffer.curSize - start
end function

/// Implements the `fragChanged` operation for `miniquake.protocol_events` (frag changed).
/// @param oldFrags The old frags input consumed by `fragChanged`.
/// @param currentFrags The current frags input consumed by `fragChanged`.
function fragChanged(oldFrags, currentFrags)
  // client_t.old_frags is int while edict->v.frags is float. C compares them
  // before converting the new float back to int. Fractional mod values thus
  // remain changed and are rebroadcast every frame, just like the original.
  return cFloat(oldFrags) != cFloat(currentFrags)
end function

/// Implements the `storedFrag` operation for `miniquake.protocol_events` (stored frag).
/// @param currentFrags The current frags input consumed by `storedFrag`.
function storedFrag(currentFrags)
  return native.trunc(cFloat(currentFrags))
end function
