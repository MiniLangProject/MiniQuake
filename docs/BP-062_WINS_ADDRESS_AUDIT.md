# BP-062 – WinSock landriver and address audit

BP-062 binds byte order, address comparison, hostname shortening, strict full
address parsing and the deliberately looser `PartialIPAddress` port behavior.
WinQuake parses the port suffix with `Q_atoi` and then stores it through a
16-bit network-order field; MiniQuake now preserves decimal-prefix parsing and
16-bit wrapping for this path.
