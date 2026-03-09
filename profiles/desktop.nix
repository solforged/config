{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
in
{
  config = lib.mkIf (lib.elem "desktop" cfg.profiles) {
    dotfiles.packages.home = lib.optionals isDarwin [
      pkgs.dockutil
    ];

    dotfiles.homebrew.casks = lib.optionals isDarwin [
      "font-jetbrains-mono-nerd-font"
    ];
  };
}
