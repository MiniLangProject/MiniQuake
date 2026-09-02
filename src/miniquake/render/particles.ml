/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniQuake fixed-function particle drawing and particle-texture bridge.
*/
package miniquake.render.particles

import miniquake.types as t
import miniquake.mathlib as math
import miniquake.render.gl11 as gl
import miniquake.native as native

/// Tracks the module-level particle texture state owned by `miniquake.render.particles`.
particleTexture = 0
/// Tracks the module-level enhanced particles state owned by `miniquake.render.particles`.
enhancedParticles = false
/// Defines the particle batch record bytes value used by `miniquake.render.particles`.
const PARTICLE_BATCH_RECORD_BYTES = 16
/// Defines the particle batch capacity value used by `miniquake.render.particles`.
const PARTICLE_BATCH_CAPACITY = 8192
// Allocate this sizeable scratch buffer on first use.  Keeping it out of the
// module initializer also keeps command-line/file inspection tools lightweight.
particleBatch = bytes(0)

/// Tracks the module-level dot texture state owned by `miniquake.render.particles`.
dotTexture = [
  [0, 1, 1, 0, 0, 0, 0, 0],
  [1, 1, 1, 1, 0, 0, 0, 0],
  [1, 1, 1, 1, 0, 0, 0, 0],
  [0, 1, 1, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0],
]

/// Implements the `particleTexturePixels` operation for `miniquake.render.particles` (particle texture pixels).
function particleTexturePixels()
  pixels = bytes(8 * 8 * 4)
  x = 0
  while x < 8
    y = 0
    while y < 8
      offset = (y * 8 + x) * 4
      pixels[offset] = 255
      pixels[offset + 1] = 255
      pixels[offset + 2] = 255
      pixels[offset + 3] = dotTexture[x][y] * 255
      y = y + 1
    end while
    x = x + 1
  end while
  return pixels
end function

// Build a softly feathered circular sprite for the Enhanced particle pass.
function softParticleTexturePixels()
  size = 16
  pixels = bytes(size * size * 4)
  y = 0
  while y < size
    x = 0
    while x < size
      dx = x - 7.5
      dy = y - 7.5
      alpha = 255 - native.trunc((dx * dx + dy * dy) * 4.5)
      if alpha < 0 then alpha = 0 end if
      if alpha > 255 then alpha = 255 end if
      offset = (y * size + x) * 4
      pixels[offset] = 255
      pixels[offset + 1] = 255
      pixels[offset + 2] = 255
      pixels[offset + 3] = alpha
      x = x + 1
    end while
    y = y + 1
  end while
  return pixels
end function

/// Switch particle presentation without changing the simulation particle list.
/// @param enabled Whether the optional behavior is enabled.
function ConfigureEnhancedParticles(enabled)
  global enhancedParticles
  if enhancedParticles == enabled then return enhancedParticles end if
  R_ShutdownParticleTexture()
  enhancedParticles = enabled
  return enhancedParticles
end function

// Restore the single-texture state assumed by GLQuake's particle pass.
function prepareParticleTextureState()
  // Native world batches bind both texture units without updating MiniLang's
  // compatibility cache.  Always select unit zero and invalidate that cache;
  // otherwise an impact can sample the last world or lightmap texture instead
  // of the 8x8 particle dot.
  if gl.multitextureAvailable() then
    gl.activeTexture(1)
    gl.disable(gl.GL_TEXTURE_2D)
    gl.activeTexture(0)
  end if
  gl.enable(gl.GL_TEXTURE_2D)
  gl.setBoundTextureForCompatibility(-1)
  return true
end function

/// Implements the `R_InitParticleTexture` operation for `miniquake.render.particles` (r init particle texture).
function R_InitParticleTexture()
  global particleTexture
  if particleTexture != 0 then return particleTexture end if
  prepareParticleTextureState()
  particleTexture = gl.generateTexture()
  gl.bindTexture(particleTexture)
  if enhancedParticles then gl.uploadRgba(16, 16, softParticleTexturePixels())
  else gl.uploadRgba(8, 8, particleTexturePixels())
  end if
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  return particleTexture
end function

// Release the particle texture before the active renderer context is replaced.
function R_ShutdownParticleTexture()
  global particleTexture
  if particleTexture == 0 then return false end if
  oldTexture = particleTexture
  particleTexture = 0
  gl.deleteTexture(oldTexture)
  gl.setBoundTextureForCompatibility(-1)
  return true
end function

/// Implements the `paletteColor` operation for `miniquake.render.particles` (palette color).
/// @param palette The palette input consumed by `paletteColor`.
/// @param index Zero-based index of the requested entry.
function paletteColor(palette, index)
  value = index & 255
  offset = value * 3
  if offset + 2 >= len(palette) then return [255, 255, 255] end if
  return [palette[offset], palette[offset + 1], palette[offset + 2]]
end function

/// Return particle batch float bits derived from the active module state.
/// @param value Value consumed by `particleBatchFloatBits`.
function inline particleBatchFloatBits(value)
  raw = nativeRawValue(value)
  if (raw & 7) == 5 then return raw >> 3 end if
  return native.floatBits(value)
end function

/// Encode and write particle batch word.
/// @param offset Zero-based offset of the requested data.
/// @param value Value consumed by `putParticleBatchWord`.
function inline putParticleBatchWord(offset, value)
  global particleBatch
  particleBatch[offset] = value & 255
  particleBatch[offset + 1] = (value >> 8) & 255
  particleBatch[offset + 2] = (value >> 16) & 255
  particleBatch[offset + 3] = (value >> 24) & 255
end function

// Allocate the reusable particle staging buffer before the first rendered effect.
function ensureParticleBatch()
  global particleBatch
  required = PARTICLE_BATCH_RECORD_BYTES * PARTICLE_BATCH_CAPACITY
  if len(particleBatch) != required then particleBatch = bytes(required) end if
  return particleBatch
end function

/// Submit the populated prefix of the reusable particle staging buffer.
/// @param count Number of entries or units to process.
/// @param viewOrigin The view origin input consumed by `drawParticleBatch`.
/// @param viewForward The view forward input consumed by `drawParticleBatch`.
/// @param viewUp The view up input consumed by `drawParticleBatch`.
/// @param viewRight The view right input consumed by `drawParticleBatch`.
function drawParticleBatch(count, viewOrigin, viewForward, viewUp, viewRight)
  global particleBatch
  if count <= 0 then return 0 end if
  if enhancedParticles then
    return native.glDrawParticleBatchStyled(
      particleBatch,
      count * PARTICLE_BATCH_RECORD_BYTES,
      native.floatBits(viewOrigin.x), native.floatBits(viewOrigin.y), native.floatBits(viewOrigin.z),
      native.floatBits(viewForward.x), native.floatBits(viewForward.y), native.floatBits(viewForward.z),
      native.floatBits(viewUp.x), native.floatBits(viewUp.y), native.floatBits(viewUp.z),
      native.floatBits(viewRight.x), native.floatBits(viewRight.y), native.floatBits(viewRight.z),
    )
  end if
  return native.glDrawParticleBatch(
    particleBatch, count * PARTICLE_BATCH_RECORD_BYTES,
    native.floatBits(viewOrigin.x), native.floatBits(viewOrigin.y), native.floatBits(viewOrigin.z),
    native.floatBits(viewForward.x), native.floatBits(viewForward.y), native.floatBits(viewForward.z),
    native.floatBits(viewUp.x), native.floatBits(viewUp.y), native.floatBits(viewUp.z),
    native.floatBits(viewRight.x), native.floatBits(viewRight.y), native.floatBits(viewRight.z),
  )
end function

/// Implements the `particleGeometry` operation for `miniquake.render.particles` (particle geometry).
/// @param particle The particle input consumed by `particleGeometry`.
/// @param viewOrigin The view origin input consumed by `particleGeometry`.
/// @param viewForward The view forward input consumed by `particleGeometry`.
/// @param viewUp The view up input consumed by `particleGeometry`.
/// @param viewRight The view right input consumed by `particleGeometry`.
function particleGeometry(particle, viewOrigin, viewForward, viewUp, viewRight)
  scaledUp = math.VectorScale(viewUp, 1.5)
  scaledRight = math.VectorScale(viewRight, 1.5)
  distance = math.DotProduct(math.VectorSubtract(particle.origin, viewOrigin), viewForward)
  scale = 1.0
  if distance >= 20.0 then scale = 1.0 + distance * 0.004 end if
  // Evaluate every allocating vector operation before constructing the result
  // array.  A GC between nested argument expressions must not invalidate the
  // particle or one of the already-created Vec3 values.
  origin = math.VectorCopy(particle.origin)
  upVertex = math.VectorMA(particle.origin, scale, scaledUp)
  rightVertex = math.VectorMA(particle.origin, scale, scaledRight)
  return [origin, upVertex, rightVertex, scale]
end function

/// Apply the Quake-compatible r draw particles trace behavior.
/// @param particles The particles input consumed by `R_DrawParticlesTrace`.
/// @param viewOrigin The view origin input consumed by `R_DrawParticlesTrace`.
/// @param viewForward The view forward input consumed by `R_DrawParticlesTrace`.
/// @param viewUp The view up input consumed by `R_DrawParticlesTrace`.
/// @param viewRight The view right input consumed by `R_DrawParticlesTrace`.
function R_DrawParticlesTrace(particles, viewOrigin, viewForward, viewUp, viewRight)
  trace = [
    ["GL_Bind", "particletexture"],
    ["glEnable", "GL_BLEND"],
    ["glTexEnv", "GL_MODULATE"],
    ["glBegin", "GL_TRIANGLES"],
  ]
  for each particle in particles
    geometry = particleGeometry(particle, viewOrigin, viewForward, viewUp, viewRight)
    particleColor = particle.color
    origin = geometry[0]
    upVertex = geometry[1]
    rightVertex = geometry[2]
    scale = geometry[3]
    traceEntry = ["particle", particleColor, origin, upVertex, rightVertex, scale]
    trace = trace + [traceEntry]
  end for
  return trace + [
    ["glEnd"],
    ["glDisable", "GL_BLEND"],
    ["glTexEnv", "GL_REPLACE"],
  ]
end function

/// Render view.
/// @param particles The particles input consumed by `renderView`.
/// @param palette The palette input consumed by `renderView`.
/// @param viewOrigin The view origin input consumed by `renderView`.
/// @param viewForward The view forward input consumed by `renderView`.
/// @param viewUp The view up input consumed by `renderView`.
/// @param viewRight The view right input consumed by `renderView`.
function renderView(particles, palette, viewOrigin, viewForward, viewUp, viewRight)
  global particleBatch
  if len(particles) == 0 then return 0 end if
  ensureParticleBatch()
  texture = R_InitParticleTexture()
  prepareParticleTextureState()
  gl.bindTexture(texture)
  gl.enable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  gl.textureEnvironment(gl.GL_MODULATE)
  batchCount = 0
  rendered = 0
  for each particle in particles
    colorOffset = (particle.color & 255) * 3
    red = 255
    green = 255
    blue = 255
    if colorOffset + 2 < len(palette) then
      red = palette[colorOffset]
      green = palette[colorOffset + 1]
      blue = palette[colorOffset + 2]
    end if
    offset = batchCount * PARTICLE_BATCH_RECORD_BYTES
    particleBatch[offset] = red
    particleBatch[offset + 1] = green
    particleBatch[offset + 2] = blue
    particleBatch[offset + 3] = 255
    putParticleBatchWord(offset + 4, particleBatchFloatBits(particle.origin.x))
    putParticleBatchWord(offset + 8, particleBatchFloatBits(particle.origin.y))
    putParticleBatchWord(offset + 12, particleBatchFloatBits(particle.origin.z))
    batchCount = batchCount + 1
    if batchCount == PARTICLE_BATCH_CAPACITY then
      rendered = rendered + drawParticleBatch(batchCount, viewOrigin, viewForward, viewUp, viewRight)
      batchCount = 0
    end if
  end for
  rendered = rendered + drawParticleBatch(batchCount, viewOrigin, viewForward, viewUp, viewRight)
  gl.disable(gl.GL_BLEND)
  gl.textureEnvironment(gl.GL_REPLACE)
  return rendered
end function

/// Compatibility entry point used by the integrated renderer until its view
/// vectors are passed explicitly.
/// @param particles The particles input consumed by `render`.
/// @param palette The palette input consumed by `render`.
function render(particles, palette)
  return renderView(
    particles,
    palette,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0),
    t.Vec3(0.0, -1.0, 0.0),
  )
end function

/// Render temporary.
/// @param effects The effects input consumed by `renderTemporary`.
/// @param currentTime Time value used by the operation.
/// @param palette The palette input consumed by `renderTemporary`.
function renderTemporary(effects, currentTime, palette)
  rendered = 0
  gl.disable(gl.GL_TEXTURE_2D)
  gl.enable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  for each timed in effects
    if len(timed) >= 2 and timed[1] >= currentTime then
      effect = timed[0]
      if effect.type == 5 or effect.type == 6 or effect.type == 9 or effect.type == 13 then
        color = paletteColor(palette, 250)
        gl.color(color[0], color[1], color[2], 220)
        gl.begin(gl.GL_LINES)
        gl.vertex3(effect.origin.x, effect.origin.y, effect.origin.z)
        gl.vertex3(effect.endPosition.x, effect.endPosition.y, effect.endPosition.z)
        gl.finishPrimitive()
        rendered = rendered + 1
      end if
    end if
  end for
  gl.disable(gl.GL_BLEND)
  gl.enable(gl.GL_TEXTURE_2D)
  return rendered
end function
