# Alias
alias vi=/usr/bin/vim
alias la="ls -la"
alias ll="ls -l"
alias glog="git log --pretty=format:'%h %s %an %cd' --graph"

# Colors
export GREP_OPTIONS='--color=auto'
export LS_OPTIONS='--color=auto'
export CLICOLOR='true'
export LSCOLORS="gxfxcxdxcxegedabagacad"
export PATH="$HOME/.yarn/bin:$PATH"
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "


[ -f ~/.fzf.bash ] && source ~/.fzf.bash
