#!/usr/bin/env bash
# ~/.config/scripts/wallpaper.sh
#
# Sets a random wallpaper with swww, then runs matugen to regenerate
# the colour scheme for Hyprland, Waybar, Wofi, Mako, and Kitty.
#
# Usage:
#   wallpaper.sh              — pick a random wallpaper
#   wallpaper.sh /path/to/img — use a specific image

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# ─── Pick wallpaper ─────────────────────────────────────────
if [[ -n "$1" && -f "$1" ]]; then
    WALLPAPER="$1"
else
    WALLPAPER=$(find "$WALLPAPER_DIR" \
        -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        | shuf -n1)
fi

if [[ -z "$WALLPAPER" ]]; then
    notify-send "Wallpaper" "No wallpapers found in $WALLPAPER_DIR" --urgency=critical
    exit 1
fi

# ─── Set wallpaper with swww ────────────────────────────────
# Pick a random transition for variety
TRANSITIONS=(fade grow outer wave wipe)
TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}

awww img "$WALLPAPER" \
    --transition-type "$TRANSITION" \
    --transition-duration 1.2 \
    --transition-fps 60

# ─── Run matugen to regenerate colours ──────────────────────
matugen image "$WALLPAPER"

# ─── Reload apps that need a restart to pick up new colours ─

# Reload Waybar
pkill -SIGUSR2 waybar 2>/dev/null || {
    pkill waybar 2>/dev/null
    sleep 0.3
    waybar &
}

# Reload Mako
pkill mako 2>/dev/null
sleep 0.2
mako &

# Hyprland picks up colors.conf on next window open, but we can
# force a reload of the config for borders to update immediately
hyprctl reload &>/dev/null

# Notify the user
WALLPAPER_NAME=$(basename "$WALLPAPER")
notify-send "Wallpaper" "🎨 Theme updated from $WALLPAPER_NAME" --expire-time=3000
