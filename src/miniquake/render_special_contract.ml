/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Frozen MiniQuake 1.09 special-render and evidence-corpus contract.
*/
package miniquake.render_special_contract

import miniquake.render.special_paths as special
import miniquake.render_evidence_corpus as corpus
import miniquake.model_ui_render_contract as parent

/// Defines the status value used by `miniquake.render_special_contract`.
const STATUS = "render_special_109_frozen_v1"
/// Defines the fingerprint value used by `miniquake.render_special_contract`.
const FINGERPRINT = 0x2a3d8081
/// Defines the mirror prefix bytes value used by `miniquake.render_special_contract`.
const MIRROR_PREFIX_BYTES = 10
/// Defines the mirror depth split milli value used by `miniquake.render_special_contract`.
const MIRROR_DEPTH_SPLIT_MILLI = 500
/// Defines the ztrick odd depth micro value used by `miniquake.render_special_contract`.
const ZTRICK_ODD_DEPTH_MICRO = 499990
/// Defines the envmap size value used by `miniquake.render_special_contract`.
const ENVMAP_SIZE = 256
/// Defines the envmap faces value used by `miniquake.render_special_contract`.
const ENVMAP_FACES = 6
/// Defines the timerefresh steps value used by `miniquake.render_special_contract`.
const TIMEREFRESH_STEPS = 128
/// Defines the evidence scenarios value used by `miniquake.render_special_contract`.
const EVIDENCE_SCENARIOS = 3
/// Defines the original ssim milli value used by `miniquake.render_special_contract`.
const ORIGINAL_SSIM_MILLI = 950
/// Defines the exact pair required value used by `miniquake.render_special_contract`.
const EXACT_PAIR_REQUIRED = 1
/// Defines the special render stage count value used by `miniquake.render_special_contract`.
const SPECIAL_RENDER_STAGE_COUNT = 12
/// Defines the original reference external value used by `miniquake.render_special_contract`.
const ORIGINAL_REFERENCE_EXTERNAL = 1
/// Defines the parent status value used by `miniquake.render_special_contract`.
const PARENT_STATUS = "model_ui_render_109_frozen_v1"

/// Returns the compatibility status reported by `miniquake.render_special_contract`.
function inline status()
  return STATUS
end function

/// Returns the compatibility fingerprint for `miniquake.render_special_contract`.
function inline fingerprint()
  return FINGERPRINT
end function

/// Returns the compatibility constants exposed by `miniquake.render_special_contract`.
function constants()
  return [
    MIRROR_PREFIX_BYTES,
    MIRROR_DEPTH_SPLIT_MILLI,
    ZTRICK_ODD_DEPTH_MICRO,
    ENVMAP_SIZE,
    ENVMAP_FACES,
    TIMEREFRESH_STEPS,
    EVIDENCE_SCENARIOS,
    ORIGINAL_SSIM_MILLI,
    EXACT_PAIR_REQUIRED,
    SPECIAL_RENDER_STAGE_COUNT,
    ORIGINAL_REFERENCE_EXTERNAL,
  ]
end function

/// Implements the `verify` operation for `miniquake.render_special_contract` (verify).
function verify()
  if parent.status() != PARENT_STATUS then return false end if
  if special.ENVMAP_SIZE != ENVMAP_SIZE then return false end if
  if special.ENVMAP_FACES != ENVMAP_FACES then return false end if
  if special.TIMEREFRESH_STEPS != TIMEREFRESH_STEPS then return false end if
  if corpus.count() != EVIDENCE_SCENARIOS then return false end if
  if corpus.ORIGINAL_SSIM_MILLI != ORIGINAL_SSIM_MILLI then return false end if
  return true
end function
