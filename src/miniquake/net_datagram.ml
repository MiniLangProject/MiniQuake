package miniquake.net_datagram

import miniquake.types as t
import miniquake.byteio as bio

const NETFLAG_LENGTH_MASK = 0x0000ffff
const NETFLAG_DATA = 0x00010000
const NETFLAG_ACK = 0x00020000
const NETFLAG_NAK = 0x00040000
const NETFLAG_EOM = 0x00080000
const NETFLAG_UNRELIABLE = 0x00100000
const NETFLAG_CTL = 0x80000000
const NET_HEADERSIZE = 8
const NET_MAXMESSAGE = 8192
const MAX_DATAGRAM = 1024

function putBigU32(data, offset, value)
  data[offset] = (value >> 24) & 255
  data[offset + 1] = (value >> 16) & 255
  data[offset + 2] = (value >> 8) & 255
  data[offset + 3] = value & 255
  return offset + 4
end function

function bigU32(data, offset)
  if offset < 0 or offset + 4 > len(data) then return error(3400, "Datagram header is truncated") end if
  return ((data[offset] & 255) << 24) | ((data[offset + 1] & 255) << 16) | ((data[offset + 2] & 255) << 8) | (data[offset + 3] & 255)
end function

function createChannel()
  return t.DatagramChannel(0, 0, 0, 0, 0)
end function

function encode(flags, sequence, payload)
  if payload is not bytes then return error(3401, "Datagram payload must be bytes") end if
  control = (flags & NETFLAG_CTL) != 0
  headerSize = NET_HEADERSIZE
  if control then headerSize = 4 end if
  total = headerSize + len(payload)
  if total > NETFLAG_LENGTH_MASK then return error(3402, "Datagram packet exceeds length mask") end if
  output = bytes(total)
  putBigU32(output, 0, (flags & ~NETFLAG_LENGTH_MASK) | total)
  if not control then putBigU32(output, 4, sequence) end if
  bio.copyInto(output, headerSize, payload, 0, len(payload))
  return output
end function

function decodePacket(data)
  if data is not bytes or len(data) < 4 then return error(3403, "Datagram packet is shorter than its header") end if
  lengthAndFlags = bigU32(data, 0)
  packetLength = lengthAndFlags & NETFLAG_LENGTH_MASK
  flags = lengthAndFlags & ~NETFLAG_LENGTH_MASK
  if packetLength != len(data) then return error(3404, "Datagram length field " + packetLength + " does not match " + len(data)) end if
  control = (flags & NETFLAG_CTL) != 0
  headerSize = NET_HEADERSIZE
  sequence = 0
  if control then
    headerSize = 4
  else
    if len(data) < NET_HEADERSIZE then return error(3405, "Sequenced datagram header is truncated") end if
    sequence = bigU32(data, 4)
  end if
  return t.DatagramPacket(flags, sequence, slice(data, headerSize, len(data) - headerSize))
end function

function reliable(channel, payload, endOfMessage)
  flags = NETFLAG_DATA
  if endOfMessage then flags = flags | NETFLAG_EOM end if
  packet = encode(flags, channel.sendSequence, payload)
  channel.sendSequence = channel.sendSequence + 1
  return packet
end function

function unreliable(channel, payload)
  packet = encode(NETFLAG_UNRELIABLE, channel.unreliableSendSequence, payload)
  channel.unreliableSendSequence = channel.unreliableSendSequence + 1
  return packet
end function

function acknowledgement(sequence)
  return encode(NETFLAG_ACK, sequence, bytes())
end function

function control(payload)
  return encode(NETFLAG_CTL, 0, payload)
end function

function acceptReliable(channel, packet)
  if (packet.flags & NETFLAG_DATA) == 0 then return false end if
  if packet.sequence != channel.receiveSequence then return false end if
  channel.receiveSequence = channel.receiveSequence + 1
  return true
end function

function acceptUnreliable(channel, packet)
  if (packet.flags & NETFLAG_UNRELIABLE) == 0 then return false end if
  if packet.sequence < channel.unreliableReceiveSequence then return false end if
  if packet.sequence > channel.unreliableReceiveSequence then
    channel.droppedUnreliable = channel.droppedUnreliable + packet.sequence - channel.unreliableReceiveSequence
  end if
  channel.unreliableReceiveSequence = packet.sequence + 1
  return true
end function
