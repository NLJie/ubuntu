# /etc/profile.d/custom_prompt.sh

# 仅对交互式 shell 生效
case $- in
    *i*) ;;
    *) return;;
esac

# 彩色定义
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[1;33m\]"
BLUE="\[\033[0;34m\]"
PURPLE="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"
GRAY="\[\033[0;90m\]"
RESET="\[\033[0m\]"

# Git 分支提示
parse_git_branch() {
    git branch 2>/dev/null | grep '^\*' | sed 's/^\* / /'
}

# 区分 root 和普通用户提示符
if [ "$UID" -eq 0 ]; then
    export PS1="${GRAY}[\t] ${RED}[\u@\h ${BLUE}\W]${YELLOW} \$(parse_git_branch)${RESET}\n${RED}\\# ${RESET}"
else
    export PS1="${GRAY}[\t] ${GREEN}[\u@\h ${BLUE}\W]${YELLOW} \$(parse_git_branch)${RESET}\n${PURPLE}\\$ ${RESET}"
fi

# 彩色 ls 和别名
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'

# 启用 dircolors 支持
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
