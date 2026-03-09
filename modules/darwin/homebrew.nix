{
  config,
  lib,
  self,
  ...
}:
let
  cfg = config.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
  selectedApps = self.lib.resolveSelectedApps cfg;
  appCasks = lib.flatten [
    (lib.optional (
      selectedApps.browser != null && selectedApps.browser.cask != null
    ) selectedApps.browser.cask)
    (lib.optional (
      selectedApps.terminal != null && selectedApps.terminal.cask != null
    ) selectedApps.terminal.cask)
    (lib.optional (
      selectedApps.passwordManager != null && selectedApps.passwordManager.cask != null
    ) selectedApps.passwordManager.cask)
    (lib.optionals (selectedApps.passwordManager != null) (
      selectedApps.passwordManager.extraCasks or [ ]
    ))
  ];
in
{
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
