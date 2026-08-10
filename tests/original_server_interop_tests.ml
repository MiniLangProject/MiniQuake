import miniquake.external_reference_contract as reference
import miniquake.constants as constants

passed = 0
failed = 0

function bp091Check(condition, label)
  global passed, failed
  if condition then passed = passed + 1; print "[" + passed + "/20] " + label; return true end if
  failed = failed + 1
  print "FAIL: " + label
  return false
end function

function main(args)
  global passed, failed
  bp091Check(constants.PROTOCOL_VERSION == 15, "Protocol 15")
  bp091Check(reference.ORIGINAL_CONTROL_PROTOCOL == 3, "control protocol 3")
  bp091Check(reference.originalServerInteropComplete(true, true, 4, 85, 85), "complete original server signon")
  bp091Check(not reference.originalServerInteropComplete(false, true, 4, 85, 85), "connection required")
  bp091Check(not reference.originalServerInteropComplete(true, false, 4, 85, 85), "spawn required")
  bp091Check(not reference.originalServerInteropComplete(true, true, 3, 85, 85), "signon four required")
  bp091Check(not reference.originalServerInteropComplete(true, true, 4, 1, 85), "model precache required")
  bp091Check(not reference.originalServerInteropComplete(true, true, 4, 85, 1), "sound precache required")
  bp091Check(reference.ORIGINAL_INTEROP_POST_FRAMES == 32, "post frames")
  bp091Check(reference.ORIGINAL_INTEROP_MAX_FRAMES == 10000, "frame budget")
  bp091Check(reference.originalServerInteropNetworkProvenance("udp", "127.0.0.1", "127.0.0.1", false, false, false), "target UDP provenance")
  bp091Check(not reference.originalServerInteropNetworkProvenance("loop", "127.0.0.1", "127.0.0.1", true, true, false), "local fallback rejected")
  bp091Check(not reference.originalServerInteropNetworkProvenance("udp", "127.0.0.2", "127.0.0.1", false, false, false), "wrong peer rejected")
  bp091Check(reference.ORIGINAL_REFERENCE_STATUS == "original_reference_109_candidate_v1", "reference candidate")
  bp091Check(reference.COMPAT_FINAL_STATUS == "compat_109_final_candidate_v1", "final candidate")
  bp091Check(reference.originalServerInteropComplete(true, true, constants.SIGNONS, 2, 2), "minimum valid client state")
  bp091Check(not reference.originalServerInteropComplete(true, true, constants.SIGNONS + 1, 2, 2), "invalid late signon")
  bp091Check(reference.ORIGINAL_GAME_PROTOCOL == constants.PROTOCOL_VERSION, "protocol binding")
  bp091Check(reference.validateReferenceContract(), "reference valid")
  bp091Check(len(reference.requiredExternalGates()) == 2, "external gate count")
  if failed > 0 then print "MiniQuake BP-091 original server interop tests failed: " + failed + "/20"; return 1 end if
  print "MiniQuake BP-091 original server interop tests passed: 20"
  return 0
end function
