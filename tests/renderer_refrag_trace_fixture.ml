/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Deterministic MiniLang side of the original gl_refrag.c differential oracle.
*/
import miniquake.render.gl_refrag as refrag
import miniquake.render.entities as entities
import miniquake.types as t
import miniquake.constants as c

// Add the requested value to the destination state.
function emit(scene, functionName, operation, arguments)
  print "{\"schema\":\"miniquake.renderer.gl.v1\",\"scene\":\"" + scene + "\",\"function\":\"" + functionName + "\",\"seq\":0,\"op\":\"" + operation + "\",\"args\":" + arguments + "}"
end function

// Create and initialize entity.
function makeEntity(number)
  zero = t.Vec3(0.0, 0.0, 0.0)
  return t.ClientEntityState(
    number, 1, 0, 0, 0, 0, zero, zero, 0.0,
    zero, zero, zero, zero, false, void, 0.0
  )
end function

// Create and initialize setup.
function makeSetup()
  zero = t.Vec3(0.0, 0.0, 0.0)
  minimum = t.Vec3(-1.0, -1.0, -1.0)
  maximum = t.Vec3(1.0, 1.0, 1.0)
  plane = t.BspPlane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0)
  node = t.BspNode(0, -1, -2, minimum, maximum, 0, 0)
  leaf0 = t.BspLeaf(-1, -1, minimum, maximum, 0, 0, bytes(4))
  leaf1 = t.BspLeaf(-1, -1, minimum, maximum, 0, 0, bytes(4))
  worldModel = t.BspModel(minimum, maximum, zero, [0, 0, 0, 0], 2, 0, 0)
  submodel = t.BspModel(minimum, maximum, zero, [0, 0, 0, 0], 0, 0, 0)
  map = t.BspMap(
    "refrag-fixture.bsp", bytes(), c.BSP_VERSION, [], "", [], [plane],
    [], [], bytes(), [node], [], [], bytes(), [], [leaf0, leaf1], [],
    [], [], [worldModel, submodel]
  )
  renderer = t.WorldRenderer(
    map, bytes(), [], [], [], true, 0, false, false, 0, bytes(), 0, 1.0
  )
  noneModel = t.ClientRenderModel("", entities.MODEL_NONE, void, void, void, [], false)
  brushModel = t.ClientRenderModel("*1", entities.MODEL_BRUSH, void, void, void, [], false)
  entityRenderer = t.EntityRenderer(void, bytes(), [noneModel, brushModel], 0)
  first = makeEntity(0)
  second = makeEntity(1)
  refrag.Configure(renderer, entityRenderer, [first, second])
  return [first, second]
end function

// Trace remove through the collision world.
function traceRemove()
  setup = makeSetup()
  refrag.R_AddEfrags(setup[0])
  refrag.R_RemoveEfrags(setup[0])
  state = refrag.GetState(0)
  emit("refrag_remove", "R_RemoveEfrags", "state", "[" + state[0] + "," + state[2][0] + "," + state[2][1] + ",1]")
end function

// Trace split through the collision world.
function traceSplit()
  setup = makeSetup()
  refrag.SetSplitState(
    setup[0], t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0)
  )
  refrag.R_SplitEntityOnNode(0)
  state = refrag.GetState(0)
  topIsRoot = 0
  if state[1] == 0 then topIsRoot = 1 end if
  emit("refrag_split", "R_SplitEntityOnNode", "state", "[" + state[0] + "," + topIsRoot + "," + state[2][0] + "," + state[2][1] + "]")
end function

// Trace add through the collision world.
function traceAdd()
  setup = makeSetup()
  refrag.R_AddEfrags(setup[0])
  state = refrag.GetState(0)
  topIsRoot = 0
  if state[1] == 0 then topIsRoot = 1 end if
  emit("refrag_add", "R_AddEfrags", "state", "[" + state[0] + "," + topIsRoot + "," + state[2][0] + "," + state[2][1] + "]")
end function

// Trace store through the collision world.
function traceStore()
  setup = makeSetup()
  refrag.R_AddEfrags(setup[0])
  refrag.R_AddEfrags(setup[1])
  visible = refrag.R_StoreEfrags(0)
  emit("refrag_store", "R_StoreEfrags", "state", "[" + len(visible) + "]")
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  traceRemove()
  traceSplit()
  traceAdd()
  traceStore()
  return 0
end function
