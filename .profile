# user specific data files
export XDG_DATA_HOME=~/.local/share
# user specific configuration files
export XDG_CONFIG_HOME=~/.config
# user specific non-essential data files
export XDG_CACHE_HOME=~/.cache
# user-specific non-essential runtime files (sockets, named pipes, ...)
# XDG_RUNTIME_DIR already set by systemd

# user preferences
export EDITOR='emacsclient -t'
export VISUAL='emacsclient -c'
export PAGER=most

# gnupg
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh

# java
export _JAVA_AWT_WM_NONREPARENTING=1

# mplayer
export MPLAYER_HOME=$XDG_CONFIG_HOME/mplayer

# rust toolchain
export CARGO_HOME=$XDG_DATA_HOME/cargo
export RUSTUP_HOME=$XDG_DATA_HOME/rustup

# go
export GOPATH=$XDG_CACHE_HOME/go

# docker
export DOCKER_BUILDKIT=1
