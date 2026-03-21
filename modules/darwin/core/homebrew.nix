{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.platform;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
  appCaskCatalog = {
    browser = {
      brave = [ "brave-browser" ];
      chatgpt-atlas = [ "chatgpt-atlas" ];
      safari = [ ];
      none = [ ];
    };
    terminal = {
      ghostty = [ "ghostty" ];
      kitty = [ "kitty" ];
      terminal = [ ];
    };
    passwordManager = {
      "1password" = [
        "1password"
      ];
      bitwarden = [ "bitwarden" ];
      proton-pass = [ "proton-pass" ];
      none = [ ];
    };
  };
  appCasks = lib.flatten [
    appCaskCatalog.browser.${cfg.apps.browser}
    appCaskCatalog.terminal.${cfg.apps.terminal}
    appCaskCatalog.passwordManager.${cfg.apps.passwordManager}
  ];
in
{
  options.platform = {
    features.homebrew.enable = mkEnableOption "manage Homebrew through nix-darwin";

    homebrew = {
      taps = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Merged Homebrew taps from profiles.";
      };

      brews = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Merged Homebrew brews from profiles.";
      };

      casks = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Merged Homebrew casks from profiles.";
      };

      masApps = mkOption {
        type = types.attrsOf types.int;
        default = { };
        example = {
          Amphetamine = 937984704;
        };
        description = "Merged Mac App Store applications for nix-darwin Homebrew management.";
      };
    };
  };

  config = lib.mkIf (isDarwin && cfg.features.homebrew.enable) {
    homebrew = {
      enable = true;
      global.autoUpdate = false;
      onActivation.autoUpdate = false;
      onActivation.upgrade = false;
      onActivation.cleanup = "none";
      taps = lib.unique cfg.homebrew.taps;
      brews = lib.unique cfg.homebrew.brews;
      casks = lib.unique (cfg.homebrew.casks ++ appCasks);
      masApps = cfg.homebrew.masApps;
    };
  };
}
