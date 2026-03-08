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
  config = lib.mkIf (lib.elem "personal" cfg.profiles) {
    dotfiles.packages.home = with pkgs; [
      yt-dlp
    ];

    dotfiles.homebrew.casks = lib.optionals isDarwin [
      "raycast"
    ];
  };
}
