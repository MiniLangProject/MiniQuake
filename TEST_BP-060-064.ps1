$Target = Join-Path $PSScriptRoot "TEST_BP-060-064R6.ps1"
Write-Warning "BP-060-064 is superseded by BP-060-064R6; forwarding to TEST_BP-060-064R6.ps1."
& $Target @args
exit $LASTEXITCODE
