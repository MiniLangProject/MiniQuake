/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Optional backend-neutral enhanced-lighting control for MiniQuake.  The Quake
game state and classic renderer remain authoritative; this module only packs
active Protocol-15 dynamic lights for the private native GPU bridge.
*/
package miniquake.render.enhanced

import miniquake.constants as c
import miniquake.byteio as byteio
import miniquake.native as native
import miniquake.render.gl11 as gl

// Keep a bounded dynamic-light packet for the native raster backends without
// changing Quake's authoritative game state.
const MAX_ENHANCED_LIGHTS = 16
const LIGHT_FLOATS = 4
const LIGHT_BYTES = LIGHT_FLOATS * 4

enabled = false
shadowsEnabled = false
shadowQualityValue = 1
lightPacket = bytes(MAX_ENHANCED_LIGHTS * LIGHT_BYTES)
selectedLightIndexes = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
selectedLightScores = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
activeLightCount = 0

// Clamp a requested shadow quality to the stable menu/config range.
function clampShadowQuality(value)
  result = native.trunc(value)
  if result < 0 then result = 0 end if
  if result > 2 then result = 2 end if
  return result
end function

// Configure the shared native enhanced renderer while preserving Classic as
// the safe fallback if the active backend cannot create its GPU program.
function configure(requestedEnabled, requestedShadows, requestedShadowQuality)
  global enabled, shadowsEnabled, shadowQualityValue, activeLightCount
  shadowQualityValue = clampShadowQuality(requestedShadowQuality)
  shadowsEnabled = requestedShadows
  enabled = requestedEnabled and gl.enhancedAvailable()
  if not gl.enhancedConfigure(enabled, shadowsEnabled, shadowQualityValue) then enabled = false end if
  if not enabled then activeLightCount = 0 end if
  return enabled
end function

// Report whether the enhanced path is active for the current frame.
function isEnabled()
  return enabled
end function

// Report whether enhanced entity/world shadows were requested.
function shadowsActive()
  return enabled and shadowsEnabled
end function

// Return the clamped enhanced shadow-quality level.
function shadowQuality()
  return shadowQualityValue
end function

// Report whether this frame contains at least one live dynamic light.  The
// world/entity renderers use this to avoid a black additive replay.
function hasActiveLights()
  return enabled and activeLightCount > 0
end function

// Write one IEEE-754 light component without allocating a temporary byte
// array.  Native receives {world x,y,z,radius} records.
function putLightFloat(offset, value)
  byteio.putU32(lightPacket, offset, native.floatBits(value))
end function

// Select the strongest active lights, pack them into the reusable bridge
// buffer, and capture the current view matrix in the native backend.
function beginFrame(dynamicLights, currentTime, viewOrigin)
  global lightPacket, selectedLightIndexes, selectedLightScores, activeLightCount
  if not enabled then return false end if
  // Keep a descending fixed-size index set, then serialize only its populated
  // prefix into the persistent native packet.
  activeLightCount = 0
  clearIndex = 0
  while clearIndex < MAX_ENHANCED_LIGHTS
    selectedLightIndexes[clearIndex] = -1
    selectedLightScores[clearIndex] = 0.0
    clearIndex = clearIndex + 1
  end while
  index = 0
  lightLimit = c.MAX_DLIGHTS
  while index < len(dynamicLights) and index < lightLimit
    light = dynamicLights[index]
    if light is not void and light.die >= currentTime and light.radius > light.minLight and light.radius > 0.0 then
      score = light.radius
      insertAt = activeLightCount
      scan = 0
      while scan < activeLightCount
        if score > selectedLightScores[scan] then insertAt = scan; scan = activeLightCount else scan = scan + 1 end if
      end while
      if insertAt < MAX_ENHANCED_LIGHTS then
        moveIndex = activeLightCount
        if moveIndex >= MAX_ENHANCED_LIGHTS then moveIndex = MAX_ENHANCED_LIGHTS - 1 end if
        while moveIndex > insertAt
          selectedLightIndexes[moveIndex] = selectedLightIndexes[moveIndex - 1]
          selectedLightScores[moveIndex] = selectedLightScores[moveIndex - 1]
          moveIndex = moveIndex - 1
        end while
        selectedLightIndexes[insertAt] = index
        selectedLightScores[insertAt] = score
        if activeLightCount < MAX_ENHANCED_LIGHTS then activeLightCount = activeLightCount + 1 end if
      end if
    end if
    index = index + 1
  end while
  index = 0
  while index < activeLightCount
    light = dynamicLights[selectedLightIndexes[index]]
    offset = index * LIGHT_BYTES
    putLightFloat(offset, light.origin.x)
    putLightFloat(offset + 4, light.origin.y)
    putLightFloat(offset + 8, light.origin.z)
    putLightFloat(offset + 12, light.radius)
    index = index + 1
  end while
  return gl.enhancedBeginFrame(lightPacket, activeLightCount * LIGHT_BYTES)
end function

// Select the additive per-pixel draw program for following 3-D geometry.
function beginOverlay()
  if not enabled then return false end if
  gl.enhancedDrawKind(gl.ENHANCED_DRAW_OVERLAY)
  return true
end function

// Restore compatibility drawing after an enhanced geometry batch.
function endOverlay()
  gl.enhancedDrawKind(gl.ENHANCED_DRAW_NONE)
  return true
end function

// Finalize the enhanced portion of the frame before 2-D rendering begins.
function endFrame()
  if not enabled then return false end if
  gl.enhancedEndFrame()
  return true
end function
