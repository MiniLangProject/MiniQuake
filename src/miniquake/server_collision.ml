package miniquake.server_collision

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.world_bsp as world
import miniquake.world_hull as boxhull
import miniquake.quakec.vm as vm

function zeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

function emptyPlane()
  return t.Plane(zeroVector(), 0.0, 0, 0)
end function

function fieldOffset(server, name)
  if server is void or server.machine is void then return -1 end if
  return vm.fieldOffset(server.machine, name)
end function

function entityFloat(server, entityIndex, name, fallback)
  offset = fieldOffset(server, name)
  if offset < 0 then return fallback end if
  return vm.entityFloat(server.machine, entityIndex, offset)
end function

function entityWord(server, entityIndex, name, fallback)
  offset = fieldOffset(server, name)
  if offset < 0 then return fallback end if
  return vm.entityField(server.machine, entityIndex, offset)
end function

function entityVector(server, entityIndex, name, fallback)
  offset = fieldOffset(server, name)
  if offset < 0 then return fallback end if
  return vm.entityVector(server.machine, entityIndex, offset)
end function

function entityString(server, entityIndex, name, fallback)
  offset = fieldOffset(server, name)
  if offset < 0 then return fallback end if
  value = vm.entityString(server.machine, entityIndex, offset)
  if value == "" then return fallback end if
  return value
end function

function setEntityFloat(server, entityIndex, name, value)
  offset = fieldOffset(server, name)
  if offset >= 0 then vm.setEntityFloat(server.machine, entityIndex, offset, value) end if
end function

function setEntityWord(server, entityIndex, name, value)
  offset = fieldOffset(server, name)
  if offset >= 0 then vm.setEntityField(server.machine, entityIndex, offset, value) end if
end function

function setEntityVector(server, entityIndex, name, value)
  offset = fieldOffset(server, name)
  if offset >= 0 then vm.setEntityVector(server.machine, entityIndex, offset, value) end if
end function

function entityValid(server, entityIndex)
  if server is void or server.machine is void or server.machine.context is void then return false end if
  runtime = server.machine.context.edicts
  if entityIndex < 0 or entityIndex >= runtime.numEdicts then return false end if
  return not runtime.freeFlags[entityIndex]
end function

function modelSubIndex(name)
  source = bytes(name)
  if len(source) < 2 or source[0] != 42 then return -1 end if
  value = toNumber(decode(slice(source, 1, len(source) - 1)))
  if value is void or value is not int then return -1 end if
  return value
end function

function entityAbsMin(server, entityIndex)
  origin = entityVector(server, entityIndex, "origin", zeroVector())
  mins = entityVector(server, entityIndex, "mins", zeroVector())
  result = math.add(origin, mins)
  flags = native.trunc(entityFloat(server, entityIndex, "flags", 0.0))
  if (flags & c.FL_ITEM) != 0 then
    result.x = result.x - 15.0
    result.y = result.y - 15.0
  else
    result.x = result.x - 1.0
    result.y = result.y - 1.0
    result.z = result.z - 1.0
  end if
  return result
end function

function entityAbsMax(server, entityIndex)
  origin = entityVector(server, entityIndex, "origin", zeroVector())
  maxs = entityVector(server, entityIndex, "maxs", zeroVector())
  result = math.add(origin, maxs)
  flags = native.trunc(entityFloat(server, entityIndex, "flags", 0.0))
  if (flags & c.FL_ITEM) != 0 then
    result.x = result.x + 15.0
    result.y = result.y + 15.0
  else
    result.x = result.x + 1.0
    result.y = result.y + 1.0
    result.z = result.z + 1.0
  end if
  return result
end function

function boxesOverlap(minsA, maxsA, minsB, maxsB)
  if minsA.x > maxsB.x or maxsA.x < minsB.x then return false end if
  if minsA.y > maxsB.y or maxsA.y < minsB.y then return false end if
  if minsA.z > maxsB.z or maxsA.z < minsB.z then return false end if
  return true
end function

function moveBounds(start, mins, maxs, finish)
  boxMins = zeroVector()
  boxMaxs = zeroVector()
  if finish.x > start.x then
    boxMins.x = start.x + mins.x - 1.0
    boxMaxs.x = finish.x + maxs.x + 1.0
  else
    boxMins.x = finish.x + mins.x - 1.0
    boxMaxs.x = start.x + maxs.x + 1.0
  end if
  if finish.y > start.y then
    boxMins.y = start.y + mins.y - 1.0
    boxMaxs.y = finish.y + maxs.y + 1.0
  else
    boxMins.y = finish.y + mins.y - 1.0
    boxMaxs.y = start.y + maxs.y + 1.0
  end if
  if finish.z > start.z then
    boxMins.z = start.z + mins.z - 1.0
    boxMaxs.z = finish.z + maxs.z + 1.0
  else
    boxMins.z = finish.z + mins.z - 1.0
    boxMaxs.z = start.z + maxs.z + 1.0
  end if
  return [boxMins, boxMaxs]
end function

function traceAgainstBox(server, entityIndex, start, mins, maxs, finish)
  origin = entityVector(server, entityIndex, "origin", zeroVector())
  entityMins = entityVector(server, entityIndex, "mins", zeroVector())
  entityMaxs = entityVector(server, entityIndex, "maxs", zeroVector())
  expandedMins = t.Vec3(
    origin.x + entityMins.x - maxs.x,
    origin.y + entityMins.y - maxs.y,
    origin.z + entityMins.z - maxs.z,
  )
  expandedMaxs = t.Vec3(
    origin.x + entityMaxs.x - mins.x,
    origin.y + entityMaxs.y - mins.y,
    origin.z + entityMaxs.z - mins.z,
  )
  hull = boxhull.createBoxHull(expandedMins, expandedMaxs)
  result = boxhull.traceLine(hull, start, finish)
  if result.fraction < 1.0 or result.startSolid then result.entity = entityIndex end if
  return result
end function

function traceAgainstBrush(server, entityIndex, start, mins, maxs, finish)
  origin = entityVector(server, entityIndex, "origin", zeroVector())
  name = entityString(server, entityIndex, "model", "")
  submodelIndex = modelSubIndex(name)
  if submodelIndex < 0 then return traceAgainstBox(server, entityIndex, start, mins, maxs, finish) end if
  result = world.traceBrushModel(server.worldModel, submodelIndex, origin, start, mins, maxs, finish)
  if result.fraction < 1.0 or result.startSolid then result.entity = entityIndex end if
  return result
end function

function clipToEntity(server, entityIndex, start, mins, maxs, finish)
  solid = native.trunc(entityFloat(server, entityIndex, "solid", c.SOLID_NOT))
  if solid == c.SOLID_BSP then return traceAgainstBrush(server, entityIndex, start, mins, maxs, finish) end if
  return traceAgainstBox(server, entityIndex, start, mins, maxs, finish)
end function

function chooseTrace(best, candidate)
  if candidate.allSolid or candidate.startSolid or candidate.fraction < best.fraction then
    preservedStartSolid = best.startSolid
    best = candidate
    if preservedStartSolid then best.startSolid = true end if
  else if candidate.startSolid then
    best.startSolid = true
  end if
  return best
end function

// SV_Move: clip first against the world, then every potentially intersecting
// solid edict.  Area nodes are an optimization only; a linear scan has the same
// observable Quake semantics and is suitable for the stock MAX_EDICTS limit.
function move(server, start, mins, maxs, finish, moveType, passedEntity)
  best = world.trace(server.worldModel, start, mins, maxs, finish)
  best.entity = 0
  if server.machine is void or server.machine.context is void then return best end if

  clipMins = mins
  clipMaxs = maxs
  if moveType == c.MOVE_MISSILE then
    clipMins = t.Vec3(-15.0, -15.0, -15.0)
    clipMaxs = t.Vec3(15.0, 15.0, 15.0)
  end if
  bounds = moveBounds(start, clipMins, clipMaxs, finish)
  boxMins = bounds[0]
  boxMaxs = bounds[1]
  passedOwner = -1
  passedSizeX = 0.0
  if passedEntity >= 0 and entityValid(server, passedEntity) then
    passedOwner = entityWord(server, passedEntity, "owner", -1)
    passedMins = entityVector(server, passedEntity, "mins", zeroVector())
    passedMaxs = entityVector(server, passedEntity, "maxs", zeroVector())
    passedSizeX = passedMaxs.x - passedMins.x
  end if

  index = 1
  runtime = server.machine.context.edicts
  while index < runtime.numEdicts
    if index != passedEntity and not runtime.freeFlags[index] then
      solid = native.trunc(entityFloat(server, index, "solid", c.SOLID_NOT))
      if solid != c.SOLID_NOT and solid != c.SOLID_TRIGGER then
        consider = true
        if moveType == c.MOVE_NOMONSTERS and solid != c.SOLID_BSP then consider = false end if
        if consider then
          owner = entityWord(server, index, "owner", -1)
          if owner == passedEntity or passedOwner == index then consider = false end if
        end if
        if consider then
          // Stock SV_ClipToLinks does not let a normal-sized mover collide
          // with point-sized helper entities.  Door targets and other QuakeC
          // markers otherwise become invisible solid specks.
          touchMinsValue = entityVector(server, index, "mins", zeroVector())
          touchMaxsValue = entityVector(server, index, "maxs", zeroVector())
          if passedSizeX != 0.0 and touchMaxsValue.x - touchMinsValue.x == 0.0 then consider = false end if
        end if
        if consider then
          absMin = entityAbsMin(server, index)
          absMax = entityAbsMax(server, index)
          if boxesOverlap(boxMins, boxMaxs, absMin, absMax) then
            touchMins = mins
            touchMaxs = maxs
            flags = native.trunc(entityFloat(server, index, "flags", 0.0))
            if moveType == c.MOVE_MISSILE and (flags & c.FL_MONSTER) != 0 then
              touchMins = clipMins
              touchMaxs = clipMaxs
            end if
            candidate = clipToEntity(server, index, start, touchMins, touchMaxs, finish)
            best = chooseTrace(best, candidate)
            if best.allSolid then return best end if
          end if
        end if
      end if
    end if
    index = index + 1
  end while
  return best
end function

function testEntityPosition(server, entityIndex)
  if not entityValid(server, entityIndex) then return -1 end if
  origin = entityVector(server, entityIndex, "origin", zeroVector())
  mins = entityVector(server, entityIndex, "mins", zeroVector())
  maxs = entityVector(server, entityIndex, "maxs", zeroVector())
  trace = move(server, origin, mins, maxs, origin, c.MOVE_NORMAL, entityIndex)
  if trace.startSolid then return trace.entity end if
  return -1
end function

function executeTouch(server, selfIndex, otherIndex)
  if not entityValid(server, selfIndex) then return false end if
  solid = native.trunc(entityFloat(server, selfIndex, "solid", c.SOLID_NOT))
  if solid == c.SOLID_NOT then return false end if
  touch = entityWord(server, selfIndex, "touch", 0)
  if touch == 0 then return false end if
  machine = server.machine
  oldSelf = vm.word(machine, c.QC_GLOBAL_SELF)
  oldOther = vm.word(machine, c.QC_GLOBAL_OTHER)
  vm.setWord(machine, c.QC_GLOBAL_SELF, selfIndex)
  vm.setWord(machine, c.QC_GLOBAL_OTHER, otherIndex)
  vm.setGlobalFloat(machine, c.QC_GLOBAL_TIME, server.time)
  vm.execute(machine, touch)
  vm.setWord(machine, c.QC_GLOBAL_SELF, oldSelf)
  vm.setWord(machine, c.QC_GLOBAL_OTHER, oldOther)
  return true
end function

function impact(server, firstEntity, secondEntity)
  // SV_Impact deliberately evaluates the second callback after the first one,
  // even if the first callback freed either edict.  The C engine still holds
  // both edict pointers and tests their current touch/solid fields.  Trigger
  // linking uses executeTouch's validity guard; collision impact must not.
  machine = server.machine
  oldSelf = vm.word(machine, c.QC_GLOBAL_SELF)
  oldOther = vm.word(machine, c.QC_GLOBAL_OTHER)
  vm.setGlobalFloat(machine, c.QC_GLOBAL_TIME, server.time)
  touched = 0
  firstSolid = native.trunc(entityFloat(server, firstEntity, "solid", c.SOLID_NOT))
  firstTouch = entityWord(server, firstEntity, "touch", 0)
  if firstTouch != 0 and firstSolid != c.SOLID_NOT then
    vm.setWord(machine, c.QC_GLOBAL_SELF, firstEntity)
    vm.setWord(machine, c.QC_GLOBAL_OTHER, secondEntity)
    vm.execute(machine, firstTouch)
    touched = touched + 1
  end if
  secondSolid = native.trunc(entityFloat(server, secondEntity, "solid", c.SOLID_NOT))
  secondTouch = entityWord(server, secondEntity, "touch", 0)
  if secondTouch != 0 and secondSolid != c.SOLID_NOT then
    vm.setWord(machine, c.QC_GLOBAL_SELF, secondEntity)
    vm.setWord(machine, c.QC_GLOBAL_OTHER, firstEntity)
    vm.execute(machine, secondTouch)
    touched = touched + 1
  end if
  vm.setWord(machine, c.QC_GLOBAL_SELF, oldSelf)
  vm.setWord(machine, c.QC_GLOBAL_OTHER, oldOther)
  return touched
end function

function pushEntity(server, entityIndex, push)
  origin = entityVector(server, entityIndex, "origin", zeroVector())
  mins = entityVector(server, entityIndex, "mins", zeroVector())
  maxs = entityVector(server, entityIndex, "maxs", zeroVector())
  target = math.add(origin, push)
  moveType = c.MOVE_NORMAL
  entityMoveType = native.trunc(entityFloat(server, entityIndex, "movetype", c.MOVETYPE_NONE))
  if entityMoveType == c.MOVETYPE_FLYMISSILE then moveType = c.MOVE_MISSILE end if
  solid = native.trunc(entityFloat(server, entityIndex, "solid", c.SOLID_NOT))
  if solid == c.SOLID_TRIGGER or solid == c.SOLID_NOT then moveType = c.MOVE_NOMONSTERS end if
  // MOVETYPE_FLYMISSILE takes precedence over the entity's solid type.
  if entityMoveType == c.MOVETYPE_FLYMISSILE then moveType = c.MOVE_MISSILE end if
  trace = move(server, origin, mins, maxs, target, moveType, entityIndex)
  setEntityVector(server, entityIndex, "origin", trace.endPosition)
  if trace.entity >= 0 and trace.fraction < 1.0 then impact(server, entityIndex, trace.entity) end if
  return trace
end function

function touchTriggers(server, entityIndex)
  if not entityValid(server, entityIndex) then return 0 end if
  origin = entityVector(server, entityIndex, "origin", zeroVector())
  mins = entityVector(server, entityIndex, "mins", zeroVector())
  maxs = entityVector(server, entityIndex, "maxs", zeroVector())
  absMin = math.add(origin, mins)
  absMax = math.add(origin, maxs)
  touched = 0
  runtime = server.machine.context.edicts
  index = 1
  while index < runtime.numEdicts
    if index != entityIndex and not runtime.freeFlags[index] then
      solid = native.trunc(entityFloat(server, index, "solid", c.SOLID_NOT))
      if solid == c.SOLID_TRIGGER then
        triggerMin = entityAbsMin(server, index)
        triggerMax = entityAbsMax(server, index)
        if boxesOverlap(absMin, absMax, triggerMin, triggerMax) then
          if executeTouch(server, index, entityIndex) then touched = touched + 1 end if
        end if
      end if
    end if
    index = index + 1
  end while
  return touched
end function

// SV_CheckBottom: first accept the common case where all four lower corners are
// solid, then trace the midpoint and corners down by two step heights.
function checkBottom(server, entityIndex)
  origin = entityVector(server, entityIndex, "origin", zeroVector())
  mins = entityVector(server, entityIndex, "mins", zeroVector())
  maxs = entityVector(server, entityIndex, "maxs", zeroVector())
  z = origin.z + mins.z - 1.0
  cornersSolid = true
  xIndex = 0
  while xIndex < 2
    yIndex = 0
    while yIndex < 2
      x = origin.x + mins.x
      y = origin.y + mins.y
      if xIndex == 1 then x = origin.x + maxs.x end if
      if yIndex == 1 then y = origin.y + maxs.y end if
      if world.pointContentsWorld(server.worldModel, t.Vec3(x, y, z)) != c.CONTENTS_SOLID then cornersSolid = false end if
      yIndex = yIndex + 1
    end while
    xIndex = xIndex + 1
  end while
  if cornersSolid then return true end if

  midpoint = t.Vec3(origin.x + (mins.x + maxs.x) * 0.5, origin.y + (mins.y + maxs.y) * 0.5, origin.z + mins.z)
  stop = math.subtract(midpoint, t.Vec3(0.0, 0.0, 36.0))
  midTrace = move(server, midpoint, zeroVector(), zeroVector(), stop, c.MOVE_NOMONSTERS, entityIndex)
  if midTrace.fraction == 1.0 then return false end if
  mid = midTrace.endPosition.z

  xIndex = 0
  while xIndex < 2
    yIndex = 0
    while yIndex < 2
      x = origin.x + mins.x
      y = origin.y + mins.y
      if xIndex == 1 then x = origin.x + maxs.x end if
      if yIndex == 1 then y = origin.y + maxs.y end if
      start = t.Vec3(x, y, origin.z + mins.z)
      finish = math.subtract(start, t.Vec3(0.0, 0.0, 36.0))
      cornerTrace = move(server, start, zeroVector(), zeroVector(), finish, c.MOVE_NOMONSTERS, entityIndex)
      if cornerTrace.fraction == 1.0 or mid - cornerTrace.endPosition.z > 18.0 then return false end if
      yIndex = yIndex + 1
    end while
    xIndex = xIndex + 1
  end while
  return true
end function
