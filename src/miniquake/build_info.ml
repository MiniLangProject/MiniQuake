/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Machine-readable identity for black-port delivery packages.  This module is
intentionally tiny so binaries, logs and user test reports can always be tied
back to an exact source baseline.
*/
package miniquake.build_info

/// Defines the package id value used by `miniquake.build_info`.
const PACKAGE_ID = "BP-094"
/// Defines the parent package id value used by `miniquake.build_info`.
const PARENT_PACKAGE_ID = "BP-093"
/// Defines the package date value used by `miniquake.build_info`.
const PACKAGE_DATE = "2026-08-09"
/// Defines the compatibility profile value used by `miniquake.build_info`.
const COMPATIBILITY_PROFILE = "compat_109"
/// Defines the native text abi value used by `miniquake.build_info`.
const NATIVE_TEXT_ABI = "caller_owned_bytes_v1"
/// Defines the protocol text abi value used by `miniquake.build_info`.
const PROTOCOL_TEXT_ABI = "quake_latin1_cstring_v1"
/// Defines the base archive value used by `miniquake.build_info`.
const BASE_ARCHIVE = "MiniQuake_Source24.07.2026.zip"
/// Defines the base archive sha256 value used by `miniquake.build_info`.
const BASE_ARCHIVE_SHA256 = "bb2b5bf173fe687cada6e7fec2dcdb8b2099589f2ebc039417a5571ced9729d3"
/// Defines the manifest format value used by `miniquake.build_info`.
const MANIFEST_FORMAT = 1
/// Defines the block id value used by `miniquake.build_info`.
const BLOCK_ID = "BP-090-094"
/// Defines the block parent package id value used by `miniquake.build_info`.
const BLOCK_PARENT_PACKAGE_ID = "BP-085-089R8"
/// Defines the protocol status value used by `miniquake.build_info`.
const PROTOCOL_STATUS = "protocol15_frozen_v1"
/// Defines the quakec status value used by `miniquake.build_info`.
const QUAKEC_STATUS = "quakec_109_frozen_v1"
/// Defines the world physics status value used by `miniquake.build_info`.
const WORLD_PHYSICS_STATUS = "world_physics_109_frozen_v1"
/// Defines the host lifecycle status value used by `miniquake.build_info`.
const HOST_LIFECYCLE_STATUS = "host_lifecycle_109_frozen_v1"
/// Defines the host lifecycle fingerprint value used by `miniquake.build_info`.
const HOST_LIFECYCLE_FINGERPRINT = 0x8cbb709f
/// Defines the client render status value used by `miniquake.build_info`.
const CLIENT_RENDER_STATUS = "client_render_109_frozen_v1"
/// Defines the client render fingerprint value used by `miniquake.build_info`.
const CLIENT_RENDER_FINGERPRINT = 0x95e2b295
/// Defines the world render status value used by `miniquake.build_info`.
const WORLD_RENDER_STATUS = "world_render_109_frozen_v1"
/// Defines the world render fingerprint value used by `miniquake.build_info`.
const WORLD_RENDER_FINGERPRINT = 0x846a74de
/// Defines the model ui render status value used by `miniquake.build_info`.
const MODEL_UI_RENDER_STATUS = "model_ui_render_109_frozen_v1"
/// Defines the model ui render fingerprint value used by `miniquake.build_info`.
const MODEL_UI_RENDER_FINGERPRINT = 0x0a62f5b1
/// Defines the render special status value used by `miniquake.build_info`.
const RENDER_SPECIAL_STATUS = "render_special_109_frozen_v1"
/// Defines the render special fingerprint value used by `miniquake.build_info`.
const RENDER_SPECIAL_FINGERPRINT = 0x2a3d8081
/// Defines the audio status value used by `miniquake.build_info`.
const AUDIO_STATUS = "audio_109_frozen_v1"
/// Defines the audio fingerprint value used by `miniquake.build_info`.
const AUDIO_FINGERPRINT = 0xdcf7a002
/// Defines the network platform status value used by `miniquake.build_info`.
const NETWORK_PLATFORM_STATUS = "network_platform_109_frozen_v1"
/// Defines the network platform fingerprint value used by `miniquake.build_info`.
const NETWORK_PLATFORM_FINGERPRINT = 0xb3ec7589
/// Defines the frontend status value used by `miniquake.build_info`.
const FRONTEND_STATUS = "frontend_109_frozen_v1"
/// Defines the frontend fingerprint value used by `miniquake.build_info`.
const FRONTEND_FINGERPRINT = 0x924251fa
/// Defines the core assets memory status value used by `miniquake.build_info`.
const CORE_ASSETS_MEMORY_STATUS = "core_assets_memory_109_frozen_v1"
/// Defines the core assets memory fingerprint value used by `miniquake.build_info`.
const CORE_ASSETS_MEMORY_FINGERPRINT = 0x6c8d974d
/// Defines the gameplay presentation status value used by `miniquake.build_info`.
const GAMEPLAY_PRESENTATION_STATUS = "gameplay_presentation_109_frozen_v1"
/// Defines the gameplay presentation fingerprint value used by `miniquake.build_info`.
const GAMEPLAY_PRESENTATION_FINGERPRINT = 0xad91624c
/// Defines the black port source status value used by `miniquake.build_info`.
const BLACK_PORT_SOURCE_STATUS = "black_port_source_109_frozen_v1"
/// Defines the black port source fingerprint value used by `miniquake.build_info`.
const BLACK_PORT_SOURCE_FINGERPRINT = 0x309b0737
/// Defines the game profile status value used by `miniquake.build_info`.
const GAME_PROFILE_STATUS = "game_profile_109_frozen_v1"
/// Defines the game profile fingerprint value used by `miniquake.build_info`.
const GAME_PROFILE_FINGERPRINT = 0x7a03b68d
/// Defines the mod runtime status value used by `miniquake.build_info`.
const MOD_RUNTIME_STATUS = "mod_runtime_109_frozen_v1"
/// Defines the mod runtime fingerprint value used by `miniquake.build_info`.
const MOD_RUNTIME_FINGERPRINT = 0x4649813d
/// Defines the artifact compat status value used by `miniquake.build_info`.
const ARTIFACT_COMPAT_STATUS = "artifact_compat_109_frozen_v1"
/// Defines the artifact compat fingerprint value used by `miniquake.build_info`.
const ARTIFACT_COMPAT_FINGERPRINT = 0x59531091
/// Defines the stability status value used by `miniquake.build_info`.
const STABILITY_STATUS = "stability_109_frozen_v1"
/// Defines the stability fingerprint value used by `miniquake.build_info`.
const STABILITY_FINGERPRINT = 0xd0e3c03f
/// Defines the compat release status value used by `miniquake.build_info`.
const COMPAT_RELEASE_STATUS = "compat_109_release_candidate_v1"
/// Defines the compat release fingerprint value used by `miniquake.build_info`.
const COMPAT_RELEASE_FINGERPRINT = 0x29b72a98
/// Defines the original reference status value used by `miniquake.build_info`.
const ORIGINAL_REFERENCE_STATUS = "original_reference_109_candidate_v1"
/// Defines the original reference fingerprint value used by `miniquake.build_info`.
const ORIGINAL_REFERENCE_FINGERPRINT = 0xdc355175
/// Defines the compat final status value used by `miniquake.build_info`.
const COMPAT_FINAL_STATUS = "compat_109_final_candidate_v1"
/// Defines the compat final fingerprint value used by `miniquake.build_info`.
const COMPAT_FINAL_FINGERPRINT = 0xe04a7727
/// Defines the package purpose value used by `miniquake.build_info`.
const PACKAGE_PURPOSE = "Verified original MiniQuake provenance, bidirectional binary interop, external visual-reference corpus and final compat_109 candidate"

/// Defines the opt001 c status value used by `miniquake.build_info`.
const OPT001C_STATUS = "opt001c_frame_allocation_candidate_v1"
/// Defines the opt001 c fingerprint value used by `miniquake.build_info`.
const OPT001C_FINGERPRINT = 0x1c001c03
/// Defines the opt001 c parent value used by `miniquake.build_info`.
const OPT001C_PARENT = "OPT-001B"

/// Defines the optimization status value used by `miniquake.build_info`.
const OPTIMIZATION_STATUS = "opt001d_performance_audio_ui_candidate_v1"
/// Defines the optimization fingerprint value used by `miniquake.build_info`.
const OPTIMIZATION_FINGERPRINT = 0x1c001c10
/// Defines the optimization parent value used by `miniquake.build_info`.
const OPTIMIZATION_PARENT = "OPT-001CR3R7"
/// Defines the optimization delivery revision value used by `miniquake.build_info`.
const OPTIMIZATION_DELIVERY_REVISION = "OPT-001D"
/// Defines the optimization delivery parent value used by `miniquake.build_info`.
const OPTIMIZATION_DELIVERY_PARENT = "OPT-001CR3R7"

/// Tracks the module-level opt001 d status state owned by `miniquake.build_info`.
OPT001D_STATUS = "opt001d_60fps_candidate_v1"
/// Tracks the module-level opt001 d parent state owned by `miniquake.build_info`.
OPT001D_PARENT = "OPT-001CR3R8"
/// Tracks the module-level opt001 d fingerprint state owned by `miniquake.build_info`.
OPT001D_FINGERPRINT = 0x1d0060f0
