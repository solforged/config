{ lib, ... }:
{
  options.platform.features.dock.enable = lib.mkEnableOption "apply an opinionated Dock layout";
}
