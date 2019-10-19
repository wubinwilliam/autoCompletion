Write-Output "Installing ..."

Invoke-Expression "cmd.exe /c mklink '$PSScriptRoot\test' '$PSScriptRoot\test.ps1'"

Write-Output "DONE"