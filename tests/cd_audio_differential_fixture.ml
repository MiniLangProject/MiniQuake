/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/cd_audio_differential_fixture.ml.
*/
import miniquake.sound.cd_audio as cd
import miniquake.native as native

// Return bool number derived from the active module state.
function boolNumber(value)
  if value then return 1 end if
  return 0
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  state = cd.create(void, 12)
  result = cd.CDAudio_Init(state)
  print "{\"function\":\"CDAudio_Init\",\"case\":\"ready\",\"result\":" +
    result + ",\"initialized\":" + boolNumber(state.initialized) +
    ",\"enabled\":" + boolNumber(state.enabled) + ",\"valid\":" +
    boolNumber(state.valid) + ",\"max\":" + state.maxTrack +
    ",\"registered\":1,\"remap\":" + state.remap[7] + "}"

  state.volume = 1.0
  cd.CDAudio_Play(state, 3, true)
  print "{\"function\":\"CDAudio_Play\",\"case\":\"loop\",\"playing\":" +
    boolNumber(state.playing) + ",\"was\":" + boolNumber(state.wasPlaying) +
    ",\"looping\":" + boolNumber(state.looping) + ",\"track\":" +
    state.track + ",\"plays\":1}"

  cd.CDAudio_Pause(state)
  print "{\"function\":\"CDAudio_Pause\",\"case\":\"active\",\"playing\":" +
    boolNumber(state.playing) + ",\"was\":" + boolNumber(state.wasPlaying) +
    ",\"pauses\":1}"

  cd.CDAudio_Resume(state)
  print "{\"function\":\"CDAudio_Resume\",\"case\":\"paused\",\"playing\":" +
    boolNumber(state.playing) + ",\"was\":" + boolNumber(state.wasPlaying) +
    ",\"plays\":2,\"track\":" + state.track + "}"

  cd.CDAudio_Stop(state)
  print "{\"function\":\"CDAudio_Stop\",\"case\":\"active\",\"playing\":" +
    boolNumber(state.playing) + ",\"was\":" + boolNumber(state.wasPlaying) +
    ",\"stops\":1}"

  state.volume = 0.0
  cd.CD_f(state, ["cd", "remap", "5", "7"])
  cd.CD_f(state, ["cd", "loop", "2"])
  print "{\"function\":\"CD_f\",\"case\":\"remap-loop\",\"remap\":[" +
    state.remap[1] + "," + state.remap[2] + "],\"track\":" + state.track +
    ",\"playing\":" + boolNumber(state.playing) + ",\"was\":" +
    boolNumber(state.wasPlaying) + ",\"looping\":" +
    boolNumber(state.looping) + "}"

  cd.CDAudio_Update(state, 1.0)
  resumed = boolNumber(state.playing)
  resumeVolume = state.volume
  cd.CDAudio_Update(state, 0.0)
  paused = 0
  if not state.playing and state.wasPlaying then paused = 1 end if
  print "{\"function\":\"CDAudio_Update\",\"case\":\"binary-volume\",\"resumed\":" +
    resumed + ",\"resume_volume\":" + native.floatText(resumeVolume) +
    ",\"paused\":" + paused + ",\"volume\":" +
    native.floatText(state.volume) + "}"

  cd.CDAudio_Shutdown(state)
  print "{\"function\":\"CDAudio_Shutdown\",\"case\":\"close\",\"initialized\":" +
    boolNumber(state.initialized) + ",\"enabled\":" +
    boolNumber(state.enabled) + ",\"playing\":" +
    boolNumber(state.playing) + ",\"closes\":1}"
  return 0
end function
