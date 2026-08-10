/* Frozen MiniQuake 1.09 special-render and evidence-corpus contract. */
package miniquake.render_special_contract

import miniquake.render.special_paths as special
import miniquake.render_evidence_corpus as corpus
import miniquake.model_ui_render_contract as parent

const STATUS = "render_special_109_frozen_v1"
const FINGERPRINT = 0x2a3d8081
const MIRROR_PREFIX_BYTES = 10
const MIRROR_DEPTH_SPLIT_MILLI = 500
const ZTRICK_ODD_DEPTH_MICRO = 499990
const ENVMAP_SIZE = 256
const ENVMAP_FACES = 6
const TIMEREFRESH_STEPS = 128
const EVIDENCE_SCENARIOS = 3
const ORIGINAL_SSIM_MILLI = 950
const EXACT_PAIR_REQUIRED = 1
const SPECIAL_RENDER_STAGE_COUNT = 12
const ORIGINAL_REFERENCE_EXTERNAL = 1
const PARENT_STATUS = "model_ui_render_109_frozen_v1"

function inline status()
  return STATUS
end function

function inline fingerprint()
  return FINGERPRINT
end function

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

function verify()
  if parent.status() != PARENT_STATUS then return false end if
  if special.ENVMAP_SIZE != ENVMAP_SIZE then return false end if
  if special.ENVMAP_FACES != ENVMAP_FACES then return false end if
  if special.TIMEREFRESH_STEPS != TIMEREFRESH_STEPS then return false end if
  if corpus.count() != EVIDENCE_SCENARIOS then return false end if
  if corpus.ORIGINAL_SSIM_MILLI != ORIGINAL_SSIM_MILLI then return false end if
  return true
end function
