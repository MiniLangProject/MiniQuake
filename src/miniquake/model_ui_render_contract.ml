/* BP-049: frozen GLQuake 1.09 model/UI/render-evidence contract. */
package miniquake.model_ui_render_contract

const STATUS = "model_ui_render_109_frozen_v1"
const FINGERPRINT = 0x0a62f5b1
const FNV_OFFSET = 2166136261
const FNV_PRIME = 16777619
const ALIAS_SHADEDOT_QUANT = 16
const SPRITE_SYNC_MODE_COUNT = 2
const ALIAS_SPRITE_PASS_COUNT = 2
const VIEWMODEL_DEPTH_MILLI = 300
const TGA_BITS_PER_PIXEL = 24
const EVIDENCE_SCHEMA = 1
const EVIDENCE_SAMPLE_GRID = 16
const EVIDENCE_SSIM_MILLI = 950
const MAX_VISIBLE_ENTITIES = 256
const NORMAL_OVERLAY_STAGE_COUNT = 11
const MULTITEXTURE_RESET = 1
const ENTITY_ORIGIN_SHADOW = 1
const SPRITE_SYNCBASE = 1
const CAPTURE_AFTER_UI_BEFORE_SWAP = 1
const CLIENT_RENDER_PARENT = "client_render_109_frozen_v1"
const WORLD_RENDER_PARENT = "world_render_109_frozen_v1"

function status()
  return STATUS
end function

function fingerprint()
  return FINGERPRINT
end function

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

function verify()
  return calculateFingerprint() == FINGERPRINT
end function

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
