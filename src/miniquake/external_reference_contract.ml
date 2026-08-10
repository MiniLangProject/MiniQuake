/*
Copyright (C) 2026 MiniQuake contributors

Original MiniQuake reference, binary interoperability and raw visual-reference
contract. The original executable is supplied by the tester and is never
redistributed in the MiniQuake source package or result archive.
*/

package miniquake.external_reference_contract

const ORIGINAL_GLQUAKE_SHA256 = "04862c835c399bc9184f62101ae0390c2a758c21656ec06dcc0384e0f373d588"
const ORIGINAL_GLQUAKE_BYTES = 435712
const ORIGINAL_GLQUAKE_PE_MACHINE = 0x014c
const ORIGINAL_CONTROL_PROTOCOL = 3
const ORIGINAL_GAME_PROTOCOL = 15
const ORIGINAL_CAPTURE_WIDTH = 640
const ORIGINAL_CAPTURE_HEIGHT = 480
const ORIGINAL_CAPTURE_MIN_SSIM = 0.95
const ORIGINAL_CAPTURE_MIN_SSIM_MILLI = 950
const ORIGINAL_CAPTURE_SEARCH_RADIUS = 2
const ORIGINAL_INTEROP_POST_FRAMES = 32
const ORIGINAL_INTEROP_MAX_FRAMES = 10000

const ORIGINAL_REFERENCE_STATUS = "original_reference_109_candidate_v1"
const ORIGINAL_REFERENCE_FINGERPRINT = 0xdc355175
const COMPAT_FINAL_STATUS = "compat_109_final_candidate_v1"
const COMPAT_FINAL_FINGERPRINT = 0xe04a7727

function referenceValues()
  return [
    ORIGINAL_GLQUAKE_BYTES,
    ORIGINAL_GLQUAKE_PE_MACHINE,
    ORIGINAL_CONTROL_PROTOCOL,
    ORIGINAL_GAME_PROTOCOL,
    ORIGINAL_CAPTURE_WIDTH,
    ORIGINAL_CAPTURE_HEIGHT,
    ORIGINAL_CAPTURE_MIN_SSIM,
    ORIGINAL_CAPTURE_SEARCH_RADIUS,
    ORIGINAL_INTEROP_POST_FRAMES,
    ORIGINAL_INTEROP_MAX_FRAMES,
  ]
end function

function visualScenarios()
  return [
    ["demo1", 256],
    ["demo2", 256],
    ["demo3", 256],
  ]
end function

function visualThreshold()
  return ORIGINAL_CAPTURE_MIN_SSIM
end function

function requiredExternalGates()
  return [
    "original_binary_interop",
    "external_glquake_visual_reference",
  ]
end function

function originalServerInteropComplete(connected, spawned, signon, modelCount, soundCount)
  return connected and
    spawned and
    signon == 4 and
    modelCount > 1 and
    soundCount > 1
end function

// A completed signon is not sufficient evidence by itself: if a remote UDP
// connect times out, Quake may continue with its local demo/start path.
// External interop therefore requires a live UDP peer matching the requested
// address and rejects local-authoritative, local-server and demo fallbacks.
function originalServerInteropNetworkProvenance(
  transport,
  remoteAddress,
  expectedAddress,
  localServerActive,
  localAuthoritative,
  demoPlayback,
)
  return transport == "udp" and
    remoteAddress == expectedAddress and
    not localServerActive and
    not localAuthoritative and
    not demoPlayback
end function

function inline originalClientInteropComplete(activeClients, spawned, signon)
  return activeClients > 0 and spawned and signon >= 3 and signon <= 4
end function

function referenceContractText()
  return "original_sha256=" + ORIGINAL_GLQUAKE_SHA256 + "\n" +
    "original_bytes=435712\n" +
    "pe_machine=332\n" +
    "control_protocol=3\n" +
    "game_protocol=15\n" +
    "capture_width=640\n" +
    "capture_height=480\n" +
    "minimum_ssim_milli=950\n" +
    "search_radius=2\n" +
    "post_frames=32\n" +
    "maximum_frames=10000\n" +
    "visual_scenarios=demo1:256,demo2:256,demo3:256\n" +
    "redistributed=0\n" +
    "system_opengl=1\n"
end function

function finalContractText()
  return "parent_status=compat_109_release_candidate_v1\n" +
    "parent_fingerprint=0x29b72a98\n" +
    "original_reference_status=original_reference_109_candidate_v1\n" +
    "original_reference_fingerprint=0xdc355175\n" +
    "external_gate_1=original_binary_interop\n" +
    "external_gate_2=external_glquake_visual_reference\n" +
    "bidirectional_protocol15=1\n" +
    "visual_scenarios=3\n" +
    "minimum_ssim_milli=950\n" +
    "raw_full_frame=1\n" +
    "normalization=none\n" +
    "status=compat_109_final_candidate_v1\n"
end function

function referenceContractHasRequiredFields()
  text = referenceContractText()
  return len(bytes(text)) > 256 and
    ORIGINAL_GLQUAKE_SHA256 != "" and
    ORIGINAL_GLQUAKE_BYTES == 435712
end function

function finalContractHasRequiredFields()
  text = finalContractText()
  return len(bytes(text)) > 256 and
    len(requiredExternalGates()) == 2 and
    COMPAT_FINAL_STATUS == "compat_109_final_candidate_v1"
end function

function validateReferenceContract()
  return len(referenceValues()) == 10 and
    len(visualScenarios()) == 3 and
    len(requiredExternalGates()) == 2 and
    ORIGINAL_CONTROL_PROTOCOL == 3 and
    ORIGINAL_GAME_PROTOCOL == 15 and
    ORIGINAL_CAPTURE_WIDTH == 640 and
    ORIGINAL_CAPTURE_HEIGHT == 480 and
    ORIGINAL_CAPTURE_MIN_SSIM == 0.95 and
    ORIGINAL_CAPTURE_SEARCH_RADIUS == 2 and
    ORIGINAL_REFERENCE_STATUS == "original_reference_109_candidate_v1" and
    referenceContractHasRequiredFields() and
    COMPAT_FINAL_STATUS == "compat_109_final_candidate_v1" and
    finalContractHasRequiredFields()
end function
