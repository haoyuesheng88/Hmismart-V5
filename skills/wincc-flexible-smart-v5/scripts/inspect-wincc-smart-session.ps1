param(
    [int]$ProcessId,
    [switch]$Capture,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\lib-wincc-smart.ps1"

$processInfo = Get-WinCCSmartProcess -ProcessId $ProcessId
if (-not $processInfo) {
    throw "No open WinCC flexible SMART V5 editor window was found."
}

$rect = Get-WinCCSmartWindowRect -WindowHandle $processInfo.MainWindowHandle
$offscreen = Test-WinCCSmartWindowOffscreen -Rect $rect
if ($offscreen) {
    $rect = Move-WinCCSmartWindow -ProcessInfo $processInfo
    $offscreen = $false
}

$layout = Get-WinCCSmartLayoutClues
$capturePath = $null
if ($Capture) {
    $capturePath = Save-WinCCSmartWindowCapture -ProcessInfo $processInfo -OutputPath $OutputPath
}

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
    Offscreen        = $offscreen
    CapturePath      = $capturePath
    CacheRoot        = if ($layout) { $layout.CacheRoot } else { $null }
    LayoutPath       = if ($layout) { $layout.LayoutPath } else { $null }
    LayoutClues      = if ($layout) { $layout.Clues } else { @() }
}
