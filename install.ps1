# install.ps1 — install Oh-My-Posh + the rainbowflag prompt on Windows (PowerShell).
#
# Usage:
#   .\install.ps1
#   .\install.ps1 -SkipFont
#
# Re-running is safe; it will not duplicate $PROFILE entries.

[CmdletBinding()]
param(
  [switch]$SkipFont
)

$ErrorActionPreference = 'Stop'
$RepoDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$Theme     = Join-Path $RepoDir 'rainbowflag.omp.json'
$Marker    = '# >>> tui-custom-prompt (oh-my-posh) >>>'
$MarkerEnd = '# <<< tui-custom-prompt (oh-my-posh) <<<'
$Placeholder = '$HOME/GitHub/tui-custom-prompt'

function Info($msg) { Write-Host "==> $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "!! $msg"  -ForegroundColor Yellow }
function Fail($msg) { Write-Host "xx $msg"  -ForegroundColor Red; exit 1 }

if (-not (Test-Path $Theme)) { Fail "Theme file not found: $Theme" }

# Rewrite the placeholder path in the theme to point at this clone.
$themeContent = Get-Content -Raw -Path $Theme
if ($themeContent.Contains($Placeholder)) {
  Info "Rewriting script paths in theme to: $RepoDir"
  $repoForward = $RepoDir -replace '\\','/'
  $themeContent = $themeContent.Replace($Placeholder, $repoForward)
  Set-Content -Path $Theme -Value $themeContent
}

# --- 1. Oh-My-Posh ----------------------------------------------------------
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
  Info "oh-my-posh already installed ($(& oh-my-posh --version))"
} else {
  Info "Installing oh-my-posh via winget..."
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Fail "winget not found. Install App Installer from the Microsoft Store, then re-run."
  }
  winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements
}

# --- 2. Nerd Font (MesloLGM) ------------------------------------------------
if ($SkipFont) {
  Warn "-SkipFont set — skipping Nerd Font install"
} else {
  Info "Installing MesloLGM Nerd Font (current user)..."
  try {
    & oh-my-posh font install meslo --user 2>&1 | Out-Null
  } catch {
    Warn "Font install failed; install MesloLGM Nerd Font manually if glyphs are missing."
  }
}

# --- 3. Wire up $PROFILE ----------------------------------------------------
if (-not (Test-Path $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$InitCmd = "oh-my-posh init pwsh --config `"$Theme`" | Invoke-Expression"
$content = Get-Content -Raw -Path $PROFILE -ErrorAction SilentlyContinue
if ($null -eq $content) { $content = '' }

if ($content -match [regex]::Escape($Marker)) {
  Info "Updating existing block in $PROFILE"
  $pattern  = "(?s)" + [regex]::Escape($Marker) + ".*?" + [regex]::Escape($MarkerEnd)
  $block    = "$Marker`n$InitCmd`n$MarkerEnd"
  $replaced = [regex]::Replace($content, $pattern, { param($m) $block })
  Set-Content -Path $PROFILE -Value $replaced
} else {
  Info "Adding oh-my-posh block to $PROFILE"
  Add-Content -Path $PROFILE -Value ''
  Add-Content -Path $PROFILE -Value $Marker
  Add-Content -Path $PROFILE -Value $InitCmd
  Add-Content -Path $PROFILE -Value $MarkerEnd
}

# --- 4. Preview -------------------------------------------------------------
Info "Preview:"
try { & oh-my-posh print primary --config $Theme --shell pwsh } catch { }

Info "Done. Open a new PowerShell window or run:  . `$PROFILE"
