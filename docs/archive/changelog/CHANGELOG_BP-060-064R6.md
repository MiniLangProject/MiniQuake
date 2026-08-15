# CHANGELOG BP-060–BP-064R6

- Replace the R5 UDP evidence server's `Start-Process` status handling with a
  direct `System.Diagnostics.Process` lifecycle.
- Drain redirected server stdout and stderr asynchronously while the client
  runs, then use a timed wait followed by parameterless `WaitForExit()` and
  `Refresh()` before reading the typed exit code.
- Classify process-start, timeout, stream-collection and unavailable-exit-code
  failures explicitly as `INFRA_FAILURE` instead of misreporting an engine
  failure.
- Emit one JSON process-pair report per evidence pair with server/client exit
  codes and PASS-marker state.
- Preserve live, unbuffered foreground compiler and test output.
- Preserve all engine and native source, 65 compiled targets, 113 network and
  platform fixtures, and fingerprint `0xb3ec7589`.

- No engine or native source is changed by this delivery-only correction.
