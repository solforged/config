{ config, lib, ... }:
let
  cfg = config.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
in
{
  config = lib.mkIf (lib.elem "media" cfg.profiles) {
    dotfiles.homebrew.casks = lib.optionals isDarwin [
      "roon"
    ];
  };
}
