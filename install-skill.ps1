$ErrorActionPreference = "Stop"

$skillName = "wincc-flexible-smart-v5"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceDir = Join-Path $repoRoot "skills\$skillName"

if (-not (Test-Path -LiteralPath $sourceDir)) {
    throw "Skill source directory not found: $sourceDir"
}

$targetRoot = if ($env:CODEX_HOME) {
    Join-Path $env:CODEX_HOME "skills"
} else {
    Join-Path $env:USERPROFILE ".codex\skills"
}

$targetDir = Join-Path $targetRoot $skillName

New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null

if (Test-Path -LiteralPath $targetDir) {
    Remove-Item -LiteralPath $targetDir -Recurse -Force
}

Copy-Item -LiteralPath $sourceDir -Destination $targetDir -Recurse -Force

Write-Output "Installed skill to: $targetDir"
Write-Output "You can now invoke: `$wincc-flexible-smart-v5"
