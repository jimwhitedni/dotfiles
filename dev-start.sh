#!/bin/bash

# 用法：
#   dev                  → 在當前目錄建立 session（session 名稱 = 目錄名）
#   dev <name>           → 智慧解析：tmux session → git worktree → ~/project/<name> → 路徑
#   dev <name> <path>    → 指定 session 名稱與目錄
#   dev -d <name>        → 建立但不進去（給 cc-monitor 用）
#   dev -l               → worktree 生命週期檢視
#   dev --reap           → 互動式清掉做完的 worktree

PROJECT_DIR="$HOME/project"
DETACH=false

# tmux 的 -t 預設做前綴比對：`has-session -t layout` 會命中 `layout-align`。
# 加 `=` 前綴才是精確比對。所有 -t 參數都必須經過這裡。
exact() { printf '=%s' "$1"; }

session_exists() { tmux has-session -t "$(exact "$1")" 2>/dev/null; }

# 在 tmux 裡面不能 attach，要用 switch-client，否則 dev 無法當作跳轉指令用。
attach_session() {
  if [ "$DETACH" = true ]; then
    echo "✓ session '$1' 已建立（未進入）"
  elif [ -n "$TMUX" ]; then
    tmux switch-client -t "$(exact "$1")"
  else
    tmux attach -t "$(exact "$1")"
  fi
}

# 取得 git 主倉庫路徑（如果在 git repo 中）
get_main_repo() {
  local toplevel
  toplevel=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  local common_dir
  common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
  if [[ "$common_dir" == *"/worktrees/"* ]] || [[ "$common_dir" != ".git" && "$common_dir" != *"/.git" ]]; then
    echo "$(cd "$(dirname "$common_dir")" && pwd)"
  else
    echo "$toplevel"
  fi
}

# 列出 ~/project 下所有「真正的」hub。
#
# 判斷依據是 .git/worktrees 存在與否，這是一個純 stat，而且會正確排除
# 只是名字前綴相同的獨立 clone —— one-ui-kb 是自己的 repo，不是 one-ui 的 worktree。
list_hubs() {
  local d
  for d in "$PROJECT_DIR"/*/; do
    [ -d "$d/.git/worktrees" ] && printf '%s\n' "${d%/}"
  done
}

# 從 worktree 清單中尋找匹配的路徑。
# 用 --porcelain：原本的 `while read` 遇到含空白的路徑會拆錯。
find_worktree() {
  local repo="$1" name="$2" line path
  local repo_basename
  repo_basename=$(basename "$repo")
  while IFS= read -r line; do
    case "$line" in
      "worktree "*) path="${line#worktree }" ;;
      *) continue ;;
    esac
    local wt_name
    wt_name=$(basename "$path")
    if [ "$wt_name" = "$name" ] || [ "$wt_name" = "${repo_basename}-${name}" ]; then
      printf '%s\n' "$path"
      return 0
    fi
  done < <(git -C "$repo" worktree list --porcelain 2>/dev/null)
  return 1
}

# 原本的解析綁在當前目錄：`dev topology` 只有先 cd 到 one-ui 才會動。
# 一旦 cc-monitor 常駐第一個分頁，你多半不在任何 repo 裡面。
find_worktree_anywhere() {
  local name="$1" hub path
  while IFS= read -r hub; do
    path=$(find_worktree "$hub" "$name") && { printf '%s\n' "$path"; return 0; }
  done < <(list_hubs)
  return 1
}

git_common_dir() {
  local dir="$1" common
  common=$(git -C "$dir" rev-parse --git-common-dir 2>/dev/null) || return 1
  # 在 hub 裡會回傳相對路徑 ".git"，要自己解析成絕對路徑
  case "$common" in
    /*) printf '%s\n' "$common" ;;
    *)  (cd "$dir" && cd "$common" && pwd) ;;
  esac
}

# 讓 git 忽略 worktree 裡的 .claude。
#
# one-ui/.gitignore 寫的是 `.claude/`，帶尾斜線只 match 目錄。hub 裡 .claude 是
# 真目錄所以被忽略；worktree 裡它是 symlink，git 視為檔案，於是沒被忽略 —— 這就是
# 每個 worktree 都固定顯示一個未提交檔的原因。寫進 info/exclude 不會動到團隊的
# .gitignore，而且 linked worktree 共用同一份 exclude，寫一次全部生效。
ignore_claude() {
  local common exclude
  common=$(git_common_dir "$1") || return 0
  exclude="$common/info/exclude"
  mkdir -p "$(dirname "$exclude")"
  grep -qxF '.claude' "$exclude" 2>/dev/null && return 0
  printf '.claude\n' >> "$exclude"
  echo "✓ 已將 .claude 加入 $exclude"
}

# 準備 worktree 的 .claude。
#
# 原本是整個 .claude 目錄 symlink 到 hub，連 settings.local.json 也共用。那個檔案
# 現在 15KB、259 條授權規則，而 Claude 每次授權都整檔重寫 —— 兩個並行 session 同時
# 授權就是 read-modify-write 競態，後寫的贏，另一個的授權靜默消失。
#
# 所以只共用真正唯讀的部分，settings.local.json 改成各自一份。
prepare_worktree() {
  local repo="$1" wt="$2"
  [ "$repo" = "$wt" ] && return 0
  [ -d "$repo/.claude" ] || return 0

  # 既有的整包 symlink 要先拆掉再重建成新結構
  if [ -L "$wt/.claude" ]; then
    rm "$wt/.claude"
    echo "✓ 拆掉舊的整包 .claude symlink（settings.local.json 將改為各自一份）"
  fi

  mkdir -p "$wt/.claude"

  local sub
  for sub in knowledge skills; do
    [ -d "$repo/.claude/$sub" ] || continue
    [ -e "$wt/.claude/$sub" ] && continue
    ln -s "$repo/.claude/$sub" "$wt/.claude/$sub"
    echo "✓ symlink: .claude/$sub → hub"
  done

  if [ -f "$repo/.claude/settings.local.json" ] && [ ! -e "$wt/.claude/settings.local.json" ]; then
    cp "$repo/.claude/settings.local.json" "$wt/.claude/settings.local.json"
    echo "✓ 複製 settings.local.json（之後各自演進，不再互相覆寫）"
  fi

  ignore_claude "$wt"
}

create_session() {
  local session="$1" dir="$2"

  # tmux 不允許 . 和 :
  session=$(echo "$session" | tr './:' '---')

  if session_exists "$session"; then
    attach_session "$session"
    exit 0
  fi

  if [ -f "$dir/.git" ]; then
    local common main_repo
    common=$(git_common_dir "$dir")
    if [ -n "$common" ]; then
      main_repo=$(cd "$(dirname "$common")" && pwd)
      prepare_worktree "$main_repo" "$dir"
    fi
  fi

  # 一個 window：左邊是 cc-monitor 側欄，右邊是你的 shell。
  #
  # 原本固定開三個 pane（nvim window + serve|claude 分割），但證據顯示 nvim window
  # 從沒用過，serve pane 五個裡有四個閒置 —— 而且 serve 本來就是單例（整台機器只有
  # 一個 dev server，綁死一個 port），每個 worktree 配一格在結構上就跑不起來。
  #
  # 交給 cc-monitor 建，跟主控台裡按 N 建出來的一模一樣：側欄一開始就在、寬度對，
  # 而且是照你看到它的尺寸建，不會先以 80x24 出生、打開時側欄被拉成一百多欄。
  # cc-monitor 不在的話照舊建一個普通 session，tmux 的 hook 會在一秒內補上側欄。
  #
  # 臨時要 shell 或 server：C-a - 往下開、C-a | 往右開，兩者都會繼承 worktree 目錄。
  if command -v cc-monitor >/dev/null 2>&1; then
    local size=""
    # tmux 裡面讓 cc-monitor 自己量你正在看的 window；外面就用這個終端機的大小
    # （少一行給狀態列）。
    if [ -z "$TMUX" ]; then
      size="$(tput cols 2>/dev/null || echo 0)x$(( $(tput lines 2>/dev/null || echo 1) - 1 ))"
    fi
    cc-monitor --new-session "$session" "$dir" ${size:+--size "$size"} >/dev/null || exit 1
  else
    tmux new-session -d -s "$session" -n "$session" -c "$dir"
  fi

  attach_session "$session"
}

# === dev -l：worktree 生命週期檢視 ===

# 從 cc-monitor 取得每個 cwd 的 Claude 狀態。它已經做了 session 檔的解析與驗證，
# 在這裡重做一遍只會多一份會走樣的實作。沒裝就跳過這一欄。
# dev 可能在沒有互動式 PATH 的情況下被呼叫（cc-monitor 自己叫它就是），
# 而 ~/.local/bin 是 .zshrc 加的，所以不能只靠 command -v。
cc_monitor_bin() {
  if command -v cc-monitor >/dev/null 2>&1; then
    command -v cc-monitor
  elif [ -x "$HOME/.local/bin/cc-monitor" ]; then
    printf '%s\n' "$HOME/.local/bin/cc-monitor"
  fi
}

claude_status_map() {
  local bin
  bin=$(cc_monitor_bin)
  [ -n "$bin" ] || return 0
  command -v python3 >/dev/null 2>&1 || return 0
  "$bin" --json 2>/dev/null | python3 -c '
import json, sys
try:
    data = sys.stdin.read().strip()
    for s in (json.loads(data) if data else []) or []:
        if s.get("cwd"):
            print(s["cwd"] + "\t" + s.get("status", ""))
except Exception:
    pass
' 2>/dev/null
}

show_list() {
  local statuses
  statuses=$(claude_status_map)

  local sessions
  sessions=$(tmux list-sessions -F '#{session_name}	#{pane_current_path}' 2>/dev/null)

  printf '%-32s %-34s %-9s %-7s %6s  %s\n' WORKTREE BRANCH CLAUDE SESSION AGE NOTE
  printf '%-32s %-34s %-9s %-7s %6s  %s\n' \
    "--------------------------------" "----------------------------------" \
    "---------" "-------" "------" "----"

  local hub
  while IFS= read -r hub; do
    local merged
    merged=$(git -C "$hub" branch --merged main --format='%(refname:short)' 2>/dev/null)

    local line path
    while IFS= read -r line; do
      case "$line" in "worktree "*) path="${line#worktree }" ;; *) continue ;; esac

      local name branch age dirty claude session note
      name=$(basename "$path")
      branch=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null)
      [ "$branch" = HEAD ] && branch="@$(git -C "$path" rev-parse --short HEAD 2>/dev/null) (detached)"
      age=$(git -C "$path" log -1 --format=%cr 2>/dev/null | sed 's/ ago//;s/ months*/mo/;s/ weeks*/w/;s/ days*/d/;s/ hours*/h/;s/ minutes*/m/')
      dirty=$(git -C "$path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      claude=$(printf '%s\n' "$statuses" | awk -F'\t' -v p="$path" '$1==p{print $2; exit}')
      session=$(printf '%s\n' "$sessions" | awk -F'\t' -v p="$path" '$2==p{print $1; exit}')

      note=""
      [ "$dirty" != 0 ] && note="$dirty 未提交"
      if [ -z "$claude" ] && [ -n "$session" ]; then
        note="${note:+$note · }空殼"
      fi
      if printf '%s\n' "$merged" | grep -qxF "$branch" 2>/dev/null; then
        note="${note:+$note · }已 merge"
      fi

      printf '%-32s %-34s %-9s %-7s %6s  %s\n' \
        "$name" "${branch:0:34}" "${claude:--}" "${session:+yes}" "${age:--}" "$note"
    done < <(git -C "$hub" worktree list --porcelain 2>/dev/null)
  done < <(list_hubs)

  echo ""
  echo "dev <name>    開始工作      dev --reap    清掉做完的"
}

# === dev --reap：互動式回收 ===

reap() {
  command -v fzf >/dev/null 2>&1 || { echo "需要 fzf"; exit 1; }

  local statuses sessions candidates=""
  statuses=$(claude_status_map)
  sessions=$(tmux list-sessions -F '#{session_name}	#{pane_current_path}' 2>/dev/null)

  local hub
  while IFS= read -r hub; do
    local merged
    merged=$(git -C "$hub" branch --merged main --format='%(refname:short)' 2>/dev/null)

    local line path
    while IFS= read -r line; do
      case "$line" in "worktree "*) path="${line#worktree }" ;; *) continue ;; esac
      [ "$path" = "$hub" ] && continue   # 不回收 hub 本身

      # 候選條件故意保守：誤刪一個還在用的 worktree，比留著一個廢的貴太多。
      # 有 tmux session 的一律跳過 —— 那是 cc-monitor 的 N 要接回的對象，不是垃圾。
      [ -n "$(printf '%s\n' "$statuses" | awk -F'\t' -v p="$path" '$1==p{print $2}')" ] && continue
      [ -n "$(printf '%s\n' "$sessions" | awk -F'\t' -v p="$path" '$2==p{print $1; exit}')" ] && continue
      [ "$(git -C "$path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')" != 0 ] && continue

      local branch label
      branch=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null)
      local why=""
      if [ "$branch" = HEAD ]; then
        why="detached"
        label="@$(git -C "$path" rev-parse --short HEAD 2>/dev/null)"
      elif printf '%s\n' "$merged" | grep -qxF "$branch" 2>/dev/null; then
        why="已 merge 進 main"
        label="$branch"
      else
        continue
      fi

      local age
      age=$(git -C "$path" log -1 --format=%cr 2>/dev/null | sed 's/ ago//')
      # 路徑放在第一欄，顯示時藏起來。不能用名字反查 —— 不同 hub 下有三個
      # 叫 norule-opus 的 worktree，用名字反查會刪錯。
      candidates+="$path	$(basename "$path")	$label	$why	$age"$'\n'
    done < <(git -C "$hub" worktree list --porcelain 2>/dev/null)
  done < <(list_hubs)

  [ -z "$candidates" ] && { echo "沒有可以回收的 worktree"; exit 0; }

  # --with-nth 只顯示第 2 欄之後，但回傳的是整行，所以路徑跟著回來。
  local chosen
  chosen=$(printf '%s' "$candidates" |
    fzf --multi --delimiter='\t' --with-nth=2.. \
        --header='選擇要刪除的 worktree（tab 多選 · enter 確認 · esc 取消）')
  [ -z "$chosen" ] && exit 0

  local line path name
  while IFS= read -r line; do
    path=$(printf '%s' "$line" | cut -f1)
    name=$(printf '%s' "$line" | cut -f2)
    [ -z "$path" ] && continue

    local hub_of
    hub_of=$(cd "$(dirname "$(git_common_dir "$path")")" && pwd) || continue
    if git -C "$hub_of" worktree remove "$path" 2>/dev/null; then
      echo "✓ 刪除 worktree $name"
    else
      echo "✗ 無法刪除 $name（可能有未追蹤檔案，需自行處理）"
    fi
  done <<< "$chosen"

  while IFS= read -r hub; do git -C "$hub" worktree prune 2>/dev/null; done < <(list_hubs)
  echo "完成。transcript 保留著，worktree 重建後 claude --continue 仍能接回。"
}

# === 主邏輯 ===

case "$1" in
  -d|--detach) DETACH=true; shift ;;
esac

case "$1" in
  -l|--list) show_list; exit 0 ;;
  --reap)    reap; exit 0 ;;
esac

# dev <name> <path> → 指定名稱與路徑
if [ -n "$2" ]; then
  DIR="$2"
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
  create_session "$(basename "$DIR")" "$DIR"
  exit 0
fi

SESSION="$1"

# 1. 同名的 tmux session
if session_exists "$SESSION"; then
  attach_session "$SESSION"
  exit 0
fi

# 2. 當前 git repo 的 worktree（在 repo 裡面時優先，比較符合直覺）
REPO=$(get_main_repo 2>/dev/null)
if [ -n "$REPO" ]; then
  REPO_NAME=$(basename "$REPO")
  if [ "$SESSION" = "main" ] || [ "$SESSION" = "$REPO_NAME" ]; then
    create_session "$SESSION" "$REPO"
    exit 0
  fi
  WT_DIR=$(find_worktree "$REPO" "$SESSION")
  if [ -n "$WT_DIR" ] && [ -d "$WT_DIR" ]; then
    create_session "$SESSION" "$WT_DIR"
    exit 0
  fi
fi

# 3. 任何 hub 的 worktree（不需要先 cd 進去）
WT_DIR=$(find_worktree_anywhere "$SESSION")
if [ -n "$WT_DIR" ] && [ -d "$WT_DIR" ]; then
  create_session "$SESSION" "$WT_DIR"
  exit 0
fi

# 4. ~/project/<name>
if [ -d "$PROJECT_DIR/$SESSION" ]; then
  create_session "$SESSION" "$PROJECT_DIR/$SESSION"
  exit 0
fi

# 5. 當作路徑處理
if [ -d "$SESSION" ]; then
  DIR=$(cd "$SESSION" && pwd)
  create_session "$(basename "$DIR")" "$DIR"
  exit 0
fi

echo "找不到: $SESSION"
echo ""
echo "嘗試過以下方式："
[ -n "$REPO" ] && echo "  - 當前 repo 的 worktree ($(basename "$REPO"))"
echo "  - 所有 hub 的 worktree"
echo "  - ~/project/$SESSION"
echo "  - 目錄路徑: $SESSION"
echo ""
echo "使用 dev -l 查看可用選項"
exit 1
