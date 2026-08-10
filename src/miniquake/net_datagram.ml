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

packetsSent = 0
packetsReSent = 0
packetsReceived = 0
receivedDuplicateCount = 0
shortPacketCount = 0
droppedDatagrams = 0

function resetStats()
  global packetsSent, packetsReSent, packetsReceived
  global receivedDuplicateCount, shortPacketCount, droppedDatagrams
  packetsSent = 0
  packetsReSent = 0
  packetsReceived = 0
  receivedDuplicateCount = 0
  shortPacketCount = 0
  droppedDatagrams = 0
  return true
end function

function inline nextSequence(sequence)
  return (sequence + 1) & 0xffffffff
end function

function inline previousSequence(sequence)
  return (sequence - 1) & 0xffffffff
end function

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
  return t.DatagramChannel(0, 0, 0, 0, 0, 0, bytes(), bytes(), true, false, 0.0, 0)
end function

function appendBytes(a, b)
  output = bytes(len(a) + len(b))
  bio.copyInto(output, 0, a, 0, len(a))
  bio.copyInto(output, len(a), b, 0, len(b))
  return output
end function

function dropPrefix(data, count)
  if count >= len(data) then return bytes() end if
  if count <= 0 then return data end if
  return slice(data, count, len(data) - count)
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
  global packetsSent
  flags = NETFLAG_DATA
  if endOfMessage then flags = flags | NETFLAG_EOM end if
  packet = encode(flags, channel.sendSequence, payload)
  channel.sendSequence = nextSequence(channel.sendSequence)
  packetsSent = packetsSent + 1
  return packet
end function

function unreliable(channel, payload)
  global packetsSent
  packet = encode(NETFLAG_UNRELIABLE, channel.unreliableSendSequence, payload)
  channel.unreliableSendSequence = nextSequence(channel.unreliableSendSequence)
  packetsSent = packetsSent + 1
  return packet
end function

function acknowledgement(sequence)
  return encode(NETFLAG_ACK, sequence, bytes())
end function

function negativeAcknowledgement(sequence)
  return encode(NETFLAG_NAK, sequence, bytes())
end function

function control(payload)
  return encode(NETFLAG_CTL, 0, payload)
end function

function acceptReliable(channel, packet)
  if (packet.flags & NETFLAG_DATA) == 0 then return false end if
  if packet.sequence != channel.receiveSequence then return false end if
  channel.receiveSequence = nextSequence(channel.receiveSequence)
  return true
end function

function acceptUnreliable(channel, packet)
  if (packet.flags & NETFLAG_UNRELIABLE) == 0 then return false end if
  if packet.sequence < channel.unreliableReceiveSequence then return false end if
  if packet.sequence > channel.unreliableReceiveSequence then
    channel.droppedUnreliable = channel.droppedUnreliable + packet.sequence - channel.unreliableReceiveSequence
  end if
  channel.unreliableReceiveSequence = nextSequence(packet.sequence)
  return true
end function

function nextReliablePacket(channel, now)
  global packetsSent
  if len(channel.sendMessage) == 0 then
    channel.sendNext = false
    channel.canSend = true
    return void
  end if
  dataLength = len(channel.sendMessage)
  if dataLength > MAX_DATAGRAM then dataLength = MAX_DATAGRAM end if
  flags = NETFLAG_DATA
  if dataLength == len(channel.sendMessage) then flags = flags | NETFLAG_EOM end if
  packet = encode(flags, channel.sendSequence, slice(channel.sendMessage, 0, dataLength))
  channel.sendSequence = nextSequence(channel.sendSequence)
  channel.sendNext = false
  channel.lastSendTime = now
  packetsSent = packetsSent + 1
  return packet
end function

function beginReliable(channel, payload, now)
  if payload is not bytes then return error(3410, "reliable message must be bytes") end if
  if len(payload) == 0 then return error(3411, "reliable message is empty") end if
  if len(payload) > NET_MAXMESSAGE then return error(3412, "reliable message exceeds NET_MAXMESSAGE") end if
  if not channel.canSend then return error(3413, "reliable channel is waiting for an ACK") end if
  channel.sendMessage = slice(payload, 0, len(payload))
  channel.canSend = false
  return nextReliablePacket(channel, now)
end function

function resendReliable(channel, now)
  global packetsReSent
  if channel.canSend or len(channel.sendMessage) == 0 then return void end if
  dataLength = len(channel.sendMessage)
  if dataLength > MAX_DATAGRAM then dataLength = MAX_DATAGRAM end if
  flags = NETFLAG_DATA
  if dataLength == len(channel.sendMessage) then flags = flags | NETFLAG_EOM end if
  channel.lastSendTime = now
  channel.sendNext = false
  channel.packetsReSent = channel.packetsReSent + 1
  packetsReSent = packetsReSent + 1
  return encode(flags, previousSequence(channel.sendSequence), slice(channel.sendMessage, 0, dataLength))
end function

function pollRetransmit(channel, now)
  if channel.canSend then return void end if
  if now - channel.lastSendTime <= 1.0 then return void end if
  return resendReliable(channel, now)
end function

// Returns [message type, payload, ACK/NAK response, immediate transport reply].
// Matching ACKs only mark sendNext.  The transport flushes the next reliable
// fragment after its receive loop, matching net_dgrm.c.  Message type follows
// NET_GetMessage: 0 = none, 1 = reliable, 2 = unreliable.
function processPacket(channel, wirePacket, now)
  global packetsReceived, receivedDuplicateCount, shortPacketCount, droppedDatagrams
  if wirePacket is not bytes or len(wirePacket) < NET_HEADERSIZE then
    shortPacketCount = shortPacketCount + 1
  end if
  if wirePacket is bytes and len(wirePacket) > NET_HEADERSIZE + MAX_DATAGRAM then
    return error(3416, "sequenced datagram exceeds NET_DATAGRAMSIZE")
  end if
  packet = decodePacket(wirePacket)
  if packet is error then return packet end if
  if (packet.flags & NETFLAG_CTL) != 0 then return [0, void, void, void] end if
  packetsReceived = packetsReceived + 1

  if (packet.flags & NETFLAG_UNRELIABLE) != 0 then
    beforeDrops = channel.droppedUnreliable
    if not acceptUnreliable(channel, packet) then return [0, void, void, void] end if
    droppedDatagrams = droppedDatagrams + channel.droppedUnreliable - beforeDrops
    return [2, packet.payload, void, void]
  end if

  if (packet.flags & NETFLAG_NAK) != 0 then
    if not channel.canSend and packet.sequence == previousSequence(channel.sendSequence) then
      return [0, void, void, resendReliable(channel, now)]
    end if
    return [0, void, void, void]
  end if

  if (packet.flags & NETFLAG_ACK) != 0 then
    if channel.canSend or packet.sequence != previousSequence(channel.sendSequence) then return [0, void, void, void] end if
    if packet.sequence != channel.ackSequence then return [0, void, void, void] end if
    channel.ackSequence = nextSequence(channel.ackSequence)
    channel.sendMessage = dropPrefix(channel.sendMessage, MAX_DATAGRAM)
    if len(channel.sendMessage) > 0 then
      // net_dgrm.c defers SendMessageNext until the socket receive loop has
      // drained.  This matters when several ACK/data packets are already
      // queued and also prevents the pure channel layer from manufacturing a
      // packet that the transport then accidentally discards.
      channel.sendNext = true
      return [0, void, void, void]
    end if
    channel.canSend = true
    channel.sendNext = false
    return [0, void, void, void]
  end if

  if (packet.flags & NETFLAG_DATA) != 0 then
    response = acknowledgement(packet.sequence)
    if packet.sequence != channel.receiveSequence then
      receivedDuplicateCount = receivedDuplicateCount + 1
      return [0, void, response, void]
    end if
    channel.receiveSequence = nextSequence(channel.receiveSequence)
    if len(channel.receiveMessage) + len(packet.payload) > NET_MAXMESSAGE then
      channel.receiveMessage = bytes()
      return error(3414, "fragmented reliable message exceeds NET_MAXMESSAGE")
    end if
    if (packet.flags & NETFLAG_EOM) != 0 then
      complete = appendBytes(channel.receiveMessage, packet.payload)
      channel.receiveMessage = bytes()
      return [1, complete, response, void]
    end if
    channel.receiveMessage = appendBytes(channel.receiveMessage, packet.payload)
    return [0, void, response, void]
  end if

  return [0, void, void, void]
end function

// Named net_dgrm.c entry points. The transport-facing net_loop module supplies
// the UDP socket operations; these functions own the original channel state.
function Datagram_SendMessage(channel, payload, now)
  return beginReliable(channel, payload, now)
end function

function SendMessageNext(channel, now)
  return nextReliablePacket(channel, now)
end function

function ReSendMessage(channel, now)
  return resendReliable(channel, now)
end function

function Datagram_FlushSendNext(channel, now)
  if not channel.sendNext then return void end if
  return nextReliablePacket(channel, now)
end function

function Datagram_CanSendMessage(channel)
  // The C driver flushes sendNext here because it owns the socket.  The pure
  // MiniLang channel cannot perform I/O; net_loop.pumpRemote performs the same
  // flush after draining the receive queue.  Keep this query side-effect free.
  return channel.canSend
end function

function Datagram_CanSendUnreliableMessage(channel)
  return true
end function

function Datagram_SendUnreliableMessage(channel, payload)
  if payload is not bytes or len(payload) == 0 or len(payload) > MAX_DATAGRAM then return error(3415, "unreliable datagram must contain 1..MAX_DATAGRAM bytes") end if
  return unreliable(channel, payload)
end function

function Datagram_GetMessage(channel, packet, now)
  return processPacket(channel, packet, now)
end function

function PrintStats(channel)
  return "canSend = " + channel.canSend + " sendSeq = " + channel.sendSequence + " recvSeq = " + channel.receiveSequence
end function

function NET_Stats_f(channels, messagesSent, messagesReceived, unreliableSent, unreliableReceived)
  text = ""
  if channels is not void then
    for each channel in channels
      text = text + PrintStats(channel) + "\n"
    end for
    return text
  end if
  return "unreliable messages sent = " + unreliableSent + "\n" +
    "unreliable messages recv = " + unreliableReceived + "\n" +
    "reliable messages sent = " + messagesSent + "\n" +
    "reliable messages received = " + messagesReceived + "\n" +
    "packetsSent = " + packetsSent + "\n" +
    "packetsReSent = " + packetsReSent + "\n" +
    "packetsReceived = " + packetsReceived + "\n" +
    "receivedDuplicateCount = " + receivedDuplicateCount + "\n" +
    "shortPacketCount = " + shortPacketCount + "\n" +
    "droppedDatagrams = " + droppedDatagrams
end function
