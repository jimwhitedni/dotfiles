# dotfiles

macOS 開發環境配置，包含 shell、終端機、編輯器與開發工作流。

## 安裝

```bash
git clone <your-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
source ~/.zshrc
```

`install.sh` 會自動安裝以下工具並建立 symlinks：

| 工具 | 用途 |
|---|---|
| fzf | 模糊搜尋 |
| zoxide | 快速跳目錄（`z`） |
| zsh-autosuggestions | 指令自動建議 |
| eza | 現代化 `ls` |
| bat | 語法高亮 `cat` |
| ripgrep | 快速搜尋檔案內容 |
| fd | 快速搜尋檔案 |
| neovim | 編輯器 |
| tmux | 終端多工 |
| ghostty | 終端機 |
| JetBrainsMono Nerd Font | 字體 |

## 內容

```
~/dotfiles/
  .zshrc              → ~/.zshrc
  ghostty.config      → ~/.config/ghostty/config
  nvim/               → ~/.config/nvim (LazyVim)
  dev-start.sh        → dev 指令
  dev-status.sh       → ds 指令
  install.sh          → 安裝腳本
```

## Dev Session 管理

用 `dev` 快速建立 tmux 開發 session，每個 session 自帶三個 window：`nvim`、`serve`、`claude`。

### 用法

```bash
# 在當前目錄建立 session（名稱 = 目錄名）
dev

# 智慧解析：依序嘗試 tmux session → git worktree → ~/project/<name> → 路徑
dev <name>

# 指定 session 名稱與目錄
dev <name> <path>

# 列出可用的 sessions 和 worktrees
dev -l
```

### 解析順序

當執行 `dev <name>` 時，會依序嘗試：

1. **tmux session** — 已存在同名 session → 直接 attach
2. **git worktree** — 當前 repo 的 worktree 名稱匹配 → 用該路徑建立 session
3. **~/project/\<name\>** — 在 `~/project/` 下有同名目錄 → 用該路徑
4. **路徑** — 當作目錄路徑處理

### 範例

```bash
# 在當前目錄開 session
cd ~/project/my-app && dev

# 開 ~/project/one-ui
dev one-ui

# 開 worktree（在 git repo 目錄內執行）
cd ~/project/one-ui && dev firmware

# 指定名稱和路徑
dev side-project ~/code/side-project

# 傳入相對路徑
dev ../other-repo

# 查看可用選項
dev -l
```

### Session 狀態

```bash
# 查看所有 dev session 狀態
ds
```

## tmux 快捷鍵

| 指令 | 說明 |
|---|---|
| `ta` | attach 到最近的 session |
| `tl` | 列出所有 session |
| `tk <name>` | 關閉指定 session |
| `Ctrl+a s` | 切換 session |
| `Ctrl+a w` | 總覽 session + window |

## 搜尋工具

### `rgf` — 互動式內容搜尋

用 ripgrep + fzf 搜尋檔案內容，帶 bat 預覽，選中後直接在 nvim 開啟對應行。

```bash
rgf "pattern"
rgf -t ts "className"
```

### `ff` — 互動式檔案搜尋

用 fd + fzf 搜尋檔案名稱，帶 bat 預覽，選中後直接用 nvim 開啟。

```bash
ff
ff "component"
```

## 檔案列表 (eza)

| 指令 | 說明 |
|---|---|
| `ls` | 全部檔案（含隱藏、icon） |
| `ll` | 全部檔案（長格式） |
| `ld` | 只列目錄 |
| `lf` | 只列檔案 |
| `lh` | 只列隱藏檔 |

## 其他

| 指令 | 說明 |
|---|---|
| `z <dir>` | 快速跳到常用目錄 (zoxide) |
| `awake` | 防止 Mac 睡眠（開會用） |
| `sleep-ok` | 恢復正常省電 |

## 終端機 (Ghostty)

- 字體：JetBrainsMono Nerd Font 14pt
- 主題：自動跟隨系統深淺色（Light: Apple System Colors / Dark: Dracula）
- 分割：`Cmd+D` 水平、`Cmd+Shift+D` 垂直
- 切換分割：`Cmd+Alt+方向鍵`
- 跳 prompt：`Cmd+Shift+上/下`

## 編輯器 (Neovim)

基於 [LazyVim](https://www.lazyvim.org/)，首次開啟會自動安裝插件。配置在 `nvim/` 目錄。
