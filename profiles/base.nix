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
      bat
      chafa
      direnv
      eza
      fd
      ffmpeg
      fzf
      git
      imagemagick
      lazygit
      nil
      nixfmt-rfc-style
      p7zip
      poppler
      ripgrep
      rsync
      tealdeer
      yazi
      zellij
      zoxide
    ];
  };
}
