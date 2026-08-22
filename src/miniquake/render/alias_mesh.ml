/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.render.alias_mesh.
*/
package miniquake.render.alias_mesh

import miniquake.types as compatAliasTypes
import miniquake.native as compatAliasNative
import miniquake.mathlib as compatAliasMath
import miniquake.array_util as compatAliasArrays
import miniquake.byteio as compatAliasBytes
import miniquake.render.gl11 as compatAliasGl
import miniquake.render.alias_normals as compatAliasNormals
import miniquake.render.ray_shadow as rayShadow

// gl_mesh.c / alias-draw state.  MiniLang arrays replace the fixed C work
// buffers but the strip/fan selection and vertex ordering are unchanged.
struct AliasMeshVertex
  vertexIndex
  s
  t
end struct

// Group the fields that describe one alias mesh command.
struct AliasMeshCommand
  count
  vertices
end struct

// Group the fields that describe one alias mesh.
struct AliasMesh
  commands
  vertexOrder
  numCommands
  numOrder
end struct

const ALIAS_MESH_CACHE_SIZE = 512
const ALIAS_BATCH_CACHE_SIZE = 4096

aliasmodel = void
paliashdr = void
triangles = []
stverts = []
used = []
commands = []
numcommands = 0
vertexorder = []
numorder = 0
allverts = 0
alltris = 0
stripverts = []
striptris = []
stripcount = 0
lastposenum = void
shadelight = 1.0
ambientlight = 0.0
shadevector = compatAliasTypes.Vec3(0.0, 0.0, 1.0)
shadedots = compatAliasNormals.shadeDots[0]
shadeRow = 0
lightspot = compatAliasTypes.Vec3(0.0, 0.0, 0.0)
shadowPointLightActive = false
shadowPointLightX = 0.0
shadowPointLightY = 0.0
shadowPointLightZ = 0.0
currentAliasFrame = void
meshCacheModelKeys = array(ALIAS_MESH_CACHE_SIZE, 0)
meshCacheValues = array(ALIAS_MESH_CACHE_SIZE)
aliasBatchFrameKeys = array(ALIAS_BATCH_CACHE_SIZE, 0)
aliasBatchMeshKeys = array(ALIAS_BATCH_CACHE_SIZE, 0)
aliasBatchValues = array(ALIAS_BATCH_CACHE_SIZE)
aliasShadeDotRows = array(16, void)

// Update module state for caches.
function clearCaches()
  global meshCacheModelKeys, meshCacheValues, aliasBatchFrameKeys, aliasBatchMeshKeys, aliasBatchValues
  meshCacheModelKeys = array(ALIAS_MESH_CACHE_SIZE, 0)
  meshCacheValues = array(ALIAS_MESH_CACHE_SIZE)
  aliasBatchFrameKeys = array(ALIAS_BATCH_CACHE_SIZE, 0)
  aliasBatchMeshKeys = array(ALIAS_BATCH_CACHE_SIZE, 0)
  aliasBatchValues = array(ALIAS_BATCH_CACHE_SIZE)
  return true
end function

// Provide triangle vertex behavior for the active subsystem.
function triangleVertex(triangle, index)
  if index == 0 then return triangle.vertex0 end if
  if index == 1 then return triangle.vertex1 end if
  return triangle.vertex2
end function

// Update subsystem configuration for configure alias model.
function configureAliasModel(model)
  global aliasmodel, paliashdr, triangles, stverts, used, stripverts, striptris
  aliasmodel = model
  paliashdr = model
  triangles = model.triangles
  stverts = model.texCoords
  used = compatAliasArrays.makeFilledArray(len(triangles), 0)
  stripverts = compatAliasArrays.makeFilledArray(1024, 0)
  striptris = compatAliasArrays.makeFilledArray(1024, 0)
  return model
end function

// Provide shade dot row behavior for the active subsystem.
function shadeDotRow(yaw)
  return (compatAliasNative.trunc(yaw * (16.0 / 360.0))) & 15
end function

// Update subsystem configuration for configure alias lighting.
function configureAliasLighting(lightValue, ambientValue, yaw, spot)
  global shadelight, ambientlight, shadevector, shadedots, shadeRow, lightspot
  shadelight = lightValue
  ambientlight = ambientValue
  row = shadeDotRow(yaw)
  shadeRow = row
  shadedots = compatAliasNormals.shadeDots[row]
  angle = yaw * compatAliasMath.DEG_TO_RAD
  // This function runs once for every visible alias entity.  Mutate the
  // persistent gl_rmain-style vector instead of allocating an input Vec3 and
  // a normalized copy for every monster, pickup and view model.
  shadeX = compatAliasNative.cos(-angle)
  shadeY = compatAliasNative.sin(-angle)
  magnitude = compatAliasNative.sqrt(shadeX * shadeX + shadeY * shadeY + 1.0)
  if magnitude != 0.0 then
    inverseMagnitude = 1.0 / magnitude
    persistentShade = shadevector
    persistentShade.x = shadeX * inverseMagnitude
    persistentShade.y = shadeY * inverseMagnitude
    persistentShade.z = inverseMagnitude
    shadevector = persistentShade
  end if
  if spot is not void then lightspot = spot end if
  return true
end function

// Select a model-local point light for physically directed projected shadows.
// Disabling it retains GLQuake's stable directional fallback.
function configureAliasShadowPointLight(enabled, x, y, z)
  global shadowPointLightActive, shadowPointLightX, shadowPointLightY, shadowPointLightZ
  shadowPointLightActive = enabled
  shadowPointLightX = x
  shadowPointLightY = y
  shadowPointLightZ = z
  return shadowPointLightActive
end function

// Exact gl_mesh.c candidate-strip walk.  Temporary used==2 markers are
// cleared after each candidate while the starting triangle remains selected.
function StripLength(starttri, startv)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global stripcount
  if starttri < 0 or starttri >= len(triangles) then return 0 end if
  used[starttri] = 2
  last = triangles[starttri]
  stripverts[0] = triangleVertex(last, startv % 3)
  stripverts[1] = triangleVertex(last, (startv + 1) % 3)
  stripverts[2] = triangleVertex(last, (startv + 2) % 3)
  striptris[0] = starttri
  stripcount = 1
  m1 = triangleVertex(last, (startv + 2) % 3)
  m2 = triangleVertex(last, (startv + 1) % 3)

  searching = true
  while searching
    searching = false
    j = starttri + 1
    while j < len(triangles)
      check = triangles[j]
      if check.facesFront == last.facesFront then
        k = 0
        matched = false
        while k < 3 and not matched
          if triangleVertex(check, k) == m1 and triangleVertex(check, (k + 1) % 3) == m2 then
            matched = true
            if used[j] == 0 then
              nextVertex = triangleVertex(check, (k + 2) % 3)
              if (stripcount & 1) != 0 then m2 = nextVertex else m1 = nextVertex end if
              stripverts[stripcount + 2] = nextVertex
              striptris[stripcount] = j
              stripcount = stripcount + 1
              used[j] = 2
              searching = true
            end if
          end if
          k = k + 1
        end while
        if matched then break end if
      end if
      j = j + 1
    end while
  end while

  j = starttri + 1
  while j < len(triangles)
    if used[j] == 2 then used[j] = 0 end if
    j = j + 1
  end while
  return stripcount
end function

// Return fan length derived from the active module state.
function FanLength(starttri, startv)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global stripcount
  if starttri < 0 or starttri >= len(triangles) then return 0 end if
  used[starttri] = 2
  last = triangles[starttri]
  stripverts[0] = triangleVertex(last, startv % 3)
  stripverts[1] = triangleVertex(last, (startv + 1) % 3)
  stripverts[2] = triangleVertex(last, (startv + 2) % 3)
  striptris[0] = starttri
  stripcount = 1
  m1 = triangleVertex(last, startv % 3)
  m2 = triangleVertex(last, (startv + 2) % 3)

  searching = true
  while searching
    searching = false
    j = starttri + 1
    while j < len(triangles)
      check = triangles[j]
      if check.facesFront == last.facesFront then
        k = 0
        matched = false
        while k < 3 and not matched
          if triangleVertex(check, k) == m1 and triangleVertex(check, (k + 1) % 3) == m2 then
            matched = true
            if used[j] == 0 then
              m2 = triangleVertex(check, (k + 2) % 3)
              stripverts[stripcount + 2] = m2
              striptris[stripcount] = j
              stripcount = stripcount + 1
              used[j] = 2
              searching = true
            end if
          end if
          k = k + 1
        end while
        if matched then break end if
      end if
      j = j + 1
    end while
  end while

  j = starttri + 1
  while j < len(triangles)
    if used[j] == 2 then used[j] = 0 end if
    j = j + 1
  end while
  return stripcount
end function

// Create and initialize tris.
function BuildTris()
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global used, commands, numcommands, vertexorder, numorder, allverts, alltris
  if paliashdr is void then return error(3900, "BuildTris: no alias header") end if
  used = compatAliasArrays.makeFilledArray(len(triangles), 0)
  commandBuilder = compatAliasArrays.createArrayBuilder(len(triangles) + 1)
  orderBuilder = compatAliasArrays.createArrayBuilder(len(triangles) * 3)
  numorder = 0
  numcommands = 0
  i = 0
  while i < len(triangles)
    if used[i] == 0 then
      bestlen = 0
      besttype = 0
      bestverts = []
      besttris = []
      type = 0
      while type < 2
        startv = 0
        while startv < 3
          candidateLength = FanLength(i, startv)
          if type == 1 then candidateLength = StripLength(i, startv) end if
          if candidateLength > bestlen then
            besttype = type
            bestlen = candidateLength
            bestverts = compatAliasArrays.makeEmptyArray(bestlen + 2)
            j = 0
            while j < bestlen + 2
              bestverts[j] = stripverts[j]
              j = j + 1
            end while
            besttris = compatAliasArrays.makeEmptyArray(bestlen)
            j = 0
            while j < bestlen
              besttris[j] = striptris[j]
              j = j + 1
            end while
          end if
          startv = startv + 1
        end while
        type = type + 1
      end while

      j = 0
      while j < bestlen
        used[besttris[j]] = 1
        j = j + 1
      end while
      count = -(bestlen + 2)
      if besttype == 1 then count = bestlen + 2 end if
      commandVertices = compatAliasArrays.makeEmptyArray(bestlen + 2)
      j = 0
      while j < bestlen + 2
        vertexIndex = bestverts[j]
        compatAliasArrays.pushArrayBuilder(orderBuilder, vertexIndex)
        s = stverts[vertexIndex].s
        textureT = stverts[vertexIndex].t
        if triangles[besttris[0]].facesFront == 0 and stverts[vertexIndex].onSeam != 0 then
          s = s + paliashdr.skinWidth / 2
        end if
        s = (s + 0.5) / paliashdr.skinWidth
        textureT = (textureT + 0.5) / paliashdr.skinHeight
        commandVertices[j] = AliasMeshVertex(vertexIndex, s, textureT)
        j = j + 1
      end while
      compatAliasArrays.pushArrayBuilder(commandBuilder, AliasMeshCommand(count, commandVertices))
      numcommands = numcommands + 1 + (bestlen + 2) * 2
    end if
    i = i + 1
  end while
  compatAliasArrays.pushArrayBuilder(commandBuilder, AliasMeshCommand(0, []))
  numcommands = numcommands + 1
  commands = compatAliasArrays.finishArrayBuilder(commandBuilder)
  vertexorder = compatAliasArrays.finishArrayBuilder(orderBuilder)
  numorder = len(vertexorder)
  allverts = allverts + numorder
  alltris = alltris + len(triangles)
  return AliasMesh(commands, vertexorder, numcommands, numorder)
end function

// Provide cached mesh behavior for the active subsystem.
function cachedMesh(model)
  key = nativeRawValue(model)
  slot = ((key >> 3) ^ (key >> 13)) & (ALIAS_MESH_CACHE_SIZE - 1)
  start = slot
  while meshCacheValues[slot] is not void
    if meshCacheModelKeys[slot] == key then return meshCacheValues[slot] end if
    slot = (slot + 1) & (ALIAS_MESH_CACHE_SIZE - 1)
    if slot == start then return void end if
  end while
  return void
end function

// Mirror Quake's GL_MakeAliasModelDisplayLists routine and its observable state changes.
function GL_MakeAliasModelDisplayLists(model, header)
  global meshCacheModelKeys, meshCacheValues, paliashdr
  existing = cachedMesh(model)
  if existing is not void then return existing end if
  configureAliasModel(model)
  if header is not void then paliashdr = header end if
  result = BuildTris()
  if result is error then return result end if
  key = nativeRawValue(model)
  slot = ((key >> 3) ^ (key >> 13)) & (ALIAS_MESH_CACHE_SIZE - 1)
  start = slot
  while meshCacheValues[slot] is not void and meshCacheModelKeys[slot] != key
    slot = (slot + 1) & (ALIAS_MESH_CACHE_SIZE - 1)
    if slot == start then break end if
  end while
  meshCacheModelKeys[slot] = key
  meshCacheValues[slot] = result
  return result
end function

// Advance for number by one processing step.
function frameForNumber(model, frameNumber, time)
  if len(model.frames) == 0 then return void end if
  index = frameNumber
  if index < 0 or index >= len(model.frames) then index = 0 end if
  set = model.frames[index]
  if len(set.frames) == 0 then return void end if
  if not set.grouped or len(set.frames) == 1 then return set.frames[0] end if
  if len(set.intervals) == 0 or set.intervals[0] <= 0.0 then return set.frames[0] end if
  pose = compatAliasNative.trunc(time / set.intervals[0]) % len(set.frames)
  return set.frames[pose]
end function

// Return a validated clamp byte value.
function clampByte(value)
  result = compatAliasNative.trunc(value)
  if result < 0 then result = 0 end if
  if result > 255 then result = 255 end if
  return result
end function

// Return alias batch data derived from the active module state.
function aliasBatchData(frame, mesh)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global aliasBatchFrameKeys, aliasBatchMeshKeys, aliasBatchValues
  frameKey = nativeRawValue(frame)
  meshKey = nativeRawValue(mesh)
  cacheIndex = ((frameKey >> 3) ^ (frameKey >> 17) ^ (meshKey >> 7)) & (ALIAS_BATCH_CACHE_SIZE - 1)
  cacheStart = cacheIndex
  cacheFull = false
  while aliasBatchValues[cacheIndex] is not void
    if aliasBatchFrameKeys[cacheIndex] == frameKey and aliasBatchMeshKeys[cacheIndex] == meshKey then
      return aliasBatchValues[cacheIndex]
    end if
    cacheIndex = (cacheIndex + 1) & (ALIAS_BATCH_CACHE_SIZE - 1)
    if cacheIndex == cacheStart then cacheFull = true; break end if
  end while

  byteCount = 4
  for each command in mesh.commands
    if command.count == 0 then break end if
    count = command.count
    if count < 0 then count = -count end if
    byteCount = byteCount + 4 + count * 12
  end for
  data = bytes(byteCount)
  offset = 0
  for each command in mesh.commands
    compatAliasBytes.putU32(data, offset, command.count & 4294967295)
    offset = offset + 4
    if command.count == 0 then break end if
    count = command.count
    if count < 0 then count = -count end if
    index = 0
    while index < count
      item = command.vertices[index]
      compatAliasBytes.putF32(data, offset, item.s)
      compatAliasBytes.putF32(data, offset + 4, item.t)
      if item.vertexIndex >= 0 and item.vertexIndex < len(frame.vertices) then
        packed = frame.vertices[item.vertexIndex]
        compatAliasBytes.putU8(data, offset + 8, packed.x)
        compatAliasBytes.putU8(data, offset + 9, packed.y)
        compatAliasBytes.putU8(data, offset + 10, packed.z)
        compatAliasBytes.putU8(data, offset + 11, packed.normalIndex)
      end if
      offset = offset + 12
      index = index + 1
    end while
  end for
  if cacheFull then cacheIndex = cacheStart end if
  aliasBatchFrameKeys[cacheIndex] = frameKey
  aliasBatchMeshKeys[cacheIndex] = meshKey
  aliasBatchValues[cacheIndex] = data
  return data
end function

// Preload and register the alias model asset.
function precacheAliasModel(model)
  if model is void then return 0 end if
  mesh = try(GL_MakeAliasModelDisplayLists(model, model))
  if mesh is error then return mesh end if
  count = 0
  for each frameSet in model.frames
    for each frame in frameSet.frames
      aliasBatchData(frame, mesh)
      count = count + 1
    end for
  end for
  return count
end function

// Return alias shade dot data derived from the active module state.
function aliasShadeDotData(row)
  global aliasShadeDotRows
  existing = aliasShadeDotRows[row]
  if existing is not void then return existing end if
  values = compatAliasNormals.shadeDots[row]
  data = bytes(len(values) * 4)
  index = 0
  while index < len(values)
    compatAliasBytes.putF32(data, index * 4, values[index])
    index = index + 1
  end while
  aliasShadeDotRows[row] = data
  return data
end function

// Build the sixteen yaw-dependent shadedot tables during level precaching.
function precacheAliasLightingRows()
  index = 0
  while index < len(aliasShadeDotRows)
    aliasShadeDotData(index)
    index = index + 1
  end while
  return index
end function

// Render alias mesh.
function drawAliasMesh(model, frame, mesh)
  if frame is void or mesh is void then return 0 end if
  if not compatAliasGl.traceEnabled() and compatAliasGl.nativeBatchAvailable() then
    batch = aliasBatchData(frame, mesh)
    dots = aliasShadeDotData(shadeRow)
    return compatAliasNative.glDrawAliasBatch(batch, len(batch), dots, len(shadedots), compatAliasNative.floatBits(shadelight))
  end if
  drawn = 0
  for each command in mesh.commands
    if command.count == 0 then break end if
    count = command.count
    mode = compatAliasGl.GL_TRIANGLE_STRIP
    if count < 0 then count = -count; mode = compatAliasGl.GL_TRIANGLE_FAN end if
    compatAliasGl.begin(mode)
    index = 0
    while index < count and index < len(command.vertices)
      item = command.vertices[index]
      if item.vertexIndex >= 0 and item.vertexIndex < len(frame.vertices) then
        packed = frame.vertices[item.vertexIndex]
        normalIndex = packed.normalIndex
        light = shadelight
        if normalIndex >= 0 and normalIndex < len(shadedots) then light = shadedots[normalIndex] * shadelight end if
        colorValue = clampByte(light * 255.0)
        compatAliasGl.color(colorValue, colorValue, colorValue, 255)
        compatAliasGl.texcoord2(item.s, item.t)
        compatAliasGl.vertex3(packed.x, packed.y, packed.z)
      end if
      index = index + 1
    end while
    compatAliasGl.finishPrimitive()
    drawn = drawn + count - 2
  end for
  return drawn
end function

// Render alias model batch.
function drawAliasModelBatch(model, frame, mesh, origin, angles, doubleEyes, smooth)
  batch = aliasBatchData(frame, mesh)
  dots = aliasShadeDotData(shadeRow)
  eyesValue = 0
  smoothValue = 0
  if doubleEyes then eyesValue = 1 end if
  if smooth then smoothValue = 1 end if
  return compatAliasNative.glDrawAliasModel(
    batch, len(batch), dots, len(shadedots), compatAliasNative.floatBits(shadelight),
    compatAliasNative.floatBits(origin.x), compatAliasNative.floatBits(origin.y), compatAliasNative.floatBits(origin.z),
    compatAliasNative.floatBits(angles.x), compatAliasNative.floatBits(angles.y), compatAliasNative.floatBits(angles.z),
    compatAliasNative.floatBits(model.scaleOrigin.x), compatAliasNative.floatBits(model.scaleOrigin.y), compatAliasNative.floatBits(model.scaleOrigin.z),
    compatAliasNative.floatBits(model.scale.x), compatAliasNative.floatBits(model.scale.y), compatAliasNative.floatBits(model.scale.z),
    eyesValue, smoothValue,
  )
end function

// Mirror Quake's GL_DrawAliasFrame routine and its observable state changes.
function GL_DrawAliasFrame(header, posenum)
  global lastposenum, currentAliasFrame
  model = header
  if model is void then model = paliashdr end if
  if model is void then return 0 end if
  frame = posenum
  if posenum is int then frame = frameForNumber(model, posenum, 0.0) end if
  if frame is void then return 0 end if
  mesh = GL_MakeAliasModelDisplayLists(model, model)
  lastposenum = frame
  currentAliasFrame = frame
  return drawAliasMesh(model, frame, mesh)
end function

// Provide alias shadow projection behavior for the active subsystem.
function aliasShadowProjection(entityOriginZ, lightSpotZ)
  lheight = entityOriginZ - lightSpotZ
  return [lheight, -lheight + 1.0]
end function

// gl_rmain.c computes the projected height from currententity->origin[2].
// The vertex coordinates below are still model-local because the entity
// transform is already active on the GL matrix stack.
function drawAliasShadowProjectionSampleAtOrigin(header, posenum, entityOriginZ, offsetX, offsetY, contactOnly)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  model = header
  if model is void then model = paliashdr end if
  if model is void then return 0 end if
  frame = posenum
  if posenum is int then frame = frameForNumber(model, posenum, 0.0) end if
  if frame is void then return 0 end if
  mesh = GL_MakeAliasModelDisplayLists(model, model)
  projection = aliasShadowProjection(entityOriginZ, lightspot.z)
  heightDifference = projection[0]
  height = projection[1]
  drawn = 0
  for each command in mesh.commands
    if command.count == 0 then break end if
    count = command.count
    mode = compatAliasGl.GL_TRIANGLE_STRIP
    if count < 0 then count = -count; mode = compatAliasGl.GL_TRIANGLE_FAN end if
    compatAliasGl.begin(mode)
    index = 0
    while index < count and index < len(command.vertices)
      item = command.vertices[index]
      if item.vertexIndex >= 0 and item.vertexIndex < len(frame.vertices) then
        packed = frame.vertices[item.vertexIndex]
        // Keep the soft-shadow replay allocation-free.  The former Vec3 per
        // vertex became costly when the high-quality path emitted five taps.
        pointX = packed.x * model.scale.x + model.scaleOrigin.x
        pointY = packed.y * model.scale.y + model.scaleOrigin.y
        pointZ = packed.z * model.scale.z + model.scaleOrigin.z
        // The contact pass projects vertically and therefore remains visible
        // around an actor's feet from the normal first-person viewpoint.  The
        // following directional pass retains the light-driven silhouette.
        projectedX = pointX
        projectedY = pointY
        if not contactOnly then
          projectedX = pointX - shadevector.x * (pointZ + heightDifference)
          projectedY = pointY - shadevector.y * (pointZ + heightDifference)
          if shadowPointLightActive and shadowPointLightZ > height + 8.0 then
            denominator = pointZ - shadowPointLightZ
            if denominator < -0.001 or denominator > 0.001 then
              fraction = (height - shadowPointLightZ) / denominator
              // Reject grazing projections that would stretch across an entire
              // room; the directional fallback is more stable in that case.
              if fraction >= 0.0 and fraction <= 4.0 then
                projectedX = shadowPointLightX + (pointX - shadowPointLightX) * fraction
                projectedY = shadowPointLightY + (pointY - shadowPointLightY) * fraction
              end if
            end if
          end if
        end if
        projectedX = projectedX + offsetX
        projectedY = projectedY + offsetY
        compatAliasGl.vertex3(projectedX, projectedY, height)
      end if
      index = index + 1
    end while
    compatAliasGl.finishPrimitive()
    drawn = drawn + count - 2
  end for
  return drawn
end function

// Draw one vertically projected model footprint as the stable contact core of
// the enhanced shadow.  This is still the model mesh, not a generic blob.
function GL_DrawAliasContactShadowAtOrigin(header, posenum, entityOriginZ)
  return drawAliasShadowProjectionSampleAtOrigin(header, posenum, entityOriginZ, 0.0, 0.0, true)
end function

// Draw one directional projected-shadow sample with the requested penumbra
// offset while retaining the public GLQuake-compatible entry point.
function GL_DrawAliasShadowSampleAtOrigin(header, posenum, entityOriginZ, offsetX, offsetY)
  return drawAliasShadowProjectionSampleAtOrigin(header, posenum, entityOriginZ, offsetX, offsetY, false)
end function

// Draw the reference single-tap projected alias silhouette.
function GL_DrawAliasShadowAtOrigin(header, posenum, entityOriginZ)
  return GL_DrawAliasShadowSampleAtOrigin(header, posenum, entityOriginZ, 0.0, 0.0)
end function

// Project every MDL triangle along a real light ray onto the first compatible
// render-BSP polygon. The caster transform and world context are configured by
// the entity renderer immediately before this call.
function GL_DrawAliasRayShadowSample(header, posenum, entity, doubleEyes, pointLightEnabled, lightX, lightY, lightZ, offsetX, offsetY)
  model = header
  if model is void then model = paliashdr end if
  if model is void or not rayShadow.isReady() then return 0 end if
  frame = posenum
  if posenum is int then frame = frameForNumber(model, posenum, 0.0) end if
  if frame is void then return 0 end if
  mesh = GL_MakeAliasModelDisplayLists(model, model)
  // The production path keeps the cached MDL command stream, transform,
  // native BVH traversal and triangle submission within one bridge call.
  // Scalar projection below intentionally remains available to trace tests.
  if not compatAliasGl.traceEnabled() and compatAliasGl.nativeBatchAvailable() then
    batch = aliasBatchData(frame, mesh)
    eyesValue = 0
    pointValue = 0
    if doubleEyes then eyesValue = 1 end if
    if pointLightEnabled then pointValue = 1 end if
    return compatAliasNative.glDrawAliasRayShadow(
      batch, len(batch),
      compatAliasNative.floatBits(entity.origin.x), compatAliasNative.floatBits(entity.origin.y), compatAliasNative.floatBits(entity.origin.z),
      compatAliasNative.floatBits(entity.angles.x), compatAliasNative.floatBits(entity.angles.y), compatAliasNative.floatBits(entity.angles.z),
      compatAliasNative.floatBits(model.scaleOrigin.x), compatAliasNative.floatBits(model.scaleOrigin.y), compatAliasNative.floatBits(model.scaleOrigin.z),
      compatAliasNative.floatBits(model.scale.x), compatAliasNative.floatBits(model.scale.y), compatAliasNative.floatBits(model.scale.z),
      eyesValue, pointValue,
      compatAliasNative.floatBits(lightX), compatAliasNative.floatBits(lightY), compatAliasNative.floatBits(lightZ),
      compatAliasNative.floatBits(offsetX), compatAliasNative.floatBits(offsetY),
    )
  end if
  rayShadow.beginProjectionSample(offsetX, offsetY)
  rayShadow.projectAliasVertices(frame.vertices)
  compatAliasGl.begin(compatAliasGl.GL_TRIANGLES)
  drawn = 0
  for each triangle in model.triangles
    first = triangle.vertex0
    second = triangle.vertex1
    third = triangle.vertex2
    if first >= 0 and first < len(frame.vertices) and second >= 0 and second < len(frame.vertices) and third >= 0 and third < len(frame.vertices) then
      firstHit = rayShadow.projectedPointValid(first)
      secondHit = rayShadow.projectedPointValid(second)
      thirdHit = rayShadow.projectedPointValid(third)
      if firstHit and secondHit and thirdHit and rayShadow.receiverTriangleCompatible(first, second, third) then
        compatAliasGl.vertex3(rayShadow.projectedPointX(first), rayShadow.projectedPointY(first), rayShadow.projectedPointZ(first))
        compatAliasGl.vertex3(rayShadow.projectedPointX(second), rayShadow.projectedPointY(second), rayShadow.projectedPointZ(second))
        compatAliasGl.vertex3(rayShadow.projectedPointX(third), rayShadow.projectedPointY(third), rayShadow.projectedPointZ(third))
        drawn = drawn + 1
      end if
    end if
  end for
  compatAliasGl.finishPrimitive()
  return drawn
end function

// Compatibility entry point retained for the direct differential wrapper.
function GL_DrawAliasShadow(header, posenum)
  return GL_DrawAliasShadowAtOrigin(header, posenum, 0.0)
end function

// Apply the Quake-compatible r setup alias frame behavior.
function R_SetupAliasFrame(frame, header)
  global lastposenum, currentAliasFrame
  model = header
  if model is void then model = paliashdr end if
  if model is void then return 0 end if
  selected = frameForNumber(model, frame, 0.0)
  if selected is void then return 0 end if
  lastposenum = selected
  currentAliasFrame = selected
  return GL_DrawAliasFrame(model, selected)
end function

// Update module state for up alias frame at time.
function setupAliasFrameAtTime(frame, header, time)
  global lastposenum, currentAliasFrame
  model = header
  if model is void then model = paliashdr end if
  if model is void then return void end if
  selected = frameForNumber(model, frame, time)
  lastposenum = selected
  currentAliasFrame = selected
  return selected
end function
