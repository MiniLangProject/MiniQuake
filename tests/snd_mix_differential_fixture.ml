import miniquake.byteio as bio
import miniquake.sound.snd_mem as sndmem
import miniquake.sound.snd_mix as mixPort

function makeCache16()
  data = bytes(8)
  bio.putI16(data, 0, 1000)
  bio.putI16(data, 2, -1000)
  bio.putI16(data, 4, 2000)
  bio.putI16(data, 6, -2000)
  return sndmem.SoundCache(4, -1, 22050, 2, 0, data)
end function

function main(args)
  state = mixPort.createState(mixPort.createDma(22050, 16, 2, 8))
  table = mixPort.SND_InitScaletable(state)
  print "{\"function\":\"SND_InitScaletable\",\"case\":\"values\",\"values\":[" +
    table[31 * 256 + 255] + "," + table[16 * 256 + 128] + "," +
    table[1 * 256 + 1] + "]}"

  state.paintBuffer[0] = 40000
  state.paintBuffer[1] = -40000
  state.paintBuffer[2] = 1000
  state.paintBuffer[3] = -1000
  state.linearSource = 0
  state.linearCount = 4
  state.linearOutput = 0
  state.transferVolume = 256
  mixPort.Snd_WriteLinearBlastStereo16(state)
  print "{\"function\":\"Snd_WriteLinearBlastStereo16\",\"case\":\"clamp\",\"values\":[" +
    bio.i16(state.dma.buffer, 0) + "," + bio.i16(state.dma.buffer, 2) + "," +
    bio.i16(state.dma.buffer, 4) + "," + bio.i16(state.dma.buffer, 6) + "]}"

  stereo = mixPort.createState(mixPort.createDma(22050, 16, 2, 8))
  stereo.volume = 1.0
  stereo.paintBuffer[0] = 1000
  stereo.paintBuffer[1] = -1000
  stereo.paintBuffer[2] = 2000
  stereo.paintBuffer[3] = -2000
  written = mixPort.S_TransferStereo16(stereo, 2)
  print "{\"function\":\"S_TransferStereo16\",\"case\":\"two\",\"written\":" +
    written + ",\"values\":[" + bio.i16(stereo.dma.buffer, 0) + "," +
    bio.i16(stereo.dma.buffer, 2) + "," + bio.i16(stereo.dma.buffer, 4) +
    "," + bio.i16(stereo.dma.buffer, 6) + "]}"

  mono = mixPort.createState(mixPort.createDma(22050, 8, 1, 8))
  mono.volume = 1.0
  mono.paintBuffer[0] = 256
  mono.paintBuffer[2] = -256
  transferred = mixPort.S_TransferPaintBuffer(mono, 2)
  print "{\"function\":\"S_TransferPaintBuffer\",\"case\":\"mono8\",\"written\":" +
    transferred + ",\"values\":[" + mono.dma.buffer[0] + "," +
    mono.dma.buffer[1] + "]}"

  channel8State = mixPort.createState(mixPort.createDma(22050, 16, 2, 8))
  channel8 = channel8State.channels[0]
  channel8.leftVolume = 255
  channel8.rightVolume = 128
  cache8 = sndmem.SoundCache(3, -1, 22050, 1, 0, bytes([0, 128, 255]))
  pos8 = mixPort.SND_PaintChannelFrom8(channel8State, channel8, cache8, 3)
  print "{\"function\":\"SND_PaintChannelFrom8\",\"case\":\"three\",\"position\":" +
    channel8.position + ",\"values\":[" + channel8State.paintBuffer[0] + "," +
    channel8State.paintBuffer[1] + "," + channel8State.paintBuffer[2] + "," +
    channel8State.paintBuffer[3] + "," + channel8State.paintBuffer[4] + "," +
    channel8State.paintBuffer[5] + "]}"

  channel16State = mixPort.createState(mixPort.createDma(22050, 16, 2, 8))
  channel16 = channel16State.channels[0]
  channel16.leftVolume = 128
  channel16.rightVolume = 64
  data16 = bytes(6)
  bio.putI16(data16, 0, 1000)
  bio.putI16(data16, 2, -2000)
  bio.putI16(data16, 4, 3000)
  cache16 = sndmem.SoundCache(3, -1, 22050, 2, 0, data16)
  pos16 = mixPort.SND_PaintChannelFrom16(channel16State, channel16, cache16, 3)
  print "{\"function\":\"SND_PaintChannelFrom16\",\"case\":\"three\",\"position\":" +
    channel16.position + ",\"values\":[" + channel16State.paintBuffer[0] + "," +
    channel16State.paintBuffer[1] + "," + channel16State.paintBuffer[2] + "," +
    channel16State.paintBuffer[3] + "," + channel16State.paintBuffer[4] + "," +
    channel16State.paintBuffer[5] + "]}"

  paintState = mixPort.createState(mixPort.createDma(22050, 16, 2, 8))
  paintState.volume = 1.0
  paintState.totalChannels = 1
  descriptor = sndmem.createDescriptor("fixture")
  descriptor.cache = makeCache16()
  paintChannel = paintState.channels[0]
  paintChannel.sfx = descriptor
  paintChannel.leftVolume = 255
  paintChannel.rightVolume = 255
  paintChannel.endTime = 4
  painted = mixPort.S_PaintChannels(paintState, 4)
  active = 0
  if paintChannel.sfx is not void then active = 1 end if
  print "{\"function\":\"S_PaintChannels\",\"case\":\"one-channel\",\"painted\":" +
    painted + ",\"active\":" + active + ",\"values\":[" +
    bio.i16(paintState.dma.buffer, 0) + "," + bio.i16(paintState.dma.buffer, 2) +
    "," + bio.i16(paintState.dma.buffer, 4) + "," +
    bio.i16(paintState.dma.buffer, 6) + "]}"
  return 0
end function
