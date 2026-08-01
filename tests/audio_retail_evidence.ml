/* BP-059: deterministic retail id1 WAVE parsing evidence. */
import miniquake.filesystem as bp059Fs
import miniquake.sound.snd_mem as bp059Mem
import miniquake.render_evidence as bp059Hash

function bp059RetailFail(message)
  print "MiniQuake BP-059 retail audio evidence: FAIL"
  print "  " + message
  return 1
end function

function bp059CacheLine(name, cache)
  return "sound=" + name +
    "|length=" + cache.length +
    "|loop_start=" + cache.loopStart +
    "|rate=" + cache.speed +
    "|width=" + cache.width +
    "|channels=" + (cache.stereo + 1) +
    "|sample_hash=" + bp059Hash.hashBytes(cache.data)
end function

function main(args)
  if len(args) < 1 then
    print "usage: MiniQuakeAudioRetailEvidence.exe BASEDIR [GAME]"
    return 2
  end if
  game = "id1"
  if len(args) > 1 then game = args[1] end if
  filesystem = try(bp059Fs.initialize(args[0], game))
  if filesystem is error then return bp059RetailFail(filesystem.message) end if

  menuDescriptor = bp059Mem.createDescriptor("misc/menu1.wav")
  menuCache = try(bp059Mem.S_LoadSound(filesystem, menuDescriptor, 22050, false))
  if menuCache is error then bp059Fs.release(filesystem); return bp059RetailFail(menuCache.message) end if

  waterDescriptor = bp059Mem.createDescriptor("ambience/water1.wav")
  waterCache = try(bp059Mem.S_LoadSound(filesystem, waterDescriptor, 22050, false))
  if waterCache is error then bp059Fs.release(filesystem); return bp059RetailFail(waterCache.message) end if

  print "MiniQuake BP-059 retail audio evidence"
  print "  schema=1"
  print "  game=" + game
  print "  " + bp059CacheLine("misc/menu1.wav", menuCache)
  print "  " + bp059CacheLine("ambience/water1.wav", waterCache)
  combined = bytes(bp059CacheLine("misc/menu1.wav", menuCache) + "\n" + bp059CacheLine("ambience/water1.wav", waterCache))
  print "  evidence_hash=" + bp059Hash.hashBytes(combined)
  bp059Fs.release(filesystem)
  print "MiniQuake BP-059 retail audio evidence: PASS"
  return 0
end function
