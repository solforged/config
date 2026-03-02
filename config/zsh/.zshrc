[[ $- != *i* ]] && return

if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

autoload -Uz compinit
mkdir -p "$XDG_CACHE_HOME/zsh"
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

mkdir -p "$XDG_STATE_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=100000
export SAVEHIST=100000

setopt APPEND_HISTORY INC_APPEND_HISTORY EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_IGNORE_SPACE
setopt HIST_VERIFY HIST_REDUCE_BLANKS
setopt AUTO_CD AUTO_PUSHD PUSHD_SILENT PUSHD_IGNORE_DUPS
setopt EXTENDED_GLOB GLOB_DOTS COMPLETE_ALIASES INTERACTIVE_COMMENTS
unsetopt BEEP NOMATCH

if (( $+commands[eza] )); then
  alias ls='eza --icons'
  alias l='eza -lbFa --git --icons'
  alias ll='eza -lbGFa --git --icons'
  alias la='eza -lbhHigUmuSa --git --color-scale --icons'
else
  alias ll='ls -al'
fi

alias e="${EDITOR:-nvim}"
alias lg='lazygit'
alias tldr='tldr --config-path "$XDG_CONFIG_HOME/tldr/config.toml"'

if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

if (( $+commands[yazi] )); then
  y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    command yazi "$@" --cwd-file="$tmp"
    cwd="$(cat "$tmp")"
    [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

# if (( $+commands[zellij] )) \
#   && [[ -z "$ZELLIJ" ]] \
#   && [[ -z "$TMUX" ]] \
#   && [[ -z "$NVIM" ]] \
#   && [[ "${ZELLIJ_AUTO_ATTACH:-1}" != "0" ]] \
#   && [[ -z "$ZSH_EXECUTION_STRING" ]] \
#   && [[ "$TERM" != "dumb" ]] \
#   && [[ "$TERM_PROGRAM" != "vscode" ]] \
#   && [[ -t 0 ]] \
#   && [[ -t 1 ]]; then
#   zellij attach -c
# fi

if [[ -f "${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/secrets/zsh/local.zsh" ]]; then
  source "${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/secrets/zsh/local.zsh"
fi

if [[ -f "$HOME/.config/zsh/local.zsh" ]]; then
  source "$HOME/.config/zsh/local.zsh"
fi
