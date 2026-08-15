# BP-090–BP-094 initial Windows-run analysis

## Observed failure

Windows PowerShell rejected `TEST_BP-090-094.ps1` at parse time:

```text
InvalidVariableReferenceWithDrive
line 683: original GLQuake captures differ for $Scenario: ...
```

No MiniLang compiler, MiniQuake executable, original GLQuake process, network
interop test or visual comparison was started.

## Root cause

Inside a PowerShell expandable string, a colon immediately following an
unbraced variable name is interpreted as part of a scope/drive-qualified
variable expression. `$Scenario:` is therefore invalid.

## Fix

The string now uses explicit braced interpolation:

```powershell
throw "original GLQuake captures differ for ${Scenario}: $OriginalHashA vs $OriginalHashB"
```

A package-wide static verifier now detects the same parser trap before
delivery. The hotfix changes test/delivery infrastructure only.
