#!/bin/bash

# 速查表。即時狀態不在這裡看：session 看 cc-monitor，worktree 看 dev -l。

cat <<'EOF'
┌─ cc-monitor ──────────── Claude session 主控台 ─────┐
│   tab       跳到下一個在等你的                      │
│   j/k       移動      i    回覆                     │
│   1-9 y n   回答提示  esc  中斷                     │
│   N         開始工作（沒有 Claude 的 worktree）     │
│   a         attach    u    用量／node               │
└─────────────────────────────────────────────────────┘

┌─ dev ─────────────────── worktree 與 session ───────┐
│   dev <name>    開始／跳到該 worktree 的 session    │
│   dev           當前目錄                            │
│   dev -l        worktree 生命週期（誰還活著）       │
│   dev --reap    清掉做完的 worktree                 │
└─────────────────────────────────────────────────────┘

┌─ tmux ────────────────── prefix = Ctrl+a ───────────┐
│   -         往下開 pane（繼承 worktree 目錄）       │
│   |         往右開 pane                             │
│   c         新 window                               │
│   h j k l   切換 pane     H J K L  調整大小         │
│   s / w     切換 session / 總覽                     │
│   d         detach（回到 cc-monitor）               │
└─────────────────────────────────────────────────────┘

session 是一個 window、一個 pane。
偶爾要 nvim 或 dev server，C-a - 臨時開一格，用完 exit。
EOF
