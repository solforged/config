{ lib, ... }:
{
  options.platform.profiles.work.enable = lib.mkEnableOption "work profile";
}
