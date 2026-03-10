{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.dotfiles.music = {
    enable = mkEnableOption "sigil-first music management foundation";

    beets.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Install and configure beets-backed read-only music library helpers.";
    };

    roon.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Install Roon bootstrap tooling for diagnostics only.";
    };

    openclaw.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Expose the music helper through the host OpenClaw instance.";
    };
  };
}
