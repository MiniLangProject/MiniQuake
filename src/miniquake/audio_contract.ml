/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Frozen WinQuake 1.09 audio compatibility contract.  The contract binds the
observable software mixer, channel, DMA ring and CD-command semantics while
allowing the physical device backend to use a modern x64-safe implementation.
*/
package miniquake.audio_contract

import miniquake.sound.snd_dma as dma
import miniquake.sound.snd_mix as mix
import miniquake.sound.snd_win as win
import miniquake.sound.mixer as production

/// Defines the status value used by `miniquake.audio_contract`.
const STATUS = "audio_109_frozen_v1"
/// Defines the fingerprint value used by `miniquake.audio_contract`.
const FINGERPRINT = 0xdcf7a002
/// Defines the max sfx value used by `miniquake.audio_contract`.
const MAX_SFX = 512
/// Defines the max channels value used by `miniquake.audio_contract`.
const MAX_CHANNELS = 128
/// Defines the ambient channels value used by `miniquake.audio_contract`.
const AMBIENT_CHANNELS = 4
/// Defines the dynamic channels value used by `miniquake.audio_contract`.
const DYNAMIC_CHANNELS = 8
/// Defines the paintbuffer frames value used by `miniquake.audio_contract`.
const PAINTBUFFER_FRAMES = 512
/// Defines the wav buffers value used by `miniquake.audio_contract`.
const WAV_BUFFERS = 64
/// Defines the wav buffer size value used by `miniquake.audio_contract`.
const WAV_BUFFER_SIZE = 1024
/// Defines the secondary buffer size value used by `miniquake.audio_contract`.
const SECONDARY_BUFFER_SIZE = 65536
/// Defines the nominal clip distance value used by `miniquake.audio_contract`.
const NOMINAL_CLIP_DISTANCE = 1000
/// Defines the default sample bits value used by `miniquake.audio_contract`.
const DEFAULT_SAMPLE_BITS = 16
/// Defines the default channels value used by `miniquake.audio_contract`.
const DEFAULT_CHANNELS = 2
/// Defines the cd remap slots value used by `miniquake.audio_contract`.
const CD_REMAP_SLOTS = 100
/// Defines the binary32 spatial value used by `miniquake.audio_contract`.
const BINARY32_SPATIAL = 1
/// Defines the i32 mixer value used by `miniquake.audio_contract`.
const I32_MIXER = 1
/// Defines the distinct ring regions value used by `miniquake.audio_contract`.
const DISTINCT_RING_REGIONS = 1
/// Defines the quake atoi cd value used by `miniquake.audio_contract`.
const QUAKE_ATOI_CD = 1
/// Defines the retail evidence sounds value used by `miniquake.audio_contract`.
const RETAIL_EVIDENCE_SOUNDS = 2

/// Returns the compatibility status reported by `miniquake.audio_contract`.
function inline status()
  return STATUS
end function

/// Returns the compatibility fingerprint for `miniquake.audio_contract`.
function inline fingerprint()
  return FINGERPRINT
end function

/// Returns the compatibility constants exposed by `miniquake.audio_contract`.
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

/// Implements the `verify` operation for `miniquake.audio_contract` (verify).
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
