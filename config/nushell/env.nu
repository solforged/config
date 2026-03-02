let xdg_state_home = ($env.XDG_STATE_HOME? | default ($nu.home-path | path join ".local" "state"))
let secret_env = ($xdg_state_home | path join "dotfiles" "secrets" "nushell" "env.nu")
let local_env = ($nu.config-path | path dirname | path join "env.local.nu")

if ($secret_env | path exists) {
  source $secret_env
}

if ($local_env | path exists) {
  source $local_env
}
