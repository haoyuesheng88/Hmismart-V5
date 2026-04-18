param(
    [int]$ProcessId,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\lib-wincc-smart.ps1"

$processInfo = Get-WinCCSmartProcess -ProcessId $ProcessId
if (-not $processInfo) {
    throw "No open WinCC flexible SMART V5 editor window was found."
}

$saved = Save-WinCCSmartWindowCapture -ProcessInfo $processInfo -OutputPath $OutputPath
[pscustomobject]@{
    MainWindowTitle = $processInfo.MainWindowTitle
    Id              = $processInfo.Id
    OutputPath      = $saved
}
