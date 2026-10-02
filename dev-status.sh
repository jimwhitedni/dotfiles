#!/bin/bash

# 速查表。即時狀態不在這裡看：session 看 cc-monitor，worktree 看 dev -l。

cat <<'EOF'
┌─ cc-monitor ─────────── 每個 window 左邊的清單 ─────┐
│   j/k       移動游標（右邊不變）                    │
│   space     把它顯示在右邊，留在清單                │
│   enter     進去，游標放進它的 prompt               │
│   tab / [   下一個／上一個在等你的                  │
│   i         回覆   1-9 y n  回答   esc  中斷        │
│   N         開始工作（沒有 Claude 的 worktree）     │
│   < >       清單寬度（每個 window 一起）            │
│   ?         全部快捷鍵  u   用量／node              │
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
│   m         回左邊的清單      z  全螢幕／還原       │
│   s / w     切換 session / 總覽                     │
│   d         detach（整個離開 tmux）                 │
└─────────────────────────────────────────────────────┘

每個 window 都是 [清單 | 你的 pane]。清單不會不見，要暫時藏起來按 C-a z。
偶爾要 nvim 或 dev server，C-a - 臨時開一格，用完 exit。
完全不要清單：cc-monitor --sidebars off（on 換回來）。
EOF
