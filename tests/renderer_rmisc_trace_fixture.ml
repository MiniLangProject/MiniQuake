/*
Deterministic MiniLang side of the original gl_rmisc.c differential oracle.
*/

import miniquake.render.gl_rmisc as rmisc
import miniquake.native as native
import std.string as string

function jsonNumber(value)
  integerValue = native.trunc(value)
  if value == integerValue then return "" + integerValue end if
  return string.replaceAll("" + value, ".e", "e")
end function

function emit(scene, functionName, sequence, operation, arguments)
  print "{\"schema\":\"miniquake.renderer.gl.v1\",\"scene\":\"" + scene + "\",\"function\":\"" + functionName + "\",\"seq\":" + sequence + ",\"op\":\"" + operation + "\",\"args\":" + arguments + "}"
end function

function inline fnvByte(hash, value)
  return ((hash ^ (value & 255)) * 16777619) & 4294967295
end function

function hashBytes(data)
  hash = 2166136261
  index = 0
  while index < len(data)
    hash = fnvByte(hash, data[index])
    index = index + 1
  end while
  return hash
end function

function traceInitTextures()
  rmisc.ResetCompatibility()
  rmisc.R_InitTextures()
  state = rmisc.GetTextureState()
  offsets = state[0]
  emit("rmisc_init_textures", "R_InitTextures", 0, "texture", "[16,16," + offsets[0] + "," + offsets[1] + "," + offsets[2] + "," + hashBytes(state[1]) + "]")
end function

function traceInitParticle()
  rmisc.ResetCompatibility()
  rmisc.R_InitParticleTexture()
  state = rmisc.GetParticleState()
  emit("rmisc_init_particle", "R_InitParticleTexture", 0, "particle", "[" + state[0] + "," + state[1] + "," + state[2] + "," + (state[3] * state[4]) + "," + hashBytes(state[5]) + "]")
end function

function traceEnvmap()
  rmisc.ResetCompatibility()
  directions = rmisc.R_Envmap_f()
  index = 0
  while index < len(directions)
    direction = directions[index]
    emit("rmisc_envmap", "R_Envmap_f", index, "env_view", "[" + index + "," + jsonNumber(direction[0]) + "," + jsonNumber(direction[1]) + ",262144]")
    index = index + 1
  end while
  state = rmisc.GetRefreshState()
  emit("rmisc_envmap", "R_Envmap_f", index, "state", "[0," + state[0] + "," + state[2] + "," + state[3] + "]")
end function

function traceInit()
  rmisc.ResetCompatibility()
  textureSort = rmisc.R_Init(true)
  state = rmisc.GetInitState()
  emit("rmisc_init", "R_Init", 0, "state", "[" + state[0] + "," + state[1] + "," + state[2] + "," + state[3] + "," + state[4] + "," + textureSort + "]")
end function

function traceTranslateSkin()
  rmisc.ResetCompatibility()
  rmisc.SetPlayerTextureBase(2000)
  skin = bytes(16)
  index = 0
  while index < 16
    skin[index] = 16 + index
    index = index + 1
  end while
  rmisc.SetPlayerSkinCompatibility(4, 4, skin, 0xd3, 4, 0)
  rmisc.R_TranslatePlayerSkin(0)
  state = rmisc.GetSkinState()
  emit("rmisc_translate_skin", "R_TranslatePlayerSkin", 0, "skin", "[" + state[0] + "," + state[1] + "," + state[2] + "," + hashBytes(state[3]) + "]")
end function

function traceNewMap()
  rmisc.ResetCompatibility()
  rmisc.SetNewMapCompatibility(["skyfixture", "window02_1", "brick"], 2)
  rmisc.R_NewMap()
  state = rmisc.GetNewMapState()
  emit("rmisc_new_map", "R_NewMap", 0, "state", "[" + state[0][0] + "," + state[0][255] + ",1,1,1," + state[2] + "," + state[3] + "," + state[4] + "," + state[5] + "]")
end function

function traceTimeRefresh()
  rmisc.ResetCompatibility()
  rmisc.R_TimeRefresh_f()
  state = rmisc.GetRefreshState()
  emit("rmisc_time_refresh", "R_TimeRefresh_f", 0, "state", "[" + state[0] + "," + jsonNumber(state[1]) + "," + state[2] + "," + state[3] + "]")
end function

function traceFlush()
  rmisc.ResetCompatibility()
  rmisc.D_FlushCaches()
  emit("rmisc_flush_caches", "D_FlushCaches", 0, "state", "[]")
end function

function main(args)
  traceInitTextures()
  traceInitParticle()
  traceEnvmap()
  traceInit()
  traceTranslateSkin()
  traceNewMap()
  traceTimeRefresh()
  traceFlush()
  return 0
end function
