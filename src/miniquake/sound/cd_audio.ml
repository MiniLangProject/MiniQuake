package miniquake.sound.cd_audio

// Functional pendant of WinQuake/cd_win.c. Physical MCI drive operations are
// the documented modern deviation; the original command/state machine drives
// bundled OGG tracks through sound/mixer instead.

import miniquake.sound.mixer as mixer
import miniquake.array_util as arrays
import miniquake.byteio as bio
import miniquake.native as native

struct CdAudioState
  mixer
  initialized
  enabled
  valid
  playing
  wasPlaying
  looping
  track
  maxTrack
  volume
  remap
  lastMessage
end struct

defaultState = void

function identityRemap()
  result = arrays.makeFilledArray(100, 0)
  index = 0
  while index < 100
    result[index] = index
    index = index + 1
  end while
  return result
end function

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

function ensure(mixerState)
  global defaultState
  if defaultState is void or defaultState.mixer != mixerState then
    if defaultState is not void then CDAudio_Shutdown(defaultState) end if
    defaultState = create(mixerState, 99)
    CDAudio_Init(defaultState)
  end if
  return defaultState
end function

function release(mixerState)
  global defaultState
  if defaultState is void or defaultState.mixer != mixerState then return false end if
  CDAudio_Shutdown(defaultState)
  defaultState = void
  return true
end function

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

function CDAudio_Stop(state)
  if not state.enabled or not state.playing then return false end if
  if state.mixer is not void then mixer.stopMusic(state.mixer) end if
  state.wasPlaying = false
  state.playing = false
  return true
end function

function CDAudio_Pause(state)
  if not state.enabled or not state.playing then return false end if
  if state.mixer is not void then mixer.pauseMusic(state.mixer) end if
  state.wasPlaying = state.playing
  state.playing = false
  return true
end function

function CDAudio_Resume(state)
  if not state.enabled or not state.valid or not state.wasPlaying then return false end if
  if state.mixer is not void then mixer.resumeMusic(state.mixer) end if
  state.playing = true
  return true
end function

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

function CDAudio_Shutdown(state)
  if not state.initialized then return false end if
  CDAudio_Stop(state)
  if state.mixer is not void then mixer.stopMusic(state.mixer) end if
  return true
end function

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
    value = toNumber(arguments[index + 1])
    if value is void then value = 0 end if
    state.remap[index] = native.trunc(value) & 255
    index = index + 1
  end while
  return ""
end function

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
  return result + "Volume is " + native.floatText(state.volume) + "\n"
end function

function CD_f(state, arguments)
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
  if command == "close" then return "" end if
  if not state.valid then
    state.lastMessage = "No CD in player."
    return state.lastMessage
  end if
  if command == "play" or command == "loop" then
    trackText = ""
    if len(arguments) >= 3 then trackText = arguments[2] end if
    track = toNumber(trackText)
    if track is void then track = 0 end if
    CDAudio_Play(state, track, command == "loop")
    return state.lastMessage
  end if
  if command == "stop" then CDAudio_Stop(state); return "" end if
  if command == "pause" then CDAudio_Pause(state); return "" end if
  if command == "resume" then CDAudio_Resume(state); return "" end if
  if command == "eject" then
    if state.playing then CDAudio_Stop(state) end if
    state.valid = false
    return ""
  end if
  if command == "info" then return infoText(state) end if
  return "cd <on|off|reset|remap|play|loop|stop|pause|resume|eject|close|info> [track]"
end function
