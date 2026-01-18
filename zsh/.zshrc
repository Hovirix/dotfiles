# -----------------------------------------------------
# BOOTSTRAP
# -----------------------------------------------------

source ~/.local/share/zinit/zinit.git/zinit.zsh
source <(fzf --zsh)

if [[ -e /home/cachy/.nix-profile/etc/profile.d/nix.sh ]]; then
  . /home/cachy/.nix-profile/etc/profile.d/nix.sh
fi

# -----------------------------------------------------
# ENVIRONMENT / EXPORTS
# -----------------------------------------------------

export EDITOR=hx
export VISUAL=hx

# export NIX_REMOTE=local
# export NIXPKGS_ALLOW_UNFREE=1

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# -----------------------------------------------------
# SHELL OPTIONS
# -----------------------------------------------------

# Changing Directories
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# History
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_FCNTL_LOCK

# Input/Output
setopt ALIASES
setopt CORRECT
setopt NO_FLOW_CONTROL
setopt IGNORE_EOF
setopt HASH_CMDS
setopt HASH_DIRS

# -----------------------------------------------------
# PLUGINS
# -----------------------------------------------------

zinit for wait=0 lucid light-mode \
  Aloxaf/fzf-tab \
  zsh-users/zsh-completions \
  zsh-users/zsh-autosuggestions \
  zdharma-continuum/fast-syntax-highlighting

# -----------------------------------------------------
# COMPLETION
# -----------------------------------------------------

autoload -Uz compinit
compinit -C
zinit cdreplay -q

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh

# -----------------------------------------------------
# ZLE (Line Editor)
# -----------------------------------------------------

autoload -Uz edit-command-line
zle -N edit-command-line

bindkey -e
bindkey '^E' edit-command-line
bindkey '^F' autosuggest-accept
bindkey '^H' backward-kill-word
bindkey '^K' up-line-or-history
bindkey '^J' down-line-or-history
bindkey '^[[127;5u' backward-kill-word

# -----------------------------------------------------
# PROMPT / UI
# -----------------------------------------------------

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#FAB387,hl:#FAB387 \
--color=fg:#CDD6F4,header:#FAB387,info:#FAB387,pointer:#FAB387 \
--color=marker:#FAB387,fg+:#CDD6F4,prompt:#FAB387,hl+:#FAB387 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

zstyle ':fzf-tab:*' fzf-flags "${=FZF_DEFAULT_OPTS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# -----------------------------------------------------
# ALIASES
# -----------------------------------------------------

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Core
alias ls='eza --icons --group-directories-first'
alias la='eza --all'
alias ll='eza --long'
alias tree='ls -T'
alias cat='bat'
alias grep='grep --color=auto'

# Git
alias g='git'
alias lg='lazygit'

# System info
alias fetch='fastfetch'
alias hxd='hx ~/.dotfiles'

# Alpine
alias as='apk search'
alias aa='doas apk add'
alias ad='doas apk del'
alias au='doas apk update && doas apk upgrade'

# Arch
alias pacs='sudo pacman -S'
alias pacrns='sudo pacman -Rns'
alias pacsyu='sudo pacman -Syu'

# Gentoo
alias es='doas emerge --sync'
alias eds='doas emerge --deselect'
alias eclean='doas emerge --ask --depclean'
alias update='doas emerge --ask --update --newuse --deep @world'

# Nixos
alias rebuild='nh os switch'
alias update='nh os switch --update'

# Systemd
alias sc='systemctl'
alias scu='systemctl --user'

# Journald
alias j='journalctl'
alias ju='journalctl --user'

alias jc='journalctl --unit'
alias jf='journalctl --follow'

alias juc='journalctl --user --unit'
alias juf='journalctl --user -follow'

# Containers
alias p='podman'
alias pps='podman ps -a'
alias pc='podman compose'
alias pvl='podman volume list'
alias pql='podman quadlet list'
alias pnl='podman network list'
alias psl='podman secret list'

# JS
alias npm='pnpm'
alias npx='pnpx'

# Nix
alias nd='nix develop --command zsh'
alias nfc='nix flake check'
alias nfu='nix flake update'
alias ncg='nix-collect-garbage -d && nix-store --gc && nix-store --repair --verify --check-contents && nix-store --optimise -vvv'

# Global aliases
alias -g G='| rg'
alias -g B='| bat'
alias -g C='| wl-copy'

# -----------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------

# --- Nix / environment -------------------------------

nsh() {
  nix shell "${@/#/nixpkgs#}"
}

# --- Directory navigation ----------------------------

up() {
  cd "$(printf '../%.0s' $(seq 1 ${1:-1}))"
}

mkcd() {
  mkdir -p "$1" && cd "$1"
}

groot() {
  cd "$(git rev-parse --show-toplevel 2>/dev/null)" || return
}

# --- Networking --------------------------------------

myip() {
  curl -s ifconfig.me
}
