#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║           Developer Extras — Install & Configure             ║
# ║           Run from your home directory: bash extras.sh       ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

# ─── Colours for output ─────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[DONE]${NC}  $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERR]${NC}   $1"; }

echo ""
echo "  ┌──────────────────────────────────────────────────┐"
echo "  │        Developer Extras — Setup Script            │"
echo "  └──────────────────────────────────────────────────┘"
echo ""

# ─── 1. Pacman packages ─────────────────────────────────────────
info "Installing pacman packages..."

sudo pacman -S --needed --noconfirm \
  eza \
  zoxide \
  tealdeer \
  dust \
  duf \
  procs \
  hyperfine \
  docker \
  docker-compose \
  git-delta \
  httpie \
  jq \
  make \
  btop \
  nvtop \
  playerctl \
  brightnessctl \
  xdg-user-dirs

success "Pacman packages installed"

# ─── 2. AUR packages ────────────────────────────────────────────
info "Installing AUR packages..."

if command -v yay &>/dev/null; then
  yay -S --needed --noconfirm \
    bandwhich \
    ttf-monaspace \
    sd
  success "AUR packages installed"
else
  warn "yay not found — skipping AUR packages (bandwhich, ttf-monaspace, sd)"
fi

# ─── 3. Docker setup ────────────────────────────────────────────
info "Setting up Docker..."

sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
success "Docker enabled — you'll need to log out and back in for group to apply"

# ─── 4. tldr cache ──────────────────────────────────────────────
info "Updating tealdeer (tldr) cache..."
tldr --update
success "tldr cache updated"

# ─── 5. xdg user dirs ───────────────────────────────────────────
info "Creating XDG user directories..."
xdg-user-dirs-update
success "User directories created"

# ─── 6. Fish config — update aliases ────────────────────────────
info "Updating Fish shell config..."

FISH_CONFIG="$HOME/.config/fish/config.fish"

# Check if fish config exists
if [[ ! -f "$FISH_CONFIG" ]]; then
  mkdir -p "$HOME/.config/fish"
  touch "$FISH_CONFIG"
  warn "No fish config found — created a fresh one"
fi

# Only append if not already there
if ! grep -q "zoxide" "$FISH_CONFIG"; then
  cat >>"$FISH_CONFIG" <<'FISH'

# ─── Better CLI tools ───────────────────────────────────────────
alias ls   'eza --icons'
alias ll   'eza -lah --icons --git'
alias la   'eza -a --icons'
alias lt   'eza --tree --icons --level=2'
alias du   'dust'
alias df   'duf'
alias ps   'procs'
alias help 'tldr'

# ─── Zoxide (smarter cd) ────────────────────────────────────────
zoxide init fish | source

# ─── Git delta (pretty diffs) ───────────────────────────────────
set -gx GIT_PAGER 'delta'
FISH
  success "Fish aliases updated"
else
  warn "Fish aliases already present — skipping"
fi

# ─── 7. Git delta config ────────────────────────────────────────
info "Configuring git-delta..."

git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.light false
git config --global delta.side-by-side true
git config --global delta.line-numbers true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default

success "git-delta configured"

# ─── 8. Hyprland keybinds — brightness, volume, media ──────────
info "Adding media/brightness/volume keybinds to Hyprland..."

HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"

if ! grep -q "XF86AudioRaiseVolume" "$HYPR_CONFIG"; then
  cat >>"$HYPR_CONFIG" <<'HYPR'

# ─── Media & System Keys ────────────────────────────────────────
# Volume
binde = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind  = , XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind  = , XF86AudioMicMute,     exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Brightness
binde = , XF86MonBrightnessUp,   exec, brightnessctl set +5%
binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Media keys
bind = , XF86AudioPlay,  exec, playerctl play-pause
bind = , XF86AudioNext,  exec, playerctl next
bind = , XF86AudioPrev,  exec, playerctl previous
bind = , XF86AudioStop,  exec, playerctl stop
HYPR
  success "Hyprland media keybinds added"
else
  warn "Hyprland media keybinds already present — skipping"
fi

# ─── 9. Reload Hyprland ─────────────────────────────────────────
if command -v hyprctl &>/dev/null; then
  info "Reloading Hyprland config..."
  hyprctl reload
  success "Hyprland reloaded"
fi

# ─── Done ───────────────────────────────────────────────────────
echo ""
echo "  ┌──────────────────────────────────────────────────┐"
echo "  │                  All done!                        │"
echo "  │                                                    │"
echo "  │  Next steps:                                       │"
echo "  │  • Log out and back in for Docker group to apply  │"
echo "  │  • Open a new Fish shell to use new aliases       │"
echo "  │  • Try: ll, lt, tldr git, duf, btop              │"
echo "  └──────────────────────────────────────────────────┘"
echo ""
