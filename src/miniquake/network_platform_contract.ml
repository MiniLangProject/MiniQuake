/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Frozen observable WinQuake 1.09 network and Windows-platform contract.
*/

package miniquake.network_platform_contract

const STATUS = "network_platform_109_frozen_v1"
const FINGERPRINT = 0xb3ec7589
const DEFAULT_HOST_PORT = 26000
const CONTROL_PROTOCOL_VERSION = 3
const MAX_RELIABLE_MESSAGE = 8192
const MAX_DATAGRAM = 1024
const HOST_CACHE_SIZE = 8
const MESSAGE_TIMEOUT_SECONDS = 300
const NETWORK_DRIVERS = 2
const LAN_DRIVERS = 1
const MAX_FILE_HANDLES = 10
const MAX_HOST_NAME = 256
const NET_NAME_LENGTH = 64
const QHOST_COMMANDS = 4

function values()
  return [
    DEFAULT_HOST_PORT,
    CONTROL_PROTOCOL_VERSION,
    MAX_RELIABLE_MESSAGE,
    MAX_DATAGRAM,
    HOST_CACHE_SIZE,
    MESSAGE_TIMEOUT_SECONDS,
    NETWORK_DRIVERS,
    LAN_DRIVERS,
    MAX_FILE_HANDLES,
    MAX_HOST_NAME,
    NET_NAME_LENGTH,
    QHOST_COMMANDS,
  ]
end function

function verify()
  return STATUS == "network_platform_109_frozen_v1" and
    FINGERPRINT == 0xb3ec7589 and
    DEFAULT_HOST_PORT == 26000 and
    CONTROL_PROTOCOL_VERSION == 3 and
    MAX_RELIABLE_MESSAGE == 8192 and
    MAX_DATAGRAM == 1024 and
    HOST_CACHE_SIZE == 8 and
    MESSAGE_TIMEOUT_SECONDS == 300 and
    NETWORK_DRIVERS == 2 and
    LAN_DRIVERS == 1 and
    MAX_FILE_HANDLES == 10 and
    MAX_HOST_NAME == 256 and
    NET_NAME_LENGTH == 64 and
    QHOST_COMMANDS == 4
end function
