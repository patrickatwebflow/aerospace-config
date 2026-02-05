#!/usr/bin/env bash
set -euo pipefail

# Paths for mode configs and the "live" config inside the config folder
NORMAL="$HOME/.config/aerospace/aerospace.normal.toml"
SIDEBAR="$HOME/.config/aerospace/aerospace.sidebar.toml"
LIVE="$HOME/.config/aerospace/aerospace.toml"

OBSIDIAN_BUNDLE_ID="md.obsidian"

get_obsidian_win_id() {
  aerospace list-windows --all --format "%{window-id}%{tab}%{app-bundle-id}%{newline}" \
    | awk -F $'\t' -v bid="$OBSIDIAN_BUNDLE_ID" '$2==bid {print $1; exit}'
}

# readlink on the live file (which lives inside ~/.config/aerospace)
CURRENT="$(readlink "$LIVE" 2>/dev/null || true)"

if [ "$CURRENT" = "$SIDEBAR" ]; then
  # SIDEBAR -> NORMAL
  ln -sf "$NORMAL" "$LIVE"
  aerospace reload-config

  WIN_ID="$(get_obsidian_win_id || true)"
  if [ -n "${WIN_ID:-}" ]; then
    aerospace move-node-to-workspace B --window-id "$WIN_ID" --fail-if-noop || true
    aerospace layout tiling --window-id "$WIN_ID" || true
  fi
else
  # NORMAL -> SIDEBAR
  ln -sf "$SIDEBAR" "$LIVE"
  aerospace reload-config
fi

exit 0
