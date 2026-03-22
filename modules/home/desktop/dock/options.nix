{
  lib,
  self,
  ...
}:
let
  inherit (self.lib) mkOpt;
in
{
  options.platform.features.dock = {
    enable = lib.mkEnableOption "apply an opinionated Dock layout";

    items = mkOpt (lib.types.listOf lib.types.str) [ ] ''
      Ordered list of application names to pin to the Dock.
      Names are matched against .app bundles in common locations
      (/Applications, /System/Applications, ~/Applications, and
      their subdirectories). The first match wins.
    '';
  };
}
