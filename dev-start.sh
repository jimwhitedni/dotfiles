#!/bin/bash

# 用法：
#   dev                  → 在當前目錄建立 session（session 名稱 = 目錄名）
#   dev <name>           → 智慧解析：tmux session → git worktree → ~/project/<name> → 路徑
#   dev <name> <path>    → 指定 session 名稱與目錄
#   dev -l               → 列出可用的 sessions 和 worktree

PROJECT_DIR="$HOME/project"

# 取得 git 主倉庫路徑（如果在 git repo 中）
get_main_repo() {
  local toplevel
  toplevel=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  # 如果是 worktree，找到主倉庫
  local common_dir
  common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
  if [[ "$common_dir" == *"/worktrees/"* ]] || [[ "$common_dir" != ".git" && "$common_dir" != *"/.git" ]]; then
    # 從 common dir 推算主倉庫路徑
    echo "$(cd "$(dirname "$common_dir")" && pwd)"
  else
    echo "$toplevel"
  fi
}

# 從 worktree 清單中尋找匹配的路徑
find_worktree() {
  local repo="$1"
  local name="$2"
  local repo_basename
  repo_basename=$(basename "$repo")

  # 完全匹配 worktree 目錄名
  git -C "$repo" worktree list 2>/dev/null | while read -r wt_path _rest; do
    local wt_name
    wt_name=$(basename "$wt_path")
    if [ "$wt_name" = "$name" ] || [ "$wt_name" = "${repo_basename}-${name}" ]; then
      echo "$wt_path"
      return
    fi
  done
}

show_list() {
  echo "┌──────────────────────────────────────────┐"
  echo "│          Dev Sessions & Worktrees         │"
  echo "├──────────────────────────────────────────┤"

  # 現有 tmux sessions
  local has_sessions=false
  if tmux ls 2>/dev/null | head -1 > /dev/null 2>&1; then
    echo "│  tmux sessions:                          │"
    tmux ls -F '  #{session_name}' 2>/dev/null | while read -r name; do
      printf "│    %-38s│\n" "$name"
    done
    has_sessions=true
  fi

  # Git worktrees（如果在 git repo 中）
  local repo
  repo=$(get_main_repo 2>/dev/null)
  if [ -n "$repo" ]; then
    [ "$has_sessions" = true ] && echo "│                                          │"
    echo "│  git worktrees ($(basename "$repo")):"
    git -C "$repo" worktree list 2>/dev/null | while read -r wt_path branch _rest; do
      local wt_name
      wt_name=$(basename "$wt_path")
      printf "│    %-28s %s\n" "$wt_name" "$branch"
    done
  fi

  echo "└──────────────────────────────────────────┘"
  echo ""
  echo "用法："
  echo "  dev                 在當前目錄建立 session"
  echo "  dev <name>          智慧解析 session/worktree/project"
  echo "  dev <name> <path>   指定 session 名稱與目錄"
}

create_session() {
  local session="$1"
  local dir="$2"

  # sanitize session name（tmux 不允許 . 和 :）
  session=$(echo "$session" | tr './:' '---')

  # 如果 session 已存在，直接 attach
  tmux has-session -t "$session" 2>/dev/null && {
    tmux attach -t "$session"
    exit 0
  }

  # 建立新 session
  tmux new-session -d -s "$session" -c "$dir"
  tmux rename-window -t "$session:1" 'nvim'
  # serve (25%) | claude (75%) 左右分割
  tmux new-window -t "$session" -n 'work' -c "$dir"
  tmux split-window -h -t "$session:2" -c "$dir" -l 75%

  tmux attach -t "$session"
}

# === 主邏輯 ===

# dev -l → 列出清單
if [ "$1" = "-l" ] || [ "$1" = "--list" ]; then
  show_list
  exit 0
fi

# dev <name> <path> → 指定名稱與路徑
if [ -n "$2" ]; then
  DIR="$2"
  # 支援相對路徑
  [ "${DIR:0:1}" != "/" ] && DIR="$(cd "$DIR" 2>/dev/null && pwd)"
  if [ -z "$DIR" ] || [ ! -d "$DIR" ]; then
    echo "目錄不存在: $2"
    exit 1
  fi
  create_session "$1" "$DIR"
  exit 0
fi

# dev（無參數）→ 當前目錄
if [ -z "$1" ]; then
  DIR=$(pwd)
  SESSION=$(basename "$DIR")
  create_session "$SESSION" "$DIR"
  exit 0
fi

SESSION="$1"

# 1. 檢查是否有同名的 tmux session
tmux has-session -t "$SESSION" 2>/dev/null && {
  tmux attach -t "$SESSION"
  exit 0
}

# 2. 檢查當前 git repo 的 worktree
REPO=$(get_main_repo 2>/dev/null)
if [ -n "$REPO" ]; then
  # 主倉庫本身
  REPO_NAME=$(basename "$REPO")
  if [ "$SESSION" = "main" ] || [ "$SESSION" = "$REPO_NAME" ]; then
    create_session "$SESSION" "$REPO"
    exit 0
  fi

  # 其他 worktree
  WT_DIR=$(find_worktree "$REPO" "$SESSION")
  if [ -n "$WT_DIR" ] && [ -d "$WT_DIR" ]; then
    create_session "$SESSION" "$WT_DIR"
    exit 0
  fi
fi

# 3. 檢查 ~/project/<name>
if [ -d "$PROJECT_DIR/$SESSION" ]; then
  create_session "$SESSION" "$PROJECT_DIR/$SESSION"
  exit 0
fi

# 4. 當作路徑處理
if [ -d "$SESSION" ]; then
  DIR=$(cd "$SESSION" && pwd)
  NAME=$(basename "$DIR")
  create_session "$NAME" "$DIR"
  exit 0
fi

# 都找不到
echo "找不到: $SESSION"
echo ""
echo "嘗試過以下方式："
[ -n "$REPO" ] && echo "  - git worktree ($(basename "$REPO"))"
echo "  - ~/project/$SESSION"
echo "  - 目錄路徑: $SESSION"
echo ""
echo "使用 dev -l 查看可用選項"
exit 1
