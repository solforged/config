{ config, lib, ... }:
let
  inherit (lib) mkEnableOption;
  cfg = config.platform;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
in
{
  options.platform.profiles.media.enable = mkEnableOption "media profile";

  config = lib.mkIf cfg.profiles.media.enable {
    platform.homebrew.casks = lib.optionals isDarwin [
      "roon"
    ];
  };
}
