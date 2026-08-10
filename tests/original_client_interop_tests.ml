import miniquake.external_reference_contract as reference
import miniquake.constants as constants

passed = 0
failed = 0

function bp092Check(condition, label)
  global passed, failed
  if condition then passed = passed + 1; print "[" + passed + "/20] " + label; return true end if
  failed = failed + 1
  print "FAIL: " + label
  return false
end function

function main(args)
  global passed, failed
  bp092Check(reference.originalClientInteropComplete(1, true, 3), "original client accepted")
  bp092Check(reference.originalClientInteropComplete(4, true, 4), "multiple clients accepted")
  bp092Check(not reference.originalClientInteropComplete(0, true, 3), "active client required")
  bp092Check(not reference.originalClientInteropComplete(1, false, 3), "spawn required")
  bp092Check(not reference.originalClientInteropComplete(1, true, 2), "server signon three required")
  bp092Check(reference.ORIGINAL_CONTROL_PROTOCOL == 3, "control protocol")
  bp092Check(reference.ORIGINAL_GAME_PROTOCOL == 15, "game protocol")
  bp092Check(constants.SIGNONS == 4, "client signon count")
  bp092Check(reference.ORIGINAL_INTEROP_POST_FRAMES == 32, "post-signon traffic")
  bp092Check(reference.ORIGINAL_INTEROP_MAX_FRAMES == 10000, "connection budget")
  bp092Check(reference.ORIGINAL_CAPTURE_WIDTH == 640, "shared video width")
  bp092Check(reference.ORIGINAL_CAPTURE_HEIGHT == 480, "shared video height")
  bp092Check(reference.ORIGINAL_REFERENCE_FINGERPRINT == 0xdc355175, "reference fingerprint")
  bp092Check(reference.COMPAT_FINAL_FINGERPRINT == 0xe04a7727, "final fingerprint")
  gates = reference.requiredExternalGates()
  bp092Check(gates[0] == "original_binary_interop", "binary gate name")
  bp092Check(gates[1] == "external_glquake_visual_reference", "visual gate name")
  bp092Check(len(gates) == 2, "gate count")
  bp092Check(reference.originalClientInteropComplete(1, true, constants.SIGNONS), "full signon state")
  bp092Check(not reference.originalClientInteropComplete(1, true, constants.SIGNON_SERVERINFO), "connected-only rejected")
  bp092Check(reference.validateReferenceContract(), "reference valid")
  if failed > 0 then print "MiniQuake BP-092 original client interop tests failed: " + failed + "/20"; return 1 end if
  print "MiniQuake BP-092 original client interop tests passed: 20"
  return 0
end function
