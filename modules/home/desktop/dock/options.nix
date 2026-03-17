{ lib, ... }:
{
  options.platform.features.dock = {
    enable = lib.mkEnableOption "apply an opinionated Dock layout";

    items = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "Apps"
        "Brave Browser"
        "Ghostty"
        "1Password"
        "App Store"
        "Claude"
        "System Settings"
      ];
      description = ''
        Ordered list of application names to pin to the Dock.
        Names are matched against .app bundles in common locations
        (/Applications, /System/Applications, ~/Applications, and
        their subdirectories). The first match wins.
      '';
    };
  };
}
