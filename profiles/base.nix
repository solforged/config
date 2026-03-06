{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles;
in
{
  config = lib.mkIf (lib.elem "base" cfg.profiles) {
    dotfiles.packages.home = with pkgs; [
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
