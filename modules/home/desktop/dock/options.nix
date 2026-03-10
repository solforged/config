{ lib, ... }:
{
  options.dotfiles.features.dock.enable = lib.mkEnableOption "apply an opinionated Dock layout";
}
