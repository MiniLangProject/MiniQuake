/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.render.gl_refrag.
*/
package miniquake.render.gl_refrag

import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.render.entities as entities
import miniquake.array_util as arrayutil
import miniquake.types as t
import miniquake.world_bsp as world

// Direct MiniLang pendant of WinQuake/gl_refrag.c. Native pointer-linked
// efrags are represented by shared EfragRef objects in per-entity/per-leaf
// arrays; insertion, removal, BSP splitting and visible-entity de-duplication
// retain the original behavior.

struct EfragRef
  /// Stores the entity value in `miniquake.render.gl_refrag.EfragRef`.
  entity
  /// Stores the leaf index value in `miniquake.render.gl_refrag.EfragRef`.
  leafIndex
end struct

/// Tracks the module-level refrag leafs state owned by `miniquake.render.gl_refrag`.
refragLeafs = []
/// Tracks the module-level refrag nodes state owned by `miniquake.render.gl_refrag`.
refragNodes = []
/// Tracks the module-level refrag planes state owned by `miniquake.render.gl_refrag`.
refragPlanes = []
/// Tracks the module-level refrag bsp models state owned by `miniquake.render.gl_refrag`.
refragBspModels = []
/// Tracks the module-level refrag models state owned by `miniquake.render.gl_refrag`.
refragModels = []
/// Tracks the module-level refrag entities state owned by `miniquake.render.gl_refrag`.
refragEntities = []
/// Tracks the module-level refrag leaf efrags state owned by `miniquake.render.gl_refrag`.
refragLeafEfrags = []
/// Tracks the module-level refrag entity efrags state owned by `miniquake.render.gl_refrag`.
refragEntityEfrags = []
/// Tracks the module-level r pefragtopnode state owned by `miniquake.render.gl_refrag`.
r_pefragtopnode = void
/// Tracks the module-level r addent state owned by `miniquake.render.gl_refrag`.
r_addent = void
/// Tracks the module-level r emins state owned by `miniquake.render.gl_refrag`.
r_emins = void
/// Tracks the module-level r emaxs state owned by `miniquake.render.gl_refrag`.
r_emaxs = void
/// Tracks the module-level cl visedicts state owned by `miniquake.render.gl_refrag`.
cl_visedicts = []
/// Tracks the module-level cl numvisedicts state owned by `miniquake.render.gl_refrag`.
cl_numvisedicts = 0
/// Tracks the module-level static renderer key state owned by `miniquake.render.gl_refrag`.
staticRendererKey = 0
/// Tracks the module-level static model renderer key state owned by `miniquake.render.gl_refrag`.
staticModelRendererKey = 0
/// Tracks the module-level static entity array key state owned by `miniquake.render.gl_refrag`.
staticEntityArrayKey = 0
/// Tracks the module-level static entity count state owned by `miniquake.render.gl_refrag`.
staticEntityCount = -1
/// Tracks the module-level visible entity generation state owned by `miniquake.render.gl_refrag`.
visibleEntityGeneration = 1
/// Tracks the module-level visible entity stamp state owned by `miniquake.render.gl_refrag`.
visibleEntityStamp = array(c.MAX_EDICTS + c.MAX_STATIC_ENTITIES, 0)

/// Implements the `Configure` operation for `miniquake.render.gl_refrag` (configure).
/// @param renderer Renderer instance or backend used for drawing.
/// @param entityRenderer The entity renderer input consumed by `Configure`.
/// @param entityStates The entity states input consumed by `Configure`.
function Configure(renderer, entityRenderer, entityStates)
  global refragLeafs, refragNodes, refragPlanes, refragBspModels
  global refragModels, refragEntities, refragLeafEfrags, refragEntityEfrags
  global r_pefragtopnode, r_addent, cl_visedicts, cl_numvisedicts
  global visibleEntityGeneration, visibleEntityStamp
  refragLeafs = renderer.map.leafs
  refragNodes = renderer.map.nodes
  refragPlanes = renderer.map.planes
  refragBspModels = renderer.map.models
  refragModels = entityRenderer.models
  refragEntities = entityStates
  refragLeafEfrags = arrayutil.makeEmptyArray(len(refragLeafs))
  index = 0
  while index < len(refragLeafEfrags)
    refragLeafEfrags[index] = []
    index = index + 1
  end while
  refragEntityEfrags = arrayutil.makeEmptyArray(len(refragEntities))
  index = 0
  while index < len(refragEntityEfrags)
    refragEntityEfrags[index] = []
    index = index + 1
  end while
  r_pefragtopnode = void
  r_addent = void
  cl_visedicts = []
  cl_numvisedicts = 0
  visibleEntityGeneration = 1
  visibleEntityStamp = array(c.MAX_EDICTS + c.MAX_STATIC_ENTITIES, 0)
  return true
end function

/// Rebuild the immutable signon-time static-entity efrag index only when its
/// map, model table or source array changes. Static renderer-local numbers sit
/// outside Protocol 15's edict range, but their shared EfragRef objects remain
/// fully linked from the BSP leaves used for frame visibility.
/// @param renderer Renderer instance or backend used for drawing.
/// @param entityRenderer The entity renderer input consumed by `ConfigureStaticEntities`.
/// @param entityStates The entity states input consumed by `ConfigureStaticEntities`.
function ConfigureStaticEntities(renderer, entityRenderer, entityStates)
  global staticRendererKey, staticModelRendererKey, staticEntityArrayKey, staticEntityCount
  if renderer is void or entityRenderer is void or entityStates is void then return false end if
  rendererKey = nativeRawValue(renderer)
  modelRendererKey = nativeRawValue(entityRenderer.models)
  entityArrayKey = nativeRawValue(entityStates)
  count = len(entityStates)
  if rendererKey == staticRendererKey and modelRendererKey == staticModelRendererKey and entityArrayKey == staticEntityArrayKey and count == staticEntityCount then return false end if
  Configure(renderer, entityRenderer, entityStates)
  for each entity in entityStates
    if entity is not void and entity.modelIndex > 0 then R_AddEfrags(entity) end if
  end for
  staticRendererKey = rendererKey
  staticModelRendererKey = modelRendererKey
  staticEntityArrayKey = entityArrayKey
  staticEntityCount = count
  return true
end function

/// Apply the Quake-compatible r remove efrags behavior.
/// @param ent The ent input consumed by `R_RemoveEfrags`.
function R_RemoveEfrags(ent)
  global refragLeafEfrags, refragEntityEfrags
  if ent is void or ent.number < 0 or ent.number >= len(refragEntityEfrags) then return false end if
  for each reference in refragEntityEfrags[ent.number]
    leafIndex = reference.leafIndex
    if leafIndex >= 0 and leafIndex < len(refragLeafEfrags) then
      source = refragLeafEfrags[leafIndex]
      builder = arrayutil.createArrayBuilder(len(source))
      for each candidate in source
        if candidate != reference then arrayutil.pushArrayBuilder(builder, candidate) end if
      end for
      refragLeafEfrags[leafIndex] = arrayutil.finishArrayBuilder(builder)
    end if
  end for
  refragEntityEfrags[ent.number] = []
  return true
end function

/// Add state for append efrag.
/// @param leafIndex Zero-based index of the requested entry.
function appendEfrag(leafIndex)
  global refragLeafEfrags, refragEntityEfrags, r_pefragtopnode
  if r_addent is void or leafIndex < 0 or leafIndex >= len(refragLeafEfrags) then return false end if
  reference = EfragRef(r_addent, leafIndex)
  // Original leaf links are head-inserted while entity links retain traversal
  // order. Shared objects preserve both views without native pointers.
  refragLeafEfrags[leafIndex] = [reference] + refragLeafEfrags[leafIndex]
  if r_addent.number >= 0 and r_addent.number < len(refragEntityEfrags) then
    refragEntityEfrags[r_addent.number] = refragEntityEfrags[r_addent.number] + [reference]
  end if
  if r_pefragtopnode is void then r_pefragtopnode = -1 - leafIndex end if
  return true
end function

/// Apply the Quake-compatible r split entity on node behavior.
/// @param nodeNumber The node number input consumed by `R_SplitEntityOnNode`.
function R_SplitEntityOnNode(nodeNumber)
  global r_pefragtopnode
  if r_addent is void then return 0 end if
  if nodeNumber < 0 then
    leafIndex = -1 - nodeNumber
    if leafIndex < 0 or leafIndex >= len(refragLeafs) then return 0 end if
    if refragLeafs[leafIndex].contents == c.CONTENTS_SOLID then return 0 end if
    if appendEfrag(leafIndex) then return 1 end if
    return 0
  end if
  if nodeNumber >= len(refragNodes) then return 0 end if
  node = refragNodes[nodeNumber]
  if node.planeIndex < 0 or node.planeIndex >= len(refragPlanes) then return 0 end if
  // BSP29 planes do not carry the renderer-only signBits field expected by
  // math.boxOnPlaneSide. Use the canonical BSP helper, including its axial
  // equality rules and non-axial positive/negative support corners.
  sides = world.boxOnBspPlaneSide(r_emins, r_emaxs, refragPlanes[node.planeIndex])
  if sides == 3 and r_pefragtopnode is void then r_pefragtopnode = nodeNumber end if
  count = 0
  if (sides & 1) != 0 then count = count + R_SplitEntityOnNode(node.child0) end if
  if (sides & 2) != 0 then count = count + R_SplitEntityOnNode(node.child1) end if
  return count
end function

/// Implements the `modelBounds` operation for `miniquake.render.gl_refrag` (model bounds).
/// @param ent The ent input consumed by `modelBounds`.
function modelBounds(ent)
  if ent.modelIndex <= 0 or ent.modelIndex >= len(refragModels) then return void end if
  model = refragModels[ent.modelIndex]
  if model.kind == entities.MODEL_BRUSH then
    submodelIndex = entities.brushModelIndex(model.name)
    if submodelIndex <= 0 or submodelIndex >= len(refragBspModels) then return void end if
    submodel = refragBspModels[submodelIndex]
    return [math.add(ent.origin, submodel.mins), math.add(ent.origin, submodel.maxs)]
  end if
  radius = 0.0
  if model.kind == entities.MODEL_ALIAS and model.aliasModel is not void then radius = model.aliasModel.boundingRadius end if
  if model.kind == entities.MODEL_SPRITE and model.spriteModel is not void then radius = model.spriteModel.boundingRadius end if
  if radius <= 0.0 then radius = 16.0 end if
  extent = t.Vec3(radius, radius, radius)
  return [math.subtract(ent.origin, extent), math.add(ent.origin, extent)]
end function

/// Apply the Quake-compatible r add efrags behavior.
/// @param ent The ent input consumed by `R_AddEfrags`.
function R_AddEfrags(ent)
  global r_addent, r_emins, r_emaxs, r_pefragtopnode
  if ent is void or len(refragBspModels) == 0 then return 0 end if
  bounds = modelBounds(ent)
  if bounds is void then return 0 end if
  r_addent = ent
  r_emins = bounds[0]
  r_emaxs = bounds[1]
  r_pefragtopnode = void
  root = refragBspModels[0].headNodes[0]
  count = R_SplitEntityOnNode(root)
  r_addent = void
  return count
end function

// Apply the Quake-compatible r begin visible frame behavior.
function R_BeginVisibleFrame()
  global cl_visedicts, cl_numvisedicts
  cl_visedicts = []
  cl_numvisedicts = 0
  return true
end function

/// Apply the Quake-compatible r store efrags behavior.
/// @param leafIndex Zero-based index of the requested entry.
function R_StoreEfrags(leafIndex)
  global cl_visedicts, cl_numvisedicts
  // World traversal calls R_StoreEfrags once for every visible leaf.  The C
  // function appends to the frame-global cl_visedicts array; it does not clear
  // that array for each leaf.  Preserve previously stored entities here and
  // de-duplicate exactly once per frame.
  builder = arrayutil.createArrayBuilder(c.MAX_VISEDICTS)
  for each existing in cl_visedicts
    if builder.count < c.MAX_VISEDICTS then arrayutil.pushArrayBuilder(builder, existing) end if
  end for
  if leafIndex >= 0 and leafIndex < len(refragLeafEfrags) then
    for each reference in refragLeafEfrags[leafIndex]
      entity = reference.entity
      present = false
      index = 0
      while index < builder.count
        if builder.values[index].number == entity.number then present = true end if
        index = index + 1
      end while
      modelValid = entity.modelIndex > 0 and entity.modelIndex < len(refragModels)
      if modelValid and not present and builder.count < c.MAX_VISEDICTS then
        arrayutil.pushArrayBuilder(builder, entity)
      end if
    end for
  end if
  cl_visedicts = arrayutil.finishArrayBuilder(builder)
  cl_numvisedicts = len(cl_visedicts)
  return cl_visedicts
end function

/// Append efrag-linked statics from exactly the leaves in the current view PVS.
/// Dynamic entities are supplied first, matching CL_RelinkEntities ordering and
/// preserving their priority at MAX_VISEDICTS. One builder replaces the old
/// per-leaf copy loop and avoids frame-time allocation bursts in large maps.
/// @param dynamicEntities The dynamic entities input consumed by `R_AppendVisiblePvs`.
/// @param pvs The pvs input consumed by `R_AppendVisiblePvs`.
function R_AppendVisiblePvs(dynamicEntities, pvs)
  global cl_visedicts, cl_numvisedicts, visibleEntityGeneration, visibleEntityStamp
  builder = arrayutil.createArrayBuilder(c.MAX_VISEDICTS)
  // Entity numbers are bounded by the Protocol-15 edict table plus the
  // renderer-local static range.  A generation stamp replaces the former
  // linear scan of the complete visible prefix for every efrag reference.
  // Dynamic entries retain their original order and duplicate behavior; they
  // merely seed the set used to suppress matching static entries.
  visibleEntityGeneration = visibleEntityGeneration + 1
  if visibleEntityGeneration > 1000000000 then
    visibleEntityStamp = array(len(visibleEntityStamp), 0)
    visibleEntityGeneration = 1
  end if
  for each entity in dynamicEntities
    if entity is not void and entity.modelIndex > 0 and builder.count < c.MAX_VISEDICTS then
      arrayutil.pushArrayBuilder(builder, entity)
      if entity.number >= 0 and entity.number < len(visibleEntityStamp) then visibleEntityStamp[entity.number] = visibleEntityGeneration end if
    end if
  end for
  leafIndex = 0
  while leafIndex < len(refragLeafEfrags) and builder.count < c.MAX_VISEDICTS
    visible = pvs is void or world.leafVisible(pvs, leafIndex)
    if visible then
      for each reference in refragLeafEfrags[leafIndex]
        entity = reference.entity
        present = false
        if entity.number >= 0 and entity.number < len(visibleEntityStamp) then
          present = visibleEntityStamp[entity.number] == visibleEntityGeneration
        else
          // Preserve compatibility for synthetic fixtures with numbers beyond
          // the original engine limits instead of indexing outside the stamp.
          index = 0
          while index < builder.count
            if builder.values[index].number == entity.number then present = true; index = builder.count else index = index + 1 end if
          end while
        end if
        modelValid = entity.modelIndex > 0 and entity.modelIndex < len(refragModels)
        if modelValid and not present and builder.count < c.MAX_VISEDICTS then
          arrayutil.pushArrayBuilder(builder, entity)
          if entity.number >= 0 and entity.number < len(visibleEntityStamp) then visibleEntityStamp[entity.number] = visibleEntityGeneration end if
        end if
      end for
    end if
    leafIndex = leafIndex + 1
  end while
  cl_visedicts = arrayutil.finishArrayBuilder(builder)
  cl_numvisedicts = len(cl_visedicts)
  return cl_visedicts
end function

// Apply the Quake-compatible r visible entities behavior.
function R_VisibleEntities()
  return cl_visedicts
end function

/// Update module state for split state.
/// @param entity Entity affected by the operation.
/// @param mins The mins input consumed by `SetSplitState`.
/// @param maxs The maxs input consumed by `SetSplitState`.
function SetSplitState(entity, mins, maxs)
  global r_addent, r_emins, r_emaxs, r_pefragtopnode
  r_addent = entity
  r_emins = mins
  r_emaxs = maxs
  r_pefragtopnode = void
  return true
end function

/// Return state.
/// @param entityNumber The entity number input consumed by `GetState`.
function GetState(entityNumber)
  entityCount = 0
  if entityNumber >= 0 and entityNumber < len(refragEntityEfrags) then entityCount = len(refragEntityEfrags[entityNumber]) end if
  leafCounts = arrayutil.makeEmptyArray(len(refragLeafEfrags))
  index = 0
  while index < len(refragLeafEfrags)
    leafCounts[index] = len(refragLeafEfrags[index])
    index = index + 1
  end while
  return [entityCount, r_pefragtopnode, leafCounts]
end function
