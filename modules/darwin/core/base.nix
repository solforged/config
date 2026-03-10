{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
  selectedShellPackage =
    if cfg.apps.shell == "fish" then
      pkgs.fish
    else if cfg.apps.shell == "nushell" then
      pkgs.nushell
    else
      pkgs.zsh;
in
{
  config = lib.mkIf isDarwin {
    nixpkgs.hostPlatform = cfg.host.platform;

    determinateNix = {
      enable = true;
      customSettings.use-xdg-base-directories = true;
    };

    nix.settings.warn-dirty = false;

    networking.hostName = cfg.host.slug;
    networking.localHostName = cfg.host.slug;
    networking.computerName = cfg.host.title;

    system.primaryUser = cfg.user.name;
    users.users.${cfg.user.name}.home = cfg.user.home;
    system.configurationRevision = lib.mkIf (self ? rev) self.rev;

    environment.shells = lib.unique [
      pkgs.zsh
      selectedShellPackage
    ];

    environment.systemPackages = lib.unique (
      [
        pkgs.git
      ]
      ++ cfg.packages.system
    );

    programs.zsh.enable = true;
    programs.fish.enable = cfg.apps.shell == "fish";

    system.defaults = lib.mkIf cfg.profiles.desktop.enable {
      dock.autohide = true;
      dock.magnification = false;
      dock.mineffect = "scale";

      finder.AppleShowAllExtensions = true;
      finder.FXEnableExtensionChangeWarning = false;
      finder.QuitMenuItem = true;
      finder.ShowPathbar = true;
      finder.ShowStatusBar = true;
      finder._FXSortFoldersFirst = true;

      NSGlobalDomain.AppleKeyboardUIMode = 3;
      NSGlobalDomain.ApplePressAndHoldEnabled = false;
      NSGlobalDomain.InitialKeyRepeat = 10;
      NSGlobalDomain.KeyRepeat = 1;
      NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    };

    system.stateVersion = cfg.host.stateVersion;
  };
}
