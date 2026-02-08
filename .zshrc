# ===== eza aliases =====
alias ld='eza -lD'
alias lf='eza -lF --color=always | grep -v /'
alias lh='eza -dl .* --group-directories-first'
alias ll='eza -al --group-directories-first'
alias ls='eza -al --icons --group-directories-first'

# ===== Node.js 環境 =====
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/whiteccchen-mac/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/Users/whiteccchen-mac/.bun/_bun" ] && source "/Users/whiteccchen-mac/.bun/_bun"

# ===== Claude Code =====
alias claude="/Users/whiteccchen-mac/.claude/local/claude"

# ===== Angular CLI =====
source <(ng completion script) 2>/dev/null

# ===== 編輯器 =====
export EDITOR="nvim"
export PAGER="less"

# ===== fzf (歷史指令搜尋) =====
source <(fzf --zsh) 2>/dev/null

# ===== zoxide (快速跳目錄) =====
eval "$(zoxide init zsh)" 2>/dev/null

# ===== zsh-autosuggestions (指令自動建議) =====
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null


# ===== Git Branch Prompt =====
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
setopt PROMPT_SUBST
PROMPT='%F{cyan}%~%f %F{green}$(parse_git_branch)%f %F{yellow}❯%f '












# ===== rg + fzf 互動搜尋 =====
rgf() {
  local result
  result=$(rg --color=always --line-number --no-heading "$@" |
    fzf --ansi \
        --delimiter : \
        --preview 'line={2}; start=$((line > 30 ? line - 30 : 1)); bat --style=numbers --color=always --highlight-line {2} {1} --line-range $start:+60 2>/dev/null' \
        --preview-window 'right:60%')
  
  if [[ -n "$result" ]]; then
    local file=$(echo "$result" | cut -d: -f1)
    local line=$(echo "$result" | cut -d: -f2)
    nvim "+$line" "$file"
  fi
}

# ===== bat theme 跟隨系統 =====
if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
  export BAT_THEME="Dracula"
else
  export BAT_THEME="GitHub"
fi



# ===== fd + fzf 搜尋檔案 =====
ff() {
  local result
  result=$(fd --type f --hidden --no-ignore --exclude .git --exclude node_modules --exclude dist --exclude .nx "$@" |
    fzf --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}' \
        --preview-window 'right:60%')
  
  if [[ -n "$result" ]]; then
    nvim "$result"
  fi
}

# tmux
alias ta='tmux attach'
alias tl='tmux ls'
alias tk='tmux kill-session -t'

# 防止睡眠（開會用）
alias awake='caffeinate -dims & echo "☕ Mac 不會睡眠了"'
alias sleep-ok='pkill caffeinate && echo "😴 恢復正常省電"'

# dev-start
alias dev='~/dotfiles/dev-start.sh'

# dev status
alias ds='~/dotfiles/dev-status.sh'
# copy pwd
alias cpwd='pwd | pbcopy'
