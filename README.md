# Aerospace pinned sidebar workaround

This folder contains two Aerospace config variants plus helper scripts that let a single app act like a pinned sidebar. The setup works by symlinking `~/.config/aerospace/aerospace.toml` to either the NORMAL or SIDEBAR config and reloading Aerospace. In SIDEBAR mode, the app (default: Obsidian) is floated, a right-side gap is reserved, and the app follows the focused workspace.

## Files

- `aerospace.normal.toml`: Baseline config with standard gaps and no sidebar behavior.
- `aerospace.sidebar.toml`: Sidebar mode config. Adds a large right-side gap and uses a workspace-change hook to keep the sidebar app on the current workspace.
- `toggle-obsidian-sidebar-mode.sh`: Toggles the live config symlink and reloads Aerospace. If leaving sidebar mode, it moves the app back to workspace `B` and returns it to tiling.
- `follow-obsidian.sh`: Runs on workspace change in sidebar mode. Moves the app to the newly focused workspace (skips workspaces `M` and `1-4`).

## How it works

1. `~/.config/aerospace/aerospace.toml` is a symlink to either:
   - `~/.config/aerospace/aerospace.normal.toml` or
   - `~/.config/aerospace/aerospace.sidebar.toml`
2. `toggle-obsidian-sidebar-mode.sh` swaps the symlink and calls `aerospace reload-config`.
3. In sidebar mode, `exec-on-workspace-change` runs `follow-obsidian.sh` to move the sidebar app to the focused workspace.

## Usage

- Toggle modes (default keybinding): `alt-shift-o`
  - Defined in both TOML files as:
    - `alt-shift-o = 'exec-and-forget /bin/bash -lc "~/.config/aerospace/toggle-obsidian-sidebar-mode.sh"'`
- Toggle modes (manual):
  - `~/.config/aerospace/toggle-obsidian-sidebar-mode.sh`

## Customize the pinned app

Change the app bundle ID in all relevant places:

- `toggle-obsidian-sidebar-mode.sh`:
  - `OBSIDIAN_BUNDLE_ID="md.obsidian"`
- `follow-obsidian.sh`:
  - `OBSIDIAN_BUNDLE_ID="md.obsidian"`
- `aerospace.sidebar.toml`:
  - In `[[on-window-detected]]`, update `if.app-id = 'md.obsidian'`

Tip: Use `md.obsidian`-style bundle IDs for reliability. To find an app ID, run:

```bash
osascript -e 'id of app "Obsidian"'
```

## Customize the sidebar width

In `aerospace.sidebar.toml`, adjust the right-side gap:

- `outer.right = 460`

This value is the reserved width in pixels. Set it to whatever sidebar width you want.

## Customize where the app lives in NORMAL mode

When leaving sidebar mode, `toggle-obsidian-sidebar-mode.sh` moves the app to workspace `B`:

- `aerospace move-node-to-workspace B --window-id "$WIN_ID" --fail-if-noop`

Change `B` to another workspace if you want the app to land elsewhere.

## Customize which workspaces the app follows

`follow-obsidian.sh` skips moving the app on workspaces `M` and `1-4`:

```bash
case "$TARGET" in
  M|1|2|3|4) exit 0 ;;
esac
```

Edit that list to control where the sidebar follows.

## Install / setup

1. Copy the files into `~/.config/aerospace/`:
   - `aerospace.normal.toml`
   - `aerospace.sidebar.toml`
   - `toggle-obsidian-sidebar-mode.sh`
   - `follow-obsidian.sh`
2. Ensure the scripts are executable:

```bash
chmod +x ~/.config/aerospace/toggle-obsidian-sidebar-mode.sh \
  ~/.config/aerospace/follow-obsidian.sh
```

3. Point the live config at NORMAL to start:

```bash
ln -sf ~/.config/aerospace/aerospace.normal.toml ~/.config/aerospace/aerospace.toml
aerospace reload-config
```

## Notes

- Sidebar mode uses `layout floating` for the pinned app and reserves space using the right outer gap.
- The workspace follow logic relies on `AEROSPACE_FOCUSED_WORKSPACE`, provided by Aerospace.
- Both TOML files include the same keybindings; the only behavioral differences are the sidebar gap and follow hook.
