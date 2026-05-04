#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║                  Dotfiles Install Script                     ║
# ║         Run this on any fresh Arch + Hyprland install        ║
# ║         curl -o install.sh <your-raw-github-url>            ║
# ║         bash install.sh                                      ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

GITHUB_USERNAME="YOUR_USERNAME" # ← change this before pushing
DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/$GITHUB_USERNAME/dotfiles.git"

# ─── Colours ────────────────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[DONE]${NC}  $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() {
  echo -e "${RED}[ERR]${NC}   $1"
  exit 1
}
header() { echo -e "\n${BOLD}── $1 ──${NC}"; }

echo ""
echo "  ┌──────────────────────────────────────────────────┐"
echo "  │           Dotfiles — Fresh Machine Setup          │"
echo "  └──────────────────────────────────────────────────┘"
echo ""

# ─── 1. System update ───────────────────────────────────────────
header "Updating system"
sudo pacman -Syu --noconfirm
success "System updated"

# ─── 2. Install base packages ───────────────────────────────────
header "Installing packages"
sudo pacman -S --needed --noconfirm \
  hyprland waybar wofi mako libnotify awww \
  kitty neovim git curl wget fish starship \
  thunar firefox grim slurp \
  xdg-desktop-portal-hyprland xdg-utils xdg-user-dirs \
  polkit-kde-agent qt5-wayland qt6-wayland \
  noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd \
  ripgrep fd lazygit btop fastfetch \
  eza zoxide tealdeer dust duf procs hyperfine \
  docker docker-compose git-delta httpie jq make \
  playerctl brightnessctl bat fzf

success "Packages installed"

# ─── 3. Install yay ─────────────────────────────────────────────
header "Installing yay"
if command -v yay &>/dev/null; then
  warn "yay already installed — skipping"
else
  sudo pacman -S --needed --noconfirm base-devel fakeroot debugedit
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si --noconfirm
  cd "$HOME"
  success "yay installed"
fi

# ─── 4. AUR packages ────────────────────────────────────────────
header "Installing AUR packages"
yay -S --needed --noconfirm \
  grimblast-git matugen-bin ttf-monaspace bandwhich sd
success "AUR packages installed"

# ─── 5. Clone dotfiles ──────────────────────────────────────────
header "Cloning dotfiles"
if [[ -d "$DOTFILES_DIR" ]]; then
  warn "Dotfiles already exist — pulling latest"
  git -C "$DOTFILES_DIR" pull
else
  git clone "$REPO_URL" "$DOTFILES_DIR"
  success "Dotfiles cloned"
fi

# ─── 6. Symlink configs ─────────────────────────────────────────
header "Linking configs"

link() {
  local src="$1"
  local dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    warn "Backing up $dst → $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  success "Linked $dst"
}

mkdir -p "$HOME/.config"
link "$DOTFILES_DIR/hypr" "$HOME/.config/hypr"
link "$DOTFILES_DIR/waybar" "$HOME/.config/waybar"
link "$DOTFILES_DIR/wofi" "$HOME/.config/wofi"
link "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
link "$DOTFILES_DIR/.config/matugen" "$HOME/.config/matugen"
link "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# ─── 7. Wallpaper script ────────────────────────────────────────
header "Setting up wallpaper script"
mkdir -p "$HOME/.config/scripts"
cp "$DOTFILES_DIR/scripts/wallpaper.sh" "$HOME/.config/scripts/wallpaper.sh"
chmod +x "$HOME/.config/scripts/wallpaper.sh"
mkdir -p "$HOME/Pictures/wallpapers"
success "Wallpaper script ready"

# ─── 8. Fish shell ──────────────────────────────────────────────
header "Setting up Fish"

if [[ "$SHELL" != "/usr/bin/fish" ]]; then
  chsh -s /usr/bin/fish
  success "Fish set as default shell"
fi

fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" 2>/dev/null
fish -c "fisher install patrickf1/fzf.fish jethrokuan/z jorgebucaran/autopair.fish" 2>/dev/null
success "Fish plugins installed"

mkdir -p "$HOME/.config/fish"
cat >"$HOME/.config/fish/config.fish" <<'FISH'
# ─── Starship ───────────────────────────────────────────
starship init fish | source

# ─── Zoxide ─────────────────────────────────────────────
zoxide init fish | source

# ─── Colours ────────────────────────────────────────────
set fish_color_autosuggestion brblack

# ─── Aliases ────────────────────────────────────────────
alias ls   'eza --icons'
alias ll   'eza -lah --icons --git'
alias la   'eza -a --icons'
alias lt   'eza --tree --icons --level=2'
alias cat  'bat'
alias du   'dust'
alias df   'duf'
alias ps   'procs'
alias help 'tldr'
alias vim  'nvim'
alias v    'nvim'
alias ga   'git add'
alias gc   'git commit'
alias gp   'git push'
alias gs   'git status'
alias gl   'git log --oneline --graph'
alias hypr-reload 'hyprctl reload'
alias wallpaper   '~/.config/scripts/wallpaper.sh'

# ─── Environment ────────────────────────────────────────
set -gx GIT_PAGER  'delta'
set -gx EDITOR     nvim
set -gx BROWSER    firefox

# ─── Greeting ───────────────────────────────────────────
function fish_greeting
    fastfetch
end
FISH
success "Fish config written"

# ─── 9. git-delta ───────────────────────────────────────────────
header "Configuring git-delta"
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.light false
git config --global delta.side-by-side true
git config --global delta.line-numbers true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default
success "git-delta configured"

# ─── 10. Docker ─────────────────────────────────────────────────
header "Setting up Docker"
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
success "Docker enabled"

# ─── 11. LazyVim ────────────────────────────────────────────────
header "Installing LazyVim"
if [[ -d "$HOME/.config/nvim" ]]; then
  warn "Neovim config already exists — skipping"
else
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
  success "LazyVim cloned — run nvim to bootstrap plugins"
fi

# ─── 12. tldr cache ─────────────────────────────────────────────
header "Updating tldr"
tldr --update
success "tldr cache updated"

# ─── 13. XDG dirs ───────────────────────────────────────────────
xdg-user-dirs-update

# ─── Done ───────────────────────────────────────────────────────
echo ""
echo "  ┌──────────────────────────────────────────────────┐"
echo "  │                   All done!                       │"
echo "  │                                                    │"
echo "  │  Remaining manual steps:                          │"
echo "  │  1. Add wallpapers to ~/Pictures/wallpapers       │"
echo "  │  2. Run nvim to finish LazyVim plugin install     │"
echo "  │  3. Log out and back in to start Hyprland         │"
echo "  └──────────────────────────────────────────────────┘"
echo ""
