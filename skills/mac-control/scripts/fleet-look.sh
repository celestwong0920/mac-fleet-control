#!/bin/bash
# Fleet Control — Screenshot remote machine's screen
# Usage: fleet-look.sh <machine> [output.png]
#
# Takes a screenshot via SSH, copies it to local /tmp, prints local path.
# Use with the `image` tool to analyze what's on screen.

set -euo pipefail

MACHINE="${1:?Usage: fleet-look.sh <machine> [output.png]}"
LOCAL_OUTPUT="${2:-/tmp/fleet-look-$(date +%s).png}"
REMOTE_PATH="/tmp/fleet-screen-$(date +%s).png"

# Find fleet-ssh and resolve machine
FLEET_SSH=""
for p in fleet-ssh /usr/local/bin/fleet-ssh "$HOME/mac-fleet-control/fleet-ssh"; do
  if command -v "$p" &>/dev/null || [ -x "$p" ]; then
    FLEET_SSH="$p"
    break
  fi
done
[ -z "$FLEET_SSH" ] && { echo "ERROR: fleet-ssh not found"; exit 1; }

# Take screenshot on remote
"$FLEET_SSH" "$MACHINE" "bash ~/fleet-tools/capture-screen.sh '$REMOTE_PATH'" >/dev/null 2>&1

# Resolve machine user@ip for scp
FLEET_FILE="${HOME}/.fleet-machines.json"
REMOTE_TARGET=$(python3 -c "
import json, sys
with open('$FLEET_FILE') as f:
    d = json.load(f)
machines = d.get('machines', [])
target = '$MACHINE'
# By number
try:
    idx = int(target) - 1
    if 0 <= idx < len(machines):
        m = machines[idx]
        print(f\"{m['user']}@{m['ip']}\")
        sys.exit(0)
except ValueError:
    pass
# By name
for m in machines:
    if target.lower() in m.get('name', '').lower():
        print(f\"{m['user']}@{m['ip']}\")
        sys.exit(0)
sys.exit(1)
" 2>/dev/null)

# Copy to local
scp -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o LogLevel=ERROR \
    "$REMOTE_TARGET:$REMOTE_PATH" "$LOCAL_OUTPUT" 2>/dev/null

# Cleanup remote
"$FLEET_SSH" "$MACHINE" "rm -f '$REMOTE_PATH'" >/dev/null 2>&1 || true

echo "$LOCAL_OUTPUT"
