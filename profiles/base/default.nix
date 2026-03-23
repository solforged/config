{
  config,
  inputs,
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
    platform.packages.home = [
      inputs.rig.packages.${cfg.host.platform}.default
    ]
    ++ (with pkgs; [
      bottom
      chafa
      cheat
      choose
      difftastic
      doggo
      duf
      dust
      fd
      ffmpeg
      gping
      imagemagick
      lazygit
      navi
      nil
      nixfmt-rfc-style
      p7zip
      poppler
      procs
      ripgrep
      rsync
      sd
      tealdeer
      xh
    ]);
  };
}
