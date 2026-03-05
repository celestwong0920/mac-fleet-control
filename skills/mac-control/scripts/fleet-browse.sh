#!/bin/bash
# Fleet Control — Browser automation on remote machine
# Usage: fleet-browse.sh <machine> screenshot <url> [output.png]
# Usage: fleet-browse.sh <machine> action '<json>'
#
# Runs headless Playwright on the remote machine. No GUI needed.

set -euo pipefail

MACHINE="${1:?Usage: fleet-browse.sh <machine> <screenshot|action> <args>}"
ACTION="${2:?Usage: fleet-browse.sh <machine> <screenshot|action> <args>}"

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
  screenshot)
    URL="${3:?Usage: fleet-browse.sh <machine> screenshot <url> [output.png]}"
    OUTPUT="${4:-/tmp/fleet-browse-screenshot.png}"
    "$FLEET_SSH" "$MACHINE" "node ~/fleet-tools/screenshot-url.js '$URL' '$OUTPUT'"
    echo "$OUTPUT"
    ;;
  action)
    JSON="${3:?Usage: fleet-browse.sh <machine> action '<json>'}"
    "$FLEET_SSH" "$MACHINE" "node ~/fleet-tools/browser-action.js '$JSON'"
    ;;
  *)
    echo "ERROR: Unknown action '$ACTION'. Use 'screenshot' or 'action'."
    exit 1
    ;;
esac
