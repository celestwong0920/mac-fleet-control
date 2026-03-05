# Fleet Control — CLI Patterns Reference

Common CLI patterns for remote Mac operations. All use `fleet-exec.sh <machine>`.

## Software Management

```bash
# Install via Homebrew
fleet-exec.sh 1 "brew install <package>"
fleet-exec.sh 1 "brew install --cask <app>"
fleet-exec.sh all "brew update && brew upgrade"

# Install via npm
fleet-exec.sh 1 "npm install -g <package>"

# Install via pip
fleet-exec.sh 1 "pip3 install <package>"

# Check installed
fleet-exec.sh 1 "brew list"
fleet-exec.sh 1 "which <command>"
```

## Service Management (launchd)

```bash
# List services
fleet-exec.sh 1 "launchctl list | grep <pattern>"

# Start/stop/restart
fleet-exec.sh 1 "launchctl load ~/Library/LaunchAgents/<plist>"
fleet-exec.sh 1 "launchctl unload ~/Library/LaunchAgents/<plist>"
fleet-exec.sh 1 "launchctl kickstart -k gui/\$(id -u)/<label>"

# Check if running
fleet-exec.sh 1 "launchctl print gui/\$(id -u)/<label> 2>&1 | head -5"
```

## File Operations

```bash
# Read files
fleet-exec.sh 1 "cat /path/to/file"
fleet-exec.sh 1 "ls -la /path/to/dir"
fleet-exec.sh 1 "find /path -name '*.log' -mtime -1"

# Edit files
fleet-exec.sh 1 "echo 'content' > /path/to/file"
fleet-exec.sh 1 "sed -i '' 's/old/new/g' /path/to/file"

# Transfer files (use scp directly, not fleet-exec)
# Master → Worker:
scp /local/file user@<ip>:/remote/path
# Worker → Master:
scp user@<ip>:/remote/file /local/path
# Worker → Worker (via master):
scp user1@ip1:/file /tmp/transfer && scp /tmp/transfer user2@ip2:/file
```

## App Management

```bash
# Open app
fleet-exec.sh 1 "open -a 'Safari'"
fleet-exec.sh 1 "open -a 'Google Chrome'"
fleet-exec.sh 1 "open https://example.com"

# Kill app
fleet-exec.sh 1 "killall Safari"
fleet-exec.sh 1 "pkill -f 'process-name'"

# List running apps
fleet-exec.sh 1 "ps aux | grep -i <app>"

# Check app installed
fleet-exec.sh 1 "ls /Applications/ | grep -i <app>"
fleet-exec.sh 1 "mdfind 'kMDItemKind == Application' | grep -i <app>"
```

## System Configuration

```bash
# Read defaults
fleet-exec.sh 1 "defaults read <domain> <key>"

# Write defaults
fleet-exec.sh 1 "defaults write <domain> <key> -<type> <value>"

# Power management
fleet-exec.sh 1 "pmset -g"
fleet-exec.sh 1 "sudo pmset -a sleep 0"

# Network info
fleet-exec.sh 1 "ifconfig | grep inet"
fleet-exec.sh 1 "networksetup -getairportnetwork en0"
fleet-exec.sh 1 "curl -s ifconfig.me"

# Disk info
fleet-exec.sh 1 "df -h"
fleet-exec.sh 1 "du -sh /path"

# System info
fleet-exec.sh 1 "system_profiler SPHardwareDataType"
fleet-exec.sh 1 "sw_vers"
fleet-exec.sh 1 "sysctl -n machdep.cpu.brand_string"
fleet-exec.sh 1 "sysctl -n hw.memsize | awk '{print \$1/1073741824\" GB\"}'"
```

## User & Permission Management

```bash
# Current user
fleet-exec.sh 1 "whoami"
fleet-exec.sh 1 "id"

# SSH status
fleet-exec.sh 1 "sudo systemsetup -getremotelogin"

# Tailscale status
fleet-exec.sh 1 "tailscale status"
fleet-exec.sh 1 "tailscale ip -4"
```

## Git Operations

```bash
fleet-exec.sh 1 "cd ~/repo && git pull"
fleet-exec.sh 1 "cd ~/repo && git status"
fleet-exec.sh all "cd ~/my-project && git pull"
```

## Process Management

```bash
# List processes
fleet-exec.sh 1 "ps aux | head -20"
fleet-exec.sh 1 "top -l 1 -n 10"

# Kill process
fleet-exec.sh 1 "kill <pid>"
fleet-exec.sh 1 "killall <name>"

# Resource usage
fleet-exec.sh 1 "vm_stat | head -5"
fleet-exec.sh 1 "iostat -c 3"
```

## Fleet-Wide Batch Operations

```bash
# Update all machines
fleet-exec.sh all "cd ~/mac-fleet-control && git pull"

# Check health
fleet-exec.sh all "hostname && uptime && tailscale ip -4"

# Install everywhere
fleet-exec.sh all "brew install <package>"

# Restart service everywhere
fleet-exec.sh all "launchctl kickstart -k gui/\$(id -u)/<label>"
```
