/* BP-059: frozen WinQuake 1.09 audio compatibility contract. */
import miniquake.audio_contract as bp059Contract
import miniquake.render_special_contract as bp059Parent
import miniquake.sound.cd_audio as bp059Cd
import miniquake.sound.mixer as bp059Mixer
import miniquake.types as bp059Types

function bp059Equal(actual, expected, name)
  if actual != expected then return error(5900, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function bp059Yes(value, name)
  if not value then return error(5901, name + ": expected true") end if
  return true
end function
function bp059Run(number, name, fn)
  print "[" + number + "/24] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
function bp059State()
  state = bp059Cd.create(void, 99)
  bp059Cd.CDAudio_Init(state)
  state.volume = 1.0
  return state
end function
function bp059Status()
  bp059Equal(bp059Contract.status(), "audio_109_frozen_v1", "status")
  return true
end function
function bp059Fingerprint()
  bp059Equal(bp059Contract.fingerprint(), 3707215874, "fingerprint")
  return true
end function
function bp059Verify()
  bp059Yes(bp059Contract.verify(), "contract verification")
  return true
end function
function bp059ParentContract()
  bp059Equal(bp059Parent.status(), "render_special_109_frozen_v1", "parent status")
  return true
end function
function bp059MaxSfx()
  bp059Equal(bp059Contract.MAX_SFX, 512, "max sfx")
  return true
end function
function bp059MaxChannels()
  bp059Equal(bp059Contract.MAX_CHANNELS, 128, "max channels")
  return true
end function
function bp059AmbientChannels()
  bp059Equal(bp059Contract.AMBIENT_CHANNELS, 4, "ambient channels")
  return true
end function
function bp059DynamicChannels()
  bp059Equal(bp059Contract.DYNAMIC_CHANNELS, 8, "dynamic channels")
  return true
end function
function bp059PaintBuffer()
  bp059Equal(bp059Contract.PAINTBUFFER_FRAMES, 512, "paintbuffer frames")
  return true
end function
function bp059WaveRing()
  bp059Equal(bp059Contract.WAV_BUFFERS, 64, "wave buffers")
  bp059Equal(bp059Contract.WAV_BUFFER_SIZE, 1024, "wave buffer size")
  bp059Equal(bp059Contract.SECONDARY_BUFFER_SIZE, 65536, "secondary buffer")
  return true
end function
function bp059ClipDistance()
  bp059Equal(bp059Contract.NOMINAL_CLIP_DISTANCE, 1000, "clip distance")
  return true
end function
function bp059Defaults()
  bp059Equal(bp059Contract.DEFAULT_SAMPLE_BITS, 16, "sample bits")
  bp059Equal(bp059Contract.DEFAULT_CHANNELS, 2, "output channels")
  return true
end function
function bp059CdSlots()
  bp059Equal(bp059Contract.CD_REMAP_SLOTS, 100, "CD remap slots")
  return true
end function
function bp059SemanticFlags()
  bp059Equal(bp059Contract.BINARY32_SPATIAL, 1, "Binary32 spatial")
  bp059Equal(bp059Contract.I32_MIXER, 1, "i32 mixer")
  bp059Equal(bp059Contract.DISTINCT_RING_REGIONS, 1, "ring regions")
  bp059Equal(bp059Contract.QUAKE_ATOI_CD, 1, "Quake atoi CD")
  return true
end function
function bp059RetailEvidenceCount()
  bp059Equal(bp059Contract.RETAIL_EVIDENCE_SOUNDS, 2, "retail evidence sounds")
  return true
end function
function bp059IdentityRemap()
  values = bp059Cd.identityRemap()
  bp059Equal(len(values), 100, "identity length")
  bp059Equal(values[0], 0, "identity zero")
  bp059Equal(values[99], 99, "identity final")
  return true
end function
function bp059TrackClamp()
  low = bp059Cd.create(void, 0)
  high = bp059Cd.create(void, 120)
  bp059Equal(low.maxTrack, 99, "low max track")
  bp059Equal(high.maxTrack, 99, "high max track")
  return true
end function
function bp059CdPlayAtoi()
  state = bp059State()
  bp059Cd.CD_f(state, ["cd", "play", "5x"])
  bp059Equal(state.track, 5, "atoi suffix track")
  bp059Equal(state.playing, true, "suffix playing")
  bp059Cd.CD_f(state, ["cd", "play", "2.9"])
  bp059Equal(state.track, 2, "atoi decimal prefix")
  invalid = bp059Cd.CD_f(state, ["cd", "play", "text"])
  bp059Yes(invalid == "CDAudio: Bad track number 0.", "bad track message")
  return true
end function
function bp059CdRemapAtoi()
  state = bp059State()
  bp059Cd.CD_f(state, ["cd", "remap", "7x", "2.9", "-1rest"])
  bp059Equal(state.remap[1], 7, "remap one")
  bp059Equal(state.remap[2], 2, "remap two")
  bp059Equal(state.remap[3], 255, "remap wrapped negative")
  return true
end function
function bp059CdReset()
  state = bp059State()
  state.remap[1] = 8
  state.valid = false
  state.enabled = false
  bp059Cd.CD_f(state, ["cd", "reset"])
  bp059Equal(state.remap[1], 1, "reset remap")
  bp059Equal(state.valid, true, "reset valid")
  bp059Equal(state.enabled, true, "reset enabled")
  return true
end function
function bp059CdLifecycle()
  state = bp059State()
  bp059Yes(bp059Cd.CDAudio_Play(state, 3, true), "play")
  bp059Equal(state.looping, true, "looping")
  bp059Yes(bp059Cd.CDAudio_Pause(state), "pause")
  bp059Equal(state.wasPlaying, true, "pause remembers")
  bp059Yes(bp059Cd.CDAudio_Resume(state), "resume")
  bp059Yes(bp059Cd.CDAudio_Stop(state), "stop")
  bp059Equal(state.playing, false, "stopped")
  return true
end function
function bp059CdInfo()
  state = bp059State()
  bp059Cd.CDAudio_Play(state, 4, false)
  text = bp059Cd.infoText(state)
  bp059Yes(text == "99 tracks\nCurrently playing track 4\nVolume is 1.000000\n", "info text")
  return true
end function
function bp059CdVolumeToggle()
  state = bp059State()
  bp059Cd.CDAudio_Play(state, 6, false)
  bp059Equal(bp059Cd.CDAudio_Update(state, 0.0), 0.0, "volume off")
  bp059Equal(state.wasPlaying, true, "volume pause")
  bp059Equal(bp059Cd.CDAudio_Update(state, 1.0), 1.0, "volume on")
  bp059Equal(state.playing, true, "volume resume")
  return true
end function
function bp059ProductionReplacementAndVector()
  state = bp059Mixer.create(void, 22050)
  state.enabled = true
  effect = bp059Types.SoundEffect("closure.wav", bytes(8), 22050, 1, 1, -1)
  state.effects = [effect]
  state.channels = [bp059Types.MixerChannel(42, 2, effect, bp059Types.Vec3(0.0,0.0,0.0), 1.0, 0.0, 3, false, true, 8)]
  bp059Yes(bp059Mixer.startSound(state, 42, 2, "closure.wav", bp059Types.Vec3(0.0,0.0,0.0), 1.0, 0.0), "exact replacement")
  bp059Equal(len(state.channels), 1, "one replacement channel")
  bp059Equal(state.channels[0].sample, 0, "replacement restarted")
  bp059Equal(len(bp059Contract.constants()), 17, "contract vector length")
  return true
end function

passed = 0
if bp059Run(1, "contract status", bp059Status) then passed = passed + 1 end if
if bp059Run(2, "contract fingerprint", bp059Fingerprint) then passed = passed + 1 end if
if bp059Run(3, "contract verification", bp059Verify) then passed = passed + 1 end if
if bp059Run(4, "parent render contract", bp059ParentContract) then passed = passed + 1 end if
if bp059Run(5, "maximum sound effects", bp059MaxSfx) then passed = passed + 1 end if
if bp059Run(6, "maximum channels", bp059MaxChannels) then passed = passed + 1 end if
if bp059Run(7, "ambient channels", bp059AmbientChannels) then passed = passed + 1 end if
if bp059Run(8, "dynamic channels", bp059DynamicChannels) then passed = passed + 1 end if
if bp059Run(9, "paintbuffer frames", bp059PaintBuffer) then passed = passed + 1 end if
if bp059Run(10, "waveOut ring constants", bp059WaveRing) then passed = passed + 1 end if
if bp059Run(11, "nominal clip distance", bp059ClipDistance) then passed = passed + 1 end if
if bp059Run(12, "output defaults", bp059Defaults) then passed = passed + 1 end if
if bp059Run(13, "CD remap slots", bp059CdSlots) then passed = passed + 1 end if
if bp059Run(14, "audio semantic flags", bp059SemanticFlags) then passed = passed + 1 end if
if bp059Run(15, "retail evidence count", bp059RetailEvidenceCount) then passed = passed + 1 end if
if bp059Run(16, "identity CD remap", bp059IdentityRemap) then passed = passed + 1 end if
if bp059Run(17, "maximum CD track clamp", bp059TrackClamp) then passed = passed + 1 end if
if bp059Run(18, "CD play Quake atoi", bp059CdPlayAtoi) then passed = passed + 1 end if
if bp059Run(19, "CD remap Quake atoi", bp059CdRemapAtoi) then passed = passed + 1 end if
if bp059Run(20, "CD reset", bp059CdReset) then passed = passed + 1 end if
if bp059Run(21, "CD pause resume stop", bp059CdLifecycle) then passed = passed + 1 end if
if bp059Run(22, "CD info text", bp059CdInfo) then passed = passed + 1 end if
if bp059Run(23, "CD volume toggle", bp059CdVolumeToggle) then passed = passed + 1 end if
if bp059Run(24, "production replacement and contract vector", bp059ProductionReplacementAndVector) then passed = passed + 1 end if
if passed != 24 then print "MiniQuake BP-059 audio closure tests failed: " + passed + "/24"; error(5999, "BP-059 audio closure") end if
print "MiniQuake BP-059 audio closure tests passed: 24"
