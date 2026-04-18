param(
    [int]$ProcessId,
    [int]$X = 40,
    [int]$Y = 40,
    [int]$Width = 1600,
    [int]$Height = 1200
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\lib-wincc-smart.ps1"

$processInfo = Get-WinCCSmartProcess -ProcessId $ProcessId
if (-not $processInfo) {
    throw "No open WinCC flexible SMART V5 editor window was found."
}

$rect = Move-WinCCSmartWindow -ProcessInfo $processInfo -X $X -Y $Y -Width $Width -Height $Height

[pscustomobject]@{
    MainWindowTitle = $processInfo.MainWindowTitle
    Id              = $processInfo.Id
    Left            = $rect.Left
    Top             = $rect.Top
    Right           = $rect.Right
    Bottom          = $rect.Bottom
    Width           = $rect.Width
    Height          = $rect.Height
}
