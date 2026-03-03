{ lib, osConfig, ... }:
let
  cfg = osConfig.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;

  browserApp =
    if cfg.apps.browser == "brave" then
      "/Applications/Brave Browser.app"
    else if cfg.apps.browser == "safari" then
      "/System/Applications/Safari.app"
    else
      "";

  terminalApp =
    if cfg.apps.terminal == "ghostty" then
      "/Applications/Ghostty.app"
    else if cfg.apps.terminal == "kitty" then
      "/Applications/kitty.app"
    else
      "/System/Applications/Utilities/Terminal.app";

  passwordManagerApp =
    if cfg.apps.passwordManager == "1password" then
      "/Applications/1Password.app"
    else if cfg.apps.passwordManager == "bitwarden" then
      "/Applications/Bitwarden.app"
    else if cfg.apps.passwordManager == "proton-pass" then
      "/Applications/Proton Pass.app"
    else
      "";
in
{
  config = lib.mkIf (isDarwin && cfg.features.dock.enable && lib.elem "desktop" cfg.profiles) {
    home.activation.configureDock = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      DOCKUTIL=""
      if [ -x /opt/homebrew/bin/dockutil ]; then
        DOCKUTIL=/opt/homebrew/bin/dockutil
      elif [ -x /usr/local/bin/dockutil ]; then
        DOCKUTIL=/usr/local/bin/dockutil
      fi

      if [ -n "$DOCKUTIL" ] && [ -e "$HOME/Library/Preferences/com.apple.dock.plist" ]; then
        add_dock_item() {
          if [ -n "$1" ] && [ -e "$1" ]; then
            "$DOCKUTIL" --add "$1" --no-restart "$HOME"
          fi
        }

        "$DOCKUTIL" --remove all --no-restart "$HOME" || true
        add_dock_item "/System/Applications/Apps.app"
        add_dock_item "${browserApp}"
        add_dock_item "/System/Applications/Calendar.app"
        add_dock_item "/System/Applications/Mail.app"
        add_dock_item "/System/Applications/Music.app"
        add_dock_item "/System/Applications/App Store.app"
        add_dock_item "${terminalApp}"
        add_dock_item "${passwordManagerApp}"
        add_dock_item "/System/Applications/System Settings.app"
        "$DOCKUTIL" --add "$HOME/Downloads" --view grid --display folder --section others --no-restart "$HOME" || true
        /usr/bin/killall Dock >/dev/null 2>&1 || true
      fi
    '';
  };
}
