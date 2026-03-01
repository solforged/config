{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
in
{
  config = lib.mkIf (lib.elem "desktop" cfg.profiles) {
    dotfiles.homebrew.brews = lib.optionals isDarwin [
      "dockutil"
    ];

    dotfiles.homebrew.casks = lib.optionals isDarwin [
      "font-jetbrains-mono-nerd-font"
    ];
  };
}
