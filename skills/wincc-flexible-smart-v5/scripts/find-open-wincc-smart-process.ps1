param(
    [int]$ProcessId,
    [string]$TitleLike = "WinCC flexible SMART"
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\lib-wincc-smart.ps1"

$processInfo = Get-WinCCSmartProcess -TitleLike $TitleLike -ProcessId $ProcessId
if (-not $processInfo) {
    throw "No open WinCC flexible SMART V5 editor window was found."
}

$rect = Get-WinCCSmartWindowRect -WindowHandle $processInfo.MainWindowHandle

[pscustomobject]@{
    ProcessName      = $processInfo.ProcessName
    Id               = $processInfo.Id
    MainWindowTitle  = $processInfo.MainWindowTitle
    MainWindowHandle = $processInfo.MainWindowHandle
    Path             = $processInfo.Path
    Visible          = $processInfo.Visible
    Left             = $rect.Left
    Top              = $rect.Top
    Right            = $rect.Right
    Bottom           = $rect.Bottom
    Width            = $rect.Width
    Height           = $rect.Height
    Offscreen        = Test-WinCCSmartWindowOffscreen -Rect $rect
}
