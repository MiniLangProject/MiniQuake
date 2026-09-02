/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.sound.cd_audio.
*/
package miniquake.sound.cd_audio

// Functional pendant of WinQuake/cd_win.c. Physical MCI drive operations are
// the documented modern deviation; the original command/state machine drives
// bundled OGG tracks through sound/mixer instead.

import miniquake.sound.mixer as mixer
import miniquake.array_util as arrays
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.common as common

// Track mutable cd audio state across subsystem calls.
struct CdAudioState
  /// Stores the mixer value in `miniquake.sound.cd_audio.CdAudioState`.
  mixer
  /// Stores the initialized value in `miniquake.sound.cd_audio.CdAudioState`.
  initialized
  /// Stores the enabled value in `miniquake.sound.cd_audio.CdAudioState`.
  enabled
  /// Stores the valid value in `miniquake.sound.cd_audio.CdAudioState`.
  valid
  /// Stores the playing value in `miniquake.sound.cd_audio.CdAudioState`.
  playing
  /// Stores the was playing value in `miniquake.sound.cd_audio.CdAudioState`.
  wasPlaying
  /// Stores the looping value in `miniquake.sound.cd_audio.CdAudioState`.
  looping
  /// Stores the track value in `miniquake.sound.cd_audio.CdAudioState`.
  track
  /// Stores the max track value in `miniquake.sound.cd_audio.CdAudioState`.
  maxTrack
  /// Stores the volume value in `miniquake.sound.cd_audio.CdAudioState`.
  volume
  /// Stores the remap value in `miniquake.sound.cd_audio.CdAudioState`.
  remap
  /// Stores the last message value in `miniquake.sound.cd_audio.CdAudioState`.
  lastMessage
end struct

/// Tracks the default module-level CD-audio state owned by `miniquake.sound.cd_audio`.
defaultState = void

/// Implements the `identityRemap` operation for `miniquake.sound.cd_audio` (identity remap).
function identityRemap()
  result = arrays.makeFilledArray(100, 0)
  index = 0
  while index < 100
    result[index] = index
    index = index + 1
  end while
  return result
end function

/// Implements the `create` operation for `miniquake.sound.cd_audio` (create).
/// @param mixerState Mutable state used by `create`.
/// @param maxTrack The max track input consumed by `create`.
function create(mixerState, maxTrack)
  if maxTrack < 1 then maxTrack = 99 end if
  if maxTrack > 99 then maxTrack = 99 end if
  return CdAudioState(
    mixerState,
    false,
    false,
    false,
    false,
    false,
    false,
    0,
    maxTrack,
    0.0,
    identityRemap(),
    "",
  )
end function

/// Ensure sufficient storage or state for the requested value.
/// @param mixerState Mutable state used by `ensure`.
function ensure(mixerState)
  global defaultState
  if defaultState is void or defaultState.mixer != mixerState then
    if defaultState is not void then CDAudio_Shutdown(defaultState) end if
    defaultState = create(mixerState, 99)
    CDAudio_Init(defaultState)
  end if
  return defaultState
end function

/// Release or remove state for the requested value.
/// @param mixerState Mutable state used by `release`.
function release(mixerState)
  global defaultState
  if defaultState is void or defaultState.mixer != mixerState then return false end if
  CDAudio_Shutdown(defaultState)
  defaultState = void
  return true
end function

/// Mirror Quake's CDAudio_Init routine and its observable state changes.
/// @param state Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Init`.
function CDAudio_Init(state)
  state.remap = identityRemap()
  state.initialized = true
  state.enabled = true
  state.valid = true
  state.playing = false
  state.wasPlaying = false
  state.looping = false
  state.track = 0
  state.volume = 0.0
  state.lastMessage = "CD Audio Initialized"
  return 0
end function

/// Mirror Quake's CDAudio_Play routine and its observable state changes.
/// @param state Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Play`.
/// @param requestedTrack The requested track input consumed by `CDAudio_Play`.
/// @param looping The looping input consumed by `CDAudio_Play`.
function CDAudio_Play(state, requestedTrack, looping)
  if not state.enabled then return false end if
  if not state.valid then return false end if
  state.lastMessage = ""
  track = native.trunc(requestedTrack) & 255
  if track < 0 or track >= len(state.remap) then return false end if
  track = state.remap[track]
  if track < 1 or track > state.maxTrack then
    state.lastMessage = "CDAudio: Bad track number " + track + "."
    return false
  end if
  if state.playing and state.track == track then return true end if
  if state.playing then CDAudio_Stop(state) end if
  if state.mixer is not void then
    played = try(mixer.playMusic(state.mixer, track, looping))
    if played is error or not played then
      if played is error then state.lastMessage = played.message end if
      return false
    end if
  end if
  state.looping = looping
  state.track = track
  state.playing = true
  state.wasPlaying = false
  if state.volume == 0.0 then CDAudio_Pause(state) end if
  return true
end function

/// Mirror Quake's CDAudio_Stop routine and its observable state changes.
/// @param state Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Stop`.
function CDAudio_Stop(state)
  if not state.enabled or not state.playing then return false end if
  if state.mixer is not void then mixer.stopMusic(state.mixer) end if
  state.wasPlaying = false
  state.playing = false
  return true
end function

/// Mirror Quake's CDAudio_Pause routine and its observable state changes.
/// @param state Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Pause`.
function CDAudio_Pause(state)
  if not state.enabled or not state.playing then return false end if
  if state.mixer is not void then mixer.pauseMusic(state.mixer) end if
  state.wasPlaying = state.playing
  state.playing = false
  return true
end function

/// Mirror Quake's CDAudio_Resume routine and its observable state changes.
/// @param state Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Resume`.
function CDAudio_Resume(state)
  if not state.enabled or not state.valid or not state.wasPlaying then return false end if
  if state.mixer is not void then mixer.resumeMusic(state.mixer) end if
  state.playing = true
  return true
end function

/// Mirror Quake's CDAudio_Update routine and its observable state changes.
/// @param state Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Update`.
/// @param requestedVolume The requested volume input consumed by `CDAudio_Update`.
function CDAudio_Update(state, requestedVolume)
  if not state.enabled then return state.volume end if
  // MCI_NOTIFY_SUCCESSFUL clears `playing` at track completion.  The OGG
  // bridge exposes the same transition through its decoded track state.
  if state.playing and state.mixer is not void then
    music = state.mixer.music
    if music is void or not music.playing then state.playing = false end if
  end if
  if requestedVolume != state.volume then
    if state.volume != 0.0 then
      state.volume = 0.0
      CDAudio_Pause(state)
    else
      state.volume = 1.0
      CDAudio_Resume(state)
    end if
  end if
  return state.volume
end function

/// Mirror Quake's CDAudio_Shutdown routine and its observable state changes.
/// @param state Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Shutdown`.
function CDAudio_Shutdown(state)
  if not state.initialized then return false end if
  CDAudio_Stop(state)
  if state.mixer is not void then mixer.stopMusic(state.mixer) end if
  return true
end function

/// Implements the `remapCommand` operation for `miniquake.sound.cd_audio` (remap command).
/// @param state Mutable `miniquake.sound.cd_audio` state used by `remapCommand`.
/// @param arguments Command-line arguments to inspect or execute.
function remapCommand(state, arguments)
  count = len(arguments) - 2
  if count <= 0 then
    result = ""
    index = 1
    while index < 100
      if state.remap[index] != index then result = result + "  " + index + " -> " + state.remap[index] + "\n" end if
      index = index + 1
    end while
    return result
  end if
  index = 1
  while index <= count and index < 100
    value = common.atoi(arguments[index + 1])
    state.remap[index] = value & 255
    index = index + 1
  end while
  return ""
end function

/// Implements the `infoText` operation for `miniquake.sound.cd_audio` (info text).
/// @param state Mutable `miniquake.sound.cd_audio` state used by `infoText`.
function infoText(state)
  result = state.maxTrack + " tracks\n"
  if state.playing then
    action = "playing"
    if state.looping then action = "looping" end if
    result = result + "Currently " + action + " track " + state.track + "\n"
  else if state.wasPlaying then
    action = "playing"
    if state.looping then action = "looping" end if
    result = result + "Paused " + action + " track " + state.track + "\n"
  end if
  volume = native.bitsFloat(native.floatBits(state.volume))
  return result + "Volume is " + common.fixedFloat(volume) + "\n"
end function

/// Mirror Quake's CD_f routine and its observable state changes.
/// @param state Mutable `miniquake.sound.cd_audio` state used by `CD_f`.
/// @param arguments Command-line arguments to inspect or execute.
function CD_f(state, arguments)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if len(arguments) < 2 then return "" end if
  command = bio.lower(arguments[1])
  if command == "on" then state.enabled = true; return "" end if
  if command == "off" then
    if state.playing then CDAudio_Stop(state) end if
    state.enabled = false
    return ""
  end if
  if command == "reset" then
    state.enabled = true
    if state.playing then CDAudio_Stop(state) end if
    state.remap = identityRemap()
    state.valid = true
    return ""
  end if
  if command == "remap" then return remapCommand(state, arguments) end if
  if command == "close" then CDAudio_CloseDoor(state); return "" end if
  if not state.valid then
    state.lastMessage = "No CD in player."
    return state.lastMessage
  end if
  if command == "play" or command == "loop" then
    trackText = ""
    if len(arguments) >= 3 then trackText = arguments[2] end if
    track = common.atoi(trackText)
    CDAudio_Play(state, track, command == "loop")
    return state.lastMessage
  end if
  if command == "stop" then CDAudio_Stop(state); return "" end if
  if command == "pause" then CDAudio_Pause(state); return "" end if
  if command == "resume" then CDAudio_Resume(state); return "" end if
  if command == "eject" then
    CDAudio_Eject(state)
    return ""
  end if
  if command == "info" then return infoText(state) end if
  return "cd <on|off|reset|remap|play|loop|stop|pause|resume|eject|close|info> [track]"
end function

// ---------------------------------------------------------------------------
// WinQuake cd_win.c source-surface technical equivalents.
//
// Physical MCI tray and media-notification operations do not exist in the
// modern OGG backend. These adapters preserve all game-observable state
// transitions and the original public names while documenting the mechanical
// drive operation as a technical equivalent.
// ---------------------------------------------------------------------------

const MCI_NOTIFY_SUCCESSFUL = 1
/// Defines the mci notify superseded value used by `miniquake.sound.cd_audio`.
const MCI_NOTIFY_SUPERSEDED = 2
/// Defines the mci notify aborted value used by `miniquake.sound.cd_audio`.
const MCI_NOTIFY_ABORTED = 4
/// Defines the mci notify failure value used by `miniquake.sound.cd_audio`.
const MCI_NOTIFY_FAILURE = 8

/// Mirror Quake's CDAudio_Eject routine and its observable state changes.
/// @param state Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Eject`.
function CDAudio_Eject(state)
  if state.playing then CDAudio_Stop(state) end if
  state.valid = false
  state.lastMessage = "CDAudio: media ejected"
  return true
end function

/// Mirror Quake's CDAudio_CloseDoor routine and its observable state changes.
/// @param state Mutable `miniquake.sound.cd_audio` state used by `CDAudio_CloseDoor`.
function CDAudio_CloseDoor(state)
  state.lastMessage = "CDAudio: close door acknowledged by virtual media backend"
  return true
end function

/// Mirror Quake's CDAudio_GetAudioDiskInfo routine and its observable state changes.
/// @param state Mutable `miniquake.sound.cd_audio` state used by `CDAudio_GetAudioDiskInfo`.
function CDAudio_GetAudioDiskInfo(state)
  state.valid = false
  if not state.initialized or state.maxTrack < 1 then
    state.lastMessage = "CDAudio: no music tracks"
    return -1
  end if
  state.valid = true
  state.lastMessage = ""
  return 0
end function

/// Mirror Quake's CDAudio_MessageHandler routine and its observable state changes.
/// @param state Mutable `miniquake.sound.cd_audio` state used by `CDAudio_MessageHandler`.
/// @param notification The notification input consumed by `CDAudio_MessageHandler`.
/// @param deviceMatches The device matches input consumed by `CDAudio_MessageHandler`.
function CDAudio_MessageHandler(state, notification, deviceMatches)
  if not deviceMatches then return 1 end if

  if notification == MCI_NOTIFY_SUCCESSFUL then
    if state.playing then
      state.playing = false
      if state.looping then CDAudio_Play(state, state.track, true) end if
    end if
    return 0
  end if

  if notification == MCI_NOTIFY_ABORTED or
      notification == MCI_NOTIFY_SUPERSEDED then
    return 0
  end if

  if notification == MCI_NOTIFY_FAILURE then
    CDAudio_Stop(state)
    state.valid = false
    state.lastMessage = "MCI_NOTIFY_FAILURE"
    return 0
  end if

  state.lastMessage = "Unexpected MM_MCINOTIFY type (" + notification + ")"
  return 1
end function
