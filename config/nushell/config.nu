# Generate and cache the Starship init script from the pinned local binary.
let starship_dir = ($nu.data-dir | path join "vendor" "autoload")
let starship_init = ($starship_dir | path join "starship.nu")
let starship_version = ($starship_dir | path join "starship.version")
let local_config = ($nu.config-path | path dirname | path join "local.nu")
let xdg_state_home = ($env.XDG_STATE_HOME? | default ($nu.home-path | path join ".local" "state"))
let secret_config = ($xdg_state_home | path join "dotfiles" "secrets" "nushell" "local.nu")

if ((which starship | length) > 0) {
  if not ($starship_dir | path exists) {
    mkdir $starship_dir
  }

  let current_starship_version = (^starship --version | str trim)
  let cached_starship_version = if ($starship_version | path exists) {
    open $starship_version | str trim
  } else {
    ""
  }

  if (not ($starship_init | path exists)) or ($cached_starship_version != $current_starship_version) {
    ^starship init nu | save --force $starship_init
    $current_starship_version | save --force $starship_version
  }

  source $starship_init
}

if ($secret_config | path exists) {
  source $secret_config
}

if ($local_config | path exists) {
  source $local_config
}
