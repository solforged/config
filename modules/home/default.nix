{
  config,
  inputs,
  lib,
  self,
  ...
}:
let
  cfg = config.platform;
in
{
  imports = [
    ./core/ai/options.nix
    ./desktop/dock/options.nix
    ./media/music/options.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
  home-manager.extraSpecialArgs = {
    inherit inputs self;
  };

  home-manager.users.${cfg.user.name} =
    { config, lib, ... }:
    {
      imports = [
        inputs.nixvim.homeModules.nixvim
        ./core
        ./shell
        ./editor
        ./desktop
        ./media
      ];

      home.username = cfg.user.name;
      home.homeDirectory = cfg.user.home;
      home.stateVersion = cfg.host.homeStateVersion;

      home.packages = lib.unique cfg.packages.home;

      xdg.enable = true;

      programs.bat.enable = true;
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      programs.eza = {
        enable = true;
        enableNushellIntegration = cfg.apps.shell == "nushell";
        enableZshIntegration = true;
      };
      programs.atuin = {
        enable = true;
        enableZshIntegration = cfg.apps.shell == "zsh";
        enableNushellIntegration = cfg.apps.shell == "nushell";
        flags = [ "--disable-up-arrow" ];
      };
      programs.fzf.enable = true;
      programs.home-manager.enable = true;
      programs.zoxide = {
        enable = true;
        enableNushellIntegration = cfg.apps.shell == "nushell";
        enableZshIntegration = cfg.apps.shell == "zsh";
      };

      home.activation.ensureGnupgHome = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        /bin/mkdir -p "${config.xdg.configHome}/gnupg"
        /bin/chmod 700 "${config.xdg.configHome}/gnupg"
      '';

      home.activation.ensureCodexHome = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        /bin/mkdir -p "${config.xdg.dataHome}/codex"
      '';

      home.file.".hushlogin".text = "";
      home.file.".local/bin/rig".source = ../../bin/rig;
      home.file.".config/nix-darwin/README.md".text = ''
        Local-only overrides belong outside the flake.
        Common examples:
          $XDG_DATA_HOME/codex
          $XDG_STATE_HOME/platform/secrets
          ~/.config/fish/local.fish
          ~/.config/git/local.inc
          ~/.config/nushell/local.nu
          ~/.config/zsh/local.zsh
          ~/.ssh/config.local
      '';
    };
}
