package miniquake.render.gl_rlight

// Functional MiniLang counterpart of WinQuake/gl_rlight.c.
//
// OpenGL state ownership remains in render/world.ml.  This module implements
// the original light animation, blend, BSP marking, dlight fan and light-point
// equations as deterministic data transformations.

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.array_util as arrayutil

function R_AnimateLight(lightStyles, currentTime)
  values = arrayutil.makeFilledArray(c.MAX_LIGHTSTYLES, 256)
  tick = native.trunc(currentTime * 10.0)
  index = 0
  while index < c.MAX_LIGHTSTYLES
    style = ""
    if index < len(lightStyles) then style = lightStyles[index] end if
    data = bytes(style)
    if len(data) > 0 then
      character = data[tick % len(data)] - 97
      values[index] = character * 22
    end if
    index = index + 1
  end while
  return values
end function

function AddLightBlend(blend, red, green, blue, alpha2)
  if blend is void or len(blend) < 4 then blend = [0.0, 0.0, 0.0, 0.0] end if
  result = [blend[0], blend[1], blend[2], blend[3]]
  alpha = result[3] + alpha2 * (1.0 - result[3])
  result[3] = alpha
  if alpha == 0.0 then return result end if
  fraction = alpha2 / alpha
  // Preserve the shipped MiniQuake source quirk: red accumulates from green.
  result[0] = result[1] * (1.0 - fraction) + red * fraction
  result[1] = result[1] * (1.0 - fraction) + green * fraction
  result[2] = result[2] * (1.0 - fraction) + blue * fraction
  return result
end function

function R_RenderDlightTrace(light, currentTime, viewOrigin, viewForward, viewRight, viewUp, blend)
  if light is void or light.radius <= 0.0 or light.die < currentTime then return [false, blend, []] end if
  radius = light.radius * 0.35
  if math.length(math.subtract(light.origin, viewOrigin)) < radius then
    return [true, AddLightBlend(blend, 1.0, 0.5, 0.0, light.radius * 0.0003), []]
  end if
  vertices = arrayutil.makeEmptyArray(18)
  vertices[0] = math.subtract(light.origin, math.scale(viewForward, radius))
  index = 16
  output = 1
  while index >= 0
    angle = index / 16.0 * math.PI * 2.0
    vertices[output] = math.add(
      light.origin,
      math.add(
        math.scale(viewRight, math.cos(angle) * radius),
        math.scale(viewUp, math.sin(angle) * radius),
      ),
    )
    output = output + 1
    index = index - 1
  end while
  return [true, blend, vertices]
end function

function R_RenderDlight(light, currentTime, viewOrigin, viewForward, viewRight, viewUp, blend)
  return R_RenderDlightTrace(light, currentTime, viewOrigin, viewForward, viewRight, viewUp, blend)
end function

function R_RenderDlights(dynamicLights, currentTime, viewOrigin, viewForward, viewRight, viewUp, blend)
  traces = arrayutil.createArrayBuilder(len(dynamicLights))
  currentBlend = blend
  count = 0
  index = 0
  while index < len(dynamicLights) and index < c.MAX_DLIGHTS
    trace = R_RenderDlightTrace(
      dynamicLights[index],
      currentTime,
      viewOrigin,
      viewForward,
      viewRight,
      viewUp,
      currentBlend,
    )
    if trace[0] then
      currentBlend = trace[1]
      arrayutil.pushArrayBuilder(traces, trace[2])
      count = count + 1
    end if
    index = index + 1
  end while
  return [count, currentBlend, arrayutil.finishArrayBuilder(traces)]
end function

function planeDistance(plane, point)
  if plane.type == 0 then return point.x - plane.dist end if
  if plane.type == 1 then return point.y - plane.dist end if
  if plane.type == 2 then return point.z - plane.dist end if
  return math.dot(point, plane.normal) - plane.dist
end function

function R_MarkLights(map, surfaceBits, surfaceFrames, frameCount, light, bit, nodeNumber)
  if light is void or nodeNumber < 0 or nodeNumber >= len(map.nodes) then return 0 end if
  node = map.nodes[nodeNumber]
  if node.planeIndex < 0 or node.planeIndex >= len(map.planes) then return 0 end if
  distance = planeDistance(map.planes[node.planeIndex], light.origin)
  if distance > light.radius then
    return R_MarkLights(map, surfaceBits, surfaceFrames, frameCount, light, bit, node.child0)
  end if
  if distance < -light.radius then
    return R_MarkLights(map, surfaceBits, surfaceFrames, frameCount, light, bit, node.child1)
  end if
  marked = 0
  faceIndex = node.firstFace
  lastFace = faceIndex + node.numFaces
  while faceIndex < lastFace and faceIndex < len(surfaceBits)
    if faceIndex >= 0 then
      if surfaceFrames[faceIndex] != frameCount then
        surfaceBits[faceIndex] = 0
        surfaceFrames[faceIndex] = frameCount
      end if
      surfaceBits[faceIndex] = surfaceBits[faceIndex] | bit
      marked = marked + 1
    end if
    faceIndex = faceIndex + 1
  end while
  marked = marked + R_MarkLights(map, surfaceBits, surfaceFrames, frameCount, light, bit, node.child0)
  marked = marked + R_MarkLights(map, surfaceBits, surfaceFrames, frameCount, light, bit, node.child1)
  return marked
end function

function R_PushDlights(map, surfaceBits, surfaceFrames, frameCount, dynamicLights, currentTime, rootNode)
  marked = 0
  index = 0
  while index < len(dynamicLights) and index < c.MAX_DLIGHTS
    light = dynamicLights[index]
    if light is not void and light.die >= currentTime and light.radius > 0.0 then
      marked = marked + R_MarkLights(map, surfaceBits, surfaceFrames, frameCount, light, 1 << index, rootNode)
    end if
    index = index + 1
  end while
  return marked
end function

function RecursiveLightPoint(map, surfaces, lightStyleValues, nodeNumber, start, finish)
  if nodeNumber < 0 or nodeNumber >= len(map.nodes) then return [-1, void, void] end if
  node = map.nodes[nodeNumber]
  if node.planeIndex < 0 or node.planeIndex >= len(map.planes) then return [-1, void, void] end if
  plane = map.planes[node.planeIndex]
  front = planeDistance(plane, start)
  back = planeDistance(plane, finish)
  side = 0
  if front < 0.0 then side = 1 end if
  sameSide = (back < 0.0 and side == 1) or (back >= 0.0 and side == 0)
  if sameSide then
    child = node.child0
    if side == 1 then child = node.child1 end if
    return RecursiveLightPoint(map, surfaces, lightStyleValues, child, start, finish)
  end if
  fraction = front / (front - back)
  middle = math.add(start, math.scale(math.subtract(finish, start), fraction))
  frontChild = node.child0
  if side == 1 then frontChild = node.child1 end if
  result = RecursiveLightPoint(map, surfaces, lightStyleValues, frontChild, start, middle)
  if result[0] >= 0 then return result end if

  faceIndex = node.firstFace
  lastFace = faceIndex + node.numFaces
  while faceIndex < lastFace and faceIndex < len(surfaces)
    if faceIndex >= 0 then
      surface = surfaces[faceIndex]
      if (surface.flags & c.SURF_DRAWTILED) == 0 and surface.faceIndex >= 0 and surface.faceIndex < len(map.faces) then
        face = map.faces[surface.faceIndex]
        if face.texInfo >= 0 and face.texInfo < len(map.texInfo) then
          info = map.texInfo[face.texInfo]
          coordinateS = native.trunc(
            middle.x * info.s[0] + middle.y * info.s[1] + middle.z * info.s[2] + info.s[3]
          )
          coordinateT = native.trunc(
            middle.x * info.t[0] + middle.y * info.t[1] + middle.z * info.t[2] + info.t[3]
          )
          if coordinateS >= surface.textureMins.x and coordinateT >= surface.textureMins.y then
            ds = coordinateS - surface.textureMins.x
            dt = coordinateT - surface.textureMins.y
            if ds <= surface.extents.x and dt <= surface.extents.y then
              if surface.lightOffset < 0 or len(map.lighting) == 0 then return [0, middle, plane] end if
              ds = native.trunc(ds) >> 4
              dt = native.trunc(dt) >> 4
              size = surface.lightWidth * surface.lightHeight
              offset = surface.lightOffset + dt * surface.lightWidth + ds
              total = 0
              mapNumber = 0
              while mapNumber < len(face.styles) and mapNumber < 4 and face.styles[mapNumber] != 255
                style = face.styles[mapNumber]
                scaleValue = 256
                if style >= 0 and style < len(lightStyleValues) then scaleValue = lightStyleValues[style] end if
                sampleOffset = offset + mapNumber * size
                if sampleOffset < len(map.lighting) then total = total + map.lighting[sampleOffset] * scaleValue end if
                mapNumber = mapNumber + 1
              end while
              return [total >> 8, middle, plane]
            end if
          end if
        end if
      end if
    end if
    faceIndex = faceIndex + 1
  end while
  backChild = node.child1
  if side == 1 then backChild = node.child0 end if
  return RecursiveLightPoint(map, surfaces, lightStyleValues, backChild, middle, finish)
end function

function R_LightPoint(map, surfaces, lightStyleValues, rootNode, point)
  if len(map.lighting) == 0 then return [255, void, void] end if
  finish = t.Vec3(point.x, point.y, point.z - 2048.0)
  result = RecursiveLightPoint(map, surfaces, lightStyleValues, rootNode, point, finish)
  if result[0] < 0 then result[0] = 0 end if
  return result
end function
