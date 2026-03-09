{ lib, osConfig, ... }:
let
  cfg = osConfig.dotfiles;
in
{
  config = lib.mkIf (cfg.apps.shell == "zsh") {
    home.file.".zshenv".source = ../../config/zsh/root-zshenv;

    xdg.configFile."zsh".source = ../../config/zsh;
    xdg.configFile."zsh".recursive = true;
  };
}
