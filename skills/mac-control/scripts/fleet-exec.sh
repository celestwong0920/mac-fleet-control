#!/bin/bash
# Fleet Control — Execute command on remote machine
# Usage: fleet-exec.sh <machine> "<command>"
# Usage: fleet-exec.sh all "<command>"
#
# <machine> = number from fleet-ssh list, name, or "all"

set -euo pipefail

MACHINE="${1:?Usage: fleet-exec.sh <machine> \"<command>\"}"
CMD="${2:?Usage: fleet-exec.sh <machine> \"<command>\"}"

# Find fleet-ssh
FLEET_SSH=""
for p in fleet-ssh /usr/local/bin/fleet-ssh "$HOME/mac-fleet-control/fleet-ssh"; do
  if command -v "$p" &>/dev/null || [ -x "$p" ]; then
    FLEET_SSH="$p"
    break
  fi
done
[ -z "$FLEET_SSH" ] && { echo "ERROR: fleet-ssh not found"; exit 1; }

if [ "$MACHINE" = "all" ]; then
  "$FLEET_SSH" all "$CMD"
else
  "$FLEET_SSH" "$MACHINE" "$CMD"
fi
