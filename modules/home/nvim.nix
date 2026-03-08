{ lib, osConfig, ... }:
let
  cfg = osConfig.dotfiles;
in
{
  config = lib.mkIf (cfg.apps.editor == "nvim") {
    xdg.configFile."nvim".source = ../../config/nvim;
    xdg.configFile."nvim".recursive = true;
  };
}
