#!/usr/bin/env bash
set -euo pipefail

TARGET="${AEROSPACE_FOCUSED_WORKSPACE:-}"
[ -n "$TARGET" ] || exit 0

# Skip workspaces: M and 1-4
case "$TARGET" in
  M|1|2|3|4) exit 0 ;;
esac

OBSIDIAN_BUNDLE_ID="md.obsidian"

WIN_ID="$(
  aerospace list-windows --all --format "%{window-id}%{tab}%{app-bundle-id}%{newline}" \
  | awk -F $'\t' -v bid="$OBSIDIAN_BUNDLE_ID" '$2==bid {print $1; exit}'
)"
[ -n "${WIN_ID:-}" ] || exit 0

aerospace layout floating --window-id "$WIN_ID" || true
aerospace move-node-to-workspace "$TARGET" --window-id "$WIN_ID" --fail-if-noop || true
