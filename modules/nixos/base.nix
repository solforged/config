{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles;
  isLinux = lib.hasSuffix "linux" cfg.host.platform;
  selectedShellPackage =
    if cfg.apps.shell == "fish" then
      pkgs.fish
    else if cfg.apps.shell == "nushell" then
      pkgs.nushell
    else
      pkgs.zsh;
in
{
  config = lib.mkIf isLinux {
    nixpkgs.hostPlatform = lib.mkDefault cfg.host.platform;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = true;
    };

    users.users.${cfg.user.name} = {
      isNormalUser = true;
      description = cfg.user.fullName;
      home = cfg.user.home;
      extraGroups = [ "wheel" ];
      shell = selectedShellPackage;
    };

    programs.zsh.enable = cfg.apps.shell == "zsh";
    environment.systemPackages = cfg.packages.system;

    system.stateVersion = cfg.host.stateVersion;
  };
}
