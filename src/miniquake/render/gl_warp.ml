package miniquake.render.gl_warp

// Functional MiniLang counterpart of WinQuake/gl_warp.c (Quake 1 path).
//
// The original stores warp polygons in hunk memory and emits immediate-mode
// commands directly.  This module keeps the same polygon ordering and math,
// but returns deterministic command data to the renderer integration layer.

import miniquake.types as t
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.array_util as arrayutil

const DEFAULT_SUBDIVIDE_SIZE = 128.0
const TURBSCALE = 40.74366543152521

// gl_model.c owns this archived cvar in GLQuake.  Keep its current numeric
// value at the warp boundary so every subdivision path observes changes made
// through the console instead of baking the default into generated polygons.
gl_subdivide_size = DEFAULT_SUBDIVIDE_SIZE

function SetSubdivideSize(value)
  global gl_subdivide_size
  if value <= 0.0 then value = DEFAULT_SUBDIVIDE_SIZE end if
  gl_subdivide_size = value
  return gl_subdivide_size
end function

function CurrentSubdivideSize()
  return gl_subdivide_size
end function

// Exact table from gl_warp_sin.h.  Looking up this table, rather than calling
// sin at render time, is observable in texture-coordinate command traces.
turbsin = [
  0.0, 0.19633, 0.392541, 0.588517, 0.784137, 0.979285, 1.17384, 1.3677,
  1.56072, 1.75281, 1.94384, 2.1337, 2.32228, 2.50945, 2.69512, 2.87916,
  3.06147, 3.24193, 3.42044, 3.59689, 3.77117, 3.94319, 4.11282, 4.27998,
  4.44456, 4.60647, 4.76559, 4.92185, 5.07515, 5.22538, 5.37247, 5.51632,
  5.65685, 5.79398, 5.92761, 6.05767, 6.18408, 6.30677, 6.42566, 6.54068,
  6.65176, 6.75883, 6.86183, 6.9607, 7.05537, 7.14579, 7.23191, 7.31368,
  7.39104, 7.46394, 7.53235, 7.59623, 7.65552, 7.71021, 7.76025, 7.80562,
  7.84628, 7.88222, 7.91341, 7.93984, 7.96148, 7.97832, 7.99036, 7.99759,
  8.0, 7.99759, 7.99036, 7.97832, 7.96148, 7.93984, 7.91341, 7.88222,
  7.84628, 7.80562, 7.76025, 7.71021, 7.65552, 7.59623, 7.53235, 7.46394,
  7.39104, 7.31368, 7.23191, 7.14579, 7.05537, 6.9607, 6.86183, 6.75883,
  6.65176, 6.54068, 6.42566, 6.30677, 6.18408, 6.05767, 5.92761, 5.79398,
  5.65685, 5.51632, 5.37247, 5.22538, 5.07515, 4.92185, 4.76559, 4.60647,
  4.44456, 4.27998, 4.11282, 3.94319, 3.77117, 3.59689, 3.42044, 3.24193,
  3.06147, 2.87916, 2.69512, 2.50945, 2.32228, 2.1337, 1.94384, 1.75281,
  1.56072, 1.3677, 1.17384, 0.979285, 0.784137, 0.588517, 0.392541, 0.19633,
  0.000000000000000979717, -0.19633, -0.392541, -0.588517, -0.784137, -0.979285, -1.17384, -1.3677,
  -1.56072, -1.75281, -1.94384, -2.1337, -2.32228, -2.50945, -2.69512, -2.87916,
  -3.06147, -3.24193, -3.42044, -3.59689, -3.77117, -3.94319, -4.11282, -4.27998,
  -4.44456, -4.60647, -4.76559, -4.92185, -5.07515, -5.22538, -5.37247, -5.51632,
  -5.65685, -5.79398, -5.92761, -6.05767, -6.18408, -6.30677, -6.42566, -6.54068,
  -6.65176, -6.75883, -6.86183, -6.9607, -7.05537, -7.14579, -7.23191, -7.31368,
  -7.39104, -7.46394, -7.53235, -7.59623, -7.65552, -7.71021, -7.76025, -7.80562,
  -7.84628, -7.88222, -7.91341, -7.93984, -7.96148, -7.97832, -7.99036, -7.99759,
  -8.0, -7.99759, -7.99036, -7.97832, -7.96148, -7.93984, -7.91341, -7.88222,
  -7.84628, -7.80562, -7.76025, -7.71021, -7.65552, -7.59623, -7.53235, -7.46394,
  -7.39104, -7.31368, -7.23191, -7.14579, -7.05537, -6.9607, -6.86183, -6.75883,
  -6.65176, -6.54068, -6.42566, -6.30677, -6.18408, -6.05767, -5.92761, -5.79398,
  -5.65685, -5.51632, -5.37247, -5.22538, -5.07515, -4.92185, -4.76559, -4.60647,
  -4.44456, -4.27998, -4.11282, -3.94319, -3.77117, -3.59689, -3.42044, -3.24193,
  -3.06147, -2.87916, -2.69512, -2.50945, -2.32228, -2.1337, -1.94384, -1.75281,
  -1.56072, -1.3677, -1.17384, -0.979285, -0.784137, -0.588517, -0.392541, -0.19633,
]

function floorValue(value)
  result = native.trunc(value)
  if result > value then result = result - 1 end if
  return result
end function

function BoundPoly(vertices)
  minimums = t.Vec3(9999.0, 9999.0, 9999.0)
  maximums = t.Vec3(-9999.0, -9999.0, -9999.0)
  for each vertex in vertices
    point = vertex.position
    if point.x < minimums.x then minimums.x = point.x end if
    if point.y < minimums.y then minimums.y = point.y end if
    if point.z < minimums.z then minimums.z = point.z end if
    if point.x > maximums.x then maximums.x = point.x end if
    if point.y > maximums.y then maximums.y = point.y end if
    if point.z > maximums.z then maximums.z = point.z end if
  end for
  return [minimums, maximums]
end function

function interpolateVertex(first, second, fraction)
  return t.RenderVertex(
    math.add(first.position, math.scale(math.subtract(second.position, first.position), fraction)),
    first.s + (second.s - first.s) * fraction,
    first.t + (second.t - first.t) * fraction,
    first.lightS + (second.lightS - first.lightS) * fraction,
    first.lightT + (second.lightT - first.lightT) * fraction,
  )
end function

function subdivideRecursive(vertices, output, subdivideSize)
  if len(vertices) > 60 then return error(3800, "SubdividePolygon: numverts > 60") end if
  bounds = BoundPoly(vertices)
  minimums = bounds[0]
  maximums = bounds[1]
  axis = 0
  while axis < 3
    minimum = minimums.x
    maximum = maximums.x
    if axis == 1 then minimum = minimums.y; maximum = maximums.y end if
    if axis == 2 then minimum = minimums.z; maximum = maximums.z end if
    middle = (minimum + maximum) * 0.5
    middle = subdivideSize * floorValue(middle / subdivideSize + 0.5)
    if maximum - middle >= 8.0 and middle - minimum >= 8.0 then
      distances = arrayutil.makeEmptyArray(len(vertices) + 1)
      index = 0
      while index < len(vertices)
        point = vertices[index].position
        coordinate = point.x
        if axis == 1 then coordinate = point.y end if
        if axis == 2 then coordinate = point.z end if
        distances[index] = coordinate - middle
        index = index + 1
      end while
      distances[len(vertices)] = distances[0]
      front = arrayutil.createArrayBuilder(len(vertices) + 4)
      back = arrayutil.createArrayBuilder(len(vertices) + 4)
      index = 0
      while index < len(vertices)
        current = vertices[index]
        next = vertices[(index + 1) % len(vertices)]
        distance = distances[index]
        nextDistance = distances[index + 1]
        if distance >= 0.0 then arrayutil.pushArrayBuilder(front, current) end if
        if distance <= 0.0 then arrayutil.pushArrayBuilder(back, current) end if
        if distance != 0.0 and nextDistance != 0.0 and ((distance > 0.0) != (nextDistance > 0.0)) then
          split = interpolateVertex(current, next, distance / (distance - nextDistance))
          arrayutil.pushArrayBuilder(front, split)
          arrayutil.pushArrayBuilder(back, split)
        end if
        index = index + 1
      end while
      result = subdivideRecursive(arrayutil.finishArrayBuilder(front), output, subdivideSize)
      if result is error then return result end if
      return subdivideRecursive(arrayutil.finishArrayBuilder(back), output, subdivideSize)
    end if
    axis = axis + 1
  end while
  arrayutil.pushArrayBuilder(output, vertices)
  return true
end function

function SubdividePolygon(vertices, subdivideSize)
  if subdivideSize <= 0.0 then subdivideSize = DEFAULT_SUBDIVIDE_SIZE end if
  output = arrayutil.createArrayBuilder(8)
  result = subdivideRecursive(vertices, output, subdivideSize)
  if result is error then return result end if
  forward = arrayutil.finishArrayBuilder(output)
  // gl_warp.c prepends each Hunk_Alloc polygon to warpface->polys.
  polygons = arrayutil.makeEmptyArray(len(forward))
  index = 0
  while index < len(forward)
    polygons[index] = forward[len(forward) - index - 1]
    index = index + 1
  end while
  return polygons
end function

function SurfaceWarpVertices(vertices, sVector, tVector)
  result = arrayutil.makeEmptyArray(len(vertices))
  index = 0
  while index < len(vertices)
    point = vertices[index].position
    // DotProduct in GL_SubdivideSurface intentionally excludes vecs[][3].
    rawS = point.x * sVector[0] + point.y * sVector[1] + point.z * sVector[2]
    rawT = point.x * tVector[0] + point.y * tVector[1] + point.z * tVector[2]
    result[index] = t.RenderVertex(math.copy(point), rawS, rawT, 0.0, 0.0)
    index = index + 1
  end while
  return result
end function

function GL_SubdivideSurface(vertices, sVector, tVector, subdivideSize)
  return SubdividePolygon(SurfaceWarpVertices(vertices, sVector, tVector), subdivideSize)
end function

function WaterTexCoords(originalS, originalT, realtime)
  sIndex = native.trunc((originalT * 0.125 + realtime) * TURBSCALE) & 255
  tIndex = native.trunc((originalS * 0.125 + realtime) * TURBSCALE) & 255
  textureS = (originalS + turbsin[sIndex]) / 64.0
  textureT = (originalT + turbsin[tIndex]) / 64.0
  return [textureS, textureT]
end function

function EmitWaterPolys(polygons, realtime)
  result = arrayutil.makeEmptyArray(len(polygons))
  polygonIndex = 0
  while polygonIndex < len(polygons)
    polygon = polygons[polygonIndex]
    commands = arrayutil.makeEmptyArray(len(polygon))
    vertexIndex = 0
    while vertexIndex < len(polygon)
      vertex = polygon[vertexIndex]
      coordinates = WaterTexCoords(vertex.s, vertex.t, realtime)
      // Materialize heap reads before allocating the command array.
      textureS = coordinates[0]
      textureT = coordinates[1]
      position = vertex.position
      commands[vertexIndex] = [textureS, textureT, position]
      vertexIndex = vertexIndex + 1
    end while
    result[polygonIndex] = commands
    polygonIndex = polygonIndex + 1
  end while
  return result
end function

function WrappedSpeedScale(realtime, speed)
  value = realtime * speed
  return value - (native.trunc(value) & -128)
end function

function SkyTexCoords(position, viewOrigin, currentSpeedScale)
  direction = math.subtract(position, viewOrigin)
  direction.z = direction.z * 3.0
  lengthValue = math.length(direction)
  if lengthValue == 0.0 then return [0.0, 0.0] end if
  scaleValue = 378.0 / lengthValue
  textureS = (currentSpeedScale + direction.x * scaleValue) / 128.0
  textureT = (currentSpeedScale + direction.y * scaleValue) / 128.0
  return [textureS, textureT]
end function

function EmitSkyPolys(polygons, viewOrigin, currentSpeedScale)
  result = arrayutil.makeEmptyArray(len(polygons))
  polygonIndex = 0
  while polygonIndex < len(polygons)
    polygon = polygons[polygonIndex]
    commands = arrayutil.makeEmptyArray(len(polygon))
    vertexIndex = 0
    while vertexIndex < len(polygon)
      vertex = polygon[vertexIndex]
      coordinates = SkyTexCoords(vertex.position, viewOrigin, currentSpeedScale)
      // See EmitWaterPolys: keep only scalar values live across allocation.
      textureS = coordinates[0]
      textureT = coordinates[1]
      position = vertex.position
      commands[vertexIndex] = [textureS, textureT, position]
      vertexIndex = vertexIndex + 1
    end while
    result[polygonIndex] = commands
    polygonIndex = polygonIndex + 1
  end while
  return result
end function

function EmitBothSkyLayers(polygons, viewOrigin, realtime)
  solidSpeed = WrappedSpeedScale(realtime, 8.0)
  alphaSpeed = WrappedSpeedScale(realtime, 16.0)
  return [
    solidSpeed,
    EmitSkyPolys(polygons, viewOrigin, solidSpeed),
    alphaSpeed,
    EmitSkyPolys(polygons, viewOrigin, alphaSpeed),
  ]
end function

function R_DrawSkyChain(surfacePolygons, viewOrigin, realtime)
  solidSpeed = WrappedSpeedScale(realtime, 8.0)
  alphaSpeed = WrappedSpeedScale(realtime, 16.0)
  solid = arrayutil.makeEmptyArray(len(surfacePolygons))
  alpha = arrayutil.makeEmptyArray(len(surfacePolygons))
  index = 0
  while index < len(surfacePolygons)
    solid[index] = EmitSkyPolys(surfacePolygons[index], viewOrigin, solidSpeed)
    alpha[index] = EmitSkyPolys(surfacePolygons[index], viewOrigin, alphaSpeed)
    index = index + 1
  end while
  return [solidSpeed, solid, alphaSpeed, alpha]
end function

function R_InitSkyPixels(texture, palette)
  if texture is void or texture.width != 256 or texture.height != 128 or len(texture.pixels) < 256 * 128 then
    return error(3801, "R_InitSky: sky texture must be 256x128")
  end if
  if len(palette) < 768 then return error(3802, "R_InitSky: palette is truncated") end if
  solid = bytes(128 * 128 * 4)
  alpha = bytes(128 * 128 * 4)
  red = 0
  green = 0
  blue = 0
  y = 0
  while y < 128
    x = 0
    while x < 128
      color = texture.pixels[y * 256 + x + 128]
      offset = (y * 128 + x) * 4
      solid[offset] = palette[color * 3]
      solid[offset + 1] = palette[color * 3 + 1]
      solid[offset + 2] = palette[color * 3 + 2]
      solid[offset + 3] = 255
      if color == 255 then solid[offset + 3] = 0 end if
      red = red + solid[offset]
      green = green + solid[offset + 1]
      blue = blue + solid[offset + 2]
      x = x + 1
    end while
    y = y + 1
  end while
  averageRed = native.trunc(red / (128 * 128))
  averageGreen = native.trunc(green / (128 * 128))
  averageBlue = native.trunc(blue / (128 * 128))
  y = 0
  while y < 128
    x = 0
    while x < 128
      color = texture.pixels[y * 256 + x]
      offset = (y * 128 + x) * 4
      if color == 0 then
        alpha[offset] = averageRed
        alpha[offset + 1] = averageGreen
        alpha[offset + 2] = averageBlue
        alpha[offset + 3] = 0
      else
        alpha[offset] = palette[color * 3]
        alpha[offset + 1] = palette[color * 3 + 1]
        alpha[offset + 2] = palette[color * 3 + 2]
        alpha[offset + 3] = 255
        if color == 255 then alpha[offset + 3] = 0 end if
      end if
      x = x + 1
    end while
    y = y + 1
  end while
  return [solid, alpha]
end function

function R_InitSky(texture, palette)
  return R_InitSkyPixels(texture, palette)
end function
