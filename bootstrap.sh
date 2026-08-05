#!/usr/bin/env bash
#
# Dotfiles bootstrap — sets up this repo on a fresh Linux or macOS machine.
#
#   ./bootstrap.sh
#
# It will:
#   1. detect the OS (Linux vs macOS)
#   2. install GNU stow and a C compiler if missing
#   3. install the tree-sitter CLI (needed by nvim-treesitter) into ~/.local/bin
#   4. stow the packages that apply to this OS
#   5. compile the Neovim treesitter parsers
#
# Safe to re-run: every step checks before acting.

set -euo pipefail

# ── resolve repo dir so the script works from anywhere ──────────────
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO"

# ── detect OS ───────────────────────────────────────────────────────
case "$(uname -s)" in
  Linux)  OS=linux ;;
  Darwin) OS=macos ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64|amd64)  ARCH=x64 ;;
  arm64|aarch64) ARCH=arm64 ;;
  *) echo "Unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

# ── package manager helper (Linux distros) ──────────────────────────
linux_install() {  # linux_install <pkg...>
  if   command -v apt-get >/dev/null; then sudo apt-get update -qq && sudo apt-get install -y "$@"
  elif command -v dnf     >/dev/null; then sudo dnf install -y "$@"
  elif command -v pacman  >/dev/null; then sudo pacman -S --needed --noconfirm "$@"
  elif command -v zypper  >/dev/null; then sudo zypper install -y "$@"
  else warn "No known package manager; please install manually: $*"; return 1
  fi
}

# ── 1. stow ─────────────────────────────────────────────────────────
if ! command -v stow >/dev/null; then
  info "Installing GNU stow"
  if [ "$OS" = macos ]; then
    command -v brew >/dev/null || { warn "Homebrew required: https://brew.sh"; exit 1; }
    brew install stow
  else
    linux_install stow
  fi
else
  info "stow already installed"
fi

# ── 2. C compiler (for treesitter parsers) ──────────────────────────
if ! command -v cc >/dev/null && ! command -v gcc >/dev/null && ! command -v clang >/dev/null; then
  info "Installing a C compiler"
  if [ "$OS" = macos ]; then
    xcode-select --install || warn "Run 'xcode-select --install' manually if it didn't start"
  else
    linux_install gcc || linux_install build-essential || true
  fi
else
  info "C compiler present"
fi

# ── 3. tree-sitter CLI → ~/.local/bin ───────────────────────────────
mkdir -p "$HOME/.local/bin"
if ! command -v tree-sitter >/dev/null && [ ! -x "$HOME/.local/bin/tree-sitter" ]; then
  info "Installing tree-sitter CLI ($OS-$ARCH)"
  url="https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-${OS}-${ARCH}.gz"
  tmp="$(mktemp)"
  curl -fsSL -o "$tmp.gz" "$url"
  gunzip -f "$tmp.gz"                      # -> $tmp
  chmod +x "$tmp"
  mv "$tmp" "$HOME/.local/bin/tree-sitter"
  info "tree-sitter $("$HOME/.local/bin/tree-sitter" --version)"
else
  info "tree-sitter CLI already installed"
fi
export PATH="$HOME/.local/bin:$PATH"

# ── 4. stow packages ────────────────────────────────────────────────
# Cross-platform packages.
COMMON=(bin fastfetch ghostty nvim nvim.bak tmux tmux-sessionizer wezterm zsh)
# macOS-only tools.
MAC_ONLY=(aerospace sketchybar)
# Linux-only tools.
LINUX_ONLY=(hypr mako waybar wofi)
# NOTE: fcitx5 is stowed separately below — it must not be tree-folded.

PKGS=("${COMMON[@]}")
[ "$OS" = macos ] && PKGS+=("${MAC_ONLY[@]}")
[ "$OS" = linux ] && PKGS+=("${LINUX_ONLY[@]}")

info "Stowing: ${PKGS[*]}"
if ! stow -v "${PKGS[@]}"; then
  warn "stow reported conflicts (pre-existing files in \$HOME)."
  warn "Back them up (e.g. mv ~/.zshrc ~/.zshrc.bak) and re-run, or use: stow --adopt ${PKGS[*]}"
fi

# ── herdr (must not be tree-folded) ─────────────────────────────────
# herdr writes runtime state (sockets, logs, session json) into
# ~/.config/herdr. If stow folds that whole dir into a symlink, all of it
# lands in this repo — so link the individual file instead.
info "Stowing herdr"
stow --no-folding -v herdr || warn "herdr stow conflict — resolve as above"

# ── fcitx5 (must not be tree-folded, Linux only) ────────────────────
# fcitx5 creates its own files under ~/.config/fcitx5 at runtime (per-addon
# conf/, cached state). Folding the dir into a symlink would drop all of
# that into this repo, so link only the two files we actually manage.
if [ "$OS" = linux ]; then
  info "Stowing fcitx5"
  stow --no-folding -v fcitx5 || warn "fcitx5 stow conflict — resolve as above"
fi

# ── typst local package (data dir differs per OS) ───────────────────
# Linux: ~/.local/share/typst   |   macOS: ~/Library/Application Support/typst
# The repo stores it under the Linux path, so stow it directly on Linux and
# symlink it into the macOS data dir by hand.
TYPST_SRC="$REPO/typst/.local/share/typst/packages"
if [ "$OS" = linux ]; then
  info "Stowing typst"
  stow -v typst || warn "typst stow conflict — resolve as above"
else
  info "Linking typst packages into macOS data dir"
  dest="$HOME/Library/Application Support/typst"
  mkdir -p "$dest"
  if [ -e "$dest/packages" ] && [ ! -L "$dest/packages" ]; then
    warn "$dest/packages exists and is not a symlink — skipping (move it aside to link)"
  else
    ln -sfn "$TYPST_SRC" "$dest/packages"
    info "linked $dest/packages -> $TYPST_SRC"
  fi
fi

# ── 5. treesitter parsers ───────────────────────────────────────────
# Keep this list in sync with ensure_installed in
# nvim/.config/nvim/lua/plugins/treesitter.lua
if command -v nvim >/dev/null; then
  info "Installing Neovim treesitter parsers (this compiles each grammar)…"
  nvim --headless "+lua require('nvim-treesitter').install({'lua','vim','vimdoc','python','typst','latex','c','cpp','r','html','css','javascript','typescript','bash','json','yaml','markdown','markdown_inline','swift'}):wait(600000)" +q \
    && info "parsers installed" \
    || warn "parser install had errors — open nvim and check :checkhealth nvim-treesitter"
else
  warn "nvim not found — install Neovim, then run: nvim (parsers auto-install on first launch)"
fi

info "Bootstrap complete."
