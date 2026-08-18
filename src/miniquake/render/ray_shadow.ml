/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Backend-neutral BSP ray projection for geometrically verified MiniQuake
entity shadows.
*/
package miniquake.render.ray_shadow

import miniquake.native as native
import miniquake.mathlib as math
import miniquake.constants as c
import miniquake.byteio as byteio
import miniquake.render.gl_rlight as glRlight

const INITIAL_VERTEX_CACHE = 1024
const MAX_RECEIVER_DISTANCE = 768.0
const RECEIVER_BIAS = 0.65

activeMap = void
activeSurfaces = []
activeRootNode = 0
ready = false
originX = 0.0
originY = 0.0
originZ = 0.0
modelScaleX = 1.0
modelScaleY = 1.0
modelScaleZ = 1.0
modelOffsetX = 0.0
modelOffsetY = 0.0
modelOffsetZ = 0.0
yawCos = 1.0
yawSin = 0.0
pitchCos = 1.0
pitchSin = 0.0
rollCos = 1.0
rollSin = 0.0
pointLightActive = false
pointLightX = 0.0
pointLightY = 0.0
pointLightZ = 0.0
sampleOffsetX = 0.0
sampleOffsetY = 0.0
projectionGeneration = 1
projectionStamp = array(INITIAL_VERTEX_CACHE, 0)
projectionValid = array(INITIAL_VERTEX_CACHE, false)
projectionX = array(INITIAL_VERTEX_CACHE, 0.0)
projectionY = array(INITIAL_VERTEX_CACHE, 0.0)
projectionZ = array(INITIAL_VERTEX_CACHE, 0.0)
projectionNormalX = array(INITIAL_VERTEX_CACHE, 0.0)
projectionNormalY = array(INITIAL_VERTEX_CACHE, 0.0)
projectionNormalZ = array(INITIAL_VERTEX_CACHE, 1.0)
projectionTravel = array(INITIAL_VERTEX_CACHE, 0.0)
sourceX = array(INITIAL_VERTEX_CACHE, 0.0)
sourceY = array(INITIAL_VERTEX_CACHE, 0.0)
sourceZ = array(INITIAL_VERTEX_CACHE, 0.0)
minimumHitFraction = array(INITIAL_VERTEX_CACHE, 0.0)
rayPreparedValid = array(INITIAL_VERTEX_CACHE, false)
rayPacket = bytes(INITIAL_VERTEX_CACHE * 24)
hitPacket = bytes(INITIAL_VERTEX_CACHE * 32)
uploadedMapName = ""
uploadedSurfaceCount = -1
nativeWorldReady = false
worldTrianglePacket = bytes()

// Grow every parallel vertex cache together so a model vertex index remains a
// stable key throughout one shadow sample.
function ensureVertexCapacity(index)
  global projectionStamp, projectionValid, projectionX, projectionY, projectionZ
  global projectionNormalX, projectionNormalY, projectionNormalZ
  global projectionTravel
  global sourceX, sourceY, sourceZ
  global minimumHitFraction, rayPreparedValid, rayPacket, hitPacket
  if index < len(projectionStamp) then return true end if
  size = len(projectionStamp)
  if size < 1 then size = INITIAL_VERTEX_CACHE end if
  while size <= index
    size = size * 2
  end while
  projectionStamp = array(size, 0)
  projectionValid = array(size, false)
  projectionX = array(size, 0.0)
  projectionY = array(size, 0.0)
  projectionZ = array(size, 0.0)
  projectionNormalX = array(size, 0.0)
  projectionNormalY = array(size, 0.0)
  projectionNormalZ = array(size, 1.0)
  projectionTravel = array(size, 0.0)
  sourceX = array(size, 0.0)
  sourceY = array(size, 0.0)
  sourceZ = array(size, 0.0)
  minimumHitFraction = array(size, 0.0)
  rayPreparedValid = array(size, false)
  rayPacket = bytes(size * 24)
  hitPacket = bytes(size * 32)
  return true
end function

// Upload a triangulated copy of the render BSP once per map. The native bridge
// builds a CPU BVH; MiniLang retains ownership of caster/light policy and all
// emitted shadow geometry.
function ensureNativeWorld(worldMap, worldSurfaces)
  global uploadedMapName, uploadedSurfaceCount, nativeWorldReady, worldTrianglePacket
  // Keep the map identity check ahead of packet construction, then count,
  // serialize and publish a complete immutable triangle set to the BVH.
  if uploadedMapName == worldMap.filename and uploadedSurfaceCount == len(worldSurfaces) then return nativeWorldReady end if
  native.shadowWorldClear()
  uploadedMapName = worldMap.filename
  uploadedSurfaceCount = len(worldSurfaces)
  nativeWorldReady = false
  triangleCount = 0
  for each surface in worldSurfaces
    if surface is not void and (surface.flags & c.SURF_DRAWSKY) == 0 and len(surface.vertices) >= 3 then
      triangleCount = triangleCount + len(surface.vertices) - 2
    end if
  end for
  if triangleCount < 1 then return false end if
  worldTrianglePacket = bytes(triangleCount * 36)
  offset = 0
  for each surface in worldSurfaces
    if surface is not void and (surface.flags & c.SURF_DRAWSKY) == 0 and len(surface.vertices) >= 3 then
      triangleIndex = 1
      while triangleIndex + 1 < len(surface.vertices)
        first = surface.vertices[0].position
        second = surface.vertices[triangleIndex].position
        third = surface.vertices[triangleIndex + 1].position
        byteio.putF32(worldTrianglePacket, offset, first.x)
        byteio.putF32(worldTrianglePacket, offset + 4, first.y)
        byteio.putF32(worldTrianglePacket, offset + 8, first.z)
        byteio.putF32(worldTrianglePacket, offset + 12, second.x)
        byteio.putF32(worldTrianglePacket, offset + 16, second.y)
        byteio.putF32(worldTrianglePacket, offset + 20, second.z)
        byteio.putF32(worldTrianglePacket, offset + 24, third.x)
        byteio.putF32(worldTrianglePacket, offset + 28, third.y)
        byteio.putF32(worldTrianglePacket, offset + 32, third.z)
        offset = offset + 36
        triangleIndex = triangleIndex + 1
      end while
    end if
  end for
  nativeWorldReady = native.shadowWorldUpload(worldTrianglePacket, len(worldTrianglePacket)) == triangleCount
  return nativeWorldReady
end function

// Configure common world, entity transform and light state for one caster.
function configureCaster(worldMap, worldSurfaces, entity, scaleX, scaleY, scaleZ, offsetX, offsetY, offsetZ, pitchSign, lightActive, lightX, lightY, lightZ)
  global activeMap, activeSurfaces, activeRootNode, ready
  global originX, originY, originZ
  global modelScaleX, modelScaleY, modelScaleZ
  global modelOffsetX, modelOffsetY, modelOffsetZ
  global yawCos, yawSin, pitchCos, pitchSin, rollCos, rollSin
  global pointLightActive, pointLightX, pointLightY, pointLightZ
  ready = false
  if worldMap is void or entity is void or len(worldMap.models) == 0 or len(worldMap.nodes) == 0 or len(worldSurfaces) == 0 then return false end if
  activeMap = worldMap
  activeSurfaces = worldSurfaces
  activeRootNode = worldMap.models[0].headNodes[0]
  ensureNativeWorld(worldMap, worldSurfaces)
  originX = entity.origin.x
  originY = entity.origin.y
  originZ = entity.origin.z
  modelScaleX = scaleX
  modelScaleY = scaleY
  modelScaleZ = scaleZ
  modelOffsetX = offsetX
  modelOffsetY = offsetY
  modelOffsetZ = offsetZ
  yaw = entity.angles.y * math.DEG_TO_RAD
  pitch = entity.angles.x * pitchSign * math.DEG_TO_RAD
  roll = entity.angles.z * math.DEG_TO_RAD
  yawCos = native.cos(yaw)
  yawSin = native.sin(yaw)
  pitchCos = native.cos(pitch)
  pitchSin = native.sin(pitch)
  rollCos = native.cos(roll)
  rollSin = native.sin(roll)
  pointLightActive = lightActive
  pointLightX = lightX
  pointLightY = lightY
  pointLightZ = lightZ
  ready = true
  return true
end function

// Configure an MDL caster using the exact GLQuake alias transform, including
// the doubled-eyes compatibility special case.
function configureAlias(worldMap, worldSurfaces, entity, model, doubleEyes, lightActive, lightX, lightY, lightZ)
  if model is void then return false end if
  scaleX = model.scale.x
  scaleY = model.scale.y
  scaleZ = model.scale.z
  offsetX = model.scaleOrigin.x
  offsetY = model.scaleOrigin.y
  offsetZ = model.scaleOrigin.z
  if doubleEyes then
    scaleX = scaleX * 2.0
    scaleY = scaleY * 2.0
    scaleZ = scaleZ * 2.0
    offsetZ = offsetZ - 30.0
  end if
  return configureCaster(
    worldMap, worldSurfaces, entity,
    scaleX, scaleY, scaleZ, offsetX, offsetY, offsetZ,
    -1.0, lightActive, lightX, lightY, lightZ,
  )
end function

// Configure an inline or external BSP caster. Brush model vertices are already
// expressed in model-local world units and use the positive pitch transform.
function configureBrush(worldMap, worldSurfaces, entity, lightActive, lightX, lightY, lightZ)
  return configureCaster(
    worldMap, worldSurfaces, entity,
    1.0, 1.0, 1.0, 0.0, 0.0, 0.0,
    1.0, lightActive, lightX, lightY, lightZ,
  )
end function

// Begin one hard-shadow or area-light sample and invalidate cached projected
// vertices by advancing a generation counter instead of clearing large arrays.
function beginProjectionSample(offsetX, offsetY)
  global sampleOffsetX, sampleOffsetY, projectionGeneration, projectionStamp
  sampleOffsetX = offsetX
  sampleOffsetY = offsetY
  projectionGeneration = projectionGeneration + 1
  if projectionGeneration > 1000000000 then
    projectionStamp = array(len(projectionStamp), 0)
    projectionGeneration = 1
  end if
  return ready
end function

// Start an independently indexed brush polygon while retaining the current
// light sample. Alias triangles deliberately share one generation so repeated
// MDL vertex indexes are traced only once.
function beginPrimitive()
  return beginProjectionSample(sampleOffsetX, sampleOffsetY)
end function

// Transform one model vertex and pack its finite light segment for either the
// native BVH batch or the scalar MiniLang fallback.
function prepareVertexRay(index, packedX, packedY, packedZ)
  global projectionStamp, projectionValid, sourceX, sourceY, sourceZ
  global minimumHitFraction, rayPreparedValid, rayPacket
  if not ready or index < 0 then return false end if
  ensureVertexCapacity(index)
  projectionStamp[index] = projectionGeneration
  projectionValid[index] = false
  rayPreparedValid[index] = false

  localX = packedX * modelScaleX + modelOffsetX
  localY = packedY * modelScaleY + modelOffsetY
  localZ = packedZ * modelScaleZ + modelOffsetZ
  rolledX = localX
  rolledY = rollCos * localY - rollSin * localZ
  rolledZ = rollSin * localY + rollCos * localZ
  pitchedX = pitchCos * rolledX + pitchSin * rolledZ
  pitchedY = rolledY
  pitchedZ = -pitchSin * rolledX + pitchCos * rolledZ
  worldX = originX + yawCos * pitchedX - yawSin * pitchedY
  worldY = originY + yawSin * pitchedX + yawCos * pitchedY
  worldZ = originZ + pitchedZ
  sourceX[index] = worldX
  sourceY[index] = worldY
  sourceZ[index] = worldZ

  minimumFraction = 0.0
  rayStartX = worldX
  rayStartY = worldY
  rayStartZ = worldZ
  rayFinishX = worldX
  rayFinishY = worldY
  rayFinishZ = worldZ
  if pointLightActive then
    rayStartX = pointLightX + sampleOffsetX
    rayStartY = pointLightY + sampleOffsetY
    rayStartZ = pointLightZ
    deltaX = worldX - rayStartX
    deltaY = worldY - rayStartY
    deltaZ = worldZ - rayStartZ
    distance = native.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
    if distance < 0.5 then return false end if
    inverse = 1.0 / distance
    rayFinishX = worldX + deltaX * inverse * MAX_RECEIVER_DISTANCE
    rayFinishY = worldY + deltaY * inverse * MAX_RECEIVER_DISTANCE
    rayFinishZ = worldZ + deltaZ * inverse * MAX_RECEIVER_DISTANCE
    minimumFraction = (distance + 0.25) / (distance + MAX_RECEIVER_DISTANCE)
  else
    // Parallel fallback rays represent the dominant baked-light direction when
    // the BSP lightmap has no recoverable point-light source.
    deltaX = 0.45 + sampleOffsetX * 0.018
    deltaY = 0.35 + sampleOffsetY * 0.018
    deltaZ = -1.0
    distance = native.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
    inverse = 1.0 / distance
    deltaX = deltaX * inverse
    deltaY = deltaY * inverse
    deltaZ = deltaZ * inverse
    rayStartX = worldX + deltaX * 0.25
    rayStartY = worldY + deltaY * 0.25
    rayStartZ = worldZ + deltaZ * 0.25
    rayFinishX = worldX + deltaX * MAX_RECEIVER_DISTANCE
    rayFinishY = worldY + deltaY * MAX_RECEIVER_DISTANCE
    rayFinishZ = worldZ + deltaZ * MAX_RECEIVER_DISTANCE
  end if

  minimumHitFraction[index] = minimumFraction
  offset = index * 24
  byteio.putF32(rayPacket, offset, rayStartX)
  byteio.putF32(rayPacket, offset + 4, rayStartY)
  byteio.putF32(rayPacket, offset + 8, rayStartZ)
  byteio.putF32(rayPacket, offset + 12, rayFinishX)
  byteio.putF32(rayPacket, offset + 16, rayFinishY)
  byteio.putF32(rayPacket, offset + 20, rayFinishZ)
  rayPreparedValid[index] = true
  return true
end function

// Validate and store one native or scalar ray result with a receiver-normal
// bias that prevents depth fighting on the actual world polygon.
function acceptProjection(index, hit, fraction, hitX, hitY, hitZ, normalX, normalY, normalZ)
  global projectionValid, projectionX, projectionY, projectionZ
  global projectionNormalX, projectionNormalY, projectionNormalZ
  global projectionTravel
  if not hit or not rayPreparedValid[index] then return false end if
  if fraction <= minimumHitFraction[index] then return false end if
  // A near point light can otherwise magnify individual MDL triangles across
  // an entire room. Three-times caster distance retains natural perspective
  // while rejecting unstable grazing projections.
  if pointLightActive and minimumHitFraction[index] > 0.0 and fraction > minimumHitFraction[index] * 3.0 then return false end if
  projectionX[index] = hitX + normalX * RECEIVER_BIAS
  projectionY[index] = hitY + normalY * RECEIVER_BIAS
  projectionZ[index] = hitZ + normalZ * RECEIVER_BIAS
  projectionNormalX[index] = normalX
  projectionNormalY[index] = normalY
  projectionNormalZ[index] = normalZ
  travelX = hitX - sourceX[index]
  travelY = hitY - sourceY[index]
  travelZ = hitZ - sourceZ[index]
  projectionTravel[index] = native.sqrt(travelX * travelX + travelY * travelY + travelZ * travelZ)
  projectionValid[index] = true
  return true
end function

// Trace the prepared prefix as one native BVH batch, falling back to the
// allocation-free render-BSP walker if the native acceleration is unavailable.
function tracePreparedVertices(count)
  global projectionValid, hitPacket
  // Prefer one packed native traversal for the prepared prefix. Only if that
  // acceleration is unavailable, replay the same rays through the render BSP.
  if count <= 0 then return 0 end if
  traced = 0
  if nativeWorldReady and native.shadowTraceBatch(rayPacket, count * 24, hitPacket, count * 32) == count then
    index = 0
    while index < count
      if projectionStamp[index] == projectionGeneration and rayPreparedValid[index] then
        offset = index * 32
        if acceptProjection(
          index, byteio.f32(hitPacket, offset) > 0.5,
          byteio.f32(hitPacket, offset + 4),
          byteio.f32(hitPacket, offset + 8), byteio.f32(hitPacket, offset + 12), byteio.f32(hitPacket, offset + 16),
          byteio.f32(hitPacket, offset + 20), byteio.f32(hitPacket, offset + 24), byteio.f32(hitPacket, offset + 28),
        ) then traced = traced + 1 end if
      end if
      index = index + 1
    end while
    return traced
  end if

  index = 0
  while index < count
    if projectionStamp[index] == projectionGeneration and rayPreparedValid[index] then
      offset = index * 24
      if glRlight.ShadowRay(
        activeMap, activeSurfaces, activeRootNode,
        byteio.f32(rayPacket, offset), byteio.f32(rayPacket, offset + 4), byteio.f32(rayPacket, offset + 8),
        byteio.f32(rayPacket, offset + 12), byteio.f32(rayPacket, offset + 16), byteio.f32(rayPacket, offset + 20),
      ) then
        if acceptProjection(
          index, true, glRlight.ShadowRayFraction(),
          glRlight.ShadowRayX(), glRlight.ShadowRayY(), glRlight.ShadowRayZ(),
          glRlight.ShadowRayNormalX(), glRlight.ShadowRayNormalY(), glRlight.ShadowRayNormalZ(),
        ) then traced = traced + 1 end if
      end if
    end if
    index = index + 1
  end while
  return traced
end function

// Trace every MDL frame vertex through one native call for the current sample.
function projectAliasVertices(vertices)
  if len(vertices) == 0 then return 0 end if
  ensureVertexCapacity(len(vertices) - 1)
  index = 0
  while index < len(vertices)
    vertex = vertices[index]
    prepareVertexRay(index, vertex.x, vertex.y, vertex.z)
    index = index + 1
  end while
  return tracePreparedVertices(len(vertices))
end function

// Trace every vertex of one BSP caster polygon through one native call.
function projectBrushVertices(vertices)
  if len(vertices) == 0 then return 0 end if
  ensureVertexCapacity(len(vertices) - 1)
  index = 0
  while index < len(vertices)
    point = vertices[index].position
    prepareVertexRay(index, point.x, point.y, point.z)
    index = index + 1
  end while
  return tracePreparedVertices(len(vertices))
end function

// Project an individual vertex for diagnostics and compatibility callers. The
// production alias/brush paths use the two batch entry points above.
function projectVertex(index, packedX, packedY, packedZ)
  if not ready or index < 0 then return false end if
  ensureVertexCapacity(index)
  if projectionStamp[index] == projectionGeneration then return projectionValid[index] end if
  if not prepareVertexRay(index, packedX, packedY, packedZ) then return false end if
  tracePreparedVertices(index + 1)
  return projectionValid[index]
end function

// Reject receiver discontinuities before the rasterizer interpolates a source
// edge across empty space.  The allowance scales with the caster edge so a
// normal slope remains intact, while an adjacent ledge/floor pair cannot form
// the long translucent triangles previously visible around crate corners.
function inline receiverEdgeContinuity(sourceLength, projectedLength, travelDifference)
  if projectedLength > sourceLength * 3.0 + 24.0 then return false end if
  return travelDifference <= sourceLength * 1.5 + 12.0
end function

// Test one projected edge for a compatible receiver plane and bounded stretch.
function receiverEdgeCompatible(left, right)
  normalDot = projectionNormalX[left] * projectionNormalX[right] + projectionNormalY[left] * projectionNormalY[right] + projectionNormalZ[left] * projectionNormalZ[right]
  if normalDot < 0.65 then return false end if
  sourceDeltaX = sourceX[left] - sourceX[right]
  sourceDeltaY = sourceY[left] - sourceY[right]
  sourceDeltaZ = sourceZ[left] - sourceZ[right]
  sourceLength = native.sqrt(sourceDeltaX * sourceDeltaX + sourceDeltaY * sourceDeltaY + sourceDeltaZ * sourceDeltaZ)
  projectedDeltaX = projectionX[left] - projectionX[right]
  projectedDeltaY = projectionY[left] - projectionY[right]
  projectedDeltaZ = projectionZ[left] - projectionZ[right]
  projectedLength = native.sqrt(projectedDeltaX * projectedDeltaX + projectedDeltaY * projectedDeltaY + projectedDeltaZ * projectedDeltaZ)
  travelDifference = projectionTravel[left] - projectionTravel[right]
  if travelDifference < 0.0 then travelDifference = -travelDifference end if
  return receiverEdgeContinuity(sourceLength, projectedLength, travelDifference)
end function

// Reject a triangle whose rays land across an abrupt BSP corner or stretch far
// beyond its source edge. Skipping that triangle prevents geometry from being
// interpolated through a wall between otherwise individually valid hits.
function receiverTriangleCompatible(first, second, third)
  if not receiverEdgeCompatible(first, second) then return false end if
  if not receiverEdgeCompatible(second, third) then return false end if
  if not receiverEdgeCompatible(third, first) then return false end if
  return true
end function

// Return one cached projected x coordinate.
function inline projectedPointX(index)
  return projectionX[index]
end function

// Return one cached projected y coordinate.
function inline projectedPointY(index)
  return projectionY[index]
end function

// Return one cached projected z coordinate.
function inline projectedPointZ(index)
  return projectionZ[index]
end function

// Report whether one vertex reached a compatible receiver in this sample.
function inline projectedPointValid(index)
  return index >= 0 and index < len(projectionValid) and projectionStamp[index] == projectionGeneration and projectionValid[index]
end function

// Report whether the current caster has a valid render-BSP context.
function inline isReady()
  return ready
end function
