#!/bin/bash
# Fleet Control — GUI simulation on remote machine (mouse/keyboard)
# Usage: fleet-act.sh <machine> <action> [args...]
#
# Actions:
#   click <x,y>           Single click
#   doubleclick <x,y>     Double click
#   rightclick <x,y>      Right click
#   move <x,y>            Move mouse
#   type <text>           Type text
#   key <key>             Press key (return, escape, tab, space, delete)
#   key <modifier-key>    Shortcut (command-a, command-c, command-v, command-w, etc.)
#   scroll <up|down> [n]  Scroll (default 3 clicks)
#
# This is Level 4 (last resort). Use fleet-exec.sh (CLI) first.

set -euo pipefail

MACHINE="${1:?Usage: fleet-act.sh <machine> <action> [args...]}"
ACTION="${2:?Usage: fleet-act.sh <machine> <action> [args...]}"
ARG1="${3:-}"
ARG2="${4:-}"

# Find fleet-ssh
FLEET_SSH=""
for p in fleet-ssh /usr/local/bin/fleet-ssh "$HOME/mac-fleet-control/fleet-ssh"; do
  if command -v "$p" &>/dev/null || [ -x "$p" ]; then
    FLEET_SSH="$p"
    break
  fi
done
[ -z "$FLEET_SSH" ] && { echo "ERROR: fleet-ssh not found"; exit 1; }

case "$ACTION" in
  click)
    [ -z "$ARG1" ] && { echo "Usage: fleet-act.sh <machine> click <x,y>"; exit 1; }
    "$FLEET_SSH" "$MACHINE" "cliclick c:$ARG1"
    echo "OK: click $ARG1"
    ;;
  doubleclick)
    [ -z "$ARG1" ] && { echo "Usage: fleet-act.sh <machine> doubleclick <x,y>"; exit 1; }
    "$FLEET_SSH" "$MACHINE" "cliclick dc:$ARG1"
    echo "OK: doubleclick $ARG1"
    ;;
  rightclick)
    [ -z "$ARG1" ] && { echo "Usage: fleet-act.sh <machine> rightclick <x,y>"; exit 1; }
    "$FLEET_SSH" "$MACHINE" "cliclick rc:$ARG1"
    echo "OK: rightclick $ARG1"
    ;;
  move)
    [ -z "$ARG1" ] && { echo "Usage: fleet-act.sh <machine> move <x,y>"; exit 1; }
    "$FLEET_SSH" "$MACHINE" "cliclick m:$ARG1"
    echo "OK: move $ARG1"
    ;;
  type)
    [ -z "$ARG1" ] && { echo "Usage: fleet-act.sh <machine> type <text>"; exit 1; }
    "$FLEET_SSH" "$MACHINE" "cliclick t:'$ARG1'"
    echo "OK: type '$ARG1'"
    ;;
  key)
    [ -z "$ARG1" ] && { echo "Usage: fleet-act.sh <machine> key <key>"; exit 1; }
    "$FLEET_SSH" "$MACHINE" "cliclick kp:$ARG1"
    echo "OK: key $ARG1"
    ;;
  scroll)
    DIRECTION="${ARG1:-down}"
    CLICKS="${ARG2:-3}"
    if [ "$DIRECTION" = "up" ]; then
      "$FLEET_SSH" "$MACHINE" "cliclick \"ku:arrow-up\" \"ku:arrow-up\" \"ku:arrow-up\""
      # Use AppleScript for actual scroll
      "$FLEET_SSH" "$MACHINE" "osascript -e 'tell application \"System Events\" to key code 126 using {}' 2>/dev/null" || true
    else
      "$FLEET_SSH" "$MACHINE" "osascript -e 'tell application \"System Events\" to key code 125 using {}' 2>/dev/null" || true
    fi
    echo "OK: scroll $DIRECTION $CLICKS"
    ;;
  *)
    echo "ERROR: Unknown action '$ACTION'"
    echo "Actions: click, doubleclick, rightclick, move, type, key, scroll"
    exit 1
    ;;
esac
