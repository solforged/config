{ config, lib, ... }:
let
  inherit (lib) mkEnableOption;
  cfg = config.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
in
{
  options.dotfiles.profiles.media.enable = mkEnableOption "media profile";

  config = lib.mkIf cfg.profiles.media.enable {
    dotfiles.homebrew.casks = lib.optionals isDarwin [
      "roon"
    ];
  };
}
