/*
Deterministic MiniLang side of the pinned WinQuake/gl_rmain.c oracle.
Each scene invokes the named MiniLang pendant body and emits the same compact
OpenGL/dependency command fingerprint as the reference fixture.
*/

import miniquake.render.gl_rmain as rmain
import miniquake.native as native
import std.string as string

function jsonNumber(value)
  integerValue = native.trunc(value)
  if value == integerValue then return "" + integerValue end if
  return string.replaceAll("" + value, ".e", "e")
end function

function boolNumber(value)
  if value then return 1 end if
  return 0
end function

function emit(scene, functionName, extras)
  state = rmain.GetSinkState()
  arguments = "["
  index = 0
  while index < len(state)
    if index > 0 then arguments = arguments + "," end if
    arguments = arguments + jsonNumber(state[index])
    index = index + 1
  end while
  for each value in extras
    arguments = arguments + "," + jsonNumber(value)
  end for
  arguments = arguments + "]"
  print "{\"schema\":\"miniquake.renderer.gl.v1\",\"scene\":\"" + scene + "\",\"function\":\"" + functionName + "\",\"seq\":0,\"op\":\"state\",\"args\":" + arguments + "}"
end function

function entity(origin, angles)
  return [origin, angles]
end function

function spriteFrame(texture)
  return [2.0, -2.0, -1.0, 1.0, texture]
end function

function traceCullBox()
  rmain.ResetCompatibility()
  rmain.SetCullPlanes([
    [[1.0, 0.0, 0.0], 0.0, 0, 0],
    [[0.0, 0.0, 0.0], 0.0, 0, 0],
    [[0.0, 0.0, 0.0], 0.0, 0, 0],
    [[0.0, 0.0, 0.0], 0.0, 0, 0],
  ])
  rmain.ResetSink()
  first = rmain.R_CullBox([-2.0, -1.0, -1.0], [-1.0, 1.0, 1.0])
  second = rmain.R_CullBox([1.0, -1.0, -1.0], [2.0, 1.0, 1.0])
  emit("rmain_cull_box", "R_CullBox", [boolNumber(first), boolNumber(second), 0, 0, 0, 0])
end function

function traceRotate()
  rmain.ResetSink()
  rmain.R_RotateForEntity(entity([1.0, 2.0, 3.0], [10.0, 20.0, 30.0]))
  emit("rmain_rotate_entity", "R_RotateForEntity", [0, 0, 0, 0, 0, 0])
end function

function traceGetSpriteFrame()
  rmain.ResetSink()
  first = rmain.R_GetSpriteFrame(0, [77], [], 0.0, 0.0)
  second = rmain.R_GetSpriteFrame(1, [81, 82], [0.25, 0.5], 0.35, 0.0)
  emit("rmain_get_sprite_frame", "R_GetSpriteFrame", [first, second, 0, 0, 0, 0])
end function

function traceDrawSprite()
  rmain.ResetSink()
  rmain.R_DrawSpriteModel(
    entity([4.0, 5.0, 6.0], [0.0, 0.0, 0.0]), spriteFrame(77)
  )
  emit("rmain_draw_sprite", "R_DrawSpriteModel", [0, 0, 0, 0, 0, 0])
end function

function traceAliasFrame()
  header = rmain.MakeAliasHeader()
  rmain.ResetSink()
  rmain.GL_DrawAliasFrame(header, 0, 2.0)
  emit("rmain_alias_frame", "GL_DrawAliasFrame", [0, 0, 0, 0, 0, 0])
end function

function traceAliasShadow()
  header = rmain.MakeAliasHeader()
  rmain.ResetSink()
  rmain.GL_DrawAliasShadow(
    header, 0, [0.0, 0.0, 10.0], [0.0, 0.0, 2.0], [0.5, 0.25, 1.0]
  )
  emit("rmain_alias_shadow", "GL_DrawAliasShadow", [0, 0, 0, 0, 0, 0])
end function

function traceSetupAliasFrame()
  header = rmain.MakeAliasHeader()
  rmain.ResetSink()
  pose = rmain.R_SetupAliasFrame(0, header, 0.35, 1.0)
  emit("rmain_setup_alias_frame", "R_SetupAliasFrame", [pose, 0, 0, 0, 0, 0])
end function

function traceDrawAliasModel()
  header = rmain.MakeAliasHeader()
  rmain.SetFrameState(0, 0, 0)
  rmain.ResetSink()
  rmain.R_DrawAliasModel(
    entity([1.0, 2.0, 3.0], [10.0, 20.0, 30.0]),
    header, 0.25, true
  )
  frame = rmain.GetFrameState()
  emit("rmain_draw_alias_model", "R_DrawAliasModel", [frame[2], frame[3], 0, 0, 0, 0])
end function

function traceDrawEntities()
  rmain.SetDrawFlags(true, false)
  rmain.ResetSink()
  rmain.R_DrawEntitiesOnList(
    1,
    [[entity([0.0, 0.0, 0.0], [0.0, 0.0, 0.0]), spriteFrame(88)]],
  )
  emit("rmain_draw_entities", "R_DrawEntitiesOnList", [2, 0, 0, 0, 0, 0])
end function

function traceDrawViewModel()
  header = rmain.MakeAliasHeader()
  rmain.SetDrawFlags(true, true)
  rmain.SetMirror(false, [[1.0, 0.0, 0.0], 0.0])
  rmain.SetClearFlags(1.0, false, false)
  rmain.SetDepthCompatibility(0.0, 1.0)
  // The prior reference scene left the shadow cvar enabled.
  rmain.ResetSink()
  rmain.R_DrawViewModel(
    entity([1.0, 2.0, 3.0], [10.0, 20.0, 30.0]),
    header, 0.25, true
  )
  frame = rmain.GetFrameState()
  emit("rmain_draw_view_model", "R_DrawViewModel", [frame[4], frame[5], 0, 0, 0, 0])
end function

function tracePolyBlend()
  rmain.SetBlend([0.1, 0.2, 0.3, 0.4])
  rmain.ResetSink()
  rmain.R_PolyBlend()
  emit("rmain_poly_blend", "R_PolyBlend", [0, 0, 0, 0, 0, 0])
end function

function traceSignbits()
  rmain.ResetSink()
  bits = rmain.SignbitsForPlane([[-1.0, 2.0, -3.0], 0.0, 0, 0])
  emit("rmain_signbits", "SignbitsForPlane", [bits, 0, 0, 0, 0, 0])
end function

function traceSetFrustum()
  rmain.SetViewBasis(
    [2.0, 3.0, 4.0], [1.0, 0.0, 0.0],
    [0.0, -1.0, 0.0], [0.0, 0.0, 1.0],
  )
  rmain.ResetSink()
  rmain.R_SetFrustum()
  frame = rmain.GetFrameState()
  planes = frame[7]
  emit(
    "rmain_set_frustum", "R_SetFrustum",
    [
      planes[0][0][0], planes[0][0][1], planes[0][1],
      planes[2][0][2], planes[2][1], planes[0][3],
    ],
  )
end function

function traceSetupFrame()
  rmain.PrepareWorld()
  rmain.SetFrameState(7, 9, 11)
  rmain.ResetSink()
  rmain.R_SetupFrame()
  frame = rmain.GetFrameState()
  emit(
    "rmain_setup_frame", "R_SetupFrame",
    [frame[0], frame[6][0], frame[6][1], frame[6][2], frame[1], frame[2]],
  )
end function

function tracePerspective()
  rmain.ResetSink()
  rmain.MYgluPerspective(75.0, 4.0 / 3.0, 4.0, 4096.0)
  emit("rmain_perspective", "MYgluPerspective", [0, 0, 0, 0, 0, 0])
end function

function traceSetupGL()
  rmain.PrepareWorld()
  rmain.SetMirror(false, [[1.0, 0.0, 0.0], 0.0])
  rmain.ResetSink()
  rmain.R_SetupGL()
  emit("rmain_setup_gl", "R_SetupGL", [0, 0, 0, 0, 0, 0])
end function

function traceRenderScene()
  rmain.PrepareWorld()
  rmain.SetMirror(false, [[1.0, 0.0, 0.0], 0.0])
  rmain.ResetSink()
  rmain.R_RenderScene()
  frame = rmain.GetFrameState()
  emit("rmain_render_scene", "R_RenderScene", [frame[0], frame[1], frame[2], 0, 0, 0])
end function

function traceClear()
  rmain.SetClearFlags(0.5, true, false)
  rmain.ResetSink()
  rmain.R_Clear()
  rmain.SetClearFlags(1.0, true, true)
  rmain.R_Clear()
  rmain.R_Clear()
  rmain.SetClearFlags(1.0, false, false)
  rmain.R_Clear()
  frame = rmain.GetFrameState()
  emit("rmain_clear", "R_Clear", [frame[4], frame[5], 0, 0, 0, 0])
end function

function traceMirror()
  rmain.PrepareWorld()
  rmain.SetMirror(true, [[1.0, 0.0, 0.0], 2.0])
  rmain.ResetSink()
  rmain.R_Mirror()
  frame = rmain.GetFrameState()
  emit(
    "rmain_mirror", "R_Mirror",
    [frame[8][0], frame[9][0], frame[9][1], 1, frame[4], frame[5]],
  )
end function

function traceRenderView()
  rmain.PrepareWorld()
  rmain.SetClearFlags(1.0, false, false)
  rmain.SetBlend([0.0, 0.0, 0.0, 0.0])
  rmain.ResetSink()
  rmain.R_RenderView()
  frame = rmain.GetFrameState()
  emit(
    "rmain_render_view", "R_RenderView",
    [frame[0], frame[1], frame[2], boolNumber(frame[10]), 0, 0],
  )
end function

function main(args)
  traceCullBox()
  traceRotate()
  traceGetSpriteFrame()
  traceDrawSprite()
  traceAliasFrame()
  traceAliasShadow()
  traceSetupAliasFrame()
  traceDrawAliasModel()
  traceDrawEntities()
  traceDrawViewModel()
  tracePolyBlend()
  traceSignbits()
  traceSetFrustum()
  traceSetupFrame()
  tracePerspective()
  traceSetupGL()
  traceRenderScene()
  traceClear()
  traceMirror()
  traceRenderView()
  return 0
end function
