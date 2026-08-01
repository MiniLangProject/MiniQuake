$Target = Join-Path $PSScriptRoot "TEST_BP-060-064R3.ps1"
Write-Warning "BP-060-064R2 is superseded by BP-060-064R3; forwarding to TEST_BP-060-064R3.ps1."
& $Target @args
exit $LASTEXITCODE
