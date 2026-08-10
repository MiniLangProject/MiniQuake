/*
Copyright (C) 2026 MiniQuake contributors

Cumulative compatibility release-candidate matrix.  The status deliberately
remains a release candidate: original executable interoperability and an
external MiniQuake visual reference corpus remain separate final gates.
*/

package miniquake.compatibility_matrix

const STATUS = "compat_109_release_candidate_v1"
const FINGERPRINT = 0x29b72a98
const CONTRACT_TEXT = "compat-release-candidate|contracts=18|source-functions=1094|maps=4|retail-demos=3|soak=2|optional-mission-packs|external-binary-pending|external-visual-pending"
const CONTRACT_COUNT = 18
const SOURCE_FUNCTION_COUNT = 1094
const BLACK_PORT_MAP_COUNT = 4
const RETAIL_DEMO_COUNT = 3
const SOAK_MODE_COUNT = 2

function acceptedContracts()
  return [
    "protocol15_frozen_v1",
    "quakec_109_frozen_v1",
    "world_physics_109_frozen_v1",
    "host_lifecycle_109_frozen_v1",
    "client_render_109_frozen_v1",
    "world_render_109_frozen_v1",
    "model_ui_render_109_frozen_v1",
    "render_special_109_frozen_v1",
    "audio_109_frozen_v1",
    "network_platform_109_frozen_v1",
    "frontend_109_frozen_v1",
    "core_assets_memory_109_frozen_v1",
    "gameplay_presentation_109_frozen_v1",
    "black_port_source_109_frozen_v1",
    "game_profile_109_frozen_v1",
    "mod_runtime_109_frozen_v1",
    "artifact_compat_109_frozen_v1",
    "stability_109_frozen_v1",
  ]
end function

function pendingExternalGates()
  return ["original_binary_interop", "external_glquake_visual_reference"]
end function

function validate()
  return len(acceptedContracts()) == CONTRACT_COUNT and len(pendingExternalGates()) == 2 and SOURCE_FUNCTION_COUNT == 1094 and BLACK_PORT_MAP_COUNT == 4 and RETAIL_DEMO_COUNT == 3 and SOAK_MODE_COUNT == 2
end function

function contractVector()
  return [STATUS, FINGERPRINT, CONTRACT_COUNT, SOURCE_FUNCTION_COUNT, BLACK_PORT_MAP_COUNT, RETAIL_DEMO_COUNT, SOAK_MODE_COUNT, acceptedContracts(), pendingExternalGates()]
end function
