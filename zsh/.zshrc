# -----------------------------------------------------
# INIT
# -----------------------------------------------------

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Packages
# zinit ice from"gh-r" as"program" junegunn/fzf; zinit light junegunn/fzf; source <(fzf --zsh)
# zinit ice from"gh-r" as"program" ajeetdsouza/zoxide; zinit light ajeetdsouza/zoxide; eval "$(zoxide init zsh)"
# zinit ice from"gh-r" as"program" bpick"*x86_64-unknown-linux-musl.tar.gz"; zinit light starship/starship; eval "$(starship init zsh)"
source <(fzf --zsh)
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# Plugins
zinit for wait=0 lucid light-mode \
      Aloxaf/fzf-tab \
      zsh-users/zsh-completions \
      zsh-users/zsh-autosuggestions \
      zdharma-continuum/fast-syntax-highlighting

# Load stuff
if [ -e /home/cachy/.nix-profile/etc/profile.d/nix.sh ]; then . /home/cachy/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
# bindkey -v
autoload -Uz compinit
compinit -C
zinit cdreplay -q

# -----------------------------------------------------
# Theming
# -----------------------------------------------------

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
# History
# -----------------------------------------------------

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt HIST_IGNORE_ALL_DUPS

# -----------------------------------------------------
# Exports
# -----------------------------------------------------

export EDITOR=hx
export VISUAL=hx
export NIX_REMOTE=local
export NIXPKGS_ALLOW_UNFREE=1

# -----------------------------------------------------
# ALIASES
# -----------------------------------------------------

alias ..="cd .."
alias ...='cd ../..'
alias ....='cd ../../..'

alias cat='bat'
alias grep="grep --color=auto"

alias ls='eza --icons --group-directories-first'
alias la='eza --all'
alias ll='eza --long'
alias tree='ls -T'

alias g="git"
alias lg="lazygit"
alias hxd="hx ~/.dotfiles"
alias fetch="fastfetch"

# Alpine
alias as="apk search"
alias aa="doas apk add"
alias ad="doas apk del"
alias au="doas apk update && doas apk upgrade" 

# Arch
alias pacs='sudo pacman -S'
alias pacrns='sudo pacman -Rns'
alias pacsyu='sudo pacman -Syu'

# Gentoo
alias es="doas emerge --sync"
alias eds="doas emerge --deselect"
alias eclean="doas emerge --ask --depclean"
alias update="doas emerge --ask --update --newuse --deep @world"

# Podman
alias p='podman'
alias pps='podman ps -a'
alias pc='podman compose'

# Copilot
alias cr='copilot --resume'
alias cc='copilot --continue'

# Nix
alias nd='nix develop --command zsh'
alias nfc='nix flake check'
alias nfu='nix flake update'
alias ncg='nix-collect-garbage -d && nix-store --gc && nix-store --repair --verify --check-contents && nix-store --optimise -vvv'  
