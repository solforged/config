{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = config.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
in
{
  options.dotfiles.profiles.desktop.enable = mkEnableOption "desktop profile";

  config = lib.mkIf cfg.profiles.desktop.enable {
    dotfiles.packages.home = lib.optionals isDarwin [
      pkgs.dockutil
    ];

    dotfiles.homebrew.casks = lib.optionals isDarwin [
      "font-jetbrains-mono-nerd-font"
    ];
  };
}
