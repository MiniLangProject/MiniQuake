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

const TEMP_KIND_POINT = 1
const TEMP_KIND_BEAM = 2
const TEMP_KIND_EXPLOSION2 = 3
const MAX_BEAMS = 24

// Provide c float behavior for the active subsystem.
function cFloat(value)
  return native.bitsFloat(native.floatBits(value))
end function

// Provide c float product behavior for the active subsystem.
function cFloatProduct(left, right)
  return cFloat(cFloat(left) * cFloat(right))
end function

// Return sound attenuation byte derived from the active module state.
function soundAttenuationByte(attenuation)
  return native.trunc(cFloatProduct(attenuation, 64.0))
end function

// SV_StartSound computes origin + 0.5 * (mins + maxs), then converts the
// result to MSG_WriteCoord's float parameter.  Keep both binary32 boundaries
// explicit rather than allowing MiniLang's wider arithmetic to leak into the
// Protocol-15 coordinate.
function soundCenterComponent(origin, minimum, maximum)
  bounds = cFloat(cFloat(minimum) + cFloat(maximum))
  return cFloat(cFloat(origin) + 0.5 * bounds)
end function

// Provide sound center behavior for the active subsystem.
function soundCenter(origin, minimum, maximum)
  return t.Vec3(
    soundCenterComponent(origin.x, minimum.x, maximum.x),
    soundCenterComponent(origin.y, minimum.y, maximum.y),
    soundCenterComponent(origin.z, minimum.z, maximum.z),
  )
end function

// Provide sound field mask behavior for the active subsystem.
function soundFieldMask(volume, attenuation)
  mask = 0
  if native.trunc(volume) != 255 then mask = mask | c.SND_VOLUME end if
  if cFloat(attenuation) != 1.0 then mask = mask | c.SND_ATTENUATION end if
  return mask
end function

// Return dynamic sound wire size derived from the active module state.
function dynamicSoundWireSize(volume, attenuation)
  mask = soundFieldMask(volume, attenuation)
  size = 11
  if (mask & c.SND_VOLUME) != 0 then size = size + 1 end if
  if (mask & c.SND_ATTENUATION) != 0 then size = size + 1 end if
  return size
end function

// WinQuake reserves a conservative 16-byte tail before looking up the sound.
// Equality is accepted; only cursize > MAX_DATAGRAM-16 drops the event.
function inline canWriteDynamicSound(buffer)
  return buffer.curSize <= c.MAX_DATAGRAM - 16
end function

// Provide pack sound channel behavior for the active subsystem.
function packSoundChannel(entityNumber, channel)
  return (native.trunc(entityNumber) << 3) | (native.trunc(channel) & 7)
end function

// Report whether is point type.
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

// Report whether is beam type.
function isBeamType(type)
  value = native.trunc(type)
  return value == c.TE_LIGHTNING1 or
    value == c.TE_LIGHTNING2 or
    value == c.TE_LIGHTNING3 or
    value == c.TE_BEAM
end function

// Provide temp kind behavior for the active subsystem.
function tempKind(type)
  if isPointType(type) then return TEMP_KIND_POINT end if
  if isBeamType(type) then return TEMP_KIND_BEAM end if
  if native.trunc(type) == c.TE_EXPLOSION2 then return TEMP_KIND_EXPLOSION2 end if
  return error(2880, "CL_ParseTEnt: bad type " + native.trunc(type))
end function

// Return temp wire size derived from the active module state.
function tempWireSize(type)
  kind = tempKind(type)
  if kind == TEMP_KIND_POINT then return 8 end if
  if kind == TEMP_KIND_BEAM then return 16 end if
  return 10
end function

// Encode and write point.
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

// Encode and write beam.
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

// Encode and write explosion2.
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

// Encode and write stop sound.
function writeStopSound(buffer, entityNumber, channel)
  start = buffer.curSize
  msg.writeByte(buffer, c.SVC_STOPSOUND)
  msg.writeShort(buffer, packSoundChannel(entityNumber, channel))
  return buffer.curSize - start
end function

// Provide sound entity behavior for the active subsystem.
function soundEntity(packedChannel)
  return native.trunc(packedChannel) >> 3
end function

// Provide sound channel behavior for the active subsystem.
function soundChannel(packedChannel)
  return native.trunc(packedChannel) & 7
end function

// PF_sound receives QuakeC floats.  The multiplication by 255 is performed as
// binary32 before assignment to C int.
function quakeCSoundChannel(value)
  return native.trunc(cFloat(value))
end function

// Return quake csound volume byte derived from the active module state.
function quakeCSoundVolumeByte(value)
  return native.trunc(cFloatProduct(value, 255.0))
end function

// Provide quake csound attenuation behavior for the active subsystem.
function quakeCSoundAttenuation(value)
  return cFloat(value)
end function

// CL_ParseStartSoundPacket stores attenuation as float and S_StartSound takes
// float volume/attenuation parameters.  Explicit binary32 conversion prevents
// MiniLang's wider numeric representation from changing mixer state.
function clientSoundVolume(volumeByte)
  return cFloat(native.trunc(volumeByte) / 255.0)
end function

// Provide client sound attenuation behavior for the active subsystem.
function clientSoundAttenuation(attenuationByte)
  return cFloat(native.trunc(attenuationByte) / 64.0)
end function

// Provide static sound volume behavior for the active subsystem.
function staticSoundVolume(volumeByte)
  // The original S_StaticSound receives the raw byte as its master volume.
  // MiniQuake stores MixerChannel.volume normalized and multiplies by 255 in
  // channelVolumes, so normalize at this adapter boundary to preserve the
  // same effective integer master volume.
  return cFloat(native.trunc(volumeByte) / 255.0)
end function

// Provide static sound attenuation behavior for the active subsystem.
function staticSoundAttenuation(attenuationByte)
  return cFloat(native.trunc(attenuationByte))
end function

// beam_t.endtime and dlight_t.die are C floats while cl.time is double.
function beamEndTime(currentTime)
  return cFloat(currentTime + 0.2)
end function

// Provide dynamic light die time behavior for the active subsystem.
function dynamicLightDieTime(currentTime)
  return cFloat(currentTime + 0.5)
end function

// Provide beam alive behavior for the active subsystem.
function beamAlive(endTime, currentTime)
  return cFloat(endTime) >= currentTime
end function

// Return only the records that CL_UpdateTEnts would draw at currentTime.  This
// is deliberately a view over the compact beam state: expired records remain
// in the retained fixed-slot state so CL_ParseBeam can still find a previous
// entity in pass one, exactly like the original cl_beams[MAX_BEAMS] array.
function activeCompactBeamList(beams, currentTime)
  active = []
  for each item in normalizeCompactBeamList(beams)
    if beamAlive(item[1], currentTime) then active = active + [item] end if
  end for
  return active
end function

// The integrated renderer stores compact records instead of beam_t objects.
// Each record is [wirePayload, endTime, originalSlot].  Retain expired records
// until their slot is reused: CL_ParseBeam first replaces the same entity even
// when that beam has expired, and only then searches the first free/expired
// slot in the fixed 24-entry pool.
function compactBeamSlot(record, fallback)
  if record is not void and len(record) >= 3 then
    slot = native.trunc(record[2])
    if slot >= 0 and slot < MAX_BEAMS then return slot end if
  end if
  return fallback
end function

// Provide compact beam slot taken behavior for the active subsystem.
function compactBeamSlotTaken(beams, slot)
  for each item in beams
    if len(item) >= 3 and native.trunc(item[2]) == slot then return true end if
  end for
  return false
end function

// Return first unused compact beam slot for the active module state.
function firstUnusedCompactBeamSlot(beams)
  slot = 0
  while slot < MAX_BEAMS
    if not compactBeamSlotTaken(beams, slot) then return slot end if
    slot = slot + 1
  end while
  return -1
end function

// Add state for insert compact beam by slot.
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

// Convert compact beam list into its canonical representation.
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

// Provide compact beam index for slot behavior for the active subsystem.
function compactBeamIndexForSlot(beams, slot)
  index = 0
  while index < len(beams)
    if len(beams[index]) >= 3 and native.trunc(beams[index][2]) == slot then return index end if
    index = index + 1
  end while
  return -1
end function

// Update module state for compact beam list result.
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

// Update module state for compact beam list.
function updateCompactBeamList(beams, value, currentTime)
  return updateCompactBeamListResult(beams, value, currentTime)[0]
end function

// Encode and write reconnect.
function writeReconnect(buffer)
  start = buffer.curSize
  msg.writeChar(buffer, c.SVC_STUFFTEXT)
  msg.writeString(buffer, "reconnect\n")
  return buffer.curSize - start
end function
