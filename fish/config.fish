# ─── Starship prompt ────────────────────────────────────
starship init fish | source

# ─── Autosuggestions colour (subtle grey) ───────────────
set fish_color_autosuggestion brblack

# ─── Useful aliases ─────────────────────────────────────
alias ls 'ls --color=auto'
alias ll 'ls -lah --color=auto'
alias la 'ls -A --color=auto'
alias vim nvim
alias v nvim
alias cat bat # needs: sudo pacman -S bat
alias grep 'grep --color=auto'
alias .. 'cd ..'
alias ... 'cd ../..'

# ─── Dev shortcuts ──────────────────────────────────────
alias ga 'git add'
alias gc 'git commit'
alias gp 'git push'
alias gs 'git status'
alias gl 'git log --oneline --graph'

# ─── Hyprland helpers ───────────────────────────────────
alias hypr-reload 'hyprctl reload'
alias hypr-kill 'hyprctl kill'
alias wallpaper '~/.config/scripts/wallpaper.sh'

# ─── Environment ────────────────────────────────────────
set -gx EDITOR nvim
set -gx BROWSER firefox
set -gx XDG_CONFIG_HOME $HOME/.config

# ─── Greeting ───────────────────────────────────────────
function fish_greeting
    fastfetch
end

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
alias ipad='uxplay'
