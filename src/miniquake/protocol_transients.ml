/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Protocol-15 temporary-entity and dynamic-sound helpers shared by client,
server/QuakeC adapters and differential fixtures.  The conversion order is
kept at the same C int/float boundaries as WinQuake cl_tent.c, cl_parse.c,
sv_main.c and pr_cmds.c.
*/
package miniquake.protocol_transients

import miniquake.types as t
import miniquake.constants as c
import miniquake.message as msg
import miniquake.native as native

/// Defines the temp kind point value used by `miniquake.protocol_transients`.
const TEMP_KIND_POINT = 1
/// Defines the temp kind beam value used by `miniquake.protocol_transients`.
const TEMP_KIND_BEAM = 2
/// Defines the temp kind explosion2 value used by `miniquake.protocol_transients`.
const TEMP_KIND_EXPLOSION2 = 3
/// Defines the max beams value used by `miniquake.protocol_transients`.
const MAX_BEAMS = 24

/// Implements the `cFloat` operation for `miniquake.protocol_transients` (c float).
/// @param value Value consumed by `cFloat`.
function cFloat(value)
  return native.bitsFloat(native.floatBits(value))
end function

/// Implements the `cFloatProduct` operation for `miniquake.protocol_transients` (c float product).
/// @param left The left input consumed by `cFloatProduct`.
/// @param right The right input consumed by `cFloatProduct`.
function cFloatProduct(left, right)
  return cFloat(cFloat(left) * cFloat(right))
end function

/// Return sound attenuation byte derived from the active module state.
/// @param attenuation The attenuation input consumed by `soundAttenuationByte`.
function soundAttenuationByte(attenuation)
  return native.trunc(cFloatProduct(attenuation, 64.0))
end function

/// SV_StartSound computes origin + 0.5 * (mins + maxs), then converts the
/// result to MSG_WriteCoord's float parameter.  Keep both binary32 boundaries
/// explicit rather than allowing MiniLang's wider arithmetic to leak into the
/// Protocol-15 coordinate.
/// @param origin World-space origin of the operation.
/// @param minimum Smallest accepted value.
/// @param maximum Largest accepted value.
function soundCenterComponent(origin, minimum, maximum)
  bounds = cFloat(cFloat(minimum) + cFloat(maximum))
  return cFloat(cFloat(origin) + 0.5 * bounds)
end function

/// Implements the `soundCenter` operation for `miniquake.protocol_transients` (sound center).
/// @param origin World-space origin of the operation.
/// @param minimum Smallest accepted value.
/// @param maximum Largest accepted value.
function soundCenter(origin, minimum, maximum)
  return t.Vec3(
    soundCenterComponent(origin.x, minimum.x, maximum.x),
    soundCenterComponent(origin.y, minimum.y, maximum.y),
    soundCenterComponent(origin.z, minimum.z, maximum.z),
  )
end function

/// Implements the `soundFieldMask` operation for `miniquake.protocol_transients` (sound field mask).
/// @param volume The volume input consumed by `soundFieldMask`.
/// @param attenuation The attenuation input consumed by `soundFieldMask`.
function soundFieldMask(volume, attenuation)
  mask = 0
  if native.trunc(volume) != 255 then mask = mask | c.SND_VOLUME end if
  if cFloat(attenuation) != 1.0 then mask = mask | c.SND_ATTENUATION end if
  return mask
end function

/// Return dynamic sound wire size derived from the active module state.
/// @param volume The volume input consumed by `dynamicSoundWireSize`.
/// @param attenuation The attenuation input consumed by `dynamicSoundWireSize`.
function dynamicSoundWireSize(volume, attenuation)
  mask = soundFieldMask(volume, attenuation)
  size = 11
  if (mask & c.SND_VOLUME) != 0 then size = size + 1 end if
  if (mask & c.SND_ATTENUATION) != 0 then size = size + 1 end if
  return size
end function

/// WinQuake reserves a conservative 16-byte tail before looking up the sound.
/// Equality is accepted; only cursize > MAX_DATAGRAM-16 drops the event.
/// @param buffer The buffer input consumed by `canWriteDynamicSound`.
function inline canWriteDynamicSound(buffer)
  return buffer.curSize <= c.MAX_DATAGRAM - 16
end function

/// Implements the `packSoundChannel` operation for `miniquake.protocol_transients` (pack sound channel).
/// @param entityNumber The entity number input consumed by `packSoundChannel`.
/// @param channel The channel input consumed by `packSoundChannel`.
function packSoundChannel(entityNumber, channel)
  return (native.trunc(entityNumber) << 3) | (native.trunc(channel) & 7)
end function

/// Report whether is point type.
/// @param type The type input consumed by `isPointType`.
function isPointType(type)
  value = native.trunc(type)
  return value == c.TE_SPIKE or
    value == c.TE_SUPERSPIKE or
    value == c.TE_GUNSHOT or
    value == c.TE_EXPLOSION or
    value == c.TE_TAREXPLOSION or
    value == c.TE_WIZSPIKE or
    value == c.TE_KNIGHTSPIKE or
    value == c.TE_LAVASPLASH or
    value == c.TE_TELEPORT
end function

/// Report whether is beam type.
/// @param type The type input consumed by `isBeamType`.
function isBeamType(type)
  value = native.trunc(type)
  return value == c.TE_LIGHTNING1 or
    value == c.TE_LIGHTNING2 or
    value == c.TE_LIGHTNING3 or
    value == c.TE_BEAM
end function

/// Implements the `tempKind` operation for `miniquake.protocol_transients` (temp kind).
/// @param type The type input consumed by `tempKind`.
function tempKind(type)
  if isPointType(type) then return TEMP_KIND_POINT end if
  if isBeamType(type) then return TEMP_KIND_BEAM end if
  if native.trunc(type) == c.TE_EXPLOSION2 then return TEMP_KIND_EXPLOSION2 end if
  return error(2880, "CL_ParseTEnt: bad type " + native.trunc(type))
end function

/// Return temp wire size derived from the active module state.
/// @param type The type input consumed by `tempWireSize`.
function tempWireSize(type)
  kind = tempKind(type)
  if kind == TEMP_KIND_POINT then return 8 end if
  if kind == TEMP_KIND_BEAM then return 16 end if
  return 10
end function

/// Encode and write point.
/// @param buffer The buffer input consumed by `writePoint`.
/// @param type The type input consumed by `writePoint`.
/// @param origin World-space origin of the operation.
function writePoint(buffer, type, origin)
  if not isPointType(type) then return error(2881, "temporary point type required") end if
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_TEMP_ENTITY)
  msg.writeByte(buffer, type)
  msg.writeCoord(buffer, origin.x)
  msg.writeCoord(buffer, origin.y)
  msg.writeCoord(buffer, origin.z)
  return buffer.curSize - start
end function

/// Encode and write beam.
/// @param buffer The buffer input consumed by `writeBeam`.
/// @param type The type input consumed by `writeBeam`.
/// @param entityNumber The entity number input consumed by `writeBeam`.
/// @param startPosition The start position input consumed by `writeBeam`.
/// @param endPosition The end position input consumed by `writeBeam`.
function writeBeam(buffer, type, entityNumber, startPosition, endPosition)
  if not isBeamType(type) then return error(2882, "temporary beam type required") end if
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_TEMP_ENTITY)
  msg.writeByte(buffer, type)
  msg.writeShort(buffer, entityNumber)
  msg.writeCoord(buffer, startPosition.x)
  msg.writeCoord(buffer, startPosition.y)
  msg.writeCoord(buffer, startPosition.z)
  msg.writeCoord(buffer, endPosition.x)
  msg.writeCoord(buffer, endPosition.y)
  msg.writeCoord(buffer, endPosition.z)
  return buffer.curSize - start
end function

/// Encode and write explosion2.
/// @param buffer The buffer input consumed by `writeExplosion2`.
/// @param origin World-space origin of the operation.
/// @param colorStart The color start input consumed by `writeExplosion2`.
/// @param colorLength Length of the requested data in units appropriate to the operation.
function writeExplosion2(buffer, origin, colorStart, colorLength)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_TEMP_ENTITY)
  msg.writeByte(buffer, c.TE_EXPLOSION2)
  msg.writeCoord(buffer, origin.x)
  msg.writeCoord(buffer, origin.y)
  msg.writeCoord(buffer, origin.z)
  msg.writeByte(buffer, colorStart)
  msg.writeByte(buffer, colorLength)
  return buffer.curSize - start
end function

/// Encode and write stop sound.
/// @param buffer The buffer input consumed by `writeStopSound`.
/// @param entityNumber The entity number input consumed by `writeStopSound`.
/// @param channel The channel input consumed by `writeStopSound`.
function writeStopSound(buffer, entityNumber, channel)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_STOPSOUND)
  msg.writeShort(buffer, packSoundChannel(entityNumber, channel))
  return buffer.curSize - start
end function

/// Implements the `soundEntity` operation for `miniquake.protocol_transients` (sound entity).
/// @param packedChannel The packed channel input consumed by `soundEntity`.
function soundEntity(packedChannel)
  return native.trunc(packedChannel) >> 3
end function

/// Implements the `soundChannel` operation for `miniquake.protocol_transients` (sound channel).
/// @param packedChannel The packed channel input consumed by `soundChannel`.
function soundChannel(packedChannel)
  return native.trunc(packedChannel) & 7
end function

/// PF_sound receives QuakeC floats.  The multiplication by 255 is performed as
/// binary32 before assignment to C int.
/// @param value Value consumed by `quakeCSoundChannel`.
function quakeCSoundChannel(value)
  return native.trunc(cFloat(value))
end function

/// Return quake csound volume byte derived from the active module state.
/// @param value Value consumed by `quakeCSoundVolumeByte`.
function quakeCSoundVolumeByte(value)
  return native.trunc(cFloatProduct(value, 255.0))
end function

/// Implements the `quakeCSoundAttenuation` operation for `miniquake.protocol_transients` (quake c sound attenuation).
/// @param value Value consumed by `quakeCSoundAttenuation`.
function quakeCSoundAttenuation(value)
  return cFloat(value)
end function

/// CL_ParseStartSoundPacket stores attenuation as float and S_StartSound takes
/// float volume/attenuation parameters.  Explicit binary32 conversion prevents
/// MiniLang's wider numeric representation from changing mixer state.
/// @param volumeByte The volume byte input consumed by `clientSoundVolume`.
function clientSoundVolume(volumeByte)
  return cFloat(native.trunc(volumeByte) / 255.0)
end function

/// Implements the `clientSoundAttenuation` operation for `miniquake.protocol_transients` (client sound attenuation).
/// @param attenuationByte The attenuation byte input consumed by `clientSoundAttenuation`.
function clientSoundAttenuation(attenuationByte)
  return cFloat(native.trunc(attenuationByte) / 64.0)
end function

/// Implements the `staticSoundVolume` operation for `miniquake.protocol_transients` (static sound volume).
/// @param volumeByte The volume byte input consumed by `staticSoundVolume`.
function staticSoundVolume(volumeByte)
  // The original S_StaticSound receives the raw byte as its master volume.
  // MiniQuake stores MixerChannel.volume normalized and multiplies by 255 in
  // channelVolumes, so normalize at this adapter boundary to preserve the
  // same effective integer master volume.
  return cFloat(native.trunc(volumeByte) / 255.0)
end function

/// Implements the `staticSoundAttenuation` operation for `miniquake.protocol_transients` (static sound attenuation).
/// @param attenuationByte The attenuation byte input consumed by `staticSoundAttenuation`.
function staticSoundAttenuation(attenuationByte)
  return cFloat(native.trunc(attenuationByte))
end function

/// beam_t.endtime and dlight_t.die are C floats while cl.time is double.
/// @param currentTime Time value used by the operation.
function beamEndTime(currentTime)
  return cFloat(currentTime + 0.2)
end function

/// Implements the `dynamicLightDieTime` operation for `miniquake.protocol_transients` (dynamic light die time).
/// @param currentTime Time value used by the operation.
function dynamicLightDieTime(currentTime)
  return cFloat(currentTime + 0.5)
end function

/// Implements the `beamAlive` operation for `miniquake.protocol_transients` (beam alive).
/// @param endTime Time value used by the operation.
/// @param currentTime Time value used by the operation.
function beamAlive(endTime, currentTime)
  return cFloat(endTime) >= currentTime
end function

/// Return only the records that CL_UpdateTEnts would draw at currentTime.  This
/// is deliberately a view over the compact beam state: expired records remain
/// in the retained fixed-slot state so CL_ParseBeam can still find a previous
/// entity in pass one, exactly like the original cl_beams[MAX_BEAMS] array.
/// @param beams The beams input consumed by `activeCompactBeamList`.
/// @param currentTime Time value used by the operation.
function activeCompactBeamList(beams, currentTime)
  active = []
  for each item in normalizeCompactBeamList(beams)
    if beamAlive(item[1], currentTime) then active = active + [item] end if
  end for
  return active
end function

/// The integrated renderer stores compact records instead of beam_t objects.
/// Each record is [wirePayload, endTime, originalSlot].  Retain expired records
/// until their slot is reused: CL_ParseBeam first replaces the same entity even
/// when that beam has expired, and only then searches the first free/expired
/// slot in the fixed 24-entry pool.
/// @param record The record input consumed by `compactBeamSlot`.
/// @param fallback Value to use when the requested input is unavailable or invalid.
function compactBeamSlot(record, fallback)
  if record is not void and len(record) >= 3 then
    slot = native.trunc(record[2])
    if slot >= 0 and slot < MAX_BEAMS then return slot end if
  end if
  return fallback
end function

/// Implements the `compactBeamSlotTaken` operation for `miniquake.protocol_transients` (compact beam slot taken).
/// @param beams The beams input consumed by `compactBeamSlotTaken`.
/// @param slot The slot input consumed by `compactBeamSlotTaken`.
function compactBeamSlotTaken(beams, slot)
  for each item in beams
    if len(item) >= 3 and native.trunc(item[2]) == slot then return true end if
  end for
  return false
end function

/// Return first unused compact beam slot for the active module state.
/// @param beams The beams input consumed by `firstUnusedCompactBeamSlot`.
function firstUnusedCompactBeamSlot(beams)
  slot = 0
  while slot < MAX_BEAMS
    if not compactBeamSlotTaken(beams, slot) then return slot end if
    slot = slot + 1
  end while
  return -1
end function

/// Add state for insert compact beam by slot.
/// @param beams The beams input consumed by `insertCompactBeamBySlot`.
/// @param record The record input consumed by `insertCompactBeamBySlot`.
function insertCompactBeamBySlot(beams, record)
  result = []
  inserted = false
  targetSlot = native.trunc(record[2])
  for each item in beams
    if not inserted and targetSlot < native.trunc(item[2]) then
      result = result + [record]
      inserted = true
    end if
    result = result + [item]
  end for
  if not inserted then result = result + [record] end if
  return result
end function

/// Convert compact beam list into its canonical representation.
/// @param beams The beams input consumed by `normalizeCompactBeamList`.
function normalizeCompactBeamList(beams)
  normalized = []
  fallback = 0
  for each item in beams
    if item is not void and len(item) >= 2 and item[0] is not void then
      slot = compactBeamSlot(item, fallback)
      if slot < 0 or slot >= MAX_BEAMS or compactBeamSlotTaken(normalized, slot) then
        slot = firstUnusedCompactBeamSlot(normalized)
      end if
      if slot >= 0 then
        normalized = insertCompactBeamBySlot(normalized, [item[0], cFloat(item[1]), slot])
      end if
    end if
    fallback = fallback + 1
  end for
  return normalized
end function

/// Implements the `compactBeamIndexForSlot` operation for `miniquake.protocol_transients` (compact beam index for slot).
/// @param beams The beams input consumed by `compactBeamIndexForSlot`.
/// @param slot The slot input consumed by `compactBeamIndexForSlot`.
function compactBeamIndexForSlot(beams, slot)
  index = 0
  while index < len(beams)
    if len(beams[index]) >= 3 and native.trunc(beams[index][2]) == slot then return index end if
    index = index + 1
  end while
  return -1
end function

/// Update module state for compact beam list result.
/// @param beams The beams input consumed by `updateCompactBeamListResult`.
/// @param value Value consumed by `updateCompactBeamListResult`.
/// @param currentTime Time value used by the operation.
function updateCompactBeamListResult(beams, value, currentTime)
  normalized = normalizeCompactBeamList(beams)
  expiry = beamEndTime(currentTime)

  // CL_ParseBeam pass one: the same entity owns its previous slot even when
  // the previous beam has already expired.
  index = 0
  while index < len(normalized)
    item = normalized[index]
    if item[0].entity == value.entity then
      slot = native.trunc(item[2])
      normalized[index] = [value, expiry, slot]
      return [normalized, true, slot]
    end if
    index = index + 1
  end while

  // CL_ParseBeam pass two: choose the lowest missing or strictly expired slot.
  slot = 0
  while slot < MAX_BEAMS
    recordIndex = compactBeamIndexForSlot(normalized, slot)
    if recordIndex < 0 then
      normalized = insertCompactBeamBySlot(normalized, [value, expiry, slot])
      return [normalized, true, slot]
    end if
    if not beamAlive(normalized[recordIndex][1], currentTime) then
      normalized[recordIndex] = [value, expiry, slot]
      return [normalized, true, slot]
    end if
    slot = slot + 1
  end while

  // The full cl_tent pendant emits "beam list overflow!".  The integrated
  // path has no console dependency here, so report rejection to fixtures and
  // leave the fixed pool unchanged.
  return [normalized, false, -1]
end function

/// Update module state for compact beam list.
/// @param beams The beams input consumed by `updateCompactBeamList`.
/// @param value Value consumed by `updateCompactBeamList`.
/// @param currentTime Time value used by the operation.
function updateCompactBeamList(beams, value, currentTime)
  return updateCompactBeamListResult(beams, value, currentTime)[0]
end function

/// Encode and write reconnect.
/// @param buffer The buffer input consumed by `writeReconnect`.
function writeReconnect(buffer)
  start = buffer.curSize
  msg.writeChar(buffer, c.SVC_STUFFTEXT)
  msg.writeString(buffer, "reconnect\n")
  return buffer.curSize - start
end function
