#!/bin/bash
# ZSH-like theme for Git Bash on Windows


# Colors
RESET="\[\033[0m\]"
BLACK="\[\033[0;30m\]"
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[0;34m\]"
PURPLE="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"
WHITE="\[\033[0;37m\]"
BOLD_BLACK="\[\033[1;30m\]"
BOLD_RED="\[\033[1;31m\]"
BOLD_GREEN="\[\033[1;32m\]"
BOLD_YELLOW="\[\033[1;33m\]"
BOLD_BLUE="\[\033[1;34m\]"
BOLD_PURPLE="\[\033[1;35m\]"
BOLD_CYAN="\[\033[1;36m\]"
BOLD_WHITE="\[\033[1;37m\]"

TICK="✔"
CROSS="✘"
RIGHT_ARROW="➜"

BRANCH_COLOR=$BOLD_GREEN

# Special characters including zsh-style arrow/powerline separators
# Note: These require a font with powerline symbols (e.g., Cascadia Code PL, Fira Code, etc.)
ARROW_RIGHT=""  # Unicode: \uE0B0
ARROW_LEFT=""   # Unicode: \uE0B2
ARROW_RIGHT_HOLLOW=""  # Unicode: \uE0B1
ARROW_LEFT_HOLLOW=""   # Unicode: \uE0B3

# Alternative using regular ASCII characters if the powerline ones don't display properly
ASCII_ARROW_RIGHT="▶"
ASCII_ARROW_LEFT="◀"

# Choose which set to use based on your font support
# Replace ARROW_RIGHT with ASCII_ARROW_RIGHT if the powerline characters don't show correctly
USE_POWERLINE=false  # Set to true for powerline symbols, false for ASCII alternatives

# Git status function - optimized for performance
git_status() {
    local git_status=""
    local branch=""
    
    # Check if we're in a git repository
    git rev-parse --is-inside-work-tree &>/dev/null || return
    
    # Get current branch - optimized by using --short
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || 
             git describe --all --exact-match HEAD 2>/dev/null || 
             git rev-parse --short HEAD 2>/dev/null || 
             echo 'unknown')
    
    # Check for uncommitted changes - use quick check for performance
    if ! git diff --quiet --ignore-submodules --cached; then
        git_status+="${GREEN}${TICK}${RESET}"  # staged changes
    fi
    
    if ! git diff-index --quiet HEAD --; then
        git_status+="${RED}${CROSS}${RESET}"    # unstaged changes
        BRANCH_COLOR=$BOLD_RED
    fi
    
    # Check for untracked files - limit search for performance
    if [ -n "$(git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' 2>/dev/null)" ]; then
        git_status+="${BOLD_RED}?${RESET}"  # untracked files
    fi
    
    # Output formatted git information
    echo -e " ${BOLD_BLUE}git:(${BRANCH_COLOR}$branch${BOLD_BLUE})${git_status}${RESET}"
}


# Custom prompt function with zsh-style arrow separators
set_prompt() {
    local exit_code=$?
    
    # Display error code if not zero
    local error_indicator=""
    if [[ $exit_code != 0 ]]; then
        error_indicator=" ${BOLD_RED}${CROSS} ${RESET}" #$exit_code${RESET}"
    fi
    
    # Get working directory with ~ for home
    local pwd_formatted=$(basename "$PWD")
    
    # Limit directory length for better performance in deep directories
    if [[ ${#pwd_formatted} -gt 30 ]]; then
        pwd_formatted="...${pwd_formatted:(-27)}"
    fi
    
    # Git status (only calculate if needed)
    local git_info=""
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        git_info=$(git_status)
    fi
    
    # Set the arrow separator based on preference
    local arrow_right
    local arrow_left
    
    if $USE_POWERLINE; then
        arrow_right=$ARROW_RIGHT
        arrow_left=$ARROW_LEFT
    else
        arrow_right=$ASCII_ARROW_RIGHT
        arrow_left=$ASCII_ARROW_LEFT
    fi
    
    # Set the actual prompt with zsh-style arrows and segments
    # First line with segmented design
    PS1="${BOLD_GREEN}${RIGHT_ARROW} ${BOLD_CYAN} ${pwd_formatted}${BOLD_BLACK}"
    PS1+="${git_info}${error_indicator} ${BOLD_YELLOW}$ ${RESET}"
    
    # Second line if wanna customize
    # PS1+="\n${BOLD_BLUE}╰${BOLD_GREEN}${arrow_right}${BOLD_YELLOW}${arrow_right}${BOLD_RED}${arrow_right} ${RESET}"

    # Set window title
    echo -ne "\033]0;${USER}@${HOSTNAME}"
}

# Set PROMPT_COMMAND to use our custom prompt function
PROMPT_COMMAND="set_prompt"


# Command aliases (few commands are configured for Windows)
alias ll="ls -lah --color=auto"
alias la="ls -A --color=auto"
alias l="ls -CF --color=auto"
alias grep="grep --color=auto"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias md="mkdir -p"
alias rd="rmdir"
alias cls="clear"
alias rmf="rm -f"
alias install="winget install"


# Enable programmable completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# History improvements
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
shopt -s checkwinsize

# Better directory navigation
shopt -s autocd 2>/dev/null
shopt -s dirspell 2>/dev/null
shopt -s cdspell 2>/dev/null

# Colored man pages like in zsh
man() {
    env \
    LESS_TERMCAP_mb=$'\E[01;31m' \
    LESS_TERMCAP_md=$'\E[01;38;5;74m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_so=$'\E[38;5;246m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    man "$@"
}

# Enable extended globbing
shopt -s extglob


# CWD_PROMPT_COLOR="B C"
# function __powerline_cwd_prompt {
#   echo "\w|${CWD_PROMPT_COLOR}"
# }
# echo "Theme Installed Successfully!"