package miniquake.render.entities

import miniquake.types as t
import miniquake.constants as c
import miniquake.model_registry as modelRegistry
import miniquake.render.gl11 as gl
import miniquake.render.world as worldRenderer
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.array_util as arrayutil
import miniquake.mathlib as math
import miniquake.render.alias_mesh as aliasMesh
import miniquake.render.draw2d as draw2d
import miniquake.render_ui_contract as renderUiContract

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
aliasNoColors = false
aliasDoubleEyes = true

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

function AliasRenderingConfiguration()
  return [
    aliasSmoothModels, aliasAffineModels, aliasShadows,
    aliasNoColors, aliasDoubleEyes,
  ]
end function

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

function emptyModel(name, kind)
  return t.ClientRenderModel(name, kind, void, void, [], false)
end function

function loadModel(renderer, name)
  global renderModelRegistry
  if name == "" then return emptyModel(name, MODEL_NONE) end if
  if startsWith(name, "*") then return emptyModel(name, MODEL_BRUSH) end if
  if renderModelRegistry is void then renderModelRegistry = modelRegistry.Mod_Init(modelRegistry.create(), void) end if
  parsed = try(modelRegistry.Mod_ForName(renderModelRegistry, renderer.filesystem, name, false))
  if parsed is error or parsed is void then return emptyModel(name, MODEL_NONE) end if
  kind = modelRegistry.modelType(renderModelRegistry, name)
  if kind == modelRegistry.MOD_ALIAS then return t.ClientRenderModel(name, MODEL_ALIAS, parsed, void, [], false) end if
  if kind == modelRegistry.MOD_SPRITE then return t.ClientRenderModel(name, MODEL_SPRITE, void, parsed, [], false) end if
  if kind == modelRegistry.MOD_BRUSH then return emptyModel(name, MODEL_BRUSH) end if
  return emptyModel(name, MODEL_NONE)
end function

function create(filesystem, palette, modelPrecache)
  global renderModelRegistry
  aliasMesh.clearCaches()
  renderModelRegistry = modelRegistry.Mod_Init(modelRegistry.create(), void)
  draw2d.Draw_SetPalette(palette)
  renderer = t.EntityRenderer(filesystem, palette, [], 0)
  synchronize(renderer, modelPrecache)
  return renderer
end function

function uploadIndexedTexture(width, height, pixels, palette, transparent)
  if width <= 0 or height <= 0 then return 0 end if
  if len(pixels) < width * height then return 0 end if
  rgba = worldRenderer.indexedToRgba(pixels, palette, transparent)
  texture = gl.generateTexture()
  gl.bindTexture(texture)
  // R_TranslatePlayerSkin uses non-mipmapped linear filtering.
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_S, gl.GL_REPEAT)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_T, gl.GL_REPEAT)
  gl.uploadRgba(width, height, rgba)
  return texture
end function

function translatedPlayerTexture(entityNumber)
  if entityNumber < 0 or entityNumber >= len(translatedPlayerTextures) then return 0 end if
  return translatedPlayerTextures[entityNumber]
end function

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
    models[index] = loadModel(renderer, modelPrecache[index])
    index = index + 1
  end while
  renderer.models = models
  return targetCount
end function

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

function upload(renderer, model)
  if model.kind == MODEL_ALIAS then return uploadAlias(renderer, model) end if
  if model.kind == MODEL_SPRITE then return uploadSprite(renderer, model) end if
  return false
end function

function precache(renderer)
  if renderer is void then return error(3940, "entity precache: renderer is void") end if
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
    end if
    index = index + 1
  end while
  return count
end function

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

function aliasVertex(source, packed)
  return t.Vec3(
    packed.x * source.scale.x + source.scaleOrigin.x,
    packed.y * source.scale.y + source.scaleOrigin.y,
    packed.z * source.scale.z + source.scaleOrigin.z,
  )
end function

function aliasShade(model, entity, time, viewModel)
  ambient = worldRenderer.R_LightPoint(entity.origin)
  shade = ambient
  for each light in worldRenderer.R_ActiveDynamicLights()
    if light.radius > 0.0 and light.die >= time then
      deltaX = entity.origin.x - light.origin.x
      deltaY = entity.origin.y - light.origin.y
      deltaZ = entity.origin.z - light.origin.z
      distance = native.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
      addition = light.radius - distance
      if addition > 0.0 then ambient = ambient + addition; shade = shade + addition end if
    end if
  end for
  if viewModel and ambient < 24.0 then ambient = 24.0; shade = 24.0 end if
  if ambient > 128.0 then ambient = 128.0 end if
  if ambient + shade > 192.0 then shade = 192.0 - ambient end if
  if entity.colormap != 0 and ambient < 8.0 then ambient = 8.0; shade = 8.0 end if
  if model.name == "progs/flame.mdl" or model.name == "progs/flame2.mdl" then ambient = 256.0; shade = 256.0 end if
  return [shade / 200.0, ambient]
end function

function drawAlias(renderer, model, entity, time, viewModel)
  uploadAlias(renderer, model)
  source = model.aliasModel
  frame = aliasFrame(source, entity.frame, time)
  if frame is void then return 0 end if
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
  lighting = aliasShade(model, entity, time, viewModel)
  aliasMesh.configureAliasLighting(lighting[0], lighting[1], entity.angles.y, worldRenderer.lightspot)
  mesh = aliasMesh.GL_MakeAliasModelDisplayLists(source, source)
  doubleEyes = model.name == "progs/eyes.mdl" and aliasDoubleEyes
  drawn = 0
  if not gl.traceEnabled() then
    drawn = aliasMesh.drawAliasModelBatch(source, frame, mesh, entity.origin, entity.angles, doubleEyes, aliasSmoothModels)
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
    drawn = aliasMesh.drawAliasMesh(source, frame, mesh)
    gl.textureEnvironment(gl.GL_REPLACE)
    gl.shadeModel(gl.GL_FLAT)
    gl.color(255, 255, 255, 255)
    gl.disable(gl.GL_CULL_FACE)
    gl.popMatrix()
  end if
  if aliasShadows then
    gl.pushMatrix()
    gl.translate(entity.origin.x, entity.origin.y, entity.origin.z)
    gl.rotate(entity.angles.y, 0.0, 0.0, 1.0)
    gl.rotate(-entity.angles.x, 0.0, 1.0, 0.0)
    gl.rotate(entity.angles.z, 1.0, 0.0, 0.0)
    gl.disable(gl.GL_TEXTURE_2D)
    gl.enable(gl.GL_BLEND)
    gl.color(0, 0, 0, 128)
    aliasMesh.GL_DrawAliasShadowAtOrigin(source, frame, entity.origin.z)
    gl.enable(gl.GL_TEXTURE_2D)
    gl.disable(gl.GL_BLEND)
    gl.color(255, 255, 255, 255)
    gl.popMatrix()
  end if
  return drawn
end function

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

  bottomLeft = t.Vec3(
    entity.origin.x + upVector.x * bottom + rightVector.x * left,
    entity.origin.y + upVector.y * bottom + rightVector.y * left,
    entity.origin.z + upVector.z * bottom + rightVector.z * left,
  )
  topLeft = t.Vec3(
    entity.origin.x + upVector.x * top + rightVector.x * left,
    entity.origin.y + upVector.y * top + rightVector.y * left,
    entity.origin.z + upVector.z * top + rightVector.z * left,
  )
  topRight = t.Vec3(
    entity.origin.x + upVector.x * top + rightVector.x * rightValue,
    entity.origin.y + upVector.y * top + rightVector.y * rightValue,
    entity.origin.z + upVector.z * top + rightVector.z * rightValue,
  )
  bottomRight = t.Vec3(
    entity.origin.x + upVector.x * bottom + rightVector.x * rightValue,
    entity.origin.y + upVector.y * bottom + rightVector.y * rightValue,
    entity.origin.z + upVector.z * bottom + rightVector.z * rightValue,
  )

  gl.begin(gl.GL_QUADS)
  gl.texcoord2(0.0, 1.0); gl.vertex3(bottomLeft.x, bottomLeft.y, bottomLeft.z)
  gl.texcoord2(0.0, 0.0); gl.vertex3(topLeft.x, topLeft.y, topLeft.z)
  gl.texcoord2(1.0, 0.0); gl.vertex3(topRight.x, topRight.y, topRight.z)
  gl.texcoord2(1.0, 1.0); gl.vertex3(bottomRight.x, bottomRight.y, bottomRight.z)
  gl.finishPrimitive()
  gl.disable(gl.GL_ALPHA_TEST)
  return 1
end function

function brushModelIndex(name)
  source = bytes(name)
  if len(source) < 2 or source[0] != 42 then return -1 end if
  value = toNumber(decode(slice(source, 1, len(source) - 1)))
  if value is void or value is not int then return -1 end if
  return value
end function

function drawBrush(worldRendererValue, model, entity)
  submodelIndex = brushModelIndex(model.name)
  if submodelIndex <= 0 or submodelIndex >= len(worldRendererValue.map.models) then return 0 end if
  // Use the canonical MiniQuake bmodel path.  The client model index is a
  // precache slot, while the leading *n name identifies the BSP submodel.
  // Passing that index explicitly preserves entity.frame texture animation,
  // dynamic-light marking and GL_LUMINANCE lightmap blend semantics.
  return worldRenderer.R_DrawBrushModelForSubmodel(entity, submodelIndex)
end function

function renderSubmitted(renderer, worldRendererValue, entities, hiddenEntityNumber, viewRight, viewUp, time)
  rendered = 0
  // R_DrawEntitiesOnList renders opaque alias/brush models first and performs
  // a second pass for alpha-tested sprites.  Keeping the passes separate is
  // observable where a sprite intersects an alias model.
  index = 0
  while index < len(entities)
    entity = entities[index]
    if entity is not void and (hiddenEntityNumber is void or entity.number != hiddenEntityNumber) and entity.modelIndex > 0 and entity.modelIndex < len(renderer.models) then
      model = renderer.models[entity.modelIndex]
      if model.kind == MODEL_BRUSH then
        drawResult = try(drawBrush(worldRendererValue, model, entity))
        if drawResult is error then return error(3893, "brush " + model.name + " entity " + entity.number + ": " + drawResult.message) end if
        rendered = rendered + 1
      else if model.kind == MODEL_ALIAS then
        drawResult = try(drawAlias(renderer, model, entity, time, false))
        if drawResult is error then return error(3894, "alias " + model.name + " entity " + entity.number + ": " + drawResult.message) end if
        rendered = rendered + 1
      end if
    end if
    index = index + 1
  end while
  index = 0
  while index < len(entities)
    entity = entities[index]
    if entity is not void and (hiddenEntityNumber is void or entity.number != hiddenEntityNumber) and entity.modelIndex > 0 and entity.modelIndex < len(renderer.models) then
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

function renderViewModel(renderer, player, view, time)
  if player.weapon <= 0 or player.weapon >= len(renderer.models) then return 0 end if
  if player.health <= 0.0 then return 0 end if
  if (player.items & c.IT_INVISIBILITY) != 0 then return 0 end if
  model = renderer.models[player.weapon]
  if model is void or model.kind != MODEL_ALIAS then return 0 end if

  if not view.viewModelVisible then return 0 end if
  gunOrigin = math.copy(view.gunOrigin)
  gunAngles = math.copy(view.gunAngles)
  messageOrigin = math.copy(gunOrigin)
  previousMessageOrigin = math.copy(gunOrigin)
  messageAngles = math.copy(gunAngles)
  previousMessageAngles = math.copy(gunAngles)
  baselineOrigin = math.copy(gunOrigin)
  baselineAngles = math.copy(gunAngles)
  baseline = [player.weapon, player.weaponFrame, 0, 0, baselineOrigin, baselineAngles, 0]
  entity = t.ClientEntityState(
    0,
    player.weapon,
    player.weaponFrame,
    0,
    0,
    0,
    gunOrigin,
    gunAngles,
    time,
    messageOrigin,
    previousMessageOrigin,
    messageAngles,
    previousMessageAngles,
    true,
    baseline,
    0.0,
  )
  activeDepth = worldRenderer.R_CurrentDepthRange()
  weaponDepth = viewModelDepthRange(activeDepth[0], activeDepth[1])
  gl.depthRange(weaponDepth[0], weaponDepth[1])
  result = drawAlias(renderer, model, entity, time, true)
  gl.depthRange(activeDepth[0], activeDepth[1])
  return result
end function

function destroy(renderer)
  global translatedPlayerTextures
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
  return true
end function
