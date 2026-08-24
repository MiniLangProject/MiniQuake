/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.render.entities.
*/
package miniquake.render.entities

import miniquake.types as t
import miniquake.constants as c
import miniquake.model_registry as modelRegistry
import miniquake.render.gl11 as gl
import miniquake.render.enhanced as enhanced
import miniquake.render.world as worldRenderer
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.array_util as arrayutil
import miniquake.mathlib as math
import miniquake.render.alias_mesh as aliasMesh
import miniquake.render.ray_shadow as rayShadow
import miniquake.render.draw2d as draw2d
import miniquake.render_ui_contract as renderUiContract
import miniquake.optimization_baseline as optBaseline

const MODEL_NONE = 0
const MODEL_BRUSH = 1
const MODEL_ALIAS = 2
const MODEL_SPRITE = 3

const SPR_ORIENTED = 3

translatedPlayerTextures = []
renderModelRegistry = void
aliasSmoothModels = true
aliasAffineModels = false
aliasShadows = false
aliasShadowQuality = 1
aliasNoColors = false
aliasDoubleEyes = true
aliasPoseInterpolation = false
aliasPosePrevious = []
aliasPoseCurrent = []
aliasPoseModels = []
aliasPoseChangeTimes = []
aliasShadeCacheValid = []
aliasShadeCacheStamp = []
aliasShadeCacheModel = []
aliasShadeCacheColormap = []
aliasShadeCacheViewModel = []
aliasShadeCacheOriginX = []
aliasShadeCacheOriginY = []
aliasShadeCacheOriginZ = []
aliasShadeCacheShade = []
aliasShadeCacheAmbient = []
aliasShadeCacheSpot = []
aliasShadeCacheReceiverHit = []
aliasLightingScratch = [0.0, 0.0, t.Vec3(0.0, 0.0, 0.0), false, 0.0, 0.0, 0.0, false]
brushShadowSourceScratch = [false, 0.0, 0.0, 0.0]
viewModelScratch = void
// Root complete external renderers (map, textures, surfaces and lightmaps) for
// the lifetime of the entity renderer.  These are independent BSP models and
// therefore are not owned by the active WorldRenderer.
externalBrushRendererRoots = []
externalBrushRendererNames = []

// Update module state for alias shade cache.
function resetAliasShadeCache()
  global aliasShadeCacheValid, aliasShadeCacheStamp, aliasShadeCacheModel
  global aliasShadeCacheColormap, aliasShadeCacheViewModel
  global aliasShadeCacheOriginX, aliasShadeCacheOriginY, aliasShadeCacheOriginZ
  global aliasShadeCacheShade, aliasShadeCacheAmbient, aliasShadeCacheSpot
  global aliasShadeCacheReceiverHit
  aliasShadeCacheValid = arrayutil.makeFilledArray(c.MAX_EDICTS, false)
  aliasShadeCacheStamp = arrayutil.makeFilledArray(c.MAX_EDICTS, -1)
  aliasShadeCacheModel = arrayutil.makeFilledArray(c.MAX_EDICTS, "")
  aliasShadeCacheColormap = arrayutil.makeFilledArray(c.MAX_EDICTS, 0)
  aliasShadeCacheViewModel = arrayutil.makeFilledArray(c.MAX_EDICTS, false)
  aliasShadeCacheOriginX = arrayutil.makeFilledArray(c.MAX_EDICTS, 0.0)
  aliasShadeCacheOriginY = arrayutil.makeFilledArray(c.MAX_EDICTS, 0.0)
  aliasShadeCacheOriginZ = arrayutil.makeFilledArray(c.MAX_EDICTS, 0.0)
  aliasShadeCacheShade = arrayutil.makeFilledArray(c.MAX_EDICTS, 0.0)
  aliasShadeCacheAmbient = arrayutil.makeFilledArray(c.MAX_EDICTS, 0.0)
  aliasShadeCacheSpot = arrayutil.makeEmptyArray(c.MAX_EDICTS)
  aliasShadeCacheReceiverHit = arrayutil.makeFilledArray(c.MAX_EDICTS, false)
  return true
end function

// Reset per-entity MDL pose history at every map/renderer transition.
function resetAliasPoseCache()
  global aliasPosePrevious, aliasPoseCurrent, aliasPoseModels, aliasPoseChangeTimes
  count = c.MAX_EDICTS + 1
  aliasPosePrevious = arrayutil.makeEmptyArray(count)
  aliasPoseCurrent = arrayutil.makeEmptyArray(count)
  aliasPoseModels = arrayutil.makeEmptyArray(count)
  aliasPoseChangeTimes = arrayutil.makeFilledArray(count, 0.0)
  return true
end function

// Update subsystem configuration for configure alias rendering.
function ConfigureAliasRendering(smoothModels, affineModels, shadows, noColors, doubleEyes)
  global aliasSmoothModels, aliasAffineModels, aliasShadows, aliasNoColors, aliasDoubleEyes
  aliasSmoothModels = smoothModels
  aliasAffineModels = affineModels
  aliasShadows = shadows
  aliasNoColors = noColors
  aliasDoubleEyes = doubleEyes
  return [
    aliasSmoothModels, aliasAffineModels, aliasShadows,
    aliasNoColors, aliasDoubleEyes,
  ]
end function

// Enable or disable temporal interpolation between consecutive MDL poses.
function ConfigureModelInterpolation(enabled)
  global aliasPoseInterpolation
  if aliasPoseInterpolation != enabled then resetAliasPoseCache() end if
  aliasPoseInterpolation = enabled
  return aliasPoseInterpolation
end function

// Provide alias rendering configuration behavior for the active subsystem.
function AliasRenderingConfiguration()
  return [
    aliasSmoothModels, aliasAffineModels, aliasShadows,
    aliasNoColors, aliasDoubleEyes,
  ]
end function

// Configure the backend-neutral projected-shadow sampling level.
function ConfigureEnhancedShadowQuality(value)
  global aliasShadowQuality
  aliasShadowQuality = native.trunc(value)
  if aliasShadowQuality < 0 then aliasShadowQuality = 0 end if
  if aliasShadowQuality > 2 then aliasShadowQuality = 2 end if
  return aliasShadowQuality
end function

// Initialize state for starts with.
function startsWith(text, prefix)
  left = bytes(text)
  right = bytes(prefix)
  if len(right) > len(left) then return false end if
  index = 0
  while index < len(right)
    if left[index] != right[index] then return false end if
    index = index + 1
  end while
  return true
end function

// Finalize state for ends with insensitive.
function endsWithInsensitive(text, suffix)
  left = bytes(bio.lower(text))
  right = bytes(bio.lower(suffix))
  if len(right) > len(left) then return false end if
  start = len(left) - len(right)
  index = 0
  while index < len(right)
    if left[start + index] != right[index] then return false end if
    index = index + 1
  end while
  return true
end function

// Provide empty model behavior for the active subsystem.
function emptyModel(name, kind)
  return t.ClientRenderModel(name, kind, void, void, void, [], false)
end function

// Return external brush for name derived from the active module state.
function externalBrushForName(name)
  index = 0
  while index < len(externalBrushRendererNames) and index < len(externalBrushRendererRoots)
    if externalBrushRendererNames[index] == name then return externalBrushRendererRoots[index] end if
    index = index + 1
  end while
  return void
end function

// Provide brush renderer for model behavior for the active subsystem.
function brushRendererForModel(model)
  if model is void then return void end if
  if model.brushRenderer is not void then return model.brushRenderer end if
  return externalBrushForName(model.name)
end function

// Read and validate model.
function loadModel(renderer, name)
  global renderModelRegistry
  if name == "" then return emptyModel(name, MODEL_NONE) end if
  if startsWith(name, "*") then return emptyModel(name, MODEL_BRUSH) end if
  if renderModelRegistry is void then renderModelRegistry = modelRegistry.Mod_Init(modelRegistry.create(), void) end if
  parsed = try(modelRegistry.Mod_ForName(renderModelRegistry, renderer.filesystem, name, false))
  if parsed is error then
    // GLQuake's Mod_ForName(..., true) turns a failed precache into a host
    // error. Preserve that behaviour for external BSPs instead of silently
    // treating a broken ammo/health model as MODEL_NONE.
    if endsWithInsensitive(name, ".bsp") then return emptyModel(name, MODEL_BRUSH) end if
    return emptyModel(name, MODEL_NONE)
  end if
  if parsed is void then
    if endsWithInsensitive(name, ".bsp") then return emptyModel(name, MODEL_BRUSH) end if
    return emptyModel(name, MODEL_NONE)
  end if
  kind = modelRegistry.modelType(renderModelRegistry, name)
  if kind == modelRegistry.MOD_ALIAS then return t.ClientRenderModel(name, MODEL_ALIAS, parsed, void, void, [], false) end if
  if kind == modelRegistry.MOD_SPRITE then return t.ClientRenderModel(name, MODEL_SPRITE, void, parsed, void, [], false) end if
  if kind == modelRegistry.MOD_BRUSH then
    global externalBrushRendererRoots, externalBrushRendererNames
    brush = try(worldRenderer.createExternal(parsed, renderer.palette))
    if brush is error then return emptyModel(name, MODEL_BRUSH) end if
    externalBrushRendererRoots = externalBrushRendererRoots + [brush]
    externalBrushRendererNames = externalBrushRendererNames + [name]
    return t.ClientRenderModel(name, MODEL_BRUSH, void, void, brush, [], false)
  end if
  return emptyModel(name, MODEL_NONE)
end function

// Read and validate world model.
function loadWorldModel(renderer, name)
  global renderModelRegistry
  if name == "" then return emptyModel(name, MODEL_NONE) end if
  if renderModelRegistry is void then renderModelRegistry = modelRegistry.Mod_Init(modelRegistry.create(), void) end if
  // Loading model_precache[1] is required because Mod_LoadModel registers all
  // *n inline models. The active world already owns its WorldRenderer, so this
  // slot deliberately carries no standalone brush renderer.
  parsed = try(modelRegistry.Mod_ForName(renderModelRegistry, renderer.filesystem, name, false))
  if parsed is error or parsed is void then return emptyModel(name, MODEL_NONE) end if
  return emptyModel(name, MODEL_BRUSH)
end function

// Create and initialize the module state.
function create(filesystem, palette, modelPrecache)
  global renderModelRegistry, externalBrushRendererRoots, externalBrushRendererNames
  aliasMesh.clearCaches()
  resetAliasShadeCache()
  resetAliasPoseCache()
  renderModelRegistry = modelRegistry.Mod_Init(modelRegistry.create(), void)
  externalBrushRendererRoots = []
  externalBrushRendererNames = []
  draw2d.Draw_SetPalette(palette)
  renderer = t.EntityRenderer(filesystem, palette, [], 0)
  synchronize(renderer, modelPrecache)
  return renderer
end function

// Upload indexed texture to the active renderer.
function uploadIndexedTexture(width, height, pixels, palette, transparent)
  if width <= 0 or height <= 0 then return 0 end if
  if len(pixels) < width * height then return 0 end if
  rgba = worldRenderer.indexedToRgba(pixels, palette, transparent)
  prepared = draw2d.GL_UpscaleTextureRgba(rgba, width, height)
  if prepared is error then return 0 end if
  texture = gl.generateTexture()
  gl.bindTexture(texture)
  // R_TranslatePlayerSkin uses non-mipmapped linear filtering.
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_S, gl.GL_REPEAT)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_T, gl.GL_REPEAT)
  gl.uploadRgba(prepared[1], prepared[2], prepared[0])
  return texture
end function

// Provide translated player texture behavior for the active subsystem.
function inline translatedPlayerTexture(entityNumber)
  if entityNumber < 0 or entityNumber >= len(translatedPlayerTextures) then return 0 end if
  return translatedPlayerTextures[entityNumber]
end function

// Update module state for translated player texture.
function setTranslatedPlayerTexture(entityNumber, texture)
  global translatedPlayerTextures
  if entityNumber < 0 then return false end if
  if len(translatedPlayerTextures) <= entityNumber then
    translatedPlayerTextures = arrayutil.growArrayTo(translatedPlayerTextures, entityNumber + 1, 0)
  end if
  previous = translatedPlayerTextures[entityNumber]
  if previous != 0 and previous != texture then gl.deleteTexture(previous) end if
  translatedPlayerTextures[entityNumber] = texture
  return true
end function

// Update module state for the requested value.
function synchronize(renderer, modelPrecache)
  oldCount = len(renderer.models)
  targetCount = len(modelPrecache)
  if oldCount >= targetCount then return oldCount end if
  models = arrayutil.makeEmptyArray(targetCount)
  index = 0
  while index < oldCount
    models[index] = renderer.models[index]
    index = index + 1
  end while
  while index < targetCount
    if index == 1 then
      models[index] = loadWorldModel(renderer, modelPrecache[index])
    else
      models[index] = loadModel(renderer, modelPrecache[index])
    end if
    index = index + 1
  end while
  renderer.models = models
  return targetCount
end function

// Upload alias to the active renderer.
function uploadAlias(renderer, model)
  if model.uploaded then return true end if
  source = model.aliasModel
  draw2d.Draw_SetPalette(renderer.palette)
  model.textureIds = arrayutil.makeFilledArray(len(source.skins), 0)
  index = 0
  while index < len(source.skins)
    skin = source.skins[index]
    textures = arrayutil.makeFilledArray(4, 0)
    imageIndex = 0
    while imageIndex < len(skin.images)
      identifier = source.filename + "_" + index
      if len(skin.images) > 1 then identifier = identifier + "_" + imageIndex end if
      texture = draw2d.GL_LoadTexture(
        identifier,
        source.skinWidth,
        source.skinHeight,
        skin.images[imageIndex],
        true,
        false,
      )
      textures[imageIndex & 3] = texture
      imageIndex = imageIndex + 1
    end while
    available = imageIndex
    while imageIndex < 4 and available > 0
      textures[imageIndex] = textures[imageIndex - available]
      imageIndex = imageIndex + 1
    end while
    model.textureIds[index] = textures
    index = index + 1
  end while
  if len(model.textureIds) == 0 then model.textureIds = [0] end if
  model.uploaded = true
  return true
end function

// Upload sprite to the active renderer.
function uploadSprite(renderer, model)
  if model.uploaded then return true end if
  source = model.spriteModel
  draw2d.Draw_SetPalette(renderer.palette)
  // Keep one texture-id array per top-level frame so grouped sprite frames
  // retain all of their independently timed images.
  model.textureIds = arrayutil.makeEmptyArray(len(source.frames))
  frameIndex = 0
  while frameIndex < len(source.frames)
    frameSet = source.frames[frameIndex]
    textures = arrayutil.makeFilledArray(len(frameSet.frames), 0)
    groupIndex = 0
    while groupIndex < len(frameSet.frames)
      frame = frameSet.frames[groupIndex]
      identifier = source.filename + "_" + frameIndex
      if frameSet.grouped then identifier = identifier + "_" + groupIndex end if
      texture = draw2d.GL_LoadTexture(
        identifier,
        frame.width,
        frame.height,
        frame.pixels,
        true,
        true,
      )
      textures[groupIndex] = texture
      groupIndex = groupIndex + 1
    end while
    model.textureIds[frameIndex] = textures
    frameIndex = frameIndex + 1
  end while
  model.uploaded = true
  return true
end function

// Upload the requested value to the active renderer.
function upload(renderer, model)
  if model.kind == MODEL_ALIAS then return uploadAlias(renderer, model) end if
  if model.kind == MODEL_SPRITE then return uploadSprite(renderer, model) end if
  brush = brushRendererForModel(model)
  if model.kind == MODEL_BRUSH and brush is not void then
    result = try(worldRenderer.uploadStandaloneBrush(brush))
    if result is error then return result end if
    model.uploaded = true
    return true
  end if
  return false
end function

// Preload and register the the requested value asset.
function precache(renderer)
  if renderer is void then return error(3940, "entity precache: renderer is void") end if
  // Native alias batches select one of sixteen yaw lighting rows. Building all
  // rows here prevents the first monster/player drawn at a new yaw from doing
  // conversion work in a playable frame.
  aliasMesh.precacheAliasLightingRows()
  count = 0
  index = 0
  while index < len(renderer.models)
    model = renderer.models[index]
    if model is not void and model.kind == MODEL_ALIAS then
      uploaded = try(uploadAlias(renderer, model))
      if uploaded is error then return error(3941, "alias upload " + model.name + ": " + uploaded.message) end if
      prepared = try(aliasMesh.precacheAliasModel(model.aliasModel))
      if prepared is error then return error(3942, "alias mesh " + model.name + ": " + prepared.message) end if
      count = count + prepared
    else if model is not void and model.kind == MODEL_SPRITE then
      uploaded = try(uploadSprite(renderer, model))
      if uploaded is error then return error(3943, "sprite upload " + model.name + ": " + uploaded.message) end if
      count = count + 1
    else if model is not void and model.kind == MODEL_BRUSH and brushRendererForModel(model) is not void then
      uploaded = try(upload(renderer, model))
      if uploaded is error then return error(3944, "brush upload " + model.name + ": " + uploaded.message) end if
      count = count + 1
    else if model is not void and model.kind == MODEL_BRUSH and index != 1 and not startsWith(model.name, "*") then
      // Never silently count an unloaded external BSP as rendered. Retail
      // ammo/health boxes are exactly this model class.
      return error(3945, "external brush renderer missing for " + model.name)
    end if
    index = index + 1
  end while
  return count
end function

// Return cycle index derived from the active module state.
function cycleIndex(intervals, time, count)
  if count <= 1 or len(intervals) == 0 then return 0 end if
  full = intervals[len(intervals) - 1]
  if full <= 0.0 then return 0 end if
  target = time - native.trunc(time / full) * full
  index = 0
  while index < len(intervals) and index < count
    if target < intervals[index] then return index end if
    index = index + 1
  end while
  return count - 1
end function

// Provide alias frame behavior for the active subsystem.
function aliasFrame(source, frameNumber, time)
  if len(source.frames) == 0 then return void end if
  index = frameNumber
  if index < 0 or index >= len(source.frames) then index = 0 end if
  set = source.frames[index]
  if len(set.frames) == 0 then return void end if
  if set.grouped then
    interval = 0.0
    if len(set.intervals) > 0 then interval = set.intervals[0] end if
    if interval <= 0.0 then return set.frames[0] end if
    pose = native.trunc(time / interval) % len(set.frames)
    return set.frames[pose]
  end if
  return set.frames[0]
end function

// Return [previous pose, current pose, blend fraction] for one render entity.
// Networked Quake changes MDL frame numbers at the 10 Hz server cadence; this
// short history removes visible pose stepping without changing simulation.
function aliasPoseBlend(source, entity, currentFrame, time, viewModel)
  if not aliasPoseInterpolation or currentFrame is void then return [currentFrame, currentFrame, 1.0] end if
  slot = entity.number
  if viewModel then slot = c.MAX_EDICTS end if
  if slot <= 0 or slot > c.MAX_EDICTS then return [currentFrame, currentFrame, 1.0] end if
  cached = aliasPoseCurrent[slot]
  cachedModel = aliasPoseModels[slot]
  modelChanged = cachedModel is void or nativeRawValue(cachedModel) != nativeRawValue(source)
  if modelChanged or cached is void or time < aliasPoseChangeTimes[slot] then
    // Root the model object so a compacting GC updates this cache entry and
    // does not create a one-frame interpolation reset after collection.
    aliasPoseModels[slot] = source
    aliasPosePrevious[slot] = currentFrame
    aliasPoseCurrent[slot] = currentFrame
    aliasPoseChangeTimes[slot] = time
    return [currentFrame, currentFrame, 1.0]
  end if
  if nativeRawValue(cached) != nativeRawValue(currentFrame) then
    aliasPosePrevious[slot] = cached
    aliasPoseCurrent[slot] = currentFrame
    aliasPoseChangeTimes[slot] = time
  end if
  duration = 0.1
  frameIndex = entity.frame
  if frameIndex >= 0 and frameIndex < len(source.frames) then
    frameSet = source.frames[frameIndex]
    if frameSet.grouped and len(frameSet.intervals) > 0 and frameSet.intervals[0] > 0.0 then duration = frameSet.intervals[0] end if
  end if
  fraction = (time - aliasPoseChangeTimes[slot]) / duration
  if fraction < 0.0 then fraction = 0.0 end if
  if fraction > 1.0 then fraction = 1.0 end if
  previous = aliasPosePrevious[slot]
  if previous is void then previous = aliasPoseCurrent[slot]; fraction = 1.0 end if
  return [previous, aliasPoseCurrent[slot], fraction]
end function

// Provide sprite frame and texture behavior for the active subsystem.
function spriteFrameAndTexture(model, entity, time)
  source = model.spriteModel
  if source is void or len(source.frames) == 0 then return void end if
  frameIndex = entity.frame
  if frameIndex < 0 or frameIndex >= len(source.frames) then frameIndex = 0 end if
  frameSet = source.frames[frameIndex]
  if len(frameSet.frames) == 0 then return void end if
  groupIndex = 0
  if frameSet.grouped then groupIndex = cycleIndex(frameSet.intervals, time + entity.syncBase, len(frameSet.frames)) end if
  frame = frameSet.frames[groupIndex]
  texture = 0
  if frameIndex < len(model.textureIds) then
    entry = model.textureIds[frameIndex]
    if entry is array then
      if groupIndex >= 0 and groupIndex < len(entry) then texture = entry[groupIndex] end if
    else if groupIndex == 0 then
      // Backward compatibility for models uploaded by an older renderer.
      texture = entry
    end if
  end if
  return [frame, texture]
end function

// Provide alias vertex behavior for the active subsystem.
function aliasVertex(source, packed)
  return t.Vec3(
    packed.x * source.scale.x + source.scaleOrigin.x,
    packed.y * source.scale.y + source.scaleOrigin.y,
    packed.z * source.scale.z + source.scaleOrigin.z,
  )
end function

// Provide alias shade behavior for the active subsystem.
function aliasShade(model, entity, time, viewModel)
  global aliasShadeCacheValid, aliasShadeCacheStamp, aliasShadeCacheModel
  global aliasShadeCacheColormap, aliasShadeCacheViewModel
  global aliasShadeCacheOriginX, aliasShadeCacheOriginY, aliasShadeCacheOriginZ
  global aliasShadeCacheShade, aliasShadeCacheAmbient, aliasShadeCacheSpot
  global aliasShadeCacheReceiverHit
  global aliasLightingScratch
  lights = worldRenderer.R_ActiveDynamicLights()
  hasActiveLight = false
  for each light in lights
    // Cache eligibility needs only the existence of one live light.  Stop at
    // the first match instead of scanning all MAX_DLIGHTS slots before the
    // contribution pass below performs the complete ordered traversal.
    if light is not void and light.radius > 0.0 and light.die >= time then hasActiveLight = true; break end if
  end for
  number = entity.number
  stamp = native.trunc(time * 10.0)
  cacheable = not hasActiveLight and number >= 0 and number < len(aliasShadeCacheValid)
  if cacheable and aliasShadeCacheValid[number] and
    aliasShadeCacheStamp[number] == stamp and
    aliasShadeCacheModel[number] == model.name and
    aliasShadeCacheColormap[number] == entity.colormap and
    aliasShadeCacheViewModel[number] == viewModel and
    aliasShadeCacheOriginX[number] == entity.origin.x and
    aliasShadeCacheOriginY[number] == entity.origin.y and
    aliasShadeCacheOriginZ[number] == entity.origin.z then
    aliasLightingScratch[0] = aliasShadeCacheShade[number]
    aliasLightingScratch[1] = aliasShadeCacheAmbient[number]
    cachedReceiverHit = aliasShadeCacheReceiverHit[number]
    cachedSpot = aliasShadeCacheSpot[number]
    if cachedReceiverHit and cachedSpot is not void then aliasLightingScratch[2] = cachedSpot end if
    aliasLightingScratch[3] = false
    aliasLightingScratch[7] = cachedReceiverHit and cachedSpot is not void
    return aliasLightingScratch
  end if
  ambient = worldRenderer.R_LightPoint(entity.origin)
  receiverHit = worldRenderer.R_LightPointHit()
  receiverSpot = worldRenderer.lightspot
  receiverPlane = worldRenderer.lightplane
  if receiverHit and (receiverSpot is void or receiverPlane is void) then receiverHit = false end if
  if receiverHit and receiverPlane.normal.z < 0.5 and receiverPlane.normal.z > -0.5 then receiverHit = false end if
  if receiverHit then
    receiverDistance = entity.origin.z - receiverSpot.z
    if receiverDistance < -4.0 or receiverDistance > 256.0 then receiverHit = false end if
  end if
  shade = ambient
  strongestLight = void
  strongestAddition = 0.0
  for each light in lights
    if light is not void and light.radius > 0.0 and light.die >= time then
      deltaX = entity.origin.x - light.origin.x
      deltaY = entity.origin.y - light.origin.y
      deltaZ = entity.origin.z - light.origin.z
      distance = native.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
      addition = light.radius - distance
      if addition > 0.0 then
        ambient = ambient + addition
        shade = shade + addition
        if addition > strongestAddition then strongestAddition = addition; strongestLight = light end if
      end if
    end if
  end for
  if viewModel and ambient < 24.0 then ambient = 24.0; shade = 24.0 end if
  if ambient > 128.0 then ambient = 128.0 end if
  if ambient + shade > 192.0 then shade = 192.0 - ambient end if
  if entity.colormap != 0 and ambient < 8.0 then ambient = 8.0; shade = 8.0 end if
  if model.name == "progs/flame.mdl" or model.name == "progs/flame2.mdl" then ambient = 256.0; shade = 256.0 end if
  shadeValue = shade / 200.0
  spot = worldRenderer.lightspot
  if not receiverHit then spot = void end if
  if cacheable then
    aliasShadeCacheValid[number] = true
    aliasShadeCacheStamp[number] = stamp
    aliasShadeCacheModel[number] = model.name
    aliasShadeCacheColormap[number] = entity.colormap
    aliasShadeCacheViewModel[number] = viewModel
    aliasShadeCacheOriginX[number] = entity.origin.x
    aliasShadeCacheOriginY[number] = entity.origin.y
    aliasShadeCacheOriginZ[number] = entity.origin.z
    aliasShadeCacheShade[number] = shadeValue
    aliasShadeCacheAmbient[number] = ambient
    aliasShadeCacheReceiverHit[number] = spot is not void
    if spot is not void then aliasShadeCacheSpot[number] = math.copy(spot) end if
  end if
  // drawAlias consumes the values immediately. Reusing this three-slot
  // record avoids one short-lived array for every alias entity every frame.
  aliasLightingScratch[0] = shadeValue
  aliasLightingScratch[1] = ambient
  if spot is not void then aliasLightingScratch[2] = spot end if
  aliasLightingScratch[3] = strongestLight is not void
  if strongestLight is not void then
    aliasLightingScratch[4] = strongestLight.origin.x
    aliasLightingScratch[5] = strongestLight.origin.y
    aliasLightingScratch[6] = strongestLight.origin.z
  end if
  aliasLightingScratch[7] = receiverHit
  return aliasLightingScratch
end function

// Transform the strongest world-space point light into the alias model's
// yaw-local coordinates used by the projected silhouette routine.
function configureAliasShadowSource(entity, enabled, lightX, lightY, lightZ)
  if not enabled then return aliasMesh.configureAliasShadowPointLight(false, 0.0, 0.0, 0.0) end if
  relativeX = lightX - entity.origin.x
  relativeY = lightY - entity.origin.y
  angle = entity.angles.y * math.DEG_TO_RAD
  cosine = native.cos(angle)
  sine = native.sin(angle)
  localX = cosine * relativeX + sine * relativeY
  localY = -sine * relativeX + cosine * relativeY
  localZ = lightZ - entity.origin.z
  return aliasMesh.configureAliasShadowPointLight(true, localX, localY, localZ)
end function

// Return whether an alias model represents opaque physical geometry. Flames
// and beam/light effects are alias MDLs in retail Quake rather than sprites;
// projecting them created bright duplicate torches and energy streaks on the
// receiver floor on backends that defer fixed-function texture state.
function aliasModelCastsShadow(model)
  if model is void then return false end if
  name = bio.lower(model.name)
  if name == "progs/flame.mdl" or name == "progs/flame2.mdl" then return false end if
  if name == "progs/bolt.mdl" or name == "progs/bolt2.mdl" or name == "progs/bolt3.mdl" or name == "progs/beam.mdl" then return false end if
  if name == "progs/lavaball.mdl" or name == "progs/laser.mdl" or name == "progs/plasma.mdl" then return false end if
  return true
end function

// Render alias.
function drawAlias(renderer, model, entity, time, viewModel, enhancedOverlay)
  // Close the preceding model's optional shadow tail before measuring this
  // model's lazy upload.  Without this diagnostic-only boundary the profiler
  // mislabeled ray projection as repeated texture upload work.
  optBaseline.checkpoint("alias_native")
  if not model.uploaded then uploadAlias(renderer, model) end if
  optBaseline.checkpoint("alias_upload")
  source = model.aliasModel
  frame = aliasFrame(source, entity.frame, time)
  if frame is void then return 0 end if
  pose = aliasPoseBlend(source, entity, frame, time, viewModel)
  previousFrame = pose[0]
  frame = pose[1]
  poseFraction = pose[2]
  // R_DrawAliasModel starts from texture unit zero even when the world pass
  // used multitexturing immediately before the entity pass.
  worldRenderer.GL_DisableMultitexture()
  skin = entity.skin
  if skin < 0 or skin >= len(model.textureIds) then skin = 0 end if
  texture = 0
  if len(model.textureIds) > 0 then
    skinTextures = model.textureIds[skin]
    if skinTextures is array then
      texture = skinTextures[native.trunc(time * 10.0) & 3]
    else
      texture = skinTextures
    end if
  end if
  translated = translatedPlayerTexture(entity.number)
  if not aliasNoColors and entity.colormap != 0 and translated != 0 then texture = translated end if
  if texture != 0 then gl.bindTexture(texture) end if
  optBaseline.checkpoint("alias_frame")
  lighting = aliasShade(model, entity, time, viewModel)
  aliasMesh.configureAliasLighting(lighting[0], lighting[1], entity.angles.y, lighting[2])
  configureAliasShadowSource(entity, lighting[3], lighting[4], lighting[5], lighting[6])
  optBaseline.checkpoint("alias_light")
  mesh = aliasMesh.GL_MakeAliasModelDisplayLists(source, source)
  optBaseline.checkpoint("alias_mesh")
  doubleEyes = model.name == "progs/eyes.mdl" and aliasDoubleEyes
  drawn = 0
  if not gl.traceEnabled() and gl.nativeBatchAvailable() then
    if poseFraction < 1.0 and previousFrame is not void and nativeRawValue(previousFrame) != nativeRawValue(frame) then
      drawn = aliasMesh.drawAliasModelBatchLerped(source, previousFrame, frame, poseFraction, mesh, entity.origin, entity.angles, doubleEyes, aliasSmoothModels)
    else
      drawn = aliasMesh.drawAliasModelBatch(source, frame, mesh, entity.origin, entity.angles, doubleEyes, aliasSmoothModels)
    end if
  else
    gl.pushMatrix()
    gl.translate(entity.origin.x, entity.origin.y, entity.origin.z)
    gl.rotate(entity.angles.y, 0.0, 0.0, 1.0)
    gl.rotate(-entity.angles.x, 0.0, 1.0, 0.0)
    gl.rotate(entity.angles.z, 1.0, 0.0, 0.0)
    if doubleEyes then
      gl.translate(source.scaleOrigin.x, source.scaleOrigin.y, source.scaleOrigin.z - 30.0)
      gl.scale(source.scale.x * 2.0, source.scale.y * 2.0, source.scale.z * 2.0)
    else
      gl.translate(source.scaleOrigin.x, source.scaleOrigin.y, source.scaleOrigin.z)
      gl.scale(source.scale.x, source.scale.y, source.scale.z)
    end if
    // Diagnostic traces retain the scalar fixed-function command sequence.
    gl.cullFace(gl.GL_FRONT)
    gl.enable(gl.GL_CULL_FACE)
    if aliasSmoothModels then gl.shadeModel(gl.GL_SMOOTH) end if
    gl.textureEnvironment(gl.GL_MODULATE)
    if poseFraction < 1.0 and previousFrame is not void and nativeRawValue(previousFrame) != nativeRawValue(frame) then
      drawn = aliasMesh.drawAliasMeshLerped(source, previousFrame, frame, poseFraction, mesh)
    else
      drawn = aliasMesh.drawAliasMesh(source, frame, mesh)
    end if
    gl.textureEnvironment(gl.GL_REPLACE)
    gl.shadeModel(gl.GL_FLAT)
    gl.color(255, 255, 255, 255)
    gl.disable(gl.GL_CULL_FACE)
    gl.popMatrix()
  end if
  optBaseline.checkpoint("alias_native")
  rayShadowReady = false
  if aliasShadows and not enhancedOverlay and not viewModel and aliasModelCastsShadow(model) then
    rayShadowReady = rayShadow.configureAlias(
      worldRenderer.R_CurrentWorldMap(), worldRenderer.R_CurrentWorldSurfaces(),
      entity, source, doubleEyes,
      lighting[3], lighting[4], lighting[5], lighting[6],
    )
  end if
  if rayShadowReady then
    gl.pushMatrix()
    gl.disable(gl.GL_TEXTURE_2D)
    gl.disable(gl.GL_ALPHA_TEST)
    gl.disable(gl.GL_CULL_FACE)
    gl.enable(gl.GL_BLEND)
    gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
    gl.depthMask(false)
    gl.depthFunc(worldRenderer.R_CurrentDepthFunction())
    // MODULATE makes the pass solid black even if a translated backend defers
    // GL_TEXTURE_2D disable until the next batch. Under REPLACE the previously
    // bound flame/item skin appeared as a fully coloured copy on the floor.
    gl.textureEnvironment(gl.GL_MODULATE)
    if aliasShadowQuality == 0 then
      gl.color(0, 0, 0, 118)
      aliasMesh.GL_DrawAliasRayShadowSample(source, frame, entity, doubleEyes, lighting[3], lighting[4], lighting[5], lighting[6], 0.0, 0.0)
    else if aliasShadowQuality == 1 then
      // Three independently traced source positions approximate a compact
      // area light without shifting finished geometry across BSP boundaries.
      gl.color(0, 0, 0, 48)
      aliasMesh.GL_DrawAliasRayShadowSample(source, frame, entity, doubleEyes, lighting[3], lighting[4], lighting[5], lighting[6], -4.0, 0.0)
      aliasMesh.GL_DrawAliasRayShadowSample(source, frame, entity, doubleEyes, lighting[3], lighting[4], lighting[5], lighting[6], 0.0, 0.0)
      aliasMesh.GL_DrawAliasRayShadowSample(source, frame, entity, doubleEyes, lighting[3], lighting[4], lighting[5], lighting[6], 4.0, 0.0)
    else
      // Five true BSP rays per model vertex form a soft cross-filtered area
      // light while retaining occlusion and receiver-plane validation.
      gl.color(0, 0, 0, 30)
      aliasMesh.GL_DrawAliasRayShadowSample(source, frame, entity, doubleEyes, lighting[3], lighting[4], lighting[5], lighting[6], 0.0, 0.0)
      aliasMesh.GL_DrawAliasRayShadowSample(source, frame, entity, doubleEyes, lighting[3], lighting[4], lighting[5], lighting[6], -6.0, 0.0)
      aliasMesh.GL_DrawAliasRayShadowSample(source, frame, entity, doubleEyes, lighting[3], lighting[4], lighting[5], lighting[6], 6.0, 0.0)
      aliasMesh.GL_DrawAliasRayShadowSample(source, frame, entity, doubleEyes, lighting[3], lighting[4], lighting[5], lighting[6], 0.0, -6.0)
      aliasMesh.GL_DrawAliasRayShadowSample(source, frame, entity, doubleEyes, lighting[3], lighting[4], lighting[5], lighting[6], 0.0, 6.0)
    end if
    gl.depthMask(true)
    gl.textureEnvironment(gl.GL_REPLACE)
    gl.enable(gl.GL_TEXTURE_2D)
    gl.disable(gl.GL_ALPHA_TEST)
    gl.disable(gl.GL_CULL_FACE)
    gl.disable(gl.GL_BLEND)
    gl.depthFunc(worldRenderer.R_CurrentDepthFunction())
    gl.color(255, 255, 255, 255)
    gl.popMatrix()
  end if
  // Attribute the complete native draw/shadow tail before the next alias model
  // reaches its upload checkpoint.  Normal gameplay profiling is disabled, so
  // these boundaries have no release-frame cost.
  optBaseline.checkpoint("alias_native")
  return drawn
end function

// Render sprite.
function drawSprite(renderer, model, entity, viewRight, viewUp, time)
  uploadSprite(renderer, model)
  // R_DrawSpriteModel has the same texture-unit-zero precondition.
  worldRenderer.GL_DisableMultitexture()
  selected = spriteFrameAndTexture(model, entity, time)
  if selected is void then return 0 end if
  frame = selected[0]
  texture = selected[1]
  if texture == 0 then return 0 end if

  source = model.spriteModel
  rightVector = viewRight
  upVector = viewUp
  if source.type == SPR_ORIENTED then
    vectors = math.angleVectors(entity.angles)
    rightVector = vectors[1]
    upVector = vectors[2]
  end if

  gl.bindTexture(texture)
  gl.enable(gl.GL_ALPHA_TEST)
  gl.alphaFunc(gl.GL_GREATER, 0.5)
  gl.color(255, 255, 255, 255)
  left = frame.originX
  rightValue = frame.originX + frame.width
  top = frame.originY
  bottom = frame.originY - frame.height

  // Submit the four billboard corners as scalars. Sprite-heavy combat used
  // to allocate four Vec3 objects per sprite and frame solely to read their
  // components in the following four calls.
  bottomLeftX = entity.origin.x + upVector.x * bottom + rightVector.x * left
  bottomLeftY = entity.origin.y + upVector.y * bottom + rightVector.y * left
  bottomLeftZ = entity.origin.z + upVector.z * bottom + rightVector.z * left
  topLeftX = entity.origin.x + upVector.x * top + rightVector.x * left
  topLeftY = entity.origin.y + upVector.y * top + rightVector.y * left
  topLeftZ = entity.origin.z + upVector.z * top + rightVector.z * left
  topRightX = entity.origin.x + upVector.x * top + rightVector.x * rightValue
  topRightY = entity.origin.y + upVector.y * top + rightVector.y * rightValue
  topRightZ = entity.origin.z + upVector.z * top + rightVector.z * rightValue
  bottomRightX = entity.origin.x + upVector.x * bottom + rightVector.x * rightValue
  bottomRightY = entity.origin.y + upVector.y * bottom + rightVector.y * rightValue
  bottomRightZ = entity.origin.z + upVector.z * bottom + rightVector.z * rightValue

  gl.begin(gl.GL_QUADS)
  gl.texcoord2(0.0, 1.0); gl.vertex3(bottomLeftX, bottomLeftY, bottomLeftZ)
  gl.texcoord2(0.0, 0.0); gl.vertex3(topLeftX, topLeftY, topLeftZ)
  gl.texcoord2(1.0, 0.0); gl.vertex3(topRightX, topRightY, topRightZ)
  gl.texcoord2(1.0, 1.0); gl.vertex3(bottomRightX, bottomRightY, bottomRightZ)
  gl.finishPrimitive()
  gl.disable(gl.GL_ALPHA_TEST)
  return 1
end function

// Return brush model index derived from the active module state.
function brushModelIndex(name)
  source = bytes(name)
  if len(source) < 2 or source[0] != 42 then return -1 end if
  value = toNumber(decode(slice(source, 1, len(source) - 1)))
  if value is void or value is not int then return -1 end if
  return value
end function

// Render brush.
function drawBrush(worldRendererValue, model, entity, time)
  submodelIndex = brushModelIndex(model.name)
  if submodelIndex <= 0 then
    brush = brushRendererForModel(model)
    if brush is void then return 0 end if
    brush.fullbright = worldRendererValue.fullbright
    return worldRenderer.drawStandaloneBrush(
      brush,
      entity,
      worldRenderer.R_CurrentViewOrigin(),
      time,
    )
  end if
  if submodelIndex >= len(worldRendererValue.map.models) then return 0 end if
  // Use the canonical MiniQuake bmodel path.  The client model index is a
  // precache slot, while the leading *n name identifies the BSP submodel.
  // Passing that index explicitly preserves entity.frame texture animation,
  // dynamic-light marking and GL_LUMINANCE lightmap blend semantics.
  return worldRenderer.R_DrawBrushModelForSubmodel(entity, submodelIndex)
end function

// Render one brush entity without its classic lightmap pass so the optional
// additive GPU program can light the geometry exactly once.
function drawBrushEnhanced(worldRendererValue, model, entity, time)
  submodelIndex = brushModelIndex(model.name)
  if submodelIndex <= 0 then
    brush = brushRendererForModel(model)
    if brush is void then return 0 end if
    return worldRenderer.drawStandaloneBrushEnhanced(
      brush,
      entity,
      worldRenderer.R_CurrentViewOrigin(),
      time,
    )
  end if
  if submodelIndex >= len(worldRendererValue.map.models) then return 0 end if
  return worldRenderer.R_DrawBrushModelEnhancedForSubmodel(entity, submodelIndex)
end function

// Resolve a stable receiver height from the main BSP beneath an object.  A
// production miss must suppress the shadow: lightspot retains reusable storage
// and may still contain another entity's receiver from an earlier trace.
function objectShadowFloorZ(worldRendererValue, entity)
  if worldRendererValue is void or worldRendererValue.map is void or len(worldRendererValue.map.models) == 0 then
    return entity.origin.z + 1.0
  end if
  worldRenderer.R_LightPoint(entity.origin)
  if not worldRenderer.R_LightPointHit() then return void end if
  spot = worldRenderer.lightspot
  plane = worldRenderer.lightplane
  if spot is void or plane is void then return void end if
  // Very steep receivers cannot be represented by this horizontal projected
  // pass.  Distant lower floors would create room-spanning silhouettes, so
  // leave those objects unshadowed instead of leaking through the level.
  if plane.normal.z < 0.5 and plane.normal.z > -0.5 then return void end if
  receiverDistance = entity.origin.z - spot.z
  if receiverDistance < -4.0 or receiverDistance > 256.0 then return void end if
  return spot.z + 1.0
end function

// Select the dynamic light with the strongest local contribution and retain
// its world-space source for BSP ray projection. When no live point light
// reaches the object, the projector uses a stable directional fallback.
function brushShadowSource(entity, time)
  global brushShadowSourceScratch
  strongest = void
  strongestAddition = 0.0
  for each light in worldRenderer.R_ActiveDynamicLights()
    if light is not void and light.radius > 0.0 and light.die >= time then
      deltaX = entity.origin.x - light.origin.x
      deltaY = entity.origin.y - light.origin.y
      deltaZ = entity.origin.z - light.origin.z
      addition = light.radius - native.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
      if addition > strongestAddition then strongestAddition = addition; strongest = light end if
    end if
  end for
  brushShadowSourceScratch[0] = strongest is not void
  if strongest is void then return brushShadowSourceScratch end if
  brushShadowSourceScratch[1] = strongest.origin.x
  brushShadowSourceScratch[2] = strongest.origin.y
  brushShadowSourceScratch[3] = strongest.origin.z
  return brushShadowSourceScratch
end function

// Draw one projected footprint sample for either an external pickup BSP or an
// inline moving brush model.
function drawBrushShadowSample(worldRendererValue, model, entity, floorWorldZ, source, offsetX, offsetY, contactOnly)
  submodelIndex = brushModelIndex(model.name)
  if submodelIndex <= 0 then
    brush = brushRendererForModel(model)
    if brush is void then return 0 end if
    return worldRenderer.drawStandaloneBrushShadow(
      brush, entity, floorWorldZ, offsetX, offsetY, contactOnly,
      source[0], source[1], source[2], source[3],
    )
  end if
  if submodelIndex >= len(worldRendererValue.map.models) then return 0 end if
  return worldRenderer.R_DrawBrushModelShadowForSubmodel(
    entity, submodelIndex, floorWorldZ, offsetX, offsetY, contactOnly,
    source[0], source[1], source[2], source[3],
  )
end function

// Render a backend-neutral soft footprint for BSP pickups, crates, doors and
// platforms. Sprite effects stay emissive and intentionally cast no shadow.
function drawBrushShadow(worldRendererValue, model, entity, time)
  source = brushShadowSource(entity, time)
  if not rayShadow.configureBrush(
    worldRenderer.R_CurrentWorldMap(), worldRenderer.R_CurrentWorldSurfaces(),
    entity, source[0], source[1], source[2], source[3],
  ) then return 0 end if
  floorWorldZ = 0.0
  worldRenderer.GL_DisableMultitexture()
  gl.disable(gl.GL_TEXTURE_2D)
  gl.disable(gl.GL_ALPHA_TEST)
  gl.disable(gl.GL_CULL_FACE)
  gl.enable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  gl.depthMask(false)
  gl.depthFunc(worldRenderer.R_CurrentDepthFunction())
  // Keep projected BSP geometry black even on deferred fixed-function state
  // backends; otherwise the last box/door texture can leak onto the receiver.
  gl.textureEnvironment(gl.GL_MODULATE)
  drawn = 0
  if aliasShadowQuality == 0 then
    gl.color(0, 0, 0, 112)
    drawn = drawBrushShadowSample(worldRendererValue, model, entity, floorWorldZ, source, 0.0, 0.0, false)
  else if aliasShadowQuality == 1 then
    gl.color(0, 0, 0, 46)
    drawn = drawBrushShadowSample(worldRendererValue, model, entity, floorWorldZ, source, -4.0, 0.0, false)
    drawn = drawn + drawBrushShadowSample(worldRendererValue, model, entity, floorWorldZ, source, 0.0, 0.0, false)
    drawn = drawn + drawBrushShadowSample(worldRendererValue, model, entity, floorWorldZ, source, 4.0, 0.0, false)
  else
    gl.color(0, 0, 0, 28)
    drawn = drawBrushShadowSample(worldRendererValue, model, entity, floorWorldZ, source, 0.0, 0.0, false)
    drawn = drawn + drawBrushShadowSample(worldRendererValue, model, entity, floorWorldZ, source, -6.0, 0.0, false)
    drawn = drawn + drawBrushShadowSample(worldRendererValue, model, entity, floorWorldZ, source, 6.0, 0.0, false)
    drawn = drawn + drawBrushShadowSample(worldRendererValue, model, entity, floorWorldZ, source, 0.0, -6.0, false)
    drawn = drawn + drawBrushShadowSample(worldRendererValue, model, entity, floorWorldZ, source, 0.0, 6.0, false)
  end if
  gl.depthMask(true)
  gl.textureEnvironment(gl.GL_REPLACE)
  gl.enable(gl.GL_TEXTURE_2D)
  gl.disable(gl.GL_ALPHA_TEST)
  gl.disable(gl.GL_CULL_FACE)
  gl.disable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  gl.depthFunc(worldRenderer.R_CurrentDepthFunction())
  gl.color(255, 255, 255, 255)
  return drawn
end function

// Restore compatibility blend/depth state after any enhanced entity replay,
// including error exits from malformed external models.
function finishEnhancedEntityOverlay()
  enhanced.endOverlay()
  gl.depthMask(true)
  gl.depthFunc(worldRenderer.R_CurrentDepthFunction())
  gl.disable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  gl.color(255, 255, 255, 255)
  return true
end function

// Render submitted.
function renderSubmitted(renderer, worldRendererValue, entities, hiddenEntityNumber, viewRight, viewUp, time)
  rendered = 0
  // R_DrawEntitiesOnList renders opaque alias/brush models first and performs
  // a second pass for alpha-tested sprites.  Keeping the passes separate is
  // observable where a sprite intersects an alias model.
  entityCount = len(entities)
  modelCount = len(renderer.models)
  index = 0
  while index < entityCount
    entity = entities[index]
    if entity is not void and (hiddenEntityNumber is void or entity.number != hiddenEntityNumber) and entity.modelIndex > 0 and entity.modelIndex < modelCount then
      model = renderer.models[entity.modelIndex]
      if model.kind == MODEL_BRUSH then
        drawResult = try(drawBrush(worldRendererValue, model, entity, time))
        if drawResult is error then return error(3893, "brush " + model.name + " entity " + entity.number + ": " + drawResult.message) end if
        if aliasShadows then drawBrushShadow(worldRendererValue, model, entity, time) end if
        rendered = rendered + 1
      else if model.kind == MODEL_ALIAS then
        drawResult = try(drawAlias(renderer, model, entity, time, false, false))
        if drawResult is error then return error(3894, "alias " + model.name + " entity " + entity.number + ": " + drawResult.message) end if
        rendered = rendered + 1
      end if
    end if
    index = index + 1
  end while
  index = 0
  while index < entityCount
    entity = entities[index]
    if entity is not void and (hiddenEntityNumber is void or entity.number != hiddenEntityNumber) and entity.modelIndex > 0 and entity.modelIndex < modelCount then
      model = renderer.models[entity.modelIndex]
      if model.kind == MODEL_SPRITE then
        drawResult = try(drawSprite(renderer, model, entity, viewRight, viewUp, time))
        if drawResult is error then return error(3895, "sprite " + model.name + " entity " + entity.number + ": " + drawResult.message) end if
        rendered = rendered + 1
      end if
    end if
    index = index + 1
  end while
  renderer.renderedEntities = rendered
  return rendered
end function

// Draw the entity portion of the optional additive per-pixel light layer.
// Sprites remain emissive/alpha-tested and intentionally do not receive it.
function renderEnhancedSubmitted(renderer, worldRendererValue, entities, hiddenEntityNumber, time)
  if not enhanced.hasActiveLights() then return 0 end if
  worldRenderer.GL_DisableMultitexture()
  gl.enable(gl.GL_TEXTURE_2D)
  gl.enable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_ONE, gl.GL_ONE)
  gl.depthMask(false)
  gl.depthFunc(worldRenderer.R_CurrentDepthFunction())
  enhanced.beginOverlay()
  rendered = 0
  entityCount = len(entities)
  modelCount = len(renderer.models)
  index = 0
  while index < entityCount
    entity = entities[index]
    if entity is not void and (hiddenEntityNumber is void or entity.number != hiddenEntityNumber) and entity.modelIndex > 0 and entity.modelIndex < modelCount then
      model = renderer.models[entity.modelIndex]
      if model.kind == MODEL_BRUSH then
        result = try(drawBrushEnhanced(worldRendererValue, model, entity, time))
        if result is error then finishEnhancedEntityOverlay(); return result end if
        rendered = rendered + 1
      else if model.kind == MODEL_ALIAS then
        result = try(drawAlias(renderer, model, entity, time, false, true))
        if result is error then finishEnhancedEntityOverlay(); return result end if
        rendered = rendered + 1
      end if
    end if
    index = index + 1
  end while
  finishEnhancedEntityOverlay()
  return rendered
end function

// Render the requested value.
function render(renderer, worldRendererValue, entities, viewEntity, viewRight, viewUp, time)
  return renderSubmitted(renderer, worldRendererValue, entities, viewEntity, viewRight, viewUp, time)
end function

// R_DrawViewModel / V_CalcRefdef. The gun is a normal alias model drawn
// from the view entity, with a compressed depth range so it cannot poke
// through nearby world surfaces.
function viewModelDepthRange(depthMin, depthMax)
  weaponMax = depthMin + renderUiContract.viewModelDepthMaximum() * (depthMax - depthMin)
  return [depthMin, weaponMax]
end function

// Render view model.
function renderViewModel(renderer, player, view, time)
  global viewModelScratch
  if player.weapon <= 0 or player.weapon >= len(renderer.models) then return 0 end if
  if player.health <= 0.0 then return 0 end if
  if (player.items & c.IT_INVISIBILITY) != 0 then return 0 end if
  model = renderer.models[player.weapon]
  if model is void or model.kind != MODEL_ALIAS then return 0 end if

  if not view.viewModelVisible then return 0 end if
  if viewModelScratch is void then
    gunOrigin = t.Vec3(0.0, 0.0, 0.0)
    gunAngles = t.Vec3(0.0, 0.0, 0.0)
    messageOrigin = t.Vec3(0.0, 0.0, 0.0)
    previousMessageOrigin = t.Vec3(0.0, 0.0, 0.0)
    messageAngles = t.Vec3(0.0, 0.0, 0.0)
    previousMessageAngles = t.Vec3(0.0, 0.0, 0.0)
    baselineOrigin = t.Vec3(0.0, 0.0, 0.0)
    baselineAngles = t.Vec3(0.0, 0.0, 0.0)
    baseline = [0, 0, 0, 0, baselineOrigin, baselineAngles, 0]
    viewModelScratch = t.ClientEntityState(
      0, 0, 0, 0, 0, 0,
      gunOrigin, gunAngles, 0.0,
      messageOrigin, previousMessageOrigin, messageAngles, previousMessageAngles,
      true, baseline, 0.0,
    )
  end if
  // R_DrawViewModel owns one transient currententity in GLQuake. Keep the
  // equivalent object and its vectors alive instead of rebuilding nine heap
  // objects for the weapon on every rendered frame.
  entity = viewModelScratch
  entity.modelIndex = player.weapon
  entity.frame = player.weaponFrame
  entity.messageTime = time
  entity.origin.x = view.gunOrigin.x; entity.origin.y = view.gunOrigin.y; entity.origin.z = view.gunOrigin.z
  entity.angles.x = view.gunAngles.x; entity.angles.y = view.gunAngles.y; entity.angles.z = view.gunAngles.z
  entity.messageOrigin.x = view.gunOrigin.x; entity.messageOrigin.y = view.gunOrigin.y; entity.messageOrigin.z = view.gunOrigin.z
  entity.previousMessageOrigin.x = view.gunOrigin.x; entity.previousMessageOrigin.y = view.gunOrigin.y; entity.previousMessageOrigin.z = view.gunOrigin.z
  entity.messageAngles.x = view.gunAngles.x; entity.messageAngles.y = view.gunAngles.y; entity.messageAngles.z = view.gunAngles.z
  entity.previousMessageAngles.x = view.gunAngles.x; entity.previousMessageAngles.y = view.gunAngles.y; entity.previousMessageAngles.z = view.gunAngles.z
  entity.baseline[0] = player.weapon
  entity.baseline[1] = player.weaponFrame
  entity.baseline[4].x = view.gunOrigin.x; entity.baseline[4].y = view.gunOrigin.y; entity.baseline[4].z = view.gunOrigin.z
  entity.baseline[5].x = view.gunAngles.x; entity.baseline[5].y = view.gunAngles.y; entity.baseline[5].z = view.gunAngles.z
  depthMin = worldRenderer.R_CurrentDepthMinimum()
  depthMax = worldRenderer.R_CurrentDepthMaximum()
  weaponDepthMax = depthMin + renderUiContract.viewModelDepthMaximum() * (depthMax - depthMin)
  gl.depthRange(depthMin, weaponDepthMax)
  result = drawAlias(renderer, model, entity, time, true, false)
  gl.depthRange(depthMin, depthMax)
  return result
end function

// Add per-pixel dynamic light to the first-person weapon using the same
// compressed depth range as the classic viewmodel draw.
function renderViewModelEnhanced(renderer, player, view, time)
  if not enhanced.hasActiveLights() then return 0 end if
  if player.weapon <= 0 or player.weapon >= len(renderer.models) then return 0 end if
  if player.health <= 0.0 or (player.items & c.IT_INVISIBILITY) != 0 or not view.viewModelVisible then return 0 end if
  model = renderer.models[player.weapon]
  if model is void or model.kind != MODEL_ALIAS then return 0 end if
  // Reuse the entity assembled by the immediately preceding classic
  // renderViewModel call.  If that call was suppressed there is no overlay.
  if viewModelScratch is void then return 0 end if
  depthMin = worldRenderer.R_CurrentDepthMinimum()
  depthMax = worldRenderer.R_CurrentDepthMaximum()
  weaponDepthMax = depthMin + renderUiContract.viewModelDepthMaximum() * (depthMax - depthMin)
  gl.depthRange(depthMin, weaponDepthMax)
  gl.enable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_ONE, gl.GL_ONE)
  gl.depthMask(false)
  enhanced.beginOverlay()
  result = drawAlias(renderer, model, viewModelScratch, time, true, true)
  finishEnhancedEntityOverlay()
  gl.depthRange(depthMin, depthMax)
  return result
end function

// Release resources owned by the requested value.
function destroy(renderer)
  global translatedPlayerTextures, externalBrushRendererRoots, externalBrushRendererNames, viewModelScratch
  for each brush in externalBrushRendererRoots
    if brush is not void then worldRenderer.destroyStandaloneBrush(brush) end if
  end for
  for each model in renderer.models
    for each entry in model.textureIds
      if entry is array then
        for each texture in entry
          if texture != 0 then gl.deleteTexture(texture) end if
        end for
      else if entry != 0 then
        gl.deleteTexture(entry)
      end if
    end for
    model.textureIds = []
    model.uploaded = false
  end for
  for each texture in translatedPlayerTextures
    if texture != 0 then gl.deleteTexture(texture) end if
  end for
  translatedPlayerTextures = []
  externalBrushRendererRoots = []
  externalBrushRendererNames = []
  viewModelScratch = void
  return true
end function
