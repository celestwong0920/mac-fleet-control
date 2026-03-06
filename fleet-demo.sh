#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Mac Fleet Control — Visual Demo (for screenshots & promotion)
# Usage: bash fleet-demo.sh
# ═══════════════════════════════════════════════════════════════

# Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
C='\033[0;36m'
M='\033[0;35m'
W='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

clear

# ── Logo Banner ──
echo ""
echo -e "${C}    ╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${C}    ║${NC}                                                           ${C}║${NC}"
echo -e "${C}    ║${NC}   ${W}${BOLD}███╗   ███╗ █████╗  ██████╗${NC}                              ${C}║${NC}"
echo -e "${C}    ║${NC}   ${W}${BOLD}████╗ ████║██╔══██╗██╔════╝${NC}    ${G}Mac Fleet Control${NC}        ${C}║${NC}"
echo -e "${C}    ║${NC}   ${W}${BOLD}██╔████╔██║███████║██║${NC}         ${DIM}One command. Full control.${NC} ${C}║${NC}"
echo -e "${C}    ║${NC}   ${W}${BOLD}██║╚██╔╝██║██╔══██║██║${NC}         ${DIM}Any Mac. Any network.${NC}     ${C}║${NC}"
echo -e "${C}    ║${NC}   ${W}${BOLD}██║ ╚═╝ ██║██║  ██║╚██████╗${NC}                              ${C}║${NC}"
echo -e "${C}    ║${NC}   ${W}${BOLD}╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝${NC}                              ${C}║${NC}"
echo -e "${C}    ║${NC}                                                           ${C}║${NC}"
echo -e "${C}    ╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

sleep 0.3

# ── Tagline ──
echo -e "    ${Y}⚡${NC} ${BOLD}SSH · Browser · Mouse · Keyboard · Screenshots · VNC${NC}"
echo -e "    ${Y}⚡${NC} ${BOLD}Tailscale WireGuard E2EE · Zero-config · Self-healing${NC}"
echo ""

sleep 0.3

# ── Network Topology ──
echo -e "    ${C}───────────────── Network Topology ─────────────────${NC}"
echo ""

# ── Mode: --showcase uses demo data, default uses real fleet ──
SHOWCASE=false
[[ "$1" == "--showcase" ]] && SHOWCASE=true

if [ "$SHOWCASE" = true ]; then
  MASTER_NAME="MacBook-Pro"
  MASTER_IP="100.64.0.1"
  WORKER_LINES=(
    "Office-iMac-1|100.64.0.10|${G}● ONLINE${NC}"
    "Office-iMac-2|100.64.0.11|${G}● ONLINE${NC}"
    "Office-iMac-3|100.64.0.12|${G}● ONLINE${NC}"
    "Home-Mac-mini|100.64.0.20|${G}● ONLINE${NC}"
    "Studio-MacPro|100.64.0.30|${G}● ONLINE${NC}"
    "Lab-Mac-mini-1|100.64.0.40|${G}● ONLINE${NC}"
    "Lab-Mac-mini-2|100.64.0.41|${G}● ONLINE${NC}"
    "Remote-iMac|100.64.0.50|${Y}● SLEEP${NC}"
  )
else
  # Detect real machines from fleet registry
  FLEET_FILE="${FLEET_FILE:-$HOME/.fleet-machines.json}"
  MASTER_NAME=$(hostname | sed 's/\.local$//')
  MASTER_IP=$(/Applications/Tailscale.app/Contents/MacOS/Tailscale ip -4 2>/dev/null || tailscale ip -4 2>/dev/null || echo "100.x.x.x")
  WORKER_LINES=()

  if [ -f "$FLEET_FILE" ] && command -v python3 &>/dev/null; then
    MACHINES=$(python3 -c "
import json
with open('$FLEET_FILE') as f: d = json.load(f)
for m in d['machines']:
    print(m['name'] + '|' + m['user'] + '|' + m['ip'])
" 2>/dev/null)

    while IFS='|' read -r name user ip; do
      [ -z "$name" ] && continue
      if ssh -o ConnectTimeout=3 -o BatchMode=yes -o StrictHostKeyChecking=no -o LogLevel=ERROR "$user@$ip" "echo ok" </dev/null &>/dev/null 2>&1; then
        WORKER_LINES+=("$name|$ip|${G}● ONLINE${NC}")
      else
        WORKER_LINES+=("$name|$ip|${R}● OFFLINE${NC}")
      fi
    done <<< "$MACHINES"
  fi

  if [ ${#WORKER_LINES[@]} -eq 0 ]; then
    WORKER_LINES=(
      "Worker-1|100.x.x.x|${DIM}● no machines${NC}"
    )
  fi
fi

  # Master box
  echo -e "                      ${G}┌─────────────────────┐${NC}"
  echo -e "                      ${G}│${NC}  ${W}${BOLD}🖥  MASTER${NC}           ${G}│${NC}"
  printf "                      ${G}│${NC}  %-20s${G}│${NC}\n" "$MASTER_NAME"
  printf "                      ${G}│${NC}  ${DIM}%-20s${NC}${G}│${NC}\n" "$MASTER_IP"
  echo -e "                      ${G}└──────────┬──────────┘${NC}"
  echo -e "                                 ${G}│${NC}"
  echo -e "                      ${C}╔══════════╧══════════╗${NC}"
  echo -e "                      ${C}║${NC} ${Y}🔒 Tailscale E2EE${NC}    ${C}║${NC}"
  echo -e "                      ${C}║${NC} ${DIM}WireGuard Encrypted${NC}  ${C}║${NC}"
  echo -e "                      ${C}╚══════════╤══════════╝${NC}"
  echo -e "                                 ${G}│${NC}"

  # Draw workers in rows of 3
  TOTAL=${#WORKER_LINES[@]}
  ROW=0

  while [ $ROW -lt $TOTAL ]; do
    # How many in this row (max 3)
    LEFT=$((TOTAL - ROW))
    [ $LEFT -gt 3 ] && COUNT=3 || COUNT=$LEFT

    # Branch lines
    if [ $ROW -eq 0 ]; then
      if [ $COUNT -eq 1 ]; then
        echo -e "                                 ${G}│${NC}"
      elif [ $COUNT -eq 2 ]; then
        echo -e "                    ${G}┌────────────┴────────────┐${NC}"
        echo -e "                    ${G}│${NC}                          ${G}│${NC}"
      else
        echo -e "          ${G}┌──────────────────────┴──────────────────────┐${NC}"
        echo -e "          ${G}│${NC}                       ${G}│${NC}                       ${G}│${NC}"
      fi
    else
      if [ $COUNT -eq 1 ]; then
        echo -e "                                 ${G}│${NC}"
      elif [ $COUNT -eq 2 ]; then
        echo -e "                    ${G}│${NC}                          ${G}│${NC}"
      else
        echo -e "          ${G}│${NC}                       ${G}│${NC}                       ${G}│${NC}"
      fi
    fi

    # Parse this row's data
    NAMES=(); IPS=(); STATS=()
    for ((c=0; c<COUNT; c++)); do
      IDX=$((ROW + c))
      IFS='|' read -r _n _ip _s <<< "${WORKER_LINES[$IDX]}"
      NAMES+=("$_n"); IPS+=("$_ip"); STATS+=("$_s")
    done

    WN=$((ROW + 1))  # worker number start

    # Top border
    LINE=""
    for ((c=0; c<COUNT; c++)); do
      LINE+="  ${G}┌──────────────────────┐${NC}"
    done
    echo -e "$LINE"

    # Worker label
    LINE=""
    for ((c=0; c<COUNT; c++)); do
      NUM=$((WN + c))
      printf -v seg "  ${G}│${NC}  ${W}${BOLD}🖥  WORKER %-2s${NC}        ${G}│${NC}" "$NUM"
      LINE+="$seg"
    done
    echo -e "$LINE"

    # Name
    LINE=""
    for ((c=0; c<COUNT; c++)); do
      printf -v seg "  ${G}│${NC}  %-20s ${G}│${NC}" "${NAMES[$c]}"
      LINE+="$seg"
    done
    echo -e "$LINE"

    # IP
    LINE=""
    for ((c=0; c<COUNT; c++)); do
      printf -v seg "  ${G}│${NC}  ${DIM}%-20s${NC} ${G}│${NC}" "${IPS[$c]}"
      LINE+="$seg"
    done
    echo -e "$LINE"

    # Status
    LINE=""
    for ((c=0; c<COUNT; c++)); do
      LINE+="  ${G}│${NC}  ${STATS[$c]}              ${G}│${NC}"
    done
    echo -e "$LINE"

    # Bottom border
    LINE=""
    for ((c=0; c<COUNT; c++)); do
      LINE+="  ${G}└──────────────────────┘${NC}"
    done
    echo -e "$LINE"

    ROW=$((ROW + COUNT))
  done

echo ""

# ── Capabilities ──
echo -e "    ${C}───────────────── Capabilities ──────────────────${NC}"
echo ""
echo -e "    ${G}▸${NC} ${BOLD}fleet-ssh 1 \"uptime\"${NC}                  ${DIM}→ Run any command${NC}"
echo -e "    ${G}▸${NC} ${BOLD}fleet-ssh 1 \"cliclick c:500,500\"${NC}      ${DIM}→ Click mouse${NC}"
echo -e "    ${G}▸${NC} ${BOLD}fleet-ssh 1 \"cliclick t:'Hello'\"${NC}      ${DIM}→ Type text${NC}"
echo -e "    ${G}▸${NC} ${BOLD}fleet-ssh all \"softwareupdate -l\"${NC}     ${DIM}→ All machines${NC}"
echo -e "    ${G}▸${NC} ${BOLD}node ~/fleet-tools/browser-action.js${NC}  ${DIM}→ Browser automation${NC}"
echo -e "    ${G}▸${NC} ${BOLD}open vnc://user@100.x.x.x${NC}            ${DIM}→ Remote desktop${NC}"
echo ""
echo -e "    ${C}─────────────────────────────────────────────────${NC}"
echo ""
echo -e "    ${DIM}github.com/celestwong0920/mac-fleet-control${NC}"
echo -e "    ${DIM}MIT License · Free & Open Source${NC}"
echo ""
