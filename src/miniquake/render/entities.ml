package miniquake.render.entities

import miniquake.types as t
import miniquake.constants as c
import miniquake.filesystem as qfs
import miniquake.format.mdl as mdl
import miniquake.format.sprite as spr
import miniquake.render.gl11 as gl
import miniquake.render.world as worldRenderer
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.array_util as arrayutil
import miniquake.mathlib as math

const MODEL_NONE = 0
const MODEL_BRUSH = 1
const MODEL_ALIAS = 2
const MODEL_SPRITE = 3

const SPR_ORIENTED = 3

translatedPlayerTextures = []

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
  if name == "" then return emptyModel(name, MODEL_NONE) end if
  if startsWith(name, "*") then return emptyModel(name, MODEL_BRUSH) end if
  data = try(qfs.readFile(renderer.filesystem, name))
  if data is error then return emptyModel(name, MODEL_NONE) end if
  if endsWithInsensitive(name, ".mdl") then
    parsed = try(mdl.parse(data, name))
    if parsed is error then return emptyModel(name, MODEL_NONE) end if
    return t.ClientRenderModel(name, MODEL_ALIAS, parsed, void, [], false)
  end if
  if endsWithInsensitive(name, ".spr") then
    parsed = try(spr.parse(data, name))
    if parsed is error then return emptyModel(name, MODEL_NONE) end if
    return t.ClientRenderModel(name, MODEL_SPRITE, void, parsed, [], false)
  end if
  return emptyModel(name, MODEL_NONE)
end function

function create(filesystem, palette, modelPrecache)
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
  model.textureIds = arrayutil.makeFilledArray(len(source.skins), 0)
  index = 0
  while index < len(source.skins)
    skin = source.skins[index]
    if len(skin.images) > 0 then
      rgba = worldRenderer.indexedToRgba(skin.images[0], renderer.palette, false)
      texture = gl.generateTexture()
      gl.bindTexture(texture)
      gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST)
      gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST)
      gl.textureParameter(gl.GL_TEXTURE_WRAP_S, gl.GL_REPEAT)
      gl.textureParameter(gl.GL_TEXTURE_WRAP_T, gl.GL_REPEAT)
      gl.uploadRgba(source.skinWidth, source.skinHeight, rgba)
      model.textureIds[index] = texture
    end if
    index = index + 1
  end while
  if len(model.textureIds) == 0 then model.textureIds = [0] end if
  model.uploaded = true
  return true
end function

function uploadSprite(renderer, model)
  if model.uploaded then return true end if
  source = model.spriteModel
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
      rgba = worldRenderer.indexedToRgba(frame.pixels, renderer.palette, true)
      texture = gl.generateTexture()
      gl.bindTexture(texture)
      gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST)
      gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST)
      gl.textureParameter(gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP)
      gl.textureParameter(gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP)
      gl.uploadRgba(frame.width, frame.height, rgba)
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
  index = frameNumber % len(source.frames)
  if index < 0 then index = 0 end if
  set = source.frames[index]
  if len(set.frames) == 0 then return void end if
  if set.grouped then return set.frames[cycleIndex(set.intervals, time, len(set.frames))] end if
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
  if frameSet.grouped then groupIndex = cycleIndex(frameSet.intervals, time, len(frameSet.frames)) end if
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

function drawAlias(renderer, model, entity, time)
  uploadAlias(renderer, model)
  source = model.aliasModel
  frame = aliasFrame(source, entity.frame, time)
  if frame is void then return 0 end if
  skin = entity.skin
  if skin < 0 or skin >= len(model.textureIds) then skin = 0 end if
  texture = 0
  if len(model.textureIds) > 0 then texture = model.textureIds[skin] end if
  translated = translatedPlayerTexture(entity.number)
  if entity.colormap != 0 and translated != 0 then texture = translated end if
  if texture != 0 then gl.bindTexture(texture) end if
  gl.pushMatrix()
  gl.translate(entity.origin.x, entity.origin.y, entity.origin.z)
  gl.rotate(entity.angles.y, 0.0, 0.0, 1.0)
  gl.rotate(-entity.angles.x, 0.0, 1.0, 0.0)
  gl.rotate(entity.angles.z, 1.0, 0.0, 0.0)
  gl.color(255, 255, 255, 255)
  gl.begin(gl.GL_TRIANGLES)
  for each triangle in source.triangles
    indices = [triangle.vertex0, triangle.vertex1, triangle.vertex2]
    for each vertexIndex in indices
      if vertexIndex >= 0 and vertexIndex < len(frame.vertices) and vertexIndex < len(source.texCoords) then
        coordinate = source.texCoords[vertexIndex]
        s = coordinate.s
        if triangle.facesFront == 0 and coordinate.onSeam != 0 then s = s + source.skinWidth / 2 end if
        gl.texcoord2((s + 0.5) / source.skinWidth, (coordinate.t + 0.5) / source.skinHeight)
        value = aliasVertex(source, frame.vertices[vertexIndex])
        gl.vertex3(value.x, value.y, value.z)
      end if
    end for
  end for
  gl.finishPrimitive()
  gl.popMatrix()
  return len(source.triangles)
end function

function drawSprite(renderer, model, entity, viewRight, viewUp, time)
  uploadSprite(renderer, model)
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
  submodel = worldRendererValue.map.models[submodelIndex]
  firstFace = submodel.firstFace
  lastFace = firstFace + submodel.numFaces
  gl.pushMatrix()
  gl.translate(entity.origin.x, entity.origin.y, entity.origin.z)
  gl.rotate(entity.angles.y, 0.0, 0.0, 1.0)
  gl.rotate(-entity.angles.x, 0.0, 1.0, 0.0)
  gl.rotate(entity.angles.z, 1.0, 0.0, 0.0)
  face = firstFace
  while face < lastFace and face < len(worldRendererValue.surfaces)
    if face >= 0 then worldRenderer.drawBaseSurface(worldRendererValue, worldRendererValue.surfaces[face]) end if
    face = face + 1
  end while
  if not worldRendererValue.fullbright and not worldRendererValue.wireframe then
    gl.enable(gl.GL_BLEND)
    gl.blendFunc(gl.GL_ZERO, gl.GL_SRC_COLOR)
    gl.depthMask(false)
    face = firstFace
    while face < lastFace and face < len(worldRendererValue.surfaces)
      if face >= 0 then worldRenderer.drawLightSurface(worldRendererValue.surfaces[face]) end if
      face = face + 1
    end while
    gl.depthMask(true)
    gl.disable(gl.GL_BLEND)
  end if
  gl.popMatrix()
  return submodel.numFaces
end function

function render(renderer, worldRendererValue, entities, viewEntity, viewRight, viewUp, time)
  rendered = 0
  index = 0
  while index < len(entities)
    entity = entities[index]
    if entity is not void and entity.number != viewEntity and entity.modelIndex > 0 and entity.modelIndex < len(renderer.models) then
      model = renderer.models[entity.modelIndex]
      if model.kind == MODEL_BRUSH then
        drawBrush(worldRendererValue, model, entity)
        rendered = rendered + 1
      else if model.kind == MODEL_ALIAS then
        drawAlias(renderer, model, entity, time)
        rendered = rendered + 1
      else if model.kind == MODEL_SPRITE then
        drawSprite(renderer, model, entity, viewRight, viewUp, time)
        rendered = rendered + 1
      end if
    end if
    index = index + 1
  end while
  renderer.renderedEntities = rendered
  return rendered
end function

// R_DrawViewModel / V_CalcRefdef. The gun is a normal alias model drawn
// from the view entity, with a compressed depth range so it cannot poke
// through nearby world surfaces.
function renderViewModel(renderer, player, view, time)
  if player.weapon <= 0 or player.weapon >= len(renderer.models) then return 0 end if
  if player.health <= 0.0 then return 0 end if
  if (player.items & c.IT_INVISIBILITY) != 0 then return 0 end if
  model = renderer.models[player.weapon]
  if model is void or model.kind != MODEL_ALIAS then return 0 end if

  // WinQuake starts the view model at the player origin plus viewheight, then
  // adds the weapon bob. view.origin already includes stair smoothing; retain
  // that correction while keeping the original forward bob component.
  gunOrigin = t.Vec3(
    view.origin.x + view.forward.x * view.bob * 0.4 - 0.03125,
    view.origin.y + view.forward.y * view.bob * 0.4 - 0.03125,
    view.origin.z - 0.03125,
  )
  gunAngles = t.Vec3(-view.angles.x, view.angles.y, view.angles.z)
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
  )
  gl.depthRange(0.0, 0.3)
  result = drawAlias(renderer, model, entity, time)
  gl.depthRange(0.0, 1.0)
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

