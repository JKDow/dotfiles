# $ZDOTDIR/.zshrc
# Used for setting user's interactive shell configuration and executing commands,
# will be read when starting as an interactive shell.

# --- ZSH CONFIG ---
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt extendedglob
unsetopt autocd beep
bindkey -e

# --- ENV AND PATHS ---
export DOTUTILS=$HOME/.local/dot_utils

path=(
    $path
    $HOME/.local/bin # local binaries
    $HOME/.config/composer/vendor/bin # PHP composer
    /usr/local/go/bin # GO
)
# rust
if [ -f "$HOME/.cargo/env" ]; then
    source $HOME/.cargo/env
fi
# NVM
if [ -f "/usr/share/nvm/init-nvm.sh" ]; then
    source /usr/share/nvm/init-nvm.sh
fi

alias ls='ls --color=auto'

# --- COMPINIT ---
zstyle :compinstall filename "${HOME}/.zshrc"
autoload -Uz compinit && compinit

# --- ZINIT BOOTSTRAP ---
# setup
export ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -s "${ZINIT_HOME}/zinit.zsh" ]]; then
  mkdir -p "$(dirname "${ZINIT_HOME}")"
  git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}"
fi

source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# annexes
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust


# --- ZINIT PLUGINS ---
# • History Substring Search (turbo + fastload + keybindings)
zinit load 'zsh-users/zsh-history-substring-search'
zinit ice wait atload"_history_substring_search_config"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# (Add any other plugins below, e.g. autosuggestions, syntax-highlighting…)
# zinit light zsh-users/zsh-autosuggestions
# zinit light zsh-users/zsh-syntax-highlighting

# --- TMUX PLUGIN ---
tmux-git-autofetch() {(/home/jkdow/dotfiles/tmux/.config/tmux/plugins/tmux-git-autofetch/git-autofetch.tmux --current &)}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd tmux-git-autofetch

# --- PROMPT ---
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
else
  export PS1='%n@%m %1~ %# '
fi

# --- CLEANUP ---
typeset -U path

fastfetch
