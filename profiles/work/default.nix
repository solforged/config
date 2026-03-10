{ lib, ... }:
{
  options.dotfiles.profiles.work.enable = lib.mkEnableOption "work profile";
}
