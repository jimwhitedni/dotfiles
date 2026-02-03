#!/bin/bash

# 用法：
#   dev-start login ~/project/one-ui
#   dev-start firmware ~/project/one-ui-firmware
#   dev-start topology ~/project/one-ui-topology

SESSION=$1
DIR=$2

if [ -z "$SESSION" ] || [ -z "$DIR" ]; then
  echo "用法: dev-start <session名稱> <worktree路徑>"
  echo "範例: dev-start firmware ~/project/one-ui-firmware"
  exit 1
fi

# 如果 session 已存在，直接進去
tmux has-session -t "$SESSION" 2>/dev/null && {
  tmux attach -t "$SESSION"
  exit 0
}

# 建立新 session
tmux new-session -d -s "$SESSION" -c "$DIR"
tmux rename-window -t "$SESSION:1" 'nvim'
tmux new-window -t "$SESSION" -n 'serve' -c "$DIR"
tmux new-window -t "$SESSION" -n 'claude' -c "$DIR"

tmux attach -t "$SESSION"
