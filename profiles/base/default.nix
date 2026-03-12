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
  options.platform.profiles.base.enable = mkEnableOption "common CLI base profile";

  config = lib.mkIf cfg.profiles.base.enable {
    platform.packages.home = with pkgs; [
      age
      chafa
      fd
      ffmpeg
      imagemagick
      lazygit
      nil
      nixfmt-rfc-style
      p7zip
      poppler
      ripgrep
      rsync
      tealdeer
    ];
  };
}
