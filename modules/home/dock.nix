{
  lib,
  osConfig,
  pkgs,
  self,
  ...
}:
let
  cfg = osConfig.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
  selectedApps = self.lib.resolveSelectedApps cfg;
  selectedDockApps = lib.flatten [
    (lib.optional (
      selectedApps.browser != null
      && selectedApps.browser.dockPath != null
      && selectedApps.browser.dockPath != ""
    ) selectedApps.browser.dockPath)
    (lib.optional (
      selectedApps.terminal != null
      && selectedApps.terminal.dockPath != null
      && selectedApps.terminal.dockPath != ""
    ) selectedApps.terminal.dockPath)
    (lib.optional (
      selectedApps.passwordManager != null
      && selectedApps.passwordManager.dockPath != null
      && selectedApps.passwordManager.dockPath != ""
    ) selectedApps.passwordManager.dockPath)
  ];
in
{
  config = lib.mkIf (isDarwin && cfg.features.dock.enable && lib.elem "desktop" cfg.profiles) {
    home.activation.configureDock = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      DOCKUTIL="${lib.getExe pkgs.dockutil}"

      if [ -n "$DOCKUTIL" ] && [ -e "$HOME/Library/Preferences/com.apple.dock.plist" ]; then
        add_dock_item() {
          if [ -n "$1" ] && [ -e "$1" ]; then
            "$DOCKUTIL" --add "$1" --no-restart "$HOME"
          fi
        }

        "$DOCKUTIL" --remove all --no-restart "$HOME" || true
        add_dock_item "/System/Applications/Apps.app"
        ${lib.concatMapStringsSep "\n" (path: ''add_dock_item "${path}"'') selectedDockApps}
        add_dock_item "/System/Applications/Calendar.app"
        add_dock_item "/System/Applications/Mail.app"
        add_dock_item "/System/Applications/Music.app"
        add_dock_item "/System/Applications/App Store.app"
        add_dock_item "/System/Applications/System Settings.app"
        "$DOCKUTIL" --add "$HOME/Downloads" --view grid --display folder --section others --no-restart "$HOME" || true
        /usr/bin/killall Dock >/dev/null 2>&1 || true
      fi
    '';
  };
}
