/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-049: frozen MiniQuake 1.09 model/UI/render-evidence contract.
*/
package miniquake.model_ui_render_contract

/// Defines the status value used by `miniquake.model_ui_render_contract`.
const STATUS = "model_ui_render_109_frozen_v1"
/// Defines the fingerprint value used by `miniquake.model_ui_render_contract`.
const FINGERPRINT = 0x0a62f5b1
/// Defines the fnv offset value used by `miniquake.model_ui_render_contract`.
const FNV_OFFSET = 2166136261
/// Defines the fnv prime value used by `miniquake.model_ui_render_contract`.
const FNV_PRIME = 16777619
/// Defines the alias shadedot quant value used by `miniquake.model_ui_render_contract`.
const ALIAS_SHADEDOT_QUANT = 16
/// Defines the sprite sync mode count value used by `miniquake.model_ui_render_contract`.
const SPRITE_SYNC_MODE_COUNT = 2
/// Defines the alias sprite pass count value used by `miniquake.model_ui_render_contract`.
const ALIAS_SPRITE_PASS_COUNT = 2
/// Defines the viewmodel depth milli value used by `miniquake.model_ui_render_contract`.
const VIEWMODEL_DEPTH_MILLI = 300
/// Defines the tga bits per pixel value used by `miniquake.model_ui_render_contract`.
const TGA_BITS_PER_PIXEL = 24
/// Defines the evidence schema value used by `miniquake.model_ui_render_contract`.
const EVIDENCE_SCHEMA = 1
/// Defines the evidence sample grid value used by `miniquake.model_ui_render_contract`.
const EVIDENCE_SAMPLE_GRID = 16
/// Defines the evidence ssim milli value used by `miniquake.model_ui_render_contract`.
const EVIDENCE_SSIM_MILLI = 950
/// Defines the max visible entities value used by `miniquake.model_ui_render_contract`.
const MAX_VISIBLE_ENTITIES = 256
/// Defines the normal overlay stage count value used by `miniquake.model_ui_render_contract`.
const NORMAL_OVERLAY_STAGE_COUNT = 11
/// Defines the multitexture reset value used by `miniquake.model_ui_render_contract`.
const MULTITEXTURE_RESET = 1
/// Defines the entity origin shadow value used by `miniquake.model_ui_render_contract`.
const ENTITY_ORIGIN_SHADOW = 1
/// Defines the sprite syncbase value used by `miniquake.model_ui_render_contract`.
const SPRITE_SYNCBASE = 1
/// Defines the capture after ui before swap value used by `miniquake.model_ui_render_contract`.
const CAPTURE_AFTER_UI_BEFORE_SWAP = 1
/// Defines the client render parent value used by `miniquake.model_ui_render_contract`.
const CLIENT_RENDER_PARENT = "client_render_109_frozen_v1"
/// Defines the world render parent value used by `miniquake.model_ui_render_contract`.
const WORLD_RENDER_PARENT = "world_render_109_frozen_v1"

/// Returns the compatibility status reported by `miniquake.model_ui_render_contract`.
function inline status()
  return STATUS
end function

/// Returns the compatibility fingerprint for `miniquake.model_ui_render_contract`.
function inline fingerprint()
  return FINGERPRINT
end function

/// Returns whether `miniquake.model_ui_render_contract` can onical text.
function canonicalText()
  result = "status=model_ui_render_109_frozen_v1\n"
  result = result + "alias=shade_quant16,shadow_origin,multitexture_zero\n"
  result = result + "sprite=sync_modes2,syncbase\n"
  result = result + "ui=overlay11,viewmodel_depth_milli300,tga24\n"
  result = result + "evidence=schema1,sample_grid16,ssim_milli950,after_ui_before_swap\n"
  result = result + "limits=max_vis256\n"
  result = result + "parents=client_render_109_frozen_v1,world_render_109_frozen_v1\n"
  return result
end function

// Compute fingerprint.
function calculateFingerprint()
  hash = FNV_OFFSET
  source = bytes(canonicalText())
  index = 0
  while index < len(source)
    hash = (((hash & 0xffffffff) ^ source[index]) * FNV_PRIME) & 0xffffffff
    index = index + 1
  end while
  return hash
end function

/// Implements the `verify` operation for `miniquake.model_ui_render_contract` (verify).
function verify()
  return calculateFingerprint() == FINGERPRINT
end function

/// Returns the compatibility constants exposed by `miniquake.model_ui_render_contract`.
function constants()
  return [
    ALIAS_SHADEDOT_QUANT,
    SPRITE_SYNC_MODE_COUNT,
    ALIAS_SPRITE_PASS_COUNT,
    VIEWMODEL_DEPTH_MILLI,
    TGA_BITS_PER_PIXEL,
    EVIDENCE_SCHEMA,
    EVIDENCE_SAMPLE_GRID,
    EVIDENCE_SSIM_MILLI,
    MAX_VISIBLE_ENTITIES,
    NORMAL_OVERLAY_STAGE_COUNT,
    MULTITEXTURE_RESET,
    ENTITY_ORIGIN_SHADOW,
    SPRITE_SYNCBASE,
    CAPTURE_AFTER_UI_BEFORE_SWAP,
  ]
end function
