/*
Copyright (C) 2026 MiniQuake contributors

Frozen WinQuake 1.09 audio compatibility contract.  The contract binds the
observable software mixer, channel, DMA ring and CD-command semantics while
allowing the physical device backend to use a modern x64-safe implementation.
*/
package miniquake.audio_contract

import miniquake.sound.snd_dma as dma
import miniquake.sound.snd_mix as mix
import miniquake.sound.snd_win as win
import miniquake.sound.mixer as production

const STATUS = "audio_109_frozen_v1"
const FINGERPRINT = 0xdcf7a002
const MAX_SFX = 512
const MAX_CHANNELS = 128
const AMBIENT_CHANNELS = 4
const DYNAMIC_CHANNELS = 8
const PAINTBUFFER_FRAMES = 512
const WAV_BUFFERS = 64
const WAV_BUFFER_SIZE = 1024
const SECONDARY_BUFFER_SIZE = 65536
const NOMINAL_CLIP_DISTANCE = 1000
const DEFAULT_SAMPLE_BITS = 16
const DEFAULT_CHANNELS = 2
const CD_REMAP_SLOTS = 100
const BINARY32_SPATIAL = 1
const I32_MIXER = 1
const DISTINCT_RING_REGIONS = 1
const QUAKE_ATOI_CD = 1
const RETAIL_EVIDENCE_SOUNDS = 2

function inline status()
  return STATUS
end function

function inline fingerprint()
  return FINGERPRINT
end function

function constants()
  return [
    MAX_SFX,
    MAX_CHANNELS,
    AMBIENT_CHANNELS,
    DYNAMIC_CHANNELS,
    PAINTBUFFER_FRAMES,
    WAV_BUFFERS,
    WAV_BUFFER_SIZE,
    SECONDARY_BUFFER_SIZE,
    NOMINAL_CLIP_DISTANCE,
    DEFAULT_SAMPLE_BITS,
    DEFAULT_CHANNELS,
    CD_REMAP_SLOTS,
    BINARY32_SPATIAL,
    I32_MIXER,
    DISTINCT_RING_REGIONS,
    QUAKE_ATOI_CD,
    RETAIL_EVIDENCE_SOUNDS,
  ]
end function

function verify()
  if dma.MAX_SFX != MAX_SFX then return false end if
  if dma.MAX_CHANNELS != MAX_CHANNELS then return false end if
  if dma.NUM_AMBIENTS != AMBIENT_CHANNELS then return false end if
  if dma.MAX_DYNAMIC_CHANNELS != DYNAMIC_CHANNELS then return false end if
  if mix.PAINTBUFFER_SIZE != PAINTBUFFER_FRAMES then return false end if
  if win.WAV_BUFFERS != WAV_BUFFERS then return false end if
  if win.WAV_BUFFER_SIZE != WAV_BUFFER_SIZE then return false end if
  if win.SECONDARY_BUFFER_SIZE != SECONDARY_BUFFER_SIZE then return false end if
  if production.MAX_CHANNELS != MAX_CHANNELS then return false end if
  if production.MAX_DYNAMIC_CHANNELS != DYNAMIC_CHANNELS then return false end if
  return true
end function
