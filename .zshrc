# Path to your oh-my-zsh configuration.
ZSH=$HOME/.config/zsh/oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="sorin"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git archlinux history-substring-search)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

# ---[ Load default shell profile ]-------------------------------------
source /etc/profile
source $HOME/.profile

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.dotnet/tools" ]] && PATH="$HOME/.dotnet/tools:${PATH}"


# ---[ System settings ]------------------------------------------------
limit -s coredumpsize 0
umask 0027


# ---[ ZSH aliases ]----------------------------------------------------
# useful aliases
# ls
alias l="exa -l --color=auto --group-directories-first" # my preferred listing
alias ls="exa -l --color=auto --group-directories-first" # same as l
alias la="exa -la --color=auto --group-directories-first" # all files/dirs
alias ll="exa -l --color=auto --group-directories-first" # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias l.="exa -ld --color=auto --group-directories-first .*" # show dotfiles/dotdirs only

# archlinux
alias pacls="pacman -Ql"
alias paclean="sudo pacman -Sc"

# VirtualBox
alias vm="VBoxManage -q startvm"
alias vmls="VBoxManage -q list vms"

# vagrant
alias v="vagrant"

# docker
alias d="docker"
alias dc="docker-compose"

# dotfiles
alias df="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# ---[ ZSH Options ]----------------------------------------------------
# General
setopt ALWAYS_TO_END BASH_AUTO_LIST NO_BEEP CLOBBER AUTO_CD MULTIOS
setopt RC_QUOTES

# Job Control
setopt CHECK_JOBS NO_HUP NOTIFY LONG_LIST_JOBS AUTO_RESUME

# History
setopt INC_APPEND_HISTORY EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
HISTFILE=~/.histfile
HISTSIZE=25000
SAVEHIST=25000

# dirs history
DIRSTACKSIZE=20
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS

# Completion
setopt GLOB_DOTS REC_EXACT EXTENDED_GLOB AUTO_PARAM_SLASH

# Base16 Shell
#BASE16_SHELL="$HOME/.config/base16-shell/"
#[ -n "$PS1" ] && \
#    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
#        eval "$("$BASE16_SHELL/profile_helper.sh")"

### SETTING THE STARSHIP PROMPT ###
eval "$(starship init zsh)"
