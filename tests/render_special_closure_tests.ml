/* BP-054: frozen GLQuake special-render and evidence-corpus contract. */
import miniquake.render_special_contract as bp054Contract
import miniquake.render.special_paths as bp054Special
import miniquake.render_evidence_corpus as bp054Corpus
import miniquake.model_ui_render_contract as bp054Parent
import miniquake.host as bp054Host
import miniquake.common as bp054Common
import miniquake.cvar as bp054Cvar
import miniquake.types as bp054Types

function bp054Equal(actual, expected, name)
  if actual != expected then return error(5400, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function bp054Yes(value, name)
  if not value then return error(5401, name + ": expected true") end if
  return true
end function
function bp054Run(number, name, fn)
  print "[" + number + "/24] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
function bp054Status()
  bp054Equal(bp054Contract.status(), "render_special_109_frozen_v1", "status")
  return true
end function
function bp054Fingerprint()
  bp054Equal(bp054Contract.fingerprint(), 708673665, "fingerprint")
  return true
end function
function bp054Verify()
  bp054Yes(bp054Contract.verify(), "contract verification")
  return true
end function
function bp054ParentStatus()
  bp054Equal(bp054Parent.status(), "model_ui_render_109_frozen_v1", "parent status")
  return true
end function
function bp054MirrorPrefix()
  bp054Equal(bp054Contract.MIRROR_PREFIX_BYTES, 10, "mirror prefix bytes")
  return true
end function
function bp054MirrorDepth()
  bp054Equal(bp054Contract.MIRROR_DEPTH_SPLIT_MILLI, 500, "mirror depth split")
  return true
end function
function bp054ZTrickDepth()
  bp054Equal(bp054Contract.ZTRICK_ODD_DEPTH_MICRO, 499990, "ztrick depth")
  return true
end function
function bp054EnvmapSize()
  bp054Equal(bp054Contract.ENVMAP_SIZE, 256, "envmap size")
  return true
end function
function bp054EnvmapFaces()
  bp054Equal(bp054Contract.ENVMAP_FACES, 6, "envmap faces")
  return true
end function
function bp054TimeRefresh()
  bp054Equal(bp054Contract.TIMEREFRESH_STEPS, 128, "timerefresh steps")
  return true
end function
function bp054CorpusCount()
  bp054Equal(bp054Contract.EVIDENCE_SCENARIOS, 3, "corpus scenarios")
  return true
end function
function bp054Ssim()
  bp054Equal(bp054Contract.ORIGINAL_SSIM_MILLI, 950, "original SSIM")
  return true
end function
function bp054ExactPair()
  bp054Equal(bp054Contract.EXACT_PAIR_REQUIRED, 1, "exact process pair")
  return true
end function
function bp054ExternalReference()
  bp054Equal(bp054Contract.ORIGINAL_REFERENCE_EXTERNAL, 1, "external original reference")
  return true
end function
function bp054StageCount()
  bp054Equal(len(bp054Special.specialRenderStageOrder()), 12, "stage count")
  return true
end function
function bp054StageClear()
  bp054Equal(bp054Special.specialRenderStageOrder()[0], "clear", "first stage")
  return true
end function
function bp054StageMirror()
  stages = bp054Special.specialRenderStageOrder()
  bp054Equal(stages[6], "mirror_scene", "mirror scene stage")
  bp054Equal(stages[8], "mirror_overlay", "mirror overlay stage")
  return true
end function
function bp054StageCapture()
  stages = bp054Special.specialRenderStageOrder()
  bp054Equal(stages[11], "capture_before_swap", "capture stage")
  return true
end function
function bp054CorpusDimensions()
  bp054Equal(bp054Corpus.CAPTURE_WIDTH, 640, "corpus width")
  bp054Equal(bp054Corpus.CAPTURE_HEIGHT, 480, "corpus height")
  return true
end function
function bp054CorpusMaps()
  bp054Equal(bp054Corpus.mapName(0), "start", "start map")
  bp054Equal(bp054Corpus.mapName(2), "e1m1", "e1m1 map")
  return true
end function
function bp054Cvars()
  commandLine = bp054Common.create([])
  registry = bp054Host.createCvars(commandLine, true)
  bp054Equal(bp054Cvar.variableValue(registry, "r_mirroralpha"), 1.0, "mirror alpha default")
  bp054Equal(bp054Cvar.variableValue(registry, "r_norefresh"), 0.0, "norefresh default")
  bp054Equal(bp054Cvar.variableValue(registry, "gl_finish"), 0.0, "finish default")
  bp054Equal(bp054Cvar.variableValue(registry, "gl_clear"), 0.0, "clear default")
  return true
end function
function bp054ProjectionFloor()
  value = bp054Special.mirrorProjectionScale(bp054Types.Plane(bp054Types.Vec3(0.0, 0.0, 1.0), 0.0, 2, 0))
  bp054Equal(value.y, -1.0, "floor projection")
  return true
end function
function bp054ClearOdd()
  value = bp054Special.clearPlan(1.0, false, true, 0)
  bp054Equal(value[4], 1, "odd trick frame")
  return true
end function
function bp054Vector()
  bp054Equal(len(bp054Contract.constants()), 11, "contract vector length")
  return true
end function

passed = 0
if bp054Run(1, "contract status", bp054Status) then passed = passed + 1 end if
if bp054Run(2, "contract fingerprint", bp054Fingerprint) then passed = passed + 1 end if
if bp054Run(3, "contract verification", bp054Verify) then passed = passed + 1 end if
if bp054Run(4, "parent contract", bp054ParentStatus) then passed = passed + 1 end if
if bp054Run(5, "mirror prefix bytes", bp054MirrorPrefix) then passed = passed + 1 end if
if bp054Run(6, "mirror depth split", bp054MirrorDepth) then passed = passed + 1 end if
if bp054Run(7, "ztrick odd depth", bp054ZTrickDepth) then passed = passed + 1 end if
if bp054Run(8, "envmap size", bp054EnvmapSize) then passed = passed + 1 end if
if bp054Run(9, "envmap faces", bp054EnvmapFaces) then passed = passed + 1 end if
if bp054Run(10, "timerefresh steps", bp054TimeRefresh) then passed = passed + 1 end if
if bp054Run(11, "evidence scenario count", bp054CorpusCount) then passed = passed + 1 end if
if bp054Run(12, "original SSIM threshold", bp054Ssim) then passed = passed + 1 end if
if bp054Run(13, "exact process pair", bp054ExactPair) then passed = passed + 1 end if
if bp054Run(14, "external original reference", bp054ExternalReference) then passed = passed + 1 end if
if bp054Run(15, "special stage count", bp054StageCount) then passed = passed + 1 end if
if bp054Run(16, "clear stage", bp054StageClear) then passed = passed + 1 end if
if bp054Run(17, "mirror stages", bp054StageMirror) then passed = passed + 1 end if
if bp054Run(18, "capture stage", bp054StageCapture) then passed = passed + 1 end if
if bp054Run(19, "corpus dimensions", bp054CorpusDimensions) then passed = passed + 1 end if
if bp054Run(20, "corpus maps", bp054CorpusMaps) then passed = passed + 1 end if
if bp054Run(21, "special cvar defaults", bp054Cvars) then passed = passed + 1 end if
if bp054Run(22, "mirror projection sample", bp054ProjectionFloor) then passed = passed + 1 end if
if bp054Run(23, "ztrick sample", bp054ClearOdd) then passed = passed + 1 end if
if bp054Run(24, "contract vector", bp054Vector) then passed = passed + 1 end if
if passed != 24 then print "MiniQuake BP-054 render-special closure tests failed: " + passed + "/24"; error(5499, "BP-054 render special closure") end if
print "MiniQuake BP-054 render-special closure tests passed: 24"
