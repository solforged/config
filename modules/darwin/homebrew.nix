{ config, lib, ... }:
let
  cfg = config.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;

  appCasks =
    lib.optionals (cfg.apps.terminal == "ghostty") [ "ghostty" ]
    ++ lib.optionals (cfg.apps.terminal == "kitty") [ "kitty" ]
    ++ lib.optionals (cfg.apps.browser == "brave") [ "brave-browser" ]
    ++ lib.optionals (cfg.apps.passwordManager == "1password") [
      "1password"
      "1password-cli"
    ]
    ++ lib.optionals (cfg.apps.passwordManager == "bitwarden") [ "bitwarden" ]
    ++ lib.optionals (cfg.apps.passwordManager == "proton-pass") [ "proton-pass" ];
in
{
  config = lib.mkIf (isDarwin && cfg.features.homebrew.enable) {
    homebrew = {
      enable = true;
      global.autoUpdate = false;
      onActivation.autoUpdate = false;
      onActivation.upgrade = false;
      onActivation.cleanup = "none";
      taps = lib.unique cfg.homebrew.taps;
      brews = lib.unique cfg.homebrew.brews;
      casks = lib.unique (cfg.homebrew.casks ++ appCasks);
    };
  };
}
