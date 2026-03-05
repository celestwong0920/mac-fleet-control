# Fleet Control — GUI Patterns Reference

GUI simulation patterns using fleet-look.sh + fleet-act.sh.
**Only use when CLI cannot solve the task.**

## General GUI Loop

```
1. fleet-look.sh <machine>           → get screenshot path
2. image tool: analyze screenshot    → identify what's on screen
3. fleet-act.sh <machine> <action>   → perform action
4. fleet-look.sh <machine>           → verify result
5. Repeat if needed
```

## Token Optimization

- **Plan multiple actions from one screenshot** before taking another
- **Use CLI alternatives first**: `open -a`, `osascript`, `defaults write`
- **Know common coordinates**: menu bar ~top 25px, dock ~bottom 70px
- **Use keyboard shortcuts** over mouse clicks when possible

## Common GUI Scenarios

### Click Allow/Deny Dialog
```bash
# First try CLI (AppleScript)
fleet-exec.sh 1 "osascript -e 'tell app \"System Events\" to click button \"Allow\" of window 1 of process \"SecurityAgent\"'"

# If CLI fails, use vision loop
fleet-look.sh 1                          # screenshot
# → analyze, find "Allow" button coords
fleet-act.sh 1 click <x>,<y>            # click Allow
```

### Open System Settings Pane
```bash
# CLI (preferred)
fleet-exec.sh 1 "open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'"

# Common panes:
# Privacy_Accessibility
# Privacy_AllFiles
# Privacy_ScreenCapture
# Privacy_Camera
# Privacy_Microphone
```

### Navigate Finder
```bash
# CLI (preferred)
fleet-exec.sh 1 "open /path/to/folder"
fleet-exec.sh 1 "open -R /path/to/file"   # reveal in Finder

# GUI fallback
fleet-act.sh 1 key command-shift-g         # Go to Folder
fleet-act.sh 1 type "/path/to/folder"
fleet-act.sh 1 key return
```

### Fill Form in GUI App
```bash
# Tab between fields + type
fleet-act.sh 1 click <x>,<y>              # click first field
fleet-act.sh 1 type "value1"
fleet-act.sh 1 key tab                     # next field
fleet-act.sh 1 type "value2"
fleet-act.sh 1 key tab
fleet-act.sh 1 type "value3"
fleet-act.sh 1 key return                  # submit
```

### Handle Popup/Notification
```bash
# Try AppleScript first
fleet-exec.sh 1 "osascript -e 'tell app \"System Events\" to click button \"OK\" of window 1 of process \"UserNotificationCenter\"'"

# Or dismiss with Escape
fleet-act.sh 1 key escape
```

### Type Password in Dialog
```bash
# Type password + submit
fleet-act.sh 1 type "<password>"
fleet-act.sh 1 key return
```

### Select Menu Item
```bash
# CLI (preferred)
fleet-exec.sh 1 "osascript -e 'tell app \"System Events\" to tell process \"<App>\" to click menu item \"<Item>\" of menu \"<Menu>\" of menu bar 1'"

# GUI fallback: click menu bar
fleet-act.sh 1 click <menu-x>,11          # menu bar y ≈ 11
# wait for menu to open
fleet-act.sh 1 click <item-x>,<item-y>
```

### Drag and Drop
```bash
# cliclick drag syntax
fleet-exec.sh 1 "cliclick dd:<start-x>,<start-y> du:<end-x>,<end-y>"
```

## Keyboard Shortcut Reference

| Action | Command |
|--------|---------|
| Select All | `key command-a` |
| Copy | `key command-c` |
| Paste | `key command-v` |
| Cut | `key command-x` |
| Undo | `key command-z` |
| Save | `key command-s` |
| Close Window | `key command-w` |
| Quit App | `key command-q` |
| New Tab | `key command-t` |
| Find | `key command-f` |
| Switch App | `key command-tab` |
| Spotlight | `key command-space` |
| Screenshot | `key command-shift-3` |
| Go to Folder | `key command-shift-g` |
| Force Quit | `key command-option-escape` |
| Tab | `key tab` |
| Enter | `key return` |
| Escape | `key escape` |
| Delete | `key delete` |
| Arrow keys | `key arrow-up` / `arrow-down` / `arrow-left` / `arrow-right` |
