# Absolute-compatibility worktree notice

This archive contains the latest complete MiniQuake source tree available in the
conversation, overlaid with the current GLQuake 1.09 compatibility worktree and
audit artifacts.

## Preflight repair in this revision

The first absolute-compatibility archive exposed ten structural diagnostics in
`render/original.ml`.  The integration layer referenced helper APIs that had
been present in the audit worktree but were omitted from the packaged source
files.  This revision restores those implementations rather than adding stubs:

- `boxOnPlaneSide` and `rotatePointAroundVector` in `mathlib.ml`;
- grouped and oriented sprite frame selection/rendering;
- indexed texture upload and translated player-skin texture ownership;
- the six-argument sprite draw path expected by `render/original.ml`.

The exact structural preflight used by `build.ps1` now passes for all 77
MiniLang source/test files.  The current official MiniLang parser and the
lexical-scope preflight also accept all 77 files, and `tools/verify.py` passes.

The compatibility additions are still a worktree: the complete new renderer
path has not yet received a full Windows backend build and runtime validation
against the Steam game data.  Do not treat the audit's symbol-name coverage as
proof of complete semantic 1:1 parity.
