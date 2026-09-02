/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.net_datagram.
*/
package miniquake.net_datagram

import miniquake.types as t
import miniquake.byteio as bio

/// Defines the netflag length mask value used by `miniquake.net_datagram`.
const NETFLAG_LENGTH_MASK = 0x0000ffff
/// Defines the netflag data value used by `miniquake.net_datagram`.
const NETFLAG_DATA = 0x00010000
/// Defines the netflag ack value used by `miniquake.net_datagram`.
const NETFLAG_ACK = 0x00020000
/// Defines the netflag nak value used by `miniquake.net_datagram`.
const NETFLAG_NAK = 0x00040000
/// Defines the netflag eom value used by `miniquake.net_datagram`.
const NETFLAG_EOM = 0x00080000
/// Defines the netflag unreliable value used by `miniquake.net_datagram`.
const NETFLAG_UNRELIABLE = 0x00100000
/// Defines the netflag ctl value used by `miniquake.net_datagram`.
const NETFLAG_CTL = 0x80000000
/// Defines the net headersize value used by `miniquake.net_datagram`.
const NET_HEADERSIZE = 8
/// Defines the net maxmessage value used by `miniquake.net_datagram`.
const NET_MAXMESSAGE = 8192
/// Defines the max datagram value used by `miniquake.net_datagram`.
const MAX_DATAGRAM = 1024

/// Tracks the module-level packets sent state owned by `miniquake.net_datagram`.
packetsSent = 0
/// Tracks the module-level packets re sent state owned by `miniquake.net_datagram`.
packetsReSent = 0
/// Tracks the module-level packets received state owned by `miniquake.net_datagram`.
packetsReceived = 0
/// Tracks the module-level received duplicate count state owned by `miniquake.net_datagram`.
receivedDuplicateCount = 0
/// Tracks the module-level short packet count state owned by `miniquake.net_datagram`.
shortPacketCount = 0
/// Tracks the module-level dropped datagrams state owned by `miniquake.net_datagram`.
droppedDatagrams = 0

// Update module state for stats.
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

/// Return next sequence for the active module state.
/// @param sequence The sequence input consumed by `nextSequence`.
function inline nextSequence(sequence)
  return (sequence + 1) & 0xffffffff
end function

/// Implements the `previousSequence` operation for `miniquake.net_datagram` (previous sequence).
/// @param sequence The sequence input consumed by `previousSequence`.
function inline previousSequence(sequence)
  return (sequence - 1) & 0xffffffff
end function

/// Encode and write big u32.
/// @param data Input data consumed by the operation.
/// @param offset Zero-based offset of the requested data.
/// @param value Value consumed by `putBigU32`.
function putBigU32(data, offset, value)
  data[offset] = (value >> 24) & 255
  data[offset + 1] = (value >> 16) & 255
  data[offset + 2] = (value >> 8) & 255
  data[offset + 3] = value & 255
  return offset + 4
end function

/// Implements the `bigU32` operation for `miniquake.net_datagram` (big u32).
/// @param data Input data consumed by the operation.
/// @param offset Zero-based offset of the requested data.
function bigU32(data, offset)
  if offset < 0 or offset + 4 > len(data) then return error(3400, "Datagram header is truncated") end if
  return ((data[offset] & 255) << 24) | ((data[offset + 1] & 255) << 16) | ((data[offset + 2] & 255) << 8) | (data[offset + 3] & 255)
end function

// Create and initialize channel.
function createChannel()
  return t.DatagramChannel(0, 0, 0, 0, 0, 0, bytes(), bytes(), true, false, 0.0, 0)
end function

/// Add state for append bytes.
/// @param a The a input consumed by `appendBytes`.
/// @param b The b input consumed by `appendBytes`.
function appendBytes(a, b)
  output = bytes(len(a) + len(b))
  bio.copyInto(output, 0, a, 0, len(a))
  bio.copyInto(output, len(a), b, 0, len(b))
  return output
end function

/// Release state for drop prefix.
/// @param data Input data consumed by the operation.
/// @param count Number of entries or units to process.
function dropPrefix(data, count)
  if count >= len(data) then return bytes() end if
  if count <= 0 then return data end if
  return slice(data, count, len(data) - count)
end function

/// Implements the `encode` operation for `miniquake.net_datagram` (encode).
/// @param flags The flags input consumed by `encode`.
/// @param sequence The sequence input consumed by `encode`.
/// @param payload The payload input consumed by `encode`.
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

/// Read and validate packet.
/// @param data Input data consumed by the operation.
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

/// Implements the `reliable` operation for `miniquake.net_datagram` (reliable).
/// @param channel The channel input consumed by `reliable`.
/// @param payload The payload input consumed by `reliable`.
/// @param endOfMessage The end of message input consumed by `reliable`.
function reliable(channel, payload, endOfMessage)
  global packetsSent
  flags = NETFLAG_DATA
  if endOfMessage then flags = flags | NETFLAG_EOM end if
  packet = encode(flags, channel.sendSequence, payload)
  channel.sendSequence = nextSequence(channel.sendSequence)
  packetsSent = packetsSent + 1
  return packet
end function

/// Implements the `unreliable` operation for `miniquake.net_datagram` (unreliable).
/// @param channel The channel input consumed by `unreliable`.
/// @param payload The payload input consumed by `unreliable`.
function unreliable(channel, payload)
  global packetsSent
  packet = encode(NETFLAG_UNRELIABLE, channel.unreliableSendSequence, payload)
  channel.unreliableSendSequence = nextSequence(channel.unreliableSendSequence)
  packetsSent = packetsSent + 1
  return packet
end function

/// Implements the `acknowledgement` operation for `miniquake.net_datagram` (acknowledgement).
/// @param sequence The sequence input consumed by `acknowledgement`.
function acknowledgement(sequence)
  return encode(NETFLAG_ACK, sequence, bytes())
end function

/// Implements the `negativeAcknowledgement` operation for `miniquake.net_datagram` (negative acknowledgement).
/// @param sequence The sequence input consumed by `negativeAcknowledgement`.
function negativeAcknowledgement(sequence)
  return encode(NETFLAG_NAK, sequence, bytes())
end function

/// Implements the `control` operation for `miniquake.net_datagram` (control).
/// @param payload The payload input consumed by `control`.
function control(payload)
  return encode(NETFLAG_CTL, 0, payload)
end function

/// Implements the `acceptReliable` operation for `miniquake.net_datagram` (accept reliable).
/// @param channel The channel input consumed by `acceptReliable`.
/// @param packet Network packet to process.
function acceptReliable(channel, packet)
  if (packet.flags & NETFLAG_DATA) == 0 then return false end if
  if packet.sequence != channel.receiveSequence then return false end if
  channel.receiveSequence = nextSequence(channel.receiveSequence)
  return true
end function

/// Implements the `acceptUnreliable` operation for `miniquake.net_datagram` (accept unreliable).
/// @param channel The channel input consumed by `acceptUnreliable`.
/// @param packet Network packet to process.
function acceptUnreliable(channel, packet)
  if (packet.flags & NETFLAG_UNRELIABLE) == 0 then return false end if
  if packet.sequence < channel.unreliableReceiveSequence then return false end if
  if packet.sequence > channel.unreliableReceiveSequence then
    channel.droppedUnreliable = channel.droppedUnreliable + packet.sequence - channel.unreliableReceiveSequence
  end if
  channel.unreliableReceiveSequence = nextSequence(packet.sequence)
  return true
end function

/// Return next reliable packet for the active module state.
/// @param channel The channel input consumed by `nextReliablePacket`.
/// @param now The now input consumed by `nextReliablePacket`.
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

/// Initialize state for begin reliable.
/// @param channel The channel input consumed by `beginReliable`.
/// @param payload The payload input consumed by `beginReliable`.
/// @param now The now input consumed by `beginReliable`.
function beginReliable(channel, payload, now)
  if payload is not bytes then return error(3410, "reliable message must be bytes") end if
  if len(payload) == 0 then return error(3411, "reliable message is empty") end if
  if len(payload) > NET_MAXMESSAGE then return error(3412, "reliable message exceeds NET_MAXMESSAGE") end if
  if not channel.canSend then return error(3413, "reliable channel is waiting for an ACK") end if
  channel.sendMessage = slice(payload, 0, len(payload))
  channel.canSend = false
  return nextReliablePacket(channel, now)
end function

/// Implements the `resendReliable` operation for `miniquake.net_datagram` (resend reliable).
/// @param channel The channel input consumed by `resendReliable`.
/// @param now The now input consumed by `resendReliable`.
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

/// Implements the `pollRetransmit` operation for `miniquake.net_datagram` (poll retransmit).
/// @param channel The channel input consumed by `pollRetransmit`.
/// @param now The now input consumed by `pollRetransmit`.
function pollRetransmit(channel, now)
  if channel.canSend then return void end if
  if now - channel.lastSendTime <= 1.0 then return void end if
  return resendReliable(channel, now)
end function

/// Returns [message type, payload, ACK/NAK response, immediate transport reply].
/// Matching ACKs only mark sendNext.  The transport flushes the next reliable
/// fragment after its receive loop, matching net_dgrm.c.  Message type follows
/// NET_GetMessage: 0 = none, 1 = reliable, 2 = unreliable.
/// @param channel The channel input consumed by `processPacket`.
/// @param wirePacket The wire packet input consumed by `processPacket`.
/// @param now The now input consumed by `processPacket`.
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

/// Named net_dgrm.c entry points. The transport-facing net_loop module supplies
/// the UDP socket operations; these functions own the original channel state.
/// @param channel The channel input consumed by `Datagram_SendMessage`.
/// @param payload The payload input consumed by `Datagram_SendMessage`.
/// @param now The now input consumed by `Datagram_SendMessage`.
function Datagram_SendMessage(channel, payload, now)
  return beginReliable(channel, payload, now)
end function

/// Send message next through the active connection.
/// @param channel The channel input consumed by `SendMessageNext`.
/// @param now The now input consumed by `SendMessageNext`.
function SendMessageNext(channel, now)
  return nextReliablePacket(channel, now)
end function

/// Implements the `ReSendMessage` operation for `miniquake.net_datagram` (re send message).
/// @param channel The channel input consumed by `ReSendMessage`.
/// @param now The now input consumed by `ReSendMessage`.
function ReSendMessage(channel, now)
  return resendReliable(channel, now)
end function

/// Mirror Quake's Datagram_FlushSendNext routine and its observable state changes.
/// @param channel The channel input consumed by `Datagram_FlushSendNext`.
/// @param now The now input consumed by `Datagram_FlushSendNext`.
function Datagram_FlushSendNext(channel, now)
  if not channel.sendNext then return void end if
  return nextReliablePacket(channel, now)
end function

/// Mirror Quake's Datagram_CanSendMessage routine and its observable state changes.
/// @param channel The channel input consumed by `Datagram_CanSendMessage`.
function Datagram_CanSendMessage(channel)
  // The C driver flushes sendNext here because it owns the socket.  The pure
  // MiniLang channel cannot perform I/O; net_loop.pumpRemote performs the same
  // flush after draining the receive queue.  Keep this query side-effect free.
  return channel.canSend
end function

/// Mirror Quake's Datagram_CanSendUnreliableMessage routine and its observable state changes.
/// @param channel The channel input consumed by `Datagram_CanSendUnreliableMessage`.
function Datagram_CanSendUnreliableMessage(channel)
  return true
end function

/// Mirror Quake's Datagram_SendUnreliableMessage routine and its observable state changes.
/// @param channel The channel input consumed by `Datagram_SendUnreliableMessage`.
/// @param payload The payload input consumed by `Datagram_SendUnreliableMessage`.
function Datagram_SendUnreliableMessage(channel, payload)
  if payload is not bytes or len(payload) == 0 or len(payload) > MAX_DATAGRAM then return error(3415, "unreliable datagram must contain 1..MAX_DATAGRAM bytes") end if
  return unreliable(channel, payload)
end function

/// Mirror Quake's Datagram_GetMessage routine and its observable state changes.
/// @param channel The channel input consumed by `Datagram_GetMessage`.
/// @param packet Network packet to process.
/// @param now The now input consumed by `Datagram_GetMessage`.
function Datagram_GetMessage(channel, packet, now)
  return processPacket(channel, packet, now)
end function

/// Format and emit stats.
/// @param channel The channel input consumed by `PrintStats`.
function PrintStats(channel)
  return "canSend = " + channel.canSend + " sendSeq = " + channel.sendSequence + " recvSeq = " + channel.receiveSequence
end function

/// Mirror Quake's NET_Stats_f routine and its observable state changes.
/// @param channels Number of interleaved audio channels.
/// @param messagesSent The messages sent input consumed by `NET_Stats_f`.
/// @param messagesReceived The messages received input consumed by `NET_Stats_f`.
/// @param unreliableSent The unreliable sent input consumed by `NET_Stats_f`.
/// @param unreliableReceived The unreliable received input consumed by `NET_Stats_f`.
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
