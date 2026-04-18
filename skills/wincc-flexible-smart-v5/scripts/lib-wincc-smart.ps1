$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class WinCcSmartNative {
  [StructLayout(LayoutKind.Sequential)]
  public struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
  }

  [DllImport("user32.dll")]
  public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

  [DllImport("user32.dll")]
  public static extern bool MoveWindow(IntPtr hWnd, int x, int y, int nWidth, int nHeight, bool repaint);

  [DllImport("user32.dll")]
  public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

  [DllImport("user32.dll")]
  public static extern bool SetForegroundWindow(IntPtr hWnd);

  [DllImport("user32.dll")]
  public static extern bool IsWindowVisible(IntPtr hWnd);
}
"@

function Get-WinCCSmartProcess {
    param(
        [string]$TitleLike = "WinCC flexible SMART",
        [int]$ProcessId
    )

    $candidates = Get-CimInstance Win32_Process |
        Where-Object {
            $_.Name -eq "HmiES.exe" -or
            ($_.ExecutablePath -and $_.ExecutablePath -like "*WinCC flexible SMART V5*")
        }

    if ($ProcessId) {
        $candidates = $candidates | Where-Object { $_.ProcessId -eq $ProcessId }
    }

    $result = foreach ($candidate in $candidates) {
        try {
            $process = Get-Process -Id $candidate.ProcessId -ErrorAction Stop
        } catch {
            continue
        }

        if ($process.MainWindowHandle -eq 0) {
            continue
        }

        [pscustomobject]@{
            ProcessName      = $process.ProcessName
            Id               = $process.Id
            MainWindowTitle  = $process.MainWindowTitle
            MainWindowHandle = $process.MainWindowHandle
            Path             = $candidate.ExecutablePath
            Visible          = [WinCcSmartNative]::IsWindowVisible($process.MainWindowHandle)
        }
    }

    if (-not $result) {
        return $null
    }

    $preferred = $result | Where-Object { $_.MainWindowTitle -like "*$TitleLike*" } | Select-Object -First 1
    if ($preferred) {
        return $preferred
    }

    return $result | Select-Object -First 1
}

function Get-WinCCSmartWindowRect {
    param(
        [Parameter(Mandatory = $true)]
        [IntPtr]$WindowHandle
    )

    $rect = New-Object WinCcSmartNative+RECT
    [void][WinCcSmartNative]::GetWindowRect($WindowHandle, [ref]$rect)

    [pscustomobject]@{
        Left   = $rect.Left
        Top    = $rect.Top
        Right  = $rect.Right
        Bottom = $rect.Bottom
        Width  = $rect.Right - $rect.Left
        Height = $rect.Bottom - $rect.Top
    }
}

function Test-WinCCSmartWindowOffscreen {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Rect
    )

    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

    if ($Rect.Right -le $screen.Left) { return $true }
    if ($Rect.Left -ge $screen.Right) { return $true }
    if ($Rect.Bottom -le $screen.Top) { return $true }
    if ($Rect.Top -ge $screen.Bottom) { return $true }
    return $false
}

function Move-WinCCSmartWindow {
    param(
        [Parameter(Mandatory = $true)]
        [object]$ProcessInfo,
        [int]$X = 40,
        [int]$Y = 40,
        [int]$Width = 1600,
        [int]$Height = 1200
    )

    [void][WinCcSmartNative]::ShowWindow($ProcessInfo.MainWindowHandle, 9)
    Start-Sleep -Milliseconds 250
    [void][WinCcSmartNative]::MoveWindow($ProcessInfo.MainWindowHandle, $X, $Y, $Width, $Height, $true)
    Start-Sleep -Milliseconds 250
    [void][WinCcSmartNative]::SetForegroundWindow($ProcessInfo.MainWindowHandle)
    Start-Sleep -Milliseconds 400

    return Get-WinCCSmartWindowRect -WindowHandle $ProcessInfo.MainWindowHandle
}

function Save-WinCCSmartWindowCapture {
    param(
        [Parameter(Mandatory = $true)]
        [object]$ProcessInfo,
        [string]$OutputPath
    )

    if (-not $OutputPath) {
        $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $OutputPath = Join-Path (Get-Location) "wincc_smart_$stamp.png"
    }

    $parent = Split-Path -Parent $OutputPath
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    $rect = Get-WinCCSmartWindowRect -WindowHandle $ProcessInfo.MainWindowHandle
    if (Test-WinCCSmartWindowOffscreen -Rect $rect) {
        $rect = Move-WinCCSmartWindow -ProcessInfo $ProcessInfo
    }

    $bitmap = New-Object System.Drawing.Bitmap $rect.Width, $rect.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()

    return (Resolve-Path -LiteralPath $OutputPath).Path
}

function Get-WinCCSmartCacheRoot {
    $base = Join-Path $env:LOCALAPPDATA "Siemens AG\SIMATIC WinCC flexible SMART V5\Caches"
    if (-not (Test-Path -LiteralPath $base)) {
        return $null
    }

    return Get-ChildItem -LiteralPath $base -Directory |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

function Get-WinCCSmartLayoutClues {
    $cacheRoot = Get-WinCCSmartCacheRoot
    if (-not $cacheRoot) {
        return $null
    }

    $layoutPath = Join-Path $cacheRoot.FullName "CurrentLayoutAfterOpenProject.xml"
    if (-not (Test-Path -LiteralPath $layoutPath)) {
        return [pscustomobject]@{
            CacheRoot = $cacheRoot.FullName
            LayoutPath = $null
            Clues = @()
        }
    }

    $patterns = @(
        ".Tag.HmiTag",
        ".Communication.HmiConnection",
        "DisplayTag",
        "FindTags"
    )

    $hits = Select-String -LiteralPath $layoutPath -Pattern $patterns -SimpleMatch -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Line -Unique

    [pscustomobject]@{
        CacheRoot  = $cacheRoot.FullName
        LayoutPath = $layoutPath
        Clues      = @($hits)
    }
}
