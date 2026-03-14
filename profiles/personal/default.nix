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
  options.platform.profiles.personal.enable = mkEnableOption "personal profile";

  config = lib.mkIf cfg.profiles.personal.enable {
    platform.packages.home = with pkgs; [
      yt-dlp
    ];

    platform.homebrew.casks = lib.optionals isDarwin [
      "raycast"
    ];
  };
}
