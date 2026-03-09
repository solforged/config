{ lib, osConfig, ... }:
let
  cfg = osConfig.dotfiles;
in
{
  config = lib.mkIf (cfg.apps.terminal == "ghostty") {
    xdg.configFile."ghostty/config".source = ../../config/ghostty/config;
  };
}
