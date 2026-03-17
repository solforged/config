{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = config.platform;
in
{
  options.platform.profiles.server.enable = mkEnableOption "headless server profile";

  config = lib.mkIf cfg.profiles.server.enable {
    platform.packages.home = with pkgs; [
      curl
      htop
      rsync
    ];
  };
}
