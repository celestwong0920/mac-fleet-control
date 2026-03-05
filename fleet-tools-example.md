# Fleet Tools 使用示例

## 从 Master 远程操作 Worker

### 1. 远程网页截图
```bash
# 截图任意网页
fleet-ssh 1 "cd ~/fleet-tools && node screenshot-url.js https://google.com /tmp/google.png"

# 把截图拉回 master
scp user@100.x.x.x:/tmp/google.png ~/Desktop/
```

### 2. 远程浏览器自动化
```bash
# 打开网页 → 填表 → 点击 → 截图
fleet-ssh 1 'cd ~/fleet-tools && node browser-action.js '"'"'{"url":"https://google.com","actions":[{"type":"type","selector":"textarea[name=q]","text":"hello world"},{"type":"screenshot","path":"/tmp/search.png"}]}'"'"''
```

### 3. 远程鼠标操作（需 Accessibility 权限）
```bash
# 移动鼠标到坐标
fleet-ssh 1 "cliclick m:500,500"

# 点击
fleet-ssh 1 "cliclick c:500,500"

# 双击
fleet-ssh 1 "cliclick dc:500,500"

# 输入文字
fleet-ssh 1 "cliclick t:'Hello World'"

# 按键
fleet-ssh 1 "cliclick kp:return"

# 组合键 (Cmd+A)
fleet-ssh 1 "cliclick kd:cmd a ku:cmd"
```

### 4. 远程屏幕截图（需 Screen Recording 权限）
```bash
fleet-ssh 1 "bash ~/fleet-tools/capture-screen.sh /tmp/screen.png"
scp user@100.x.x.x:/tmp/screen.png ~/Desktop/
```

### 5. VNC 远程桌面（需 Screen Sharing 开启）
```bash
# 从 master 打开远程桌面
open vnc://100.x.x.x
```

### 6. 批量操作
```bash
# 所有机器更新代码
fleet-ssh all "cd ~/my-project && git pull"

# 所有机器检查磁盘
fleet-ssh all "df -h /"

# 所有机器安装软件
fleet-ssh all "brew install htop"
```
