package miniquake.render.original

import miniquake.types as compatRmainTypes
import miniquake.constants as compatRmainConstants
import miniquake.mathlib as compatRmainMath
import miniquake.native as compatRmainNative
import miniquake.cvar as compatRmainCvar
import miniquake.client as compatRmainClient
import miniquake.array_util as compatRmainArrays
import miniquake.world_bsp as compatRmainBsp
import miniquake.render.gl11 as compatRmainGl
import miniquake.render.world as compatRmainWorld
import miniquake.render.entities as compatRmainEntities
import miniquake.render.alias_mesh as compatRmainAlias
import miniquake.render.particles as compatRmainParticles
import miniquake.platform.win32 as compatRmainWin
import std.fs as compatRmainFs

// Canonical WinQuake 1.09 gl_refrag.c, gl_rmain.c and gl_rmisc.c public
// surface.  C pointers, fixed arrays and translation-unit globals are mapped
// to explicit MiniLang object references and package globals.  Rendering and
// gameplay equations are retained; only platform/pointer storage differs.

struct EfragRef
  entity
  leafIndex
end struct

r_worldentity = void
r_cache_thrash = false
modelorg = compatRmainTypes.Vec3(0.0, 0.0, 0.0)
r_entorigin = compatRmainTypes.Vec3(0.0, 0.0, 0.0)
currententity = void
frustum = [
  compatRmainTypes.Plane(compatRmainTypes.Vec3(0.0, 0.0, 0.0), 0.0, 5, 0),
  compatRmainTypes.Plane(compatRmainTypes.Vec3(0.0, 0.0, 0.0), 0.0, 5, 0),
  compatRmainTypes.Plane(compatRmainTypes.Vec3(0.0, 0.0, 0.0), 0.0, 5, 0),
  compatRmainTypes.Plane(compatRmainTypes.Vec3(0.0, 0.0, 0.0), 0.0, 5, 0),
]
c_brush_polys = 0
c_alias_polys = 0
envmap = false
currenttexture = -1
cnttextures = [-1, -1]
particletexture = 0
playertextures = []
mirrortexturenum = -1
mirror = false
mirror_plane = void
vup = compatRmainTypes.Vec3(0.0, 0.0, 1.0)
vpn = compatRmainTypes.Vec3(1.0, 0.0, 0.0)
vright = compatRmainTypes.Vec3(0.0, -1.0, 0.0)
r_origin = compatRmainTypes.Vec3(0.0, 0.0, 0.0)
r_viewleaf = 0
r_oldviewleaf = 0
r_notexture_mip = void
r_notexture_mips = []
rCompatParticleTexture = 0
rCompatRenderer = void
rCompatEntityRenderer = void
rCompatView = void
rCompatPlayer = void
rCompatClient = void
rCompatServer = void
rCompatParticles = []
rCompatTemporary = []
rCompatCvars = void
rCompatGameDirectory = ""
rCompatWidth = 640
rCompatHeight = 480
rCompatTime = 0.0
rCompatRealtime = 0.0
rCompatFrameTime = 0.0
rCompatViewEntity = 0
rCompatDrawEntities = true
rCompatDrawViewModel = true
rCompatDepthMin = 0.0
rCompatDepthMax = 1.0
rCompatTrickFrame = 0
rCompatLeafEfrags = []
rCompatEntityEfrags = []
rCompatEfragTopNode = void
rCompatAddEntity = void
rCompatEntityMins = compatRmainTypes.Vec3(0.0, 0.0, 0.0)
rCompatEntityMaxs = compatRmainTypes.Vec3(0.0, 0.0, 0.0)
cl_visedicts = []
cl_numvisedicts = 0

function compatCvarValue(name, fallback)
  if rCompatCvars is void then return fallback end if
  variable = compatRmainCvar.find(rCompatCvars, name)
  if variable is void then return fallback end if
  return variable.value
end function

function compatBoolCvar(name, fallback)
  return compatCvarValue(name, fallback) != 0.0
end function

function compatVector(value)
  if value is void then return compatRmainTypes.Vec3(0.0, 0.0, 0.0) end if
  return compatRmainMath.copy(value)
end function

function R_ConfigureCompatibility(
  renderer,
  entityRenderer,
  viewState,
  player,
  client,
  server,
  particles,
  temporaryEntities,
  cvars,
  gameDirectory,
  width,
  height,
  currentTime,
  realtime,
  frameTime,
)
  global rCompatRenderer, rCompatEntityRenderer, rCompatView, rCompatPlayer
  global rCompatClient, rCompatServer, rCompatParticles, rCompatTemporary
  global rCompatCvars, rCompatGameDirectory, rCompatWidth, rCompatHeight
  global rCompatTime, rCompatRealtime, rCompatFrameTime, rCompatViewEntity
  global rCompatDrawEntities, rCompatDrawViewModel
  rCompatRenderer = renderer
  rCompatEntityRenderer = entityRenderer
  rCompatView = viewState
  rCompatPlayer = player
  rCompatClient = client
  rCompatServer = server
  rCompatParticles = particles
  rCompatTemporary = temporaryEntities
  rCompatCvars = cvars
  rCompatGameDirectory = gameDirectory
  rCompatWidth = width
  rCompatHeight = height
  rCompatTime = currentTime
  rCompatRealtime = realtime
  rCompatFrameTime = frameTime
  if client is not void then rCompatViewEntity = client.viewEntity end if
  rCompatDrawEntities = compatBoolCvar("r_drawentities", 1.0)
  rCompatDrawViewModel = compatBoolCvar("r_drawviewmodel", 1.0)
  if renderer is not void and viewState is not void then
    dynamicLights = compatRmainClient.clDlights
    lightStyles = []
    if server is not void then lightStyles = server.lightStyles end if
    compatRmainWorld.R_ConfigureWorldCompatibility(
      renderer,
      viewState.origin,
      viewState.angles,
      viewState.forward,
      viewState.right,
      viewState.up,
      dynamicLights,
      lightStyles,
      viewState.blend,
      currentTime,
      realtime,
      frameTime,
      compatBoolCvar("gl_flashblend", 1.0),
      compatBoolCvar("r_dynamic", 1.0),
      compatBoolCvar("r_novis", 0.0),
    )
  end if
  compatEnsureEfragState()
  return true
end function

// -----------------------------------------------------------------------------
// gl_refrag.c
// -----------------------------------------------------------------------------

function compatEnsureEfragState()
  global rCompatLeafEfrags, rCompatEntityEfrags
  leafCount = 0
  entityCount = 0
  if rCompatRenderer is not void then leafCount = len(rCompatRenderer.map.leafs) end if
  if rCompatClient is not void then entityCount = len(rCompatClient.entities) end if
  if len(rCompatLeafEfrags) != leafCount then
    rCompatLeafEfrags = compatRmainArrays.makeEmptyArray(leafCount)
    index = 0
    while index < leafCount
      rCompatLeafEfrags[index] = []
      index = index + 1
    end while
  end if
  if len(rCompatEntityEfrags) < entityCount then
    old = rCompatEntityEfrags
    rCompatEntityEfrags = compatRmainArrays.makeEmptyArray(entityCount)
    index = 0
    while index < len(old)
      rCompatEntityEfrags[index] = old[index]
      index = index + 1
    end while
    while index < entityCount
      rCompatEntityEfrags[index] = []
      index = index + 1
    end while
  end if
  return true
end function

function R_RemoveEfrags(ent)
  global rCompatLeafEfrags, rCompatEntityEfrags
  if ent is void then return false end if
  compatEnsureEfragState()
  number = ent.number
  if number < 0 or number >= len(rCompatEntityEfrags) then return false end if
  for each reference in rCompatEntityEfrags[number]
    leafIndex = reference.leafIndex
    if leafIndex >= 0 and leafIndex < len(rCompatLeafEfrags) then
      source = rCompatLeafEfrags[leafIndex]
      builder = compatRmainArrays.createArrayBuilder(len(source))
      for each candidate in source
        if candidate != reference then compatRmainArrays.pushArrayBuilder(builder, candidate) end if
      end for
      rCompatLeafEfrags[leafIndex] = compatRmainArrays.finishArrayBuilder(builder)
    end if
  end for
  rCompatEntityEfrags[number] = []
  return true
end function

function compatAppendEfrag(leafIndex)
  global rCompatLeafEfrags, rCompatEntityEfrags, rCompatEfragTopNode
  if rCompatAddEntity is void then return false end if
  if leafIndex < 0 or leafIndex >= len(rCompatLeafEfrags) then return false end if
  reference = EfragRef(rCompatAddEntity, leafIndex)
  rCompatLeafEfrags[leafIndex] = rCompatLeafEfrags[leafIndex] + [reference]
  number = rCompatAddEntity.number
  if number >= 0 and number < len(rCompatEntityEfrags) then
    rCompatEntityEfrags[number] = rCompatEntityEfrags[number] + [reference]
  end if
  if rCompatEfragTopNode is void then rCompatEfragTopNode = -1 - leafIndex end if
  return true
end function

function R_SplitEntityOnNode(node)
  global rCompatEfragTopNode
  if rCompatRenderer is void or rCompatAddEntity is void then return 0 end if
  if node < 0 then
    leafIndex = -1 - node
    if leafIndex < 0 or leafIndex >= len(rCompatRenderer.map.leafs) then return 0 end if
    if rCompatRenderer.map.leafs[leafIndex].contents == compatRmainConstants.CONTENTS_SOLID then return 0 end if
    if compatAppendEfrag(leafIndex) then return 1 end if
    return 0
  end if
  if node >= len(rCompatRenderer.map.nodes) then return 0 end if
  bspNode = rCompatRenderer.map.nodes[node]
  if bspNode.planeIndex < 0 or bspNode.planeIndex >= len(rCompatRenderer.map.planes) then return 0 end if
  plane = rCompatRenderer.map.planes[bspNode.planeIndex]
  sides = compatRmainMath.boxOnPlaneSide(rCompatEntityMins, rCompatEntityMaxs, plane)
  if sides == 3 and rCompatEfragTopNode is void then rCompatEfragTopNode = node end if
  count = 0
  if (sides & 1) != 0 then count = count + R_SplitEntityOnNode(bspNode.child0) end if
  if (sides & 2) != 0 then count = count + R_SplitEntityOnNode(bspNode.child1) end if
  return count
end function

function compatModelBounds(ent)
  if rCompatEntityRenderer is void or ent.modelIndex <= 0 or ent.modelIndex >= len(rCompatEntityRenderer.models) then return void end if
  model = rCompatEntityRenderer.models[ent.modelIndex]
  if model.kind == compatRmainEntities.MODEL_BRUSH then
    submodelIndex = compatRmainEntities.brushModelIndex(model.name)
    if rCompatRenderer is void or submodelIndex <= 0 or submodelIndex >= len(rCompatRenderer.map.models) then return void end if
    submodel = rCompatRenderer.map.models[submodelIndex]
    return [compatRmainMath.add(ent.origin, submodel.mins), compatRmainMath.add(ent.origin, submodel.maxs)]
  end if
  radius = 0.0
  if model.kind == compatRmainEntities.MODEL_ALIAS and model.aliasModel is not void then radius = model.aliasModel.boundingRadius end if
  if model.kind == compatRmainEntities.MODEL_SPRITE and model.spriteModel is not void then radius = model.spriteModel.boundingRadius end if
  if radius <= 0.0 then radius = 16.0 end if
  extent = compatRmainTypes.Vec3(radius, radius, radius)
  return [compatRmainMath.subtract(ent.origin, extent), compatRmainMath.add(ent.origin, extent)]
end function

function R_AddEfrags(ent)
  global rCompatAddEntity, rCompatEntityMins, rCompatEntityMaxs, rCompatEfragTopNode
  if ent is void or rCompatRenderer is void or len(rCompatRenderer.map.models) == 0 then return 0 end if
  bounds = compatModelBounds(ent)
  if bounds is void then return 0 end if
  R_RemoveEfrags(ent)
  rCompatAddEntity = ent
  rCompatEntityMins = bounds[0]
  rCompatEntityMaxs = bounds[1]
  rCompatEfragTopNode = void
  root = rCompatRenderer.map.models[0].headNodes[0]
  result = R_SplitEntityOnNode(root)
  rCompatAddEntity = void
  return result
end function

function compatStoreReference(reference, output)
  global cl_numvisedicts
  if reference is void or reference.entity is void then return false end if
  entity = reference.entity
  index = 0
  while index < output.count
    if output.values[index].number == entity.number then return false end if
    index = index + 1
  end while
  if output.count >= compatRmainConstants.MAX_VISEDICTS then return false end if
  compatRmainArrays.pushArrayBuilder(output, entity)
  cl_numvisedicts = cl_numvisedicts + 1
  return true
end function

function R_StoreEfrags(ppefrag)
  global cl_visedicts, cl_numvisedicts
  builder = compatRmainArrays.createArrayBuilder(compatRmainConstants.MAX_VISEDICTS)
  cl_numvisedicts = 0
  if ppefrag is int then
    if ppefrag >= 0 and ppefrag < len(rCompatLeafEfrags) then
      for each reference in rCompatLeafEfrags[ppefrag]
        compatStoreReference(reference, builder)
      end for
    end if
  else if ppefrag is array then
    for each reference in ppefrag
      compatStoreReference(reference, builder)
    end for
  else if typeName(ppefrag) == "EfragRef" then
    compatStoreReference(ppefrag, builder)
  end if
  cl_visedicts = compatRmainArrays.finishArrayBuilder(builder)
  cl_numvisedicts = len(cl_visedicts)
  return cl_visedicts
end function

function compatCollectVisibleEfrags()
  global cl_visedicts, cl_numvisedicts
  compatEnsureEfragState()
  if rCompatClient is void then return [] end if
  index = 0
  while index < len(rCompatClient.entities)
    entity = rCompatClient.entities[index]
    if entity is not void and entity.modelIndex > 0 then R_AddEfrags(entity) end if
    index = index + 1
  end while
  builder = compatRmainArrays.createArrayBuilder(compatRmainConstants.MAX_VISEDICTS)
  leafIndex = 0
  while leafIndex < len(rCompatLeafEfrags)
    visible = true
    if rCompatRenderer is not void and leafIndex > 0 then
      pvs = compatRmainBsp.leafPvs(rCompatRenderer.map, rCompatRenderer.viewLeaf)
      visible = compatRmainBsp.leafVisible(pvs, leafIndex)
    end if
    if visible then
      for each reference in rCompatLeafEfrags[leafIndex]
        compatStoreReference(reference, builder)
      end for
    end if
    leafIndex = leafIndex + 1
  end while
  cl_visedicts = compatRmainArrays.finishArrayBuilder(builder)
  cl_numvisedicts = len(cl_visedicts)
  return cl_visedicts
end function

// -----------------------------------------------------------------------------
// gl_rmain.c
// -----------------------------------------------------------------------------

function R_CullBox(mins, maxs)
  index = 0
  while index < 4
    if compatRmainMath.boxOnPlaneSide(mins, maxs, frustum[index]) == 2 then return true end if
    index = index + 1
  end while
  return false
end function

function R_RotateForEntity(entity)
  if entity is void then return false end if
  compatRmainGl.translate(entity.origin.x, entity.origin.y, entity.origin.z)
  compatRmainGl.rotate(entity.angles.y, 0.0, 0.0, 1.0)
  compatRmainGl.rotate(-entity.angles.x, 0.0, 1.0, 0.0)
  compatRmainGl.rotate(entity.angles.z, 1.0, 0.0, 0.0)
  return true
end function

function R_GetSpriteFrame(entity)
  if entity is void or rCompatEntityRenderer is void then return void end if
  if entity.modelIndex <= 0 or entity.modelIndex >= len(rCompatEntityRenderer.models) then return void end if
  model = rCompatEntityRenderer.models[entity.modelIndex]
  if model.kind != compatRmainEntities.MODEL_SPRITE then return void end if
  selected = compatRmainEntities.spriteFrameAndTexture(model, entity, rCompatTime)
  if selected is void then return void end if
  return selected[0]
end function

function R_DrawSpriteModel(entity)
  global currententity
  if entity is void or rCompatEntityRenderer is void or rCompatView is void then return 0 end if
  if entity.modelIndex <= 0 or entity.modelIndex >= len(rCompatEntityRenderer.models) then return 0 end if
  model = rCompatEntityRenderer.models[entity.modelIndex]
  if model.kind != compatRmainEntities.MODEL_SPRITE then return 0 end if
  currententity = entity
  return compatRmainEntities.drawSprite(rCompatEntityRenderer, model, entity, rCompatView.right, rCompatView.up, rCompatTime)
end function

function R_DrawAliasModel(entity)
  global currententity, c_alias_polys, r_entorigin, modelorg
  if entity is void or rCompatEntityRenderer is void or rCompatRenderer is void then return 0 end if
  if entity.modelIndex <= 0 or entity.modelIndex >= len(rCompatEntityRenderer.models) then return 0 end if
  model = rCompatEntityRenderer.models[entity.modelIndex]
  if model.kind != compatRmainEntities.MODEL_ALIAS or model.aliasModel is void then return 0 end if
  radius = model.aliasModel.boundingRadius
  extent = compatRmainTypes.Vec3(radius, radius, radius)
  mins = compatRmainMath.subtract(entity.origin, extent)
  maxs = compatRmainMath.add(entity.origin, extent)
  if R_CullBox(mins, maxs) then return 0 end if
  currententity = entity
  r_entorigin = compatRmainMath.copy(entity.origin)
  modelorg = compatRmainMath.subtract(r_origin, r_entorigin)
  result = compatRmainEntities.drawAlias(rCompatEntityRenderer, model, entity, rCompatTime)
  c_alias_polys = c_alias_polys + model.aliasModel.numTriangles
  return result
end function

function R_DrawEntitiesOnList()
  if not rCompatDrawEntities or rCompatEntityRenderer is void or rCompatClient is void then return 0 end if
  visible = compatCollectVisibleEfrags()
  if len(visible) == 0 then visible = rCompatClient.entities end if
  count = 0
  for each entity in visible
    if entity is not void and entity.number != rCompatViewEntity and entity.modelIndex > 0 and entity.modelIndex < len(rCompatEntityRenderer.models) then
      model = rCompatEntityRenderer.models[entity.modelIndex]
      if model.kind == compatRmainEntities.MODEL_ALIAS then count = count + R_DrawAliasModel(entity)
      else if model.kind == compatRmainEntities.MODEL_BRUSH then count = count + compatRmainEntities.drawBrush(rCompatRenderer, model, entity)
      end if
    end if
  end for
  for each entity in visible
    if entity is not void and entity.number != rCompatViewEntity and entity.modelIndex > 0 and entity.modelIndex < len(rCompatEntityRenderer.models) then
      model = rCompatEntityRenderer.models[entity.modelIndex]
      if model.kind == compatRmainEntities.MODEL_SPRITE then count = count + R_DrawSpriteModel(entity) end if
    end if
  end for
  return count
end function

function R_DrawViewModel()
  if not rCompatDrawViewModel or not rCompatDrawEntities then return 0 end if
  if envmap or rCompatPlayer is void or rCompatView is void or rCompatEntityRenderer is void then return 0 end if
  if compatBoolCvar("chase_active", 0.0) then return 0 end if
  return compatRmainEntities.renderViewModel(rCompatEntityRenderer, rCompatPlayer, rCompatView, rCompatTime)
end function

function R_PolyBlend()
  if not compatBoolCvar("gl_polyblend", 1.0) or rCompatView is void then return false end if
  blend = rCompatView.blend
  if blend is void or len(blend) < 4 or blend[3] == 0.0 then return false end if
  compatRmainWorld.GL_DisableMultitexture()
  compatRmainGl.disable(compatRmainGl.GL_ALPHA_TEST)
  compatRmainGl.enable(compatRmainGl.GL_BLEND)
  compatRmainGl.disable(compatRmainGl.GL_DEPTH_TEST)
  compatRmainGl.disable(compatRmainGl.GL_TEXTURE_2D)
  compatRmainGl.matrixMode(compatRmainGl.GL_MODELVIEW)
  compatRmainGl.loadIdentity()
  compatRmainGl.rotate(-90.0, 1.0, 0.0, 0.0)
  compatRmainGl.rotate(90.0, 0.0, 0.0, 1.0)
  compatRmainGl.color(
    compatRmainNative.trunc(compatRmainMath.clamp(blend[0], 0.0, 1.0) * 255.0),
    compatRmainNative.trunc(compatRmainMath.clamp(blend[1], 0.0, 1.0) * 255.0),
    compatRmainNative.trunc(compatRmainMath.clamp(blend[2], 0.0, 1.0) * 255.0),
    compatRmainNative.trunc(compatRmainMath.clamp(blend[3], 0.0, 1.0) * 255.0),
  )
  compatRmainGl.begin(compatRmainGl.GL_QUADS)
  compatRmainGl.vertex3(10.0, 100.0, 100.0)
  compatRmainGl.vertex3(10.0, -100.0, 100.0)
  compatRmainGl.vertex3(10.0, -100.0, -100.0)
  compatRmainGl.vertex3(10.0, 100.0, -100.0)
  compatRmainGl.finishPrimitive()
  compatRmainGl.color(255, 255, 255, 255)
  compatRmainGl.disable(compatRmainGl.GL_BLEND)
  compatRmainGl.enable(compatRmainGl.GL_TEXTURE_2D)
  compatRmainGl.enable(compatRmainGl.GL_ALPHA_TEST)
  return true
end function

function SignbitsForPlane(plane)
  bitsValue = 0
  if plane.normal.x < 0.0 then bitsValue = bitsValue | 1 end if
  if plane.normal.y < 0.0 then bitsValue = bitsValue | 2 end if
  if plane.normal.z < 0.0 then bitsValue = bitsValue | 4 end if
  return bitsValue
end function

function R_SetFrustum()
  global frustum
  if rCompatView is void then return false end if
  fovX = 90.0
  fovY = 90.0
  if rCompatHeight > 0 then
    aspect = rCompatWidth * 1.0 / rCompatHeight
    fovY = 2.0 * compatRmainNative.atan2(1.0, aspect) * compatRmainMath.RAD_TO_DEG
  end if
  if fovX == 90.0 then
    frustum[0].normal = compatRmainMath.add(vpn, vright)
    frustum[1].normal = compatRmainMath.subtract(vpn, vright)
    frustum[2].normal = compatRmainMath.add(vpn, vup)
    frustum[3].normal = compatRmainMath.subtract(vpn, vup)
  else
    frustum[0].normal = compatRmainMath.rotatePointAroundVector(vup, vpn, -(90.0 - fovX * 0.5))
    frustum[1].normal = compatRmainMath.rotatePointAroundVector(vup, vpn, 90.0 - fovX * 0.5)
    frustum[2].normal = compatRmainMath.rotatePointAroundVector(vright, vpn, 90.0 - fovY * 0.5)
    frustum[3].normal = compatRmainMath.rotatePointAroundVector(vright, vpn, -(90.0 - fovY * 0.5))
  end if
  index = 0
  while index < 4
    frustum[index].normal = compatRmainMath.normalize(frustum[index].normal)
    frustum[index].type = 5
    frustum[index].dist = compatRmainMath.dot(r_origin, frustum[index].normal)
    frustum[index].signBits = SignbitsForPlane(frustum[index])
    index = index + 1
  end while
  return true
end function

function R_SetupFrame()
  global r_origin, vpn, vright, vup, r_oldviewleaf, r_viewleaf
  global r_cache_thrash, c_brush_polys, c_alias_polys
  if rCompatView is void or rCompatRenderer is void then return false end if
  compatRmainWorld.R_AnimateLight()
  compatRmainWorld.R_AdvanceFrameCounters()
  r_origin = compatRmainMath.copy(rCompatView.origin)
  vectors = compatRmainMath.angleVectors(rCompatView.angles)
  vpn = vectors[0]
  vright = vectors[1]
  vup = vectors[2]
  r_oldviewleaf = r_viewleaf
  r_viewleaf = compatRmainBsp.leafForPoint(rCompatRenderer.map, r_origin)
  rCompatRenderer.viewLeaf = r_viewleaf
  r_cache_thrash = false
  c_brush_polys = 0
  c_alias_polys = 0
  return true
end function

function MYgluPerspective(fovy, aspect, zNear, zFar)
  angle = fovy * compatRmainMath.PI / 360.0
  cosine = compatRmainNative.cos(angle)
  if cosine == 0.0 then cosine = 0.000001 end if
  ymax = zNear * compatRmainNative.sin(angle) / cosine
  ymin = -ymax
  xmin = ymin * aspect
  xmax = ymax * aspect
  compatRmainGl.frustum(xmin, xmax, ymin, ymax, zNear, zFar)
  return true
end function

function R_SetupGL()
  if rCompatView is void then return false end if
  width = rCompatWidth
  height = rCompatHeight
  if width < 1 then width = 1 end if
  if height < 1 then height = 1 end if
  compatRmainGl.matrixMode(compatRmainGl.GL_PROJECTION)
  compatRmainGl.loadIdentity()
  compatRmainGl.viewport(0, 0, width, height)
  MYgluPerspective(90.0, width * 1.0 / height, 4.0, 4096.0)
  if mirror and mirror_plane is not void then
    if mirror_plane.normal.z != 0.0 then compatRmainGl.scale(1.0, -1.0, 1.0) else compatRmainGl.scale(-1.0, 1.0, 1.0) end if
    compatRmainGl.cullFace(compatRmainGl.GL_BACK)
  else
    compatRmainGl.cullFace(compatRmainGl.GL_FRONT)
  end if
  compatRmainGl.matrixMode(compatRmainGl.GL_MODELVIEW)
  compatRmainGl.loadIdentity()
  compatRmainGl.rotate(-90.0, 1.0, 0.0, 0.0)
  compatRmainGl.rotate(90.0, 0.0, 0.0, 1.0)
  compatRmainGl.rotate(-rCompatView.angles.z, 1.0, 0.0, 0.0)
  compatRmainGl.rotate(-rCompatView.angles.x, 0.0, 1.0, 0.0)
  compatRmainGl.rotate(-rCompatView.angles.y, 0.0, 0.0, 1.0)
  compatRmainGl.translate(-rCompatView.origin.x, -rCompatView.origin.y, -rCompatView.origin.z)
  if compatBoolCvar("gl_cull", 1.0) then compatRmainGl.enable(compatRmainGl.GL_CULL_FACE) else compatRmainGl.disable(compatRmainGl.GL_CULL_FACE) end if
  compatRmainGl.disable(compatRmainGl.GL_BLEND)
  compatRmainGl.disable(compatRmainGl.GL_ALPHA_TEST)
  compatRmainGl.enable(compatRmainGl.GL_DEPTH_TEST)
  return true
end function

function R_RenderScene()
  global c_brush_polys
  if rCompatRenderer is void then return 0 end if
  R_SetupFrame()
  R_SetFrustum()
  R_SetupGL()
  compatRmainWorld.R_MarkLeaves()
  compatRmainWorld.R_PushDlights()
  worldPolys = compatRmainWorld.R_DrawWorld()
  entityPolys = R_DrawEntitiesOnList()
  compatRmainWorld.GL_DisableMultitexture()
  compatRmainWorld.R_RenderDlights()
  if rCompatRenderer is not void then compatRmainParticles.render(rCompatParticles, rCompatRenderer.palette) end if
  if rCompatRenderer is not void then compatRmainParticles.renderTemporary(rCompatTemporary, rCompatTime, rCompatRenderer.palette) end if
  c_brush_polys = worldPolys
  return worldPolys + entityPolys
end function

function R_Clear()
  global rCompatDepthMin, rCompatDepthMax, rCompatTrickFrame
  clearColor = compatBoolCvar("gl_clear", 0.0)
  mirrorAlpha = compatCvarValue("r_mirroralpha", 1.0)
  zTrick = compatBoolCvar("gl_ztrick", 1.0)
  if mirrorAlpha != 1.0 then
    if clearColor then compatRmainGl.clear(compatRmainGl.GL_COLOR_BUFFER_BIT | compatRmainGl.GL_DEPTH_BUFFER_BIT) else compatRmainGl.clear(compatRmainGl.GL_DEPTH_BUFFER_BIT) end if
    rCompatDepthMin = 0.0
    rCompatDepthMax = 0.5
    compatRmainGl.depthFunc(compatRmainGl.GL_LEQUAL)
  else if zTrick then
    if clearColor then compatRmainGl.clear(compatRmainGl.GL_COLOR_BUFFER_BIT) end if
    rCompatTrickFrame = rCompatTrickFrame + 1
    if (rCompatTrickFrame & 1) != 0 then
      rCompatDepthMin = 0.0
      rCompatDepthMax = 0.49999
      compatRmainGl.depthFunc(compatRmainGl.GL_LEQUAL)
    else
      rCompatDepthMin = 1.0
      rCompatDepthMax = 0.5
      compatRmainGl.depthFunc(compatRmainGl.GL_GEQUAL)
    end if
  else
    if clearColor then compatRmainGl.clear(compatRmainGl.GL_COLOR_BUFFER_BIT | compatRmainGl.GL_DEPTH_BUFFER_BIT) else compatRmainGl.clear(compatRmainGl.GL_DEPTH_BUFFER_BIT) end if
    rCompatDepthMin = 0.0
    rCompatDepthMax = 1.0
    compatRmainGl.depthFunc(compatRmainGl.GL_LEQUAL)
  end if
  compatRmainGl.depthRange(rCompatDepthMin, rCompatDepthMax)
  return true
end function

function R_Mirror()
  global mirror
  if not mirror or mirror_plane is void or rCompatView is void then return false end if
  originalOrigin = compatRmainMath.copy(rCompatView.origin)
  originalAngles = compatRmainMath.copy(rCompatView.angles)
  distance = compatRmainMath.dot(rCompatView.origin, mirror_plane.normal) - mirror_plane.dist
  rCompatView.origin = compatRmainMath.multiplyAdd(rCompatView.origin, -2.0 * distance, mirror_plane.normal)
  reflectedForward = compatRmainMath.copy(vpn)
  distance = compatRmainMath.dot(reflectedForward, mirror_plane.normal)
  reflectedForward = compatRmainMath.multiplyAdd(reflectedForward, -2.0 * distance, mirror_plane.normal)
  horizontal = compatRmainNative.sqrt(reflectedForward.x * reflectedForward.x + reflectedForward.y * reflectedForward.y)
  rCompatView.angles.x = -compatRmainNative.atan2(reflectedForward.z, horizontal) * compatRmainMath.RAD_TO_DEG
  rCompatView.angles.y = compatRmainNative.atan2(reflectedForward.y, reflectedForward.x) * compatRmainMath.RAD_TO_DEG
  rCompatView.angles.z = -rCompatView.angles.z
  compatRmainGl.depthRange(0.5, 1.0)
  R_RenderScene()
  compatRmainWorld.R_DrawWaterSurfaces()
  rCompatView.origin = originalOrigin
  rCompatView.angles = originalAngles
  compatRmainGl.depthRange(0.0, 0.5)
  mirror = false
  return true
end function

function R_RenderView()
  global mirror
  if compatBoolCvar("r_norefresh", 0.0) then return 0 end if
  if rCompatRenderer is void then return error(3800, "R_RenderView: NULL worldmodel") end if
  if compatBoolCvar("gl_finish", 0.0) then compatRmainGl.finish() end if
  mirror = false
  R_Clear()
  result = R_RenderScene()
  R_DrawViewModel()
  compatRmainWorld.R_DrawWaterSurfaces()
  R_Mirror()
  R_PolyBlend()
  return result
end function

// -----------------------------------------------------------------------------
// gl_rmisc.c
// -----------------------------------------------------------------------------

function R_InitTextures()
  global r_notexture_mip, r_notexture_mips
  mipSizes = [16, 8, 4, 2]
  mipBuilder = compatRmainArrays.createArrayBuilder(4)
  combined = bytes(16 * 16 + 8 * 8 + 4 * 4 + 2 * 2)
  destination = 0
  mip = 0
  while mip < 4
    size = mipSizes[mip]
    pixels = bytes(size * size)
    y = 0
    while y < size
      x = 0
      while x < size
        value = 255
        if (y < (8 >> mip)) != (x < (8 >> mip)) then value = 0 end if
        pixels[y * size + x] = value
        combined[destination] = value
        destination = destination + 1
        x = x + 1
      end while
      y = y + 1
    end while
    compatRmainArrays.pushArrayBuilder(mipBuilder, pixels)
    mip = mip + 1
  end while
  r_notexture_mips = compatRmainArrays.finishArrayBuilder(mipBuilder)
  r_notexture_mip = compatRmainTypes.RenderTexture("notexture", 16, 16, 0, combined, false)
  return r_notexture_mip
end function

function R_InitParticleTexture()
  global particletexture, rCompatParticleTexture
  dot = [
    [0, 1, 1, 0, 0, 0, 0, 0],
    [1, 1, 1, 1, 0, 0, 0, 0],
    [1, 1, 1, 1, 0, 0, 0, 0],
    [0, 1, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ]
  pixels = bytes(8 * 8 * 4)
  x = 0
  while x < 8
    y = 0
    while y < 8
      offset = (y * 8 + x) * 4
      pixels[offset] = 255
      pixels[offset + 1] = 255
      pixels[offset + 2] = 255
      pixels[offset + 3] = dot[x][y] * 255
      y = y + 1
    end while
    x = x + 1
  end while
  if particletexture != 0 then compatRmainGl.deleteTexture(particletexture) end if
  particletexture = compatRmainGl.generateTexture()
  compatRmainGl.bindTexture(particletexture)
  compatRmainGl.textureParameter(compatRmainGl.GL_TEXTURE_MIN_FILTER, compatRmainGl.GL_LINEAR)
  compatRmainGl.textureParameter(compatRmainGl.GL_TEXTURE_MAG_FILTER, compatRmainGl.GL_LINEAR)
  compatRmainGl.uploadRgba(8, 8, pixels)
  rCompatParticleTexture = particletexture
  return particletexture
end function

function compatEnvmapPath(index)
  name = "env" + index + ".rgb"
  if rCompatGameDirectory == "" then return name end if
  return compatRmainFs.joinPath(rCompatGameDirectory, name)
end function

function R_Envmap_f()
  global envmap
  if rCompatRenderer is void or rCompatView is void then return error(3801, "R_Envmap_f: renderer is not initialized") end if
  originalOrigin = compatRmainMath.copy(rCompatView.origin)
  originalAngles = compatRmainMath.copy(rCompatView.angles)
  originalWidth = rCompatWidth
  originalHeight = rCompatHeight
  envmap = true
  directions = [
    compatRmainTypes.Vec3(0.0, 0.0, 0.0),
    compatRmainTypes.Vec3(0.0, 90.0, 0.0),
    compatRmainTypes.Vec3(0.0, 180.0, 0.0),
    compatRmainTypes.Vec3(0.0, 270.0, 0.0),
    compatRmainTypes.Vec3(-90.0, 0.0, 0.0),
    compatRmainTypes.Vec3(90.0, 0.0, 0.0),
  ]
  index = 0
  while index < len(directions)
    rCompatView.angles = directions[index]
    R_RenderView()
    pixels = compatRmainGl.readPixelsRgba(0, 0, 256, 256)
    written = try(compatRmainFs.writeAllBytes(compatEnvmapPath(index), pixels))
    if written is error then
      envmap = false
      rCompatView.origin = originalOrigin
      rCompatView.angles = originalAngles
      return written
    end if
    index = index + 1
  end while
  rCompatView.origin = originalOrigin
  rCompatView.angles = originalAngles
  envmap = false
  return true
end function

function R_Init()
  R_InitTextures()
  if rCompatRenderer is not void then R_InitParticleTexture() end if
  return true
end function

function compatTranslateRange(table, destination, source)
  index = 0
  while index < 16
    value = source + index
    if source >= 128 then value = source + 15 - index end if
    table[destination + index] = value
    index = index + 1
  end while
  return table
end function

function R_TranslatePlayerSkin(playernum)
  global playertextures
  if rCompatEntityRenderer is void or rCompatClient is void then return false end if
  entityNumber = 1 + playernum
  if entityNumber < 0 or entityNumber >= len(rCompatClient.entities) then return false end if
  entity = rCompatClient.entities[entityNumber]
  if entity is void or entity.modelIndex <= 0 or entity.modelIndex >= len(rCompatEntityRenderer.models) then return false end if
  model = rCompatEntityRenderer.models[entity.modelIndex]
  if model.kind != compatRmainEntities.MODEL_ALIAS or model.aliasModel is void then return false end if
  colors = entity.colormap
  if rCompatServer is not void and playernum >= 0 and playernum < len(rCompatServer.clients) then colors = rCompatServer.clients[playernum].colors end if
  top = colors & 0xf0
  bottom = (colors & 15) << 4
  translation = compatRmainArrays.makeEmptyArray(256)
  index = 0
  while index < 256
    translation[index] = index
    index = index + 1
  end while
  compatTranslateRange(translation, compatRmainConstants.TOP_RANGE, top)
  compatTranslateRange(translation, compatRmainConstants.BOTTOM_RANGE, bottom)
  source = model.aliasModel
  skinIndex = entity.skin
  if skinIndex < 0 or skinIndex >= len(source.skins) then skinIndex = 0 end if
  if skinIndex >= len(source.skins) or len(source.skins[skinIndex].images) == 0 then return false end if
  original = source.skins[skinIndex].images[0]
  translated = bytes(len(original))
  index = 0
  while index < len(original)
    translated[index] = translation[original[index]]
    index = index + 1
  end while
  texture = compatRmainEntities.uploadIndexedTexture(source.skinWidth, source.skinHeight, translated, rCompatEntityRenderer.palette, false)
  compatRmainEntities.setTranslatedPlayerTexture(entityNumber, texture)
  if len(playertextures) <= playernum then playertextures = compatRmainArrays.growArrayTo(playertextures, playernum + 1, 0) end if
  playertextures[playernum] = texture
  return texture
end function

function R_NewMap()
  global r_worldentity, r_viewleaf, r_oldviewleaf, mirrortexturenum, mirror, mirror_plane
  if rCompatRenderer is void then return false end if
  compatRmainWorld.R_ResetLightStyles(264)
  r_worldentity = rCompatRenderer.map.models[0]
  r_viewleaf = 0
  r_oldviewleaf = 0
  mirror = false
  mirror_plane = void
  mirrortexturenum = -1
  compatEnsureEfragState()
  leaf = 0
  while leaf < len(rCompatLeafEfrags)
    rCompatLeafEfrags[leaf] = []
    leaf = leaf + 1
  end while
  compatRmainWorld.GL_BuildLightmaps()
  index = 0
  while index < len(rCompatRenderer.textures)
    texture = rCompatRenderer.textures[index]
    if texture is not void then
      if compatRmainWorld.startsWith(texture.name, "sky") then compatRmainWorld.R_InitSky(texture) end if
      if compatRmainWorld.startsWith(texture.name, "window02_1") then mirrortexturenum = index end if
    end if
    index = index + 1
  end while
  return true
end function

function R_TimeRefresh_f()
  if rCompatView is void then return error(3802, "R_TimeRefresh_f: no view") end if
  originalYaw = rCompatView.angles.y
  start = compatRmainWin.ticks()
  index = 0
  while index < 128
    rCompatView.angles.y = index / 128.0 * 360.0
    R_RenderView()
    index = index + 1
  end while
  compatRmainGl.finish()
  stop = compatRmainWin.ticks()
  rCompatView.angles.y = originalYaw
  seconds = (stop - start) / 1000.0
  fps = 0.0
  if seconds > 0.0 then fps = 128.0 / seconds end if
  print seconds + " seconds (" + fps + " fps)"
  return [seconds, fps]
end function

function D_FlushCaches()
  return void
end function
