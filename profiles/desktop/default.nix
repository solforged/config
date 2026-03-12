{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = config.platform;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
in
{
  options.platform.profiles.desktop.enable = mkEnableOption "desktop profile";

  config = lib.mkIf cfg.profiles.desktop.enable {
    platform.packages.home = lib.optionals isDarwin [
      pkgs.dockutil
    ];

    platform.homebrew.casks = lib.optionals isDarwin [
      "font-blex-mono-nerd-font"
      "font-ibm-plex-sans"
      "font-symbols-only-nerd-font"
    ];
  };
}
