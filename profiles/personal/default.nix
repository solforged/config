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
  options.dotfiles.profiles.personal.enable = mkEnableOption "personal profile";

  config = lib.mkIf cfg.profiles.personal.enable {
    dotfiles.packages.home = with pkgs; [
      yt-dlp
    ];

    dotfiles.homebrew.casks = lib.optionals isDarwin [
      "raycast"
    ];
  };
}
