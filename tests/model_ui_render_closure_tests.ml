/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-049: frozen alias/sprite/UI/render-evidence closure contract.
*/
import miniquake.model_ui_render_contract as contract
import miniquake.client_render_contract as clientContract
import miniquake.world_render_contract as worldContract
import miniquake.render_ui_contract as ui
import miniquake.render_evidence as evidence
import miniquake.render.alias_mesh as aliasMesh
import miniquake.constants as c

// Assert exact equality and report both values on failure.
function bp049Equal(actual, expected, name)
  if actual != expected then return error(4900, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert that the condition holds and identify a failing test.
function bp049Yes(value, name)
  if not value then return error(4901, name + ": expected true") end if
  return true
end function
// Execute one named test case and record its pass/fail result.
function bp049Run(number, name, fn)
  print "[" + number + "/24] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
// Return status derived from the active module state.
function bp049Status()
  bp049Equal(contract.status(), "model_ui_render_109_frozen_v1", "status")
  return true
end function
// Return fingerprint for the active module state.
function bp049Fingerprint()
  bp049Equal(contract.fingerprint(), 174257585, "fingerprint")
  return true
end function
// Validate the requested value and report any incompatibility.
function bp049Verify()
  bp049Yes(contract.verify(), "fingerprint verify")
  return true
end function
// Exercise the alias quant test scenario and verify its expected result.
function bp049AliasQuant()
  bp049Equal(contract.ALIAS_SHADEDOT_QUANT, 16, "alias quantization")
  return true
end function
// Exercise the sprite modes test scenario and verify its expected result.
function bp049SpriteModes()
  bp049Equal(contract.SPRITE_SYNC_MODE_COUNT, 2, "sprite modes")
  return true
end function
// Render passes.
function bp049RenderPasses()
  bp049Equal(contract.ALIAS_SPRITE_PASS_COUNT, 2, "model passes")
  return true
end function
// Exercise the view depth test scenario and verify its expected result.
function bp049ViewDepth()
  bp049Equal(contract.VIEWMODEL_DEPTH_MILLI, 300, "viewmodel depth")
  bp049Equal(ui.viewModelDepthMaximum(), 0.3, "viewmodel depth value")
  return true
end function
// Exercise the tga bits test scenario and verify its expected result.
function bp049TgaBits()
  bp049Equal(contract.TGA_BITS_PER_PIXEL, 24, "TGA bits")
  return true
end function
// Exercise the evidence schema test scenario and verify its expected result.
function bp049EvidenceSchema()
  bp049Equal(contract.EVIDENCE_SCHEMA, evidence.EVIDENCE_SCHEMA, "evidence schema")
  return true
end function
// Exercise the evidence grid test scenario and verify its expected result.
function bp049EvidenceGrid()
  bp049Equal(contract.EVIDENCE_SAMPLE_GRID, evidence.SAMPLE_GRID, "evidence grid")
  return true
end function
// Exercise the ssim test scenario and verify its expected result.
function bp049Ssim()
  bp049Equal(contract.EVIDENCE_SSIM_MILLI, 950, "SSIM threshold")
  return true
end function
// Report whether visible limit holds for the active state.
function bp049VisibleLimit()
  bp049Equal(contract.MAX_VISIBLE_ENTITIES, c.MAX_VISEDICTS, "visible limit")
  return true
end function
// Exercise the overlay count test scenario and verify its expected result.
function bp049OverlayCount()
  bp049Equal(contract.NORMAL_OVERLAY_STAGE_COUNT, len(ui.overlayOrder(false, false, 0, true)), "overlay count")
  return true
end function
// Exercise the multitexture test scenario and verify its expected result.
function bp049Multitexture()
  bp049Equal(contract.MULTITEXTURE_RESET, 1, "multitexture reset")
  return true
end function
// Exercise the shadow origin test scenario and verify its expected result.
function bp049ShadowOrigin()
  bp049Equal(contract.ENTITY_ORIGIN_SHADOW, 1, "shadow origin")
  return true
end function
// Exercise the sprite syncbase test scenario and verify its expected result.
function bp049SpriteSyncbase()
  bp049Equal(contract.SPRITE_SYNCBASE, 1, "sprite syncbase")
  return true
end function
// Exercise the capture stage test scenario and verify its expected result.
function bp049CaptureStage()
  bp049Equal(contract.CAPTURE_AFTER_UI_BEFORE_SWAP, 1, "capture stage")
  return true
end function
// Exercise the client parent test scenario and verify its expected result.
function bp049ClientParent()
  bp049Equal(contract.CLIENT_RENDER_PARENT, clientContract.status(), "client parent")
  return true
end function
// Exercise the world parent test scenario and verify its expected result.
function bp049WorldParent()
  bp049Equal(contract.WORLD_RENDER_PARENT, worldContract.status(), "world parent")
  return true
end function
// Exercise the shadow sample a test scenario and verify its expected result.
function bp049ShadowSampleA()
  projected = aliasMesh.aliasShadowProjection(13.0, 3.0)
  bp049Equal(projected[0], 10.0, "shadow lheight")
  return true
end function
// Exercise the shadow sample b test scenario and verify its expected result.
function bp049ShadowSampleB()
  projected = aliasMesh.aliasShadowProjection(13.0, 3.0)
  bp049Equal(projected[1], -9.0, "shadow height")
  return true
end function
// Exercise the evidence hash test scenario and verify its expected result.
function bp049EvidenceHash()
  bp049Equal(evidence.hashBytes(bytes("123456789")), 3146166556, "evidence FNV")
  return true
end function
// Exercise the hud offset test scenario and verify its expected result.
function bp049HudOffset()
  bp049Equal(ui.statusbarXOffset(640, c.GAME_COOP), 160, "HUD offset")
  return true
end function
// Exercise the vector test scenario and verify its expected result.
function bp049Vector()
  bp049Equal(len(contract.constants()), 14, "contract vector")
  return true
end function

passed = 0
if bp049Run(1, "contract status", bp049Status) then passed = passed + 1 end if
if bp049Run(2, "contract fingerprint", bp049Fingerprint) then passed = passed + 1 end if
if bp049Run(3, "contract verification", bp049Verify) then passed = passed + 1 end if
if bp049Run(4, "alias shadedot quantization", bp049AliasQuant) then passed = passed + 1 end if
if bp049Run(5, "sprite sync modes", bp049SpriteModes) then passed = passed + 1 end if
if bp049Run(6, "alias/sprite passes", bp049RenderPasses) then passed = passed + 1 end if
if bp049Run(7, "viewmodel depth", bp049ViewDepth) then passed = passed + 1 end if
if bp049Run(8, "TGA bit depth", bp049TgaBits) then passed = passed + 1 end if
if bp049Run(9, "evidence schema", bp049EvidenceSchema) then passed = passed + 1 end if
if bp049Run(10, "evidence sample grid", bp049EvidenceGrid) then passed = passed + 1 end if
if bp049Run(11, "visual SSIM threshold", bp049Ssim) then passed = passed + 1 end if
if bp049Run(12, "visible entity limit", bp049VisibleLimit) then passed = passed + 1 end if
if bp049Run(13, "normal overlay stages", bp049OverlayCount) then passed = passed + 1 end if
if bp049Run(14, "multitexture reset", bp049Multitexture) then passed = passed + 1 end if
if bp049Run(15, "entity-origin shadow", bp049ShadowOrigin) then passed = passed + 1 end if
if bp049Run(16, "sprite syncbase", bp049SpriteSyncbase) then passed = passed + 1 end if
if bp049Run(17, "capture stage", bp049CaptureStage) then passed = passed + 1 end if
if bp049Run(18, "client/render parent", bp049ClientParent) then passed = passed + 1 end if
if bp049Run(19, "world/render parent", bp049WorldParent) then passed = passed + 1 end if
if bp049Run(20, "shadow lheight sample", bp049ShadowSampleA) then passed = passed + 1 end if
if bp049Run(21, "shadow height sample", bp049ShadowSampleB) then passed = passed + 1 end if
if bp049Run(22, "evidence hash sample", bp049EvidenceHash) then passed = passed + 1 end if
if bp049Run(23, "HUD position sample", bp049HudOffset) then passed = passed + 1 end if
if bp049Run(24, "contract vector", bp049Vector) then passed = passed + 1 end if

if passed != 24 then
  print "MiniQuake BP-049 model/UI/render closure tests failed: " + passed + "/24"
  error(4999, "BP-049 model/UI/render closure")
end if
print "MiniQuake BP-049 model/UI/render closure tests passed: 24"
