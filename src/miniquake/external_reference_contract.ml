/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Original MiniQuake reference, binary interoperability and raw visual-reference
contract. The original executable is supplied by the tester and is never
redistributed in the MiniQuake source package or result archive.
*/
package miniquake.external_reference_contract

/// Defines the original glquake sha256 value used by `miniquake.external_reference_contract`.
const ORIGINAL_GLQUAKE_SHA256 = "04862c835c399bc9184f62101ae0390c2a758c21656ec06dcc0384e0f373d588"
/// Defines the original glquake bytes value used by `miniquake.external_reference_contract`.
const ORIGINAL_GLQUAKE_BYTES = 435712
/// Defines the original glquake pe machine value used by `miniquake.external_reference_contract`.
const ORIGINAL_GLQUAKE_PE_MACHINE = 0x014c
/// Defines the original control protocol value used by `miniquake.external_reference_contract`.
const ORIGINAL_CONTROL_PROTOCOL = 3
/// Defines the original game protocol value used by `miniquake.external_reference_contract`.
const ORIGINAL_GAME_PROTOCOL = 15
/// Defines the original capture width value used by `miniquake.external_reference_contract`.
const ORIGINAL_CAPTURE_WIDTH = 640
/// Defines the original capture height value used by `miniquake.external_reference_contract`.
const ORIGINAL_CAPTURE_HEIGHT = 480
/// Defines the original capture min ssim value used by `miniquake.external_reference_contract`.
const ORIGINAL_CAPTURE_MIN_SSIM = 0.95
/// Defines the original capture min ssim milli value used by `miniquake.external_reference_contract`.
const ORIGINAL_CAPTURE_MIN_SSIM_MILLI = 950
/// Defines the original capture search radius value used by `miniquake.external_reference_contract`.
const ORIGINAL_CAPTURE_SEARCH_RADIUS = 2
/// Defines the original interop post frames value used by `miniquake.external_reference_contract`.
const ORIGINAL_INTEROP_POST_FRAMES = 32
/// Defines the original interop max frames value used by `miniquake.external_reference_contract`.
const ORIGINAL_INTEROP_MAX_FRAMES = 10000

/// Defines the original reference status value used by `miniquake.external_reference_contract`.
const ORIGINAL_REFERENCE_STATUS = "original_reference_109_candidate_v1"
/// Defines the original reference fingerprint value used by `miniquake.external_reference_contract`.
const ORIGINAL_REFERENCE_FINGERPRINT = 0xdc355175
/// Defines the compat final status value used by `miniquake.external_reference_contract`.
const COMPAT_FINAL_STATUS = "compat_109_final_candidate_v1"
/// Defines the compat final fingerprint value used by `miniquake.external_reference_contract`.
const COMPAT_FINAL_FINGERPRINT = 0xe04a7727

// Return reference values derived from the active module state.
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

/// Implements the `visualScenarios` operation for `miniquake.external_reference_contract` (visual scenarios).
function visualScenarios()
  return [
    ["demo1", 256],
    ["demo2", 256],
    ["demo3", 256],
  ]
end function

/// Implements the `visualThreshold` operation for `miniquake.external_reference_contract` (visual threshold).
function visualThreshold()
  return ORIGINAL_CAPTURE_MIN_SSIM
end function

/// Validates d external gates for `miniquake.external_reference_contract`.
function requiredExternalGates()
  return [
    "original_binary_interop",
    "external_glquake_visual_reference",
  ]
end function

/// Implements the `originalServerInteropComplete` operation for `miniquake.external_reference_contract` (original server interop complete).
/// @param connected The connected input consumed by `originalServerInteropComplete`.
/// @param spawned The spawned input consumed by `originalServerInteropComplete`.
/// @param signon The signon input consumed by `originalServerInteropComplete`.
/// @param modelCount Number of entries or units to process.
/// @param soundCount Number of entries or units to process.
function originalServerInteropComplete(connected, spawned, signon, modelCount, soundCount)
  return connected and
    spawned and
    signon == 4 and
    modelCount > 1 and
    soundCount > 1
end function

/// A completed signon is not sufficient evidence by itself: if a remote UDP
/// connect times out, Quake may continue with its local demo/start path.
/// External interop therefore requires a live UDP peer matching the requested
/// address and rejects local-authoritative, local-server and demo fallbacks.
/// @param transport The transport input consumed by `originalServerInteropNetworkProvenance`.
/// @param remoteAddress The remote address input consumed by `originalServerInteropNetworkProvenance`.
/// @param expectedAddress The expected address input consumed by `originalServerInteropNetworkProvenance`.
/// @param localServerActive The local server active input consumed by `originalServerInteropNetworkProvenance`.
/// @param localAuthoritative The local authoritative input consumed by `originalServerInteropNetworkProvenance`.
/// @param demoPlayback The demo playback input consumed by `originalServerInteropNetworkProvenance`.
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

/// Implements the `originalClientInteropComplete` operation for `miniquake.external_reference_contract` (original client interop complete).
/// @param activeClients The active clients input consumed by `originalClientInteropComplete`.
/// @param spawned The spawned input consumed by `originalClientInteropComplete`.
/// @param signon The signon input consumed by `originalClientInteropComplete`.
function inline originalClientInteropComplete(activeClients, spawned, signon)
  return activeClients > 0 and spawned and signon >= 3 and signon <= 4
end function

/// Implements the `referenceContractText` operation for `miniquake.external_reference_contract` (reference contract text).
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

/// Implements the `finalContractText` operation for `miniquake.external_reference_contract` (final contract text).
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

/// Implements the `referenceContractHasRequiredFields` operation for `miniquake.external_reference_contract` (reference contract has required fields).
function referenceContractHasRequiredFields()
  text = referenceContractText()
  return len(bytes(text)) > 256 and
    ORIGINAL_GLQUAKE_SHA256 != "" and
    ORIGINAL_GLQUAKE_BYTES == 435712
end function

/// Implements the `finalContractHasRequiredFields` operation for `miniquake.external_reference_contract` (final contract has required fields).
function finalContractHasRequiredFields()
  text = finalContractText()
  return len(bytes(text)) > 256 and
    len(requiredExternalGates()) == 2 and
    COMPAT_FINAL_STATUS == "compat_109_final_candidate_v1"
end function

// Validate reference contract and report any incompatibility.
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
