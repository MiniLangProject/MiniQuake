/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

MiniQuake fixed-function particle drawing and particle-texture bridge.
*/

package miniquake.render.particles

import miniquake.types as t
import miniquake.mathlib as math
import miniquake.render.gl11 as gl

particleTexture = 0

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

function R_InitParticleTexture()
  global particleTexture
  if particleTexture != 0 then return particleTexture end if
  particleTexture = gl.generateTexture()
  gl.bindTexture(particleTexture)
  gl.uploadRgba(8, 8, particleTexturePixels())
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  return particleTexture
end function

function paletteColor(palette, index)
  value = index & 255
  offset = value * 3
  if offset + 2 >= len(palette) then return [255, 255, 255] end if
  return [palette[offset], palette[offset + 1], palette[offset + 2]]
end function

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

function renderView(particles, palette, viewOrigin, viewForward, viewUp, viewRight)
  if len(particles) == 0 then return 0 end if
  texture = R_InitParticleTexture()
  gl.bindTexture(texture)
  gl.enable(gl.GL_BLEND)
  gl.textureEnvironment(gl.GL_MODULATE)
  gl.begin(gl.GL_TRIANGLES)
  for each particle in particles
    color = paletteColor(palette, particle.color)
    geometry = particleGeometry(particle, viewOrigin, viewForward, viewUp, viewRight)
    red = color[0]
    green = color[1]
    blue = color[2]
    origin = geometry[0]
    upVertex = geometry[1]
    rightVertex = geometry[2]
    originX = origin.x
    originY = origin.y
    originZ = origin.z
    upX = upVertex.x
    upY = upVertex.y
    upZ = upVertex.z
    rightX = rightVertex.x
    rightY = rightVertex.y
    rightZ = rightVertex.z
    gl.color(red, green, blue, 255)
    gl.texcoord2(0.0, 0.0)
    gl.vertex3(originX, originY, originZ)
    gl.texcoord2(1.0, 0.0)
    gl.vertex3(upX, upY, upZ)
    gl.texcoord2(0.0, 1.0)
    gl.vertex3(rightX, rightY, rightZ)
  end for
  gl.finishPrimitive()
  gl.disable(gl.GL_BLEND)
  gl.textureEnvironment(gl.GL_REPLACE)
  return len(particles)
end function

// Compatibility entry point used by the integrated renderer until its view
// vectors are passed explicitly.
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
