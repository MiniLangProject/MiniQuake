package miniquake.core_assets_memory_contract

const STATUS = "core_assets_memory_109_frozen_v1"
const FINGERPRINT = 0x6c8d974d
const PAK_ENTRY_BYTES = 64
const PACK_NAME_BYTES = 56
const MAX_PACK_FILES = 2048
const WAD_NAME_BYTES = 16
const WAD_LUMPINFO_BYTES = 32
const BSP_VERSION = 29
const MDL_VERSION = 6
const SPRITE_VERSION = 1
const HUNK_ALIGNMENT = 16
const ZONE_ALIGNMENT = 8
const HUNK_NAME_BYTES = 8
const CACHE_NAME_BYTES = 15
const ZONE_DYNAMIC_SIZE = 0xc000
const RETAIL_EVIDENCE_FILES = 4

function canonicalText()
  return STATUS + "\n" +
    "common_q_atof_binary32=1\n" +
    "common_q_atoi_int32=1\n" +
    "quake_text_abi=quake_latin1_cstring_v1\n" +
    "pak_entry_bytes=64\n" +
    "pack_name_bytes=56\n" +
    "max_pack_files=2048\n" +
    "wad_name_bytes=16\n" +
    "wad_lumpinfo_bytes=32\n" +
    "bsp_version=29\n" +
    "mdl_version=6\n" +
    "sprite_version=1\n" +
    "hunk_alignment=16\n" +
    "zone_alignment=8\n" +
    "hunk_name_bytes=8\n" +
    "cache_name_bytes=15\n" +
    "zone_dynamic_size=49152\n" +
    "retail_evidence_files=4\n"
end function

function fnv1a32(text)
  data = bytes(text)
  value = 0x811c9dc5
  index = 0
  while index < len(data)
    value = ((value ^ data[index]) * 0x01000193) & 0xffffffff
    index = index + 1
  end while
  return value
end function

function verify()
  if fnv1a32(canonicalText()) != FINGERPRINT then return error(10740, "core assets/memory fingerprint mismatch") end if
  if PAK_ENTRY_BYTES != 64 or PACK_NAME_BYTES != 56 or MAX_PACK_FILES != 2048 then return error(10741, "PACK contract mismatch") end if
  if WAD_NAME_BYTES != 16 or WAD_LUMPINFO_BYTES != 32 then return error(10742, "WAD contract mismatch") end if
  if BSP_VERSION != 29 or MDL_VERSION != 6 or SPRITE_VERSION != 1 then return error(10743, "model format contract mismatch") end if
  if HUNK_ALIGNMENT != 16 or ZONE_ALIGNMENT != 8 then return error(10744, "allocator alignment contract mismatch") end if
  if HUNK_NAME_BYTES != 8 or CACHE_NAME_BYTES != 15 then return error(10745, "allocator name contract mismatch") end if
  if ZONE_DYNAMIC_SIZE != 0xc000 or RETAIL_EVIDENCE_FILES != 4 then return error(10746, "core evidence contract mismatch") end if
  return true
end function
