#!/usr/bin/env bash
# install.sh — install Oh-My-Posh + the rainbowflag prompt on macOS or Linux.
#
# Usage:
#   ./install.sh              # auto-detect shell from $SHELL
#   ./install.sh zsh          # force a specific shell (zsh|bash|fish)
#   SKIP_FONT=1 ./install.sh  # skip Nerd Font install
#
# Re-running the script is safe; it will not duplicate rc entries.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME="${REPO_DIR}/rainbowflag.omp.json"
MARKER="# >>> tui-custom-prompt (oh-my-posh) >>>"
MARKER_END="# <<< tui-custom-prompt (oh-my-posh) <<<"
PLACEHOLDER='$HOME/GitHub/tui-custom-prompt'

c_green=$'\033[32m'; c_yellow=$'\033[33m'; c_red=$'\033[31m'; c_reset=$'\033[0m'
log()  { printf '%s==>%s %s\n' "$c_green"  "$c_reset" "$*"; }
warn() { printf '%s!! %s%s\n'  "$c_yellow" "$*" "$c_reset"; }
err()  { printf '%sxx %s%s\n'  "$c_red"    "$*" "$c_reset" >&2; }

[[ -f "$THEME" ]] || { err "Theme file not found: $THEME"; exit 1; }

# Make scripts executable and point the theme's command paths at this clone.
if [[ -d "$REPO_DIR/scripts" ]]; then
  chmod +x "$REPO_DIR"/scripts/*.sh 2>/dev/null || true
fi
if grep -q "$PLACEHOLDER" "$THEME"; then
  log "Rewriting script paths in theme to: $REPO_DIR"
  # Portable in-place sed (BSD + GNU): use a temp file.
  tmp_theme="$(mktemp)"
  sed "s|\$HOME/GitHub/tui-custom-prompt|${REPO_DIR}|g" "$THEME" > "$tmp_theme"
  mv "$tmp_theme" "$THEME"
fi

OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM=macos ;;
  Linux)  PLATFORM=linux ;;
  *)      err "Unsupported OS: $OS (use install.ps1 on Windows)"; exit 1 ;;
esac

SHELL_NAME="${1:-$(basename "${SHELL:-bash}")}"
case "$SHELL_NAME" in
  zsh)  RC="$HOME/.zshrc"      ; INIT_CMD="eval \"\$(oh-my-posh init zsh --config \"$THEME\")\"" ;;
  bash) RC="$HOME/.bashrc"     ; INIT_CMD="eval \"\$(oh-my-posh init bash --config \"$THEME\")\"" ;;
  fish) RC="$HOME/.config/fish/config.fish"
        INIT_CMD="oh-my-posh init fish --config \"$THEME\" | source" ;;
  *)    err "Unsupported shell: $SHELL_NAME (zsh|bash|fish)"; exit 1 ;;
esac

# --- 1. Oh-My-Posh ----------------------------------------------------------
if command -v oh-my-posh >/dev/null 2>&1; then
  log "oh-my-posh already installed ($(oh-my-posh --version))"
else
  log "Installing oh-my-posh..."
  if [[ "$PLATFORM" == macos ]]; then
    if command -v brew >/dev/null 2>&1; then
      brew install jandedobbeleer/oh-my-posh/oh-my-posh
    else
      err "Homebrew not found. Install from https://brew.sh and re-run."
      exit 1
    fi
  else
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s
  fi
fi

# --- 2. Nerd Font (MesloLGM) ------------------------------------------------
if [[ "${SKIP_FONT:-0}" == "1" ]]; then
  warn "SKIP_FONT=1 — skipping Nerd Font install"
else
  log "Ensuring a MesloLGM Nerd Font is installed..."
  if [[ "$PLATFORM" == macos ]]; then
    if command -v brew >/dev/null 2>&1; then
      brew list --cask font-meslo-lg-nerd-font >/dev/null 2>&1 \
        || brew install --cask font-meslo-lg-nerd-font || warn "Font install failed; continuing"
    else
      warn "Homebrew not found; install MesloLGM Nerd Font manually."
    fi
  else
    FONT_DIR="$HOME/.local/share/fonts"
    FONT_FILE="$FONT_DIR/MesloLGMNerdFont-Regular.ttf"
    if [[ ! -f "$FONT_FILE" ]]; then
      mkdir -p "$FONT_DIR"
      curl -fLo "$FONT_FILE" \
        https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M/Regular/MesloLGMNerdFont-Regular.ttf \
        && fc-cache -f >/dev/null 2>&1 || warn "Font install failed; continuing"
    fi
  fi
fi

# --- 3. Wire up the rc file -------------------------------------------------
mkdir -p "$(dirname "$RC")"
touch "$RC"

if grep -Fq "$MARKER" "$RC"; then
  log "Updating existing block in $RC"
  # Replace the existing block between markers
  tmp="$(mktemp)"
  awk -v start="$MARKER" -v end="$MARKER_END" -v cmd="$INIT_CMD" '
    $0 == start { print; print cmd; skip=1; next }
    $0 == end   { print; skip=0; next }
    !skip
  ' "$RC" > "$tmp"
  mv "$tmp" "$RC"
else
  log "Adding oh-my-posh block to $RC"
  {
    printf '\n%s\n' "$MARKER"
    printf '%s\n'   "$INIT_CMD"
    printf '%s\n'   "$MARKER_END"
  } >> "$RC"
fi

# --- 4. Preview -------------------------------------------------------------
log "Preview:"
oh-my-posh print primary --config "$THEME" --shell "$SHELL_NAME" 2>/dev/null \
  | sed 's/%{[^}]*}//g' || true
echo

log "Done. Open a new terminal or run:  exec $SHELL_NAME"
