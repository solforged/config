{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.platform;
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
      # Dock
      dock.autohide = true;
      dock.autohide-delay = 0.0;
      dock.autohide-time-modifier = 0.0;
      dock.expose-animation-duration = 0.1;
      dock.launchanim = false;
      dock.magnification = false;
      dock.mineffect = "scale";
      dock.minimize-to-application = true;
      dock.mouse-over-hilite-stack = true;
      dock.mru-spaces = false;
      dock.show-process-indicators = true;
      dock.show-recents = false;
      dock.showhidden = true;
      dock.tilesize = 36;

      # Trackpad
      trackpad.Clicking = true;

      # Finder
      finder.AppleShowAllExtensions = true;
      finder.FXDefaultSearchScope = "SCcf";
      finder.FXEnableExtensionChangeWarning = false;
      finder.QuitMenuItem = true;
      finder.ShowPathbar = true;
      finder.ShowStatusBar = true;
      finder._FXSortFoldersFirst = true;

      # Keyboard & input
      NSGlobalDomain.AppleKeyboardUIMode = 3;
      NSGlobalDomain.ApplePressAndHoldEnabled = false;
      NSGlobalDomain.InitialKeyRepeat = 10;
      NSGlobalDomain.KeyRepeat = 1;

      # Text corrections
      NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
      NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;

      # Dialogs & windows
      NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
      NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
      NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
      NSGlobalDomain.NSWindowResizeTime = 0.001;
      NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
      NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;

      # Spring-loaded folders
      NSGlobalDomain."com.apple.springing.enabled" = true;
      NSGlobalDomain."com.apple.springing.delay" = 0.0;

      # Screenshots
      screencapture.type = "png";
      screencapture.disable-shadow = true;

      # Misc
      CustomUserPreferences = {
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.ActivityMonitor" = {
          OpenMainWindow = true;
          ShowCategory = 0;
          SortColumn = "CPUUsage";
          SortDirection = 0;
        };
        "com.apple.ImageCapture" = {
          disableHotPlug = true;
        };
        "com.apple.print.PrintingPrefs" = {
          "Quit When Finished" = true;
        };
      };
    };

    system.stateVersion = cfg.host.stateVersion;
  };
}
