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

用 `dev` 建立 tmux 開發 session。**一個 session = 一個 worktree = 一個 window = 一個 pane。**

偶爾要 nvim 或 dev server 時臨時開一格就好（`C-a -` 往下、`C-a |` 往右，兩者都會繼承
worktree 目錄），不預先配置。dev server 本來就是單例 —— 整台機器只有一個、綁死一個
port —— 所以每個 worktree 配一格在結構上跑不起來。

### 用法

```bash
# 在當前目錄建立 session（名稱 = 目錄名）
dev

# 智慧解析：tmux session → 當前 repo 的 worktree → 任何 hub 的 worktree → ~/project/<name> → 路徑
dev <name>

# 指定 session 名稱與目錄
dev <name> <path>

# 建立但不進去（cc-monitor 按 N 時走這條）
dev -d <name>

# worktree 生命週期：誰有 Claude、誰只剩空殼、誰已經 merge
dev -l

# 互動式清掉做完的 worktree
dev --reap
```

### 解析順序

當執行 `dev <name>` 時，會依序嘗試：

1. **tmux session** — 已存在同名 session → 直接進去（在 tmux 裡用 `switch-client`）
2. **當前 repo 的 worktree** — 人在 repo 裡時優先，比較符合直覺
3. **任何 hub 的 worktree** — 不需要先 `cd` 進去。hub 的判斷依據是 `.git/worktrees`
   存在與否，所以只是名字前綴相同的獨立 clone（例如 `one-ui-kb`）不會被誤判
4. **~/project/\<name\>** — 在 `~/project/` 下有同名目錄 → 用該路徑
5. **路徑** — 當作目錄路徑處理

比對一律用 tmux 的 `=` 精確前綴。沒有它 `dev layout` 會因為前綴比對而跑去 attach
`layout-align`。

### worktree 的 .claude

建立 session 時會把 hub 的 `.claude/knowledge` 與 `.claude/skills` symlink 進 worktree，
但 `settings.local.json` 是**複製**的。

那個檔案有 259 條授權規則，而 Claude 每次授權都整檔重寫 —— 全部共用同一份的話，兩個
並行 session 同時授權就是 read-modify-write 競態，後寫的贏，另一個的授權靜默消失，
之後又被重複詢問。

同時會把 `.claude` 寫進 `$GIT_COMMON_DIR/info/exclude`。專案的 `.gitignore` 寫的是
`.claude/`，帶尾斜線只 match 目錄 —— worktree 裡它是 symlink，git 視為檔案，所以沒被
忽略。linked worktree 共用同一份 exclude，寫一次全部生效。

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

### 看目前狀態

| 看什麼 | 用什麼 |
|---|---|
| Claude session 在做什麼、誰在等你 | `cc-monitor` |
| worktree 還活著嗎、該不該收掉 | `dev -l` |
| 快捷鍵速查 | `ds` |

`cc-monitor` 是主控台 —— 左邊列出所有 Claude session、右邊是選中那個的即時畫面，
`tab` 跳到下一個在等你的，`i` 直接回覆，`N` 從 worktree 清單開始新工作。

## tmux 快捷鍵

| 指令 | 說明 |
|---|---|
| `ta` | attach 到最近的 session |
| `tl` | 列出所有 session |
| `tk <name>` | 關閉指定 session |
| `Ctrl+a s` | 切換 session |
| `Ctrl+a w` | 總覽 session + window |
| `Ctrl+a -` | 往下開 pane（繼承 worktree 目錄）|
| `Ctrl+a \|` | 往右開 pane |

### Session 持久化

用 [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) +
[continuum](https://github.com/tmux-plugins/tmux-continuum)，每 15 分鐘自動存檔，
tmux server 啟動時自動還原。

還原的是 session、window、cwd 與版面，**不是 Claude 的對話**。Claude 不在 resurrect
的 process 白名單裡，而且本來就是手動起的 —— 所以重開機後你會得到停在正確目錄的 shell，
自己決定要不要 `claude --continue` 接回去。

刻意沒開 `@resurrect-capture-pane-contents`：還原出來會是「上次 Claude 畫面的靜態快照」
貼在一個沒有 Claude 的 shell 裡，看起來像還在跑但其實不是。乾淨的 shell 比會騙人的截圖好。

| 指令 | 說明 |
|---|---|
| `Ctrl+a C-s` | 立即存檔 |
| `Ctrl+a C-r` | 立即還原 |

跑完 `dev --reap` 之後記得 `Ctrl+a C-s` 存一次，否則下次還原會把剛刪掉的 worktree
的 session 復活回來。

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

第一個分頁開啟時直接進 cc-monitor（`initial-command`，只作用於第一個 surface，
`cmd+t` 開的新分頁仍是普通 shell）。它同時會 `tmux start-server` —— continuum 的
自動還原掛在 tmux server 啟動時，而 cc-monitor 自己不會啟動 server，所以重開機後
需要有人去碰一下 tmux，session 才會回來。

按 `q` 離開 cc-monitor 不會關掉分頁，會落回一個普通 shell。

- 字體：JetBrainsMono Nerd Font Mono 14pt
- 主題：自動跟隨系統深淺色（Light: Apple System Colors / Dark: Dracula）
- 分割：`Cmd+D` 水平、`Cmd+Shift+D` 垂直
- 切換分割：`Cmd+Alt+方向鍵`
- 跳 prompt：`Cmd+Shift+上/下`

## 編輯器 (Neovim)

基於 [LazyVim](https://www.lazyvim.org/)，首次開啟會自動安裝插件。配置在 `nvim/` 目錄。
