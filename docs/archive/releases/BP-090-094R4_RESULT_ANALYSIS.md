# BP-090--BP-094R3 Windows result analysis

## Result boundary

The cumulative MiniQuake build and every internal runtime group completed
successfully.  All BP-090 through BP-094 asset-free fixtures passed and the
original binary provenance gate accepted the expected `kit/GLQUAKE.EXE`.

The first external process failed before map startup:

```text
exit=-1073741819 / 0xC0000005
last qconsole line=GL_EXTENSIONS: ...
```

The original process had already created a 640x480 WGL context and reported the
NVIDIA renderer.  No MiniQuake interop client had started yet.

## Exact original-source cause

The original Windows GL path prints the complete extension string in
`gl_vidnt.c::GL_Init`:

```c
Con_Printf("GL_EXTENSIONS: %s\n", gl_extensions);
```

R3 started the binary with `-condebug`.  That enables
`console.c::Con_DebugLog`, which contains:

```c
static char data[1024];
vsprintf(data, fmt, argptr);
```

The extension line observed in the R3 result was 2580 bytes.  It therefore
exceeded the legacy 1024-byte debug-log buffer by more than 1500 bytes.  The
complete line was written to `qconsole.log`, after which the process terminated
with an access violation.  This is an original-binary logging incompatibility with modern OpenGL extension strings. It is not a Protocol-3, Protocol-15 or MiniQuake gameplay failure.

The same unsafe launch flag was present in all three external GUI uses:

- original GLQuake listen server,
- original GLQuake client,
- original GLQuake visual-reference capture.

Correcting only the first launch would therefore have moved the same crash to
BP-092 or BP-093.

## R4 evidence strategy

R4 keeps the original binary byte-identical and omits `-condebug` for all GUI
runs.  Evidence no longer depends on `qconsole.log`:

- original server readiness is proven by bounded real Protocol-3 connection
  retries and full MiniQuake Protocol-15 signon 4;
- original client interoperability is proven by the MiniQuake server summary
  and a live original process at completed signon;
- visual evidence is the original TGA screenshot itself.

Per-process JSON files retain the observable launch and completion state.
