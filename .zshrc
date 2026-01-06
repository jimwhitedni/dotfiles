# ===== eza aliases =====
alias ld='eza -lD'
alias lf='eza -lF --color=always | grep -v /'
alias lh='eza -dl .* --group-directories-first'
alias ll='eza -al --group-directories-first'
alias ls='eza -a --icons'

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
