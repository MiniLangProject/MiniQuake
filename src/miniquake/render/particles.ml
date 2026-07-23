package miniquake.render.particles

import miniquake.render.gl11 as gl

function paletteColor(palette, index)
  value = index & 255
  offset = value * 3
  if offset + 2 >= len(palette) then return [255, 255, 255] end if
  return [palette[offset], palette[offset + 1], palette[offset + 2]]
end function

function render(particles, palette)
  if len(particles) == 0 then return 0 end if
  gl.disable(gl.GL_TEXTURE_2D)
  gl.enable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  gl.begin(gl.GL_POINTS)
  for each particle in particles
    color = paletteColor(palette, particle.color)
    gl.color(color[0], color[1], color[2], 255)
    gl.vertex3(particle.origin.x, particle.origin.y, particle.origin.z)
  end for
  gl.finishPrimitive()
  gl.disable(gl.GL_BLEND)
  gl.enable(gl.GL_TEXTURE_2D)
  return len(particles)
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
