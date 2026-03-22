{
  lib,
  self,
  ...
}:
let
  inherit (lib) mkEnableOption;
  inherit (self.lib) mkBoolOpt;
in
{
  options.platform.music = {
    enable = mkEnableOption "sigil-first music management foundation";
    beets.enable = mkBoolOpt true "Install and configure beets-backed read-only music library helpers.";
    roon.enable = mkBoolOpt false "Install Roon bootstrap tooling for diagnostics only.";
    openclaw.enable = mkBoolOpt false "Expose the music helper through the host OpenClaw instance.";
  };
}
