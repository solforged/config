export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"

hm_session_vars="$XDG_STATE_HOME/home-manager/gcroots/current-home/home-path/etc/profile.d/hm-session-vars.sh"
if [[ ! -f "$hm_session_vars" && -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
  hm_session_vars="$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi

if [[ -f "$hm_session_vars" ]]; then
  source "$hm_session_vars"
fi

typeset -U path PATH
path=(
  "$XDG_BIN_HOME"
  "$path[@]"
)

export PATH
