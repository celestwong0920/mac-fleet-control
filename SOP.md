# Mac Fleet Control — SOP (Standard Operating Procedure)

## 概述

一条命令让任何 Mac 远程完全控制另一台 Mac。

## 架构

```
Master (控制方)          Worker (被控方)
┌─────────────┐         ┌─────────────┐
│ fleet-ssh   │ ──SSH──→ │ cliclick    │ 鼠标/键盘
│ (命令工具)   │ ──SSH──→ │ playwright  │ 浏览器自动化
│             │ ──SSH──→ │ fleet-tools │ 截图/脚本
│             │ ──VNC──→ │ Screen Share│ 远程桌面
└─────────────┘         └─────────────┘
        ↑                       ↑
        └── Tailscale VPN ──────┘
```

## 快速开始

### 前提条件（两台机器都要）

1. **安装 Tailscale** — App Store 或 `brew install --cask tailscale`
2. **打开 Tailscale** — 登录同一个账号，确保连接成功
3. **安装 Homebrew** — 如果没有: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
4. **安装 Node.js** — 如果没有: `brew install node`

### Master 机器（控制方）

```bash
git clone https://github.com/celestwong0920/mac-fleet-control.git ~/mac-fleet-control
cd ~/mac-fleet-control
bash master-setup.sh
```

完成后会显示你的 Tailscale IP 和用户名，例如 `john@100.x.x.x`。

### Worker 机器（被控方）

```bash
git clone https://github.com/celestwong0920/mac-fleet-control.git ~/mac-fleet-control
cd ~/mac-fleet-control
bash worker-setup.sh --master <master的user>@<master的tailscale-ip>
```

例如:
```bash
bash worker-setup.sh --master john@100.x.x.x
```

多个 master:
```bash
bash worker-setup.sh --master john@100.x.x.x --master jane@100.y.y.y
```

脚本会自动:
- ✅ 检查 Tailscale 连接
- ✅ 开启 SSH
- ✅ 安装 cliclick + Playwright
- ✅ 创建 fleet-tools 脚本
- ✅ 配置 SSH 免密码登录（双向）
- ✅ 自动注册到 master 的 fleet

### Worker 手动权限（一次性）

脚本跑完后，在 worker 上手动设置（只需一次，重启不丢）:

**1. Screen Sharing**
> System Settings → General → Sharing → Screen Sharing → ON

**2. Screen Recording**
> System Settings → Privacy & Security → Screen & System Audio Recording
> → 点 + → Cmd+Shift+G → 加入:
> - `/usr/libexec/sshd-keygen-wrapper`
> - `/opt/homebrew/opt/tailscale/bin/tailscaled`

**3. Accessibility**
> System Settings → Privacy & Security → Accessibility
> → 点 + → Cmd+Shift+G → 加入:
> - `/usr/libexec/sshd-keygen-wrapper`
> - `/opt/homebrew/opt/tailscale/bin/tailscaled`

## 使用 fleet-ssh

```bash
# 查看所有机器
fleet-ssh list

# 用编号执行命令
fleet-ssh 1 "hostname && uptime"

# 用名字执行命令
fleet-ssh seas-imac "hostname"

# 所有机器执行
fleet-ssh all "uptime"

# Ping 测速
fleet-ssh ping

# 交互式 SSH
fleet-ssh shell 1

# 手动添加机器
fleet-ssh add <name> <user> <ip>

# 删除机器
fleet-ssh remove <name>
```

## 远程控制能力

### 命令执行
```bash
fleet-ssh 1 "any shell command"
```

### 鼠标/键盘控制
```bash
# 移动鼠标
fleet-ssh 1 "cliclick m:500,500"

# 点击
fleet-ssh 1 "cliclick c:500,500"

# 双击
fleet-ssh 1 "cliclick dc:500,500"

# 打字
fleet-ssh 1 "cliclick t:'hello world'"

# 组合键 (Cmd+A)
fleet-ssh 1 "cliclick kp:command-a"
```

### 截图
```bash
# 屏幕截图
fleet-ssh 1 "bash ~/fleet-tools/capture-screen.sh /tmp/screen.png"

# 拉回本地查看
scp user@ip:/tmp/screen.png ~/Desktop/
```

### 网页截图
```bash
fleet-ssh 1 "node ~/fleet-tools/screenshot-url.js https://google.com /tmp/google.png"
```

### VNC 远程桌面
```bash
# 在 master 打开远程桌面
open vnc://user@<tailscale-ip>
```

## 一台机器同时做 Master 和 Worker

完全支持。分别跑两个脚本:
```bash
bash master-setup.sh                                    # 作为 master
bash worker-setup.sh --master other-user@other-ip       # 作为 worker
```

## 常见问题

### fleet-ssh list 显示 timeout
SSH key 没配好。在 master 上跑:
```bash
ssh-copy-id user@<worker-tailscale-ip>
```

### 截图失败
Screen Recording 权限没加 `sshd-keygen-wrapper`。见上方手动权限。

### cliclick 不动
Accessibility 权限没加 `sshd-keygen-wrapper`。见上方手动权限。

### Tailscale 显示 offline
在 worker 上打开 Tailscale app，确保连接状态是绿色。

### 重复跑 worker-setup.sh
安全的，脚本是幂等设计，不会覆盖或删除任何已有配置。
