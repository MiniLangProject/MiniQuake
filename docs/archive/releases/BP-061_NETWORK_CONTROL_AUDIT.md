# BP-061 – Datagram control, discovery and connection audit

BP-061 binds Protocol 3 connectionless requests and replies, the eight-entry
host cache, duplicate suppression, wildcard advertised addresses, host-name
conflict handling, server-rule enumeration, connect duplicate/replacement
classification and IPv4 ban masks.

## R2 rule-enumeration parity

The original `net_dgrm.c` distinguishes the final two states of
`CCREQ_RULE_INFO`:

- When the requested previous cvar does not exist, the server returns without
  sending a packet.
- When the requested previous cvar is the final server cvar, the server emits a
  command-only `CCREP_RULE_INFO` packet. No name/value strings follow.

MiniQuake represents these states separately:

```text
next rule          -> [name, value]
end of enumeration -> ["", ""] -> command-only reply
unknown previous   -> internal error sentinel -> no reply
```

The listener catches the internal sentinel with `try(...)`. It is not exposed
on the network and does not change the Protocol-3 wire format. Runtime fixture
20 parses the command-only terminator; the C oracle and golden metadata also
bind the silent unknown-previous path.
